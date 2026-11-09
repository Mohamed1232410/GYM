"use strict";
// AI analysis for body-composition reports (InBody sheets, smart-scale app screenshots, PDFs).
// Pure logic: no Firebase in here, so it can be tested without any cloud account.

const ANTHROPIC_URL = "https://api.anthropic.com/v1/messages";
const ANTHROPIC_VERSION = "2023-06-01";
const MODEL = "claude-sonnet-5-5";
const MAX_PLAN_ATTEMPTS = 3;

const GOALS = {
  lose_fat: "lose body fat while keeping muscle",
  build_muscle: "build muscle with minimal fat gain",
  recomposition: "body recomposition: lose fat and build muscle at the same time",
  maintain: "maintain the current body composition and improve general fitness",
};

class AiError extends Error {
  constructor(code, message, status) {
    super(message || code);
    this.code = code;
    this.status = status;
  }
}

// ─── Claude HTTP ─────────────────────────────────────────────
function mapHttpError(status, bodyText) {
  let message = bodyText;
  try { message = JSON.parse(bodyText).error.message || bodyText; } catch (_) { /* keep raw text */ }
  if (/credit balance/i.test(message) || status === 402) return new AiError("ai_no_credit", message, status);
  if (status === 401 || status === 403) return new AiError("ai_key_invalid", message, status);
  if (status === 429) return new AiError("ai_rate_limited", message, status);
  if (status === 413) return new AiError("files_too_large", message, status);
  if (status === 529 || status >= 500) return new AiError("ai_unavailable", message, status);
  return new AiError("ai_error", message, status);
}

async function callClaude({ apiKey, content, maxTokens, temperature, fetchImpl }) {
  const doFetch = fetchImpl || fetch;
  const send = (withTemperature) => {
    const body = { model: MODEL, max_tokens: maxTokens, messages: [{ role: "user", content }] };
    if (withTemperature && temperature !== undefined) body.temperature = temperature;
    return doFetch(ANTHROPIC_URL, {
      method: "POST",
      headers: {
        "content-type": "application/json",
        "x-api-key": apiKey,
        "anthropic-version": ANTHROPIC_VERSION,
      },
      body: JSON.stringify(body),
    });
  };

  let res = await send(true);
  if (res.status === 400) {
    const text = await res.text();
    // some models don't accept a custom temperature: retry once without it
    if (/temperature/i.test(text)) res = await send(false);
    else throw mapHttpError(400, text);
  }
  if (!res.ok) throw mapHttpError(res.status, await res.text());

  const json = await res.json();
  const text = (json.content || []).filter((b) => b.type === "text").map((b) => b.text).join("\n");
  if (!text.trim()) throw new AiError("bad_ai_response", "empty response");
  return text;
}

function extractJson(text) {
  const start = text.indexOf("{");
  const end = text.lastIndexOf("}");
  if (start < 0 || end <= start) throw new AiError("bad_ai_response", "no JSON found");
  try { return JSON.parse(text.slice(start, end + 1)); } catch (e) { throw new AiError("bad_ai_response", "invalid JSON"); }
}

function attachmentBlocks(attachments) {
  return attachments.map((a) => (a.kind === "pdf"
    ? { type: "document", source: { type: "base64", media_type: "application/pdf", data: a.data } }
    : { type: "image", source: { type: "base64", media_type: a.mediaType || "image/jpeg", data: a.data } }));
}

// ─── Step 1: read the report (never invent numbers) ──────────
const num = (v) => {
  if (typeof v === "number" && Number.isFinite(v)) return v;
  if (typeof v === "string") {
    const m = v.replace(/,/g, ".").match(/-?\d+(\.\d+)?/);
    return m ? Number(m[0]) : null;
  }
  return null;
};
const str = (v) => (typeof v === "string" && v.trim() ? v.trim() : null);

function normalizeReading(raw) {
  const previous = raw.previous && typeof raw.previous === "object" ? raw.previous : null;
  return {
    is_body_composition_report: raw.is_body_composition_report === true,
    report_type: str(raw.report_type),
    report_date: str(raw.report_date),
    gender: raw.gender === "male" || raw.gender === "female" ? raw.gender : null,
    age: num(raw.age),
    height_cm: num(raw.height_cm),
    weight_kg: num(raw.weight_kg),
    target_weight_kg: num(raw.target_weight_kg),
    bmi: num(raw.bmi),
    body_fat_percent: num(raw.body_fat_percent),
    body_fat_mass_kg: num(raw.body_fat_mass_kg),
    muscle_mass_kg: num(raw.muscle_mass_kg),
    body_water_percent: num(raw.body_water_percent),
    bone_mass_kg: num(raw.bone_mass_kg),
    protein_percent: num(raw.protein_percent),
    visceral_fat: num(raw.visceral_fat),
    bmr_kcal: num(raw.bmr_kcal),
    body_age: num(raw.body_age),
    inbody_score: num(raw.inbody_score),
    segmental_notes: str(raw.segmental_notes),
    notes: str(raw.notes),
    previous: previous && {
      report_date: str(previous.report_date),
      weight_kg: num(previous.weight_kg),
      body_fat_percent: num(previous.body_fat_percent),
      muscle_mass_kg: num(previous.muscle_mass_kg),
    },
  };
}

