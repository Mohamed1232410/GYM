"use strict";
const test = require("node:test");
const assert = require("node:assert");
const { analyze, validatePlan, AiError } = require("../inbody");

const READING = {
  is_body_composition_report: true, report_type: "smart_scale_app", report_date: "08/17/2023",
  gender: null, age: null, height_cm: null, weight_kg: 59.5, target_weight_kg: 63.0, bmi: 20.6,
  body_fat_percent: 14.5, muscle_mass_kg: null, body_water_percent: 57.5, bone_mass_kg: 2.91,
  protein_percent: 23.1, visceral_fat: 3.5, bmr_kcal: 1454.8, body_age: 20,
};

const exercise = (n) => ({ name: `Exercise ${n}`, sets: 4, reps: "8-10", rest_seconds: 90, note: "" });
function makePlan({ days = 4, perDay = 6, meals = 5, kcal = 2500 } = {}) {
  return JSON.stringify({
    assessment: "Weight 59.5 kg with 14.5% body fat and a target of 63 kg.",
    findings: ["BMI 20.6", "Visceral fat 3.5"],
    targets: { calories: kcal, protein_g: 130, carbs_g: 320, fat_g: 70, water_liters: 3, calc_note: "1454.8 x 1.5 = 2182, +10% = 2400" },
    workout_plan: Array.from({ length: days }, (_, d) => ({
      day: `Day ${d + 1}`, focus: "Push", exercises: Array.from({ length: perDay }, (_, i) => exercise(i)),
    })),
    meals: Array.from({ length: meals }, (_, i) => ({
      name: `Meal ${i + 1}`, time: "08:00", items: ["eggs"], calories: kcal / meals, protein_g: 30,
    })),
    recommendations: ["a", "b", "c", "d", "e"],
  });
}

function fakeClaude(responses) {
  const calls = [];
  const fetchImpl = async (_url, opts) => {
    calls.push(JSON.parse(opts.body));
    const next = responses.shift();
    if (typeof next === "string") {
      return { ok: true, status: 200, json: async () => ({ content: [{ type: "text", text: next }] }), text: async () => next };
    }
    return { ok: false, status: next.status, text: async () => JSON.stringify({ error: { message: next.message } }) };
  };
  return { fetchImpl, calls };
}

const base = (fetchImpl, over = {}) => ({
  apiKey: "k", attachments: [{ kind: "image", data: "AAAA" }, { kind: "pdf", data: "BBBB" }],
  goal: "build_muscle", daysPerWeek: 4, notes: "", language: "English", fetchImpl, ...over,
});

test("reads the report, rejects a bad first plan, returns a valid second one", async () => {
  const { fetchImpl, calls } = fakeClaude([
    JSON.stringify(READING),
    makePlan({ perDay: 4 }),            // too few exercises per day -> must be retried
    makePlan({ perDay: 6 }),
  ]);
  const out = await analyze(base(fetchImpl));

  assert.equal(out.meta.attempts, 2);
  assert.equal(out.reading.weight_kg, 59.5);
  assert.equal(out.reading.bmr_kcal, 1454.8);
  assert.equal(out.plan.workout_plan.length, 4);
  assert.ok(out.plan.workout_plan.every((d) => d.exercises.length >= 5 && d.exercises.length <= 7));
  assert.ok(out.plan.meals.length >= 4 && out.plan.meals.length <= 5);

  // call 1 sends the files with temperature 0; later calls are text-only and carry the real numbers
  assert.equal(calls[0].temperature, 0);
  assert.equal(calls[0].messages[0].content[0].type, "image");
  assert.equal(calls[0].messages[0].content[1].type, "document");
  assert.match(calls[1].messages[0].content[0].text, /59\.5/);
  assert.match(calls[2].messages[0].content[0].text, /REJECTED/);
  assert.match(calls[2].messages[0].content[0].text, /needs 5 to 7/);
});

test("different reports produce different prompts (nothing is canned)", async () => {
  const other = { ...READING, weight_kg: 88.2, body_fat_percent: 27.9, bmi: 28.4, bmr_kcal: 1810 };
  const a = fakeClaude([JSON.stringify(READING), makePlan()]);
  const b = fakeClaude([JSON.stringify(other), makePlan()]);
  await analyze(base(a.fetchImpl));
  await analyze(base(b.fetchImpl));
  assert.notEqual(a.calls[1].messages[0].content[0].text, b.calls[1].messages[0].content[0].text);
  assert.match(b.calls[1].messages[0].content[0].text, /88\.2/);
});

test("refuses to invent a plan when the file is not a report", async () => {
  const { fetchImpl } = fakeClaude([JSON.stringify({ is_body_composition_report: false })]);
  await assert.rejects(analyze(base(fetchImpl)), (e) => e instanceof AiError && e.code === "unreadable_report");
});

test("fails loudly if the model keeps returning invalid plans", async () => {
  const { fetchImpl } = fakeClaude([JSON.stringify(READING), makePlan({ perDay: 3 }), makePlan({ perDay: 3 }), makePlan({ perDay: 3 })]);
  await assert.rejects(analyze(base(fetchImpl)), (e) => e.code === "plan_invalid");
});

test("maps API errors to clear codes", async () => {
  const cases = [
    [{ status: 401, message: "invalid x-api-key" }, "ai_key_invalid"],
    [{ status: 400, message: "Your credit balance is too low" }, "ai_no_credit"],
    [{ status: 429, message: "rate" }, "ai_rate_limited"],
    [{ status: 529, message: "overloaded" }, "ai_unavailable"],
  ];
  for (const [resp, code] of cases) {
    const { fetchImpl } = fakeClaude([resp]);
    await assert.rejects(analyze(base(fetchImpl)), (e) => e.code === code, code);
  }
});

test("retries without temperature when the model rejects it", async () => {
  const { fetchImpl, calls } = fakeClaude([{ status: 400, message: "temperature is not supported" }, JSON.stringify(READING), makePlan()]);
  await analyze(base(fetchImpl));
  assert.equal(calls[0].temperature, 0);
  assert.equal(calls[1].temperature, undefined);
});

test("validatePlan catches the problems we care about", () => {
  const plan = JSON.parse(makePlan({ days: 3, perDay: 8, meals: 3 }));
  const issues = validatePlan(require("../inbody").normalizePlan(plan), 4);
  assert.ok(issues.some((i) => /exactly 4/.test(i)));
  assert.ok(issues.some((i) => /5 to 7/.test(i)));
  assert.ok(issues.some((i) => /4 to 5/.test(i)));
});