const EXTRACTION_PROMPT = (count) => `You are reading ${count} attached file(s): photos, screenshots or PDFs of a body-composition report. It may be an InBody sheet or a smart-scale app screen (Xiaomi, Huawei, Renpho, etc.).

Extract ONLY values that are actually printed in the files. Never estimate, never invent. If a value is not visible or not legible, use null. "Metabolism", "BMR" and "basal metabolism" all mean bmr_kcal. If the files are not a body-composition report at all, set is_body_composition_report to false.
If several reports from different dates are attached, put the MOST RECENT in the main fields and the older one in "previous".

Return ONLY one JSON object (no markdown, no commentary) with exactly these keys, numbers as JSON numbers without units:
{
  "is_body_composition_report": boolean,
  "report_type": "inbody" | "smart_scale_app" | "other",
  "report_date": string | null,
  "gender": "male" | "female" | null,
  "age": number | null,
  "height_cm": number | null,
  "weight_kg": number | null,
  "target_weight_kg": number | null,
  "bmi": number | null,
  "body_fat_percent": number | null,
  "body_fat_mass_kg": number | null,
  "muscle_mass_kg": number | null,
  "body_water_percent": number | null,
  "bone_mass_kg": number | null,
  "protein_percent": number | null,
  "visceral_fat": number | null,
  "bmr_kcal": number | null,
  "body_age": number | null,
  "inbody_score": number | null,
  "segmental_notes": string | null,
  "notes": string | null,
  "previous": { "report_date": string | null, "weight_kg": number | null, "body_fat_percent": number | null, "muscle_mass_kg": number | null } | null
}`;

async function extractReading(ctx) {
  const content = [...attachmentBlocks(ctx.attachments), { type: "text", text: EXTRACTION_PROMPT(ctx.attachments.length) }];
  const text = await callClaude({ ...ctx, content, maxTokens: 1500, temperature: 0 });
  const reading = normalizeReading(extractJson(text));
  const keyNumbers = [reading.weight_kg, reading.body_fat_percent, reading.muscle_mass_kg, reading.bmi]
    .filter((v) => v !== null).length;
  if (!reading.is_body_composition_report || keyNumbers < 2) {
    throw new AiError("unreadable_report", "could not read body composition numbers");
  }
  return reading;
}

// ─── Step 2: build the plan from the measured numbers ────────
function buildPlanPrompt({ reading, goal, daysPerWeek, notes, language, problems }) {
  const retry = problems.length
    ? `\nYOUR PREVIOUS ANSWER WAS REJECTED. Fix every one of these and return the full JSON again:\n- ${problems.join("\n- ")}\n`
    : "";
  const { is_body_composition_report: _ignored, ...measured } = reading;

  return `You are an experienced strength & nutrition coach. Build a personalised plan strictly from the measured data below.

MEASURED DATA (read from the user's own report; null = not on the report):
${JSON.stringify(measured)}

GOAL: ${GOALS[goal]}
TRAINING DAYS PER WEEK: ${daysPerWeek}
USER NOTES (injuries, equipment, preferences): ${notes || "none"}
${retry}
HARD RULES
- Use only the numbers above. Never invent measurements; if a value is null, do not guess it.
- Quote the user's real numbers in the assessment and findings. If "previous" is present, compare and state the change.
- Choose emphasis from the data (fat %, muscle mass, visceral fat, water %, body age, target weight, segmental notes).
- "workout_plan" must contain EXACTLY ${daysPerWeek} training days. EVERY training day must have between 5 and 7 exercises (never fewer than 5). Order: big compound lifts first, isolation after.
- "meals" must contain between 4 and 5 meals for one full day. Meal calories must add up to about targets.calories.
- Calories: if bmr_kcal is present, maintenance = bmr_kcal x activity factor (3 days 1.375, 4 days 1.5, 5 days 1.55, 6 days 1.65). If not, use Mifflin-St Jeor from weight, height, age and gender when available, otherwise estimate from weight and say so. Then adjust for the goal (lose fat -15% to -20%, build muscle +8% to +12%, recomposition -5% to 0%, maintain 0%). Protein 1.8-2.2 g per kg body weight. Show the arithmetic in targets.calc_note.
- Exercise names must be standard gym names in English. Everything else (assessment, findings, focus, notes, meals, items, recommendations) must be written in ${language}.
- End the last recommendation with a short reminder that this is general guidance, not medical advice.

Return ONLY one JSON object, no markdown, in exactly this shape:
{
  "assessment": "100-180 words quoting the real numbers",
  "findings": ["3 to 5 short strings, each tied to a specific number"],
  "targets": { "calories": integer, "protein_g": integer, "carbs_g": integer, "fat_g": integer, "water_liters": number, "calc_note": "one line with the calculation" },
  "workout_plan": [ { "day": "Day 1", "focus": "string", "exercises": [ { "name": "English exercise name", "sets": integer, "reps": "e.g. 8-10", "rest_seconds": integer, "note": "short tip or empty string" } ] } ],
  "meals": [ { "name": "Breakfast", "time": "08:00", "items": ["food with portion"], "calories": integer, "protein_g": integer } ],
  "recommendations": ["exactly 5 strings"]
}`;
}

const int = (v) => { const n = num(v); return n === null ? null : Math.round(n); };
const list = (v) => (Array.isArray(v) ? v.map((x) => String(x).trim()).filter(Boolean) : []);

function normalizePlan(raw) {
  const targets = raw.targets && typeof raw.targets === "object" ? raw.targets : {};
  return {
    assessment: str(raw.assessment) || "",
    findings: list(raw.findings),
    targets: {
      calories: int(targets.calories),
      protein_g: int(targets.protein_g),
      carbs_g: int(targets.carbs_g),
      fat_g: int(targets.fat_g),
      water_liters: num(targets.water_liters),
      calc_note: str(targets.calc_note),
    },
    workout_plan: (Array.isArray(raw.workout_plan) ? raw.workout_plan : []).map((d, i) => ({
      day: str(d.day) || `Day ${i + 1}`,
      focus: str(d.focus) || "",
      exercises: (Array.isArray(d.exercises) ? d.exercises : [])
        .filter((e) => e && str(e.name))
        .map((e) => ({
          name: str(e.name),
          sets: int(e.sets),
          reps: e.reps === undefined || e.reps === null ? "" : String(e.reps).trim(),
          rest_seconds: int(e.rest_seconds),
          note: str(e.note) || "",
        })),
    })),
    meals: (Array.isArray(raw.meals) ? raw.meals : []).map((m, i) => ({
      name: str(m.name) || `Meal ${i + 1}`,
      time: str(m.time) || "",
      items: list(m.items),
      calories: int(m.calories),
      protein_g: int(m.protein_g),
    })),
    recommendations: list(raw.recommendations),
  };
}

function validatePlan(plan, daysPerWeek) {
  const problems = [];
  if (!plan.assessment) problems.push("assessment is empty");
  if (plan.workout_plan.length !== daysPerWeek) {
    problems.push(`workout_plan has ${plan.workout_plan.length} days but it must have exactly ${daysPerWeek}`);
  }
  plan.workout_plan.forEach((d) => {
    const n = d.exercises.length;
    if (n < 5 || n > 7) problems.push(`${d.day} has ${n} exercises but every day needs 5 to 7`);
  });
  if (plan.meals.length < 4 || plan.meals.length > 5) {
    problems.push(`meals has ${plan.meals.length} entries but it must have 4 to 5`);
  }
  plan.meals.forEach((m) => { if (m.items.length === 0) problems.push(`meal "${m.name}" has no food items`); });
  const total = plan.meals.reduce((s, m) => s + (m.calories || 0), 0);
  const target = plan.targets.calories;
  if (target && total && Math.abs(total - target) / target > 0.15) {
    problems.push(`meal calories add up to ${total} but targets.calories is ${target}; they must match within 15%`);
  }
  if (plan.recommendations.length < 3) problems.push("recommendations needs 5 items");
  return problems;
}

async function generatePlan(ctx, reading) {
  let problems = [];
  for (let attempt = 1; attempt <= MAX_PLAN_ATTEMPTS; attempt += 1) {
    const prompt = buildPlanPrompt({
      reading, goal: ctx.goal, daysPerWeek: ctx.daysPerWeek, notes: ctx.notes, language: ctx.language, problems,
    });
    const text = await callClaude({
      ...ctx, content: [{ type: "text", text: prompt }], maxTokens: 6000, temperature: 0.7,
    });
    let plan;
    try {
      plan = normalizePlan(extractJson(text));
    } catch (_) {
      problems = ["the answer was not one valid JSON object; return ONLY the JSON"];
      continue;
    }
    problems = validatePlan(plan, ctx.daysPerWeek);
    if (problems.length === 0) return { plan, attempts: attempt };
  }
  throw new AiError("plan_invalid", problems.join("; "));
}

// ─── Public entry ────────────────────────────────────────────
// ctx: { apiKey, attachments:[{kind:'image'|'pdf', data(base64), mediaType?}], goal, daysPerWeek, notes, language, fetchImpl? }
async function analyze(ctx) {
  const reading = await extractReading(ctx);
  const { plan, attempts } = await generatePlan(ctx, reading);
  const { is_body_composition_report: _ok, ...readingOut } = reading;
  return { reading: readingOut, plan, meta: { attempts, model: MODEL } };
}

module.exports = { analyze, validatePlan, normalizePlan, normalizeReading, AiError, GOALS, MODEL };
