"use strict";

const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const logger = require("firebase-functions/logger");
const { initializeApp } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");
const { getFirestore } = require("firebase-admin/firestore");
const nodemailer = require("nodemailer");
const { generateCode, newSalt, hashCode, hashesMatch } = require("./codes");
const { analyze, AiError, GOALS } = require("./inbody");

initializeApp();

const REGION = "us-central1";
const GMAIL_USER = defineSecret("GMAIL_USER");
const GMAIL_APP_PASSWORD = defineSecret("GMAIL_APP_PASSWORD");
const ANTHROPIC_API_KEY = defineSecret("ANTHROPIC_API_KEY");

const CODE_TTL_MS = 10 * 60 * 1000;       // code valid for 10 minutes
const RESEND_COOLDOWN_MS = 60 * 1000;     // 1 code per minute
const HOUR_MS = 60 * 60 * 1000;
const MAX_SENDS_PER_HOUR = 5;
const MAX_ATTEMPTS = 5;                   // wrong guesses before the code is burned

const codesCollection = () => getFirestore().collection("emailCodes");

function requireUid(request) {
  if (!request.auth || !request.auth.uid) {
    throw new HttpsError("unauthenticated", "unauthenticated");
  }
  return request.auth.uid;
}

function escapeHtml(value) {
  return String(value || "").replace(/[&<>"']/g, (c) => (
    { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]
  ));
}

async function sendCodeEmail(to, code, name) {
  const transporter = nodemailer.createTransport({
    host: "smtp.gmail.com",
    port: 465,
    secure: true,
    auth: { user: GMAIL_USER.value(), pass: GMAIL_APP_PASSWORD.value() },
  });

  const who = escapeHtml(name || "");
  await transporter.sendMail({
    from: `"FitBody" <${GMAIL_USER.value()}>`,
    to,
    subject: `${code} is your FitBody verification code | كود التحقق ${code}`,
    text:
      `Your FitBody verification code is ${code}\n` +
      `It expires in 10 minutes. If you didn't request it, ignore this email.\n\n` +
      `كود التحقق الخاص بك في FitBody هو ${code}\n` +
      `الكود صالح لمدة 10 دقائق. لو ماطلبتوش تجاهل الرسالة.`,
    html: `
      <div style="font-family:-apple-system,Segoe UI,Arial,sans-serif;max-width:420px;margin:auto;padding:24px;background:#0b0b0b;color:#fff;border-radius:16px;text-align:center">
        <h2 style="margin:0 0 4px;color:#e0ff33">FIT<span style="color:#fff;font-weight:300">BODY</span></h2>
        <p style="color:#aaa;margin:0 0 20px">${who ? `Hi ${who}, ` : ""}your verification code is</p>
        <div style="font-size:38px;letter-spacing:10px;font-weight:700;background:#1c1c1e;border-radius:12px;padding:16px 8px;direction:ltr">${code}</div>
        <p style="color:#aaa;font-size:13px;margin:20px 0 0">Valid for 10 minutes. If you didn't request this, ignore this email.</p>
        <p style="color:#aaa;font-size:13px;margin:6px 0 0;direction:rtl">الكود صالح لمدة 10 دقائق. لو ماطلبتوش تجاهل الرسالة.</p>
      </div>`,
  });
}

// ─────────────────────────────────────────────────────────────
// 1) Send a code to the signed-in user's email
// ─────────────────────────────────────────────────────────────
exports.sendVerificationCode = onCall(
  { region: REGION, secrets: [GMAIL_USER, GMAIL_APP_PASSWORD] },
  async (request) => {
    const uid = requireUid(request);
    const user = await getAuth().getUser(uid);

    if (!user.email) throw new HttpsError("failed-precondition", "no_email");
    if (user.emailVerified) return { alreadyVerified: true };

    const ref = codesCollection().doc(uid);
    const snap = await ref.get();
    const prev = snap.exists ? snap.data() : {};
    const now = Date.now();

    if (prev.sentAt && now - prev.sentAt < RESEND_COOLDOWN_MS) {
      throw new HttpsError("resource-exhausted", "cooldown");
    }

    const windowActive = prev.hourStart && now - prev.hourStart < HOUR_MS;
    const hourStart = windowActive ? prev.hourStart : now;
    const hourCount = windowActive ? (prev.hourCount || 0) : 0;
    if (hourCount >= MAX_SENDS_PER_HOUR) {
      throw new HttpsError("resource-exhausted", "too_many_requests");
    }

    const code = generateCode();
    const salt = newSalt();
    await ref.set({
      salt,
      hash: hashCode(salt, uid, code),
      email: user.email,
      sentAt: now,
      expiresAt: now + CODE_TTL_MS,
      attempts: 0,
      hourStart,
      hourCount: hourCount + 1,
    });

    try {
      await sendCodeEmail(user.email, code, user.displayName);
    } catch (err) {
      logger.error("Failed to send verification email", err);
      await ref.delete();
      throw new HttpsError("internal", "send_failed");
    }

    return { sent: true, expiresInSeconds: CODE_TTL_MS / 1000, cooldownSeconds: RESEND_COOLDOWN_MS / 1000 };
  }
);

// ─────────────────────────────────────────────────────────────
// 2) Check the code and mark the email as verified in Firebase Auth
// ─────────────────────────────────────────────────────────────
exports.verifyCode = onCall({ region: REGION }, async (request) => {
  const uid = requireUid(request);
  const code = String((request.data && request.data.code) || "").trim();
  if (!/^\d{6}$/.test(code)) throw new HttpsError("invalid-argument", "wrong_code");

  const ref = codesCollection().doc(uid);
  const snap = await ref.get();
  if (!snap.exists) throw new HttpsError("failed-precondition", "no_code");

  const data = snap.data();
  if (Date.now() > data.expiresAt) {
    await ref.delete();
    throw new HttpsError("deadline-exceeded", "expired");
  }
  if ((data.attempts || 0) >= MAX_ATTEMPTS) {
    await ref.delete();
    throw new HttpsError("resource-exhausted", "too_many_attempts");
  }

  if (!hashesMatch(hashCode(data.salt, uid, code), data.hash)) {
    await ref.update({ attempts: (data.attempts || 0) + 1 });
    throw new HttpsError("invalid-argument", "wrong_code");
  }

  await getAuth().updateUser(uid, { emailVerified: true });
  await ref.delete();
  return { verified: true };
});

// ─────────────────────────────────────────────────────────────
// 3) InBody / body-composition AI analysis (the Claude key lives here, never in the app)
// ─────────────────────────────────────────────────────────────
const MAX_ANALYSES_PER_DAY = 10;
const MAX_ATTACHMENTS = 5;
const MAX_BASE64_CHARS = 24 * 1024 * 1024;
const IMAGE_TYPES = ["image/jpeg", "image/png", "image/webp"];

function parseAnalyzeInput(data) {
  const d = data || {};
  if (!Object.prototype.hasOwnProperty.call(GOALS, d.goal)) throw new HttpsError("invalid-argument", "bad_goal");
  const daysPerWeek = Number(d.daysPerWeek);
  if (!Number.isInteger(daysPerWeek) || daysPerWeek < 3 || daysPerWeek > 6) {
    throw new HttpsError("invalid-argument", "bad_days");
  }
  if (!Array.isArray(d.attachments) || d.attachments.length < 1 || d.attachments.length > MAX_ATTACHMENTS) {
    throw new HttpsError("invalid-argument", "bad_attachments");
  }
  let totalChars = 0;
  const attachments = d.attachments.map((a) => {
    if (!a || typeof a.data !== "string" || a.data.length === 0 || (a.kind !== "image" && a.kind !== "pdf")) {
      throw new HttpsError("invalid-argument", "bad_attachments");
    }
    totalChars += a.data.length;
    const mediaType = IMAGE_TYPES.includes(a.mediaType) ? a.mediaType : "image/jpeg";
    return { kind: a.kind, data: a.data, mediaType };
  });
  if (totalChars > MAX_BASE64_CHARS) throw new HttpsError("invalid-argument", "files_too_large");

  return {
    attachments,
    goal: d.goal,
    daysPerWeek,
    notes: String(d.notes || "").slice(0, 500),
    language: d.language === "ar" ? "Arabic" : "English",
  };
}

const HTTPS_CODE_FOR = {
  unreadable_report: "failed-precondition",
  ai_key_invalid: "failed-precondition",
  ai_no_credit: "failed-precondition",
  ai_rate_limited: "resource-exhausted",
  ai_unavailable: "unavailable",
  files_too_large: "invalid-argument",
};

exports.analyzeInBody = onCall(
  { region: REGION, secrets: [ANTHROPIC_API_KEY], timeoutSeconds: 300, memory: "512MiB" },
  async (request) => {
    const uid = requireUid(request);
    const input = parseAnalyzeInput(request.data);

    const usageRef = getFirestore().collection("usage").doc(uid);
    const today = new Date().toISOString().slice(0, 10);
    const usageSnap = await usageRef.get();
    const usage = (usageSnap.exists && usageSnap.data()) || {};
    const used = usage.day === today ? usage.count || 0 : 0;
    if (used >= MAX_ANALYSES_PER_DAY) throw new HttpsError("resource-exhausted", "daily_limit");

    try {
      const result = await analyze({ apiKey: ANTHROPIC_API_KEY.value(), ...input });
      await usageRef.set({ day: today, count: used + 1 });
      return result;
    } catch (err) {
      if (err instanceof AiError) {
        logger.error("analyzeInBody failed", { code: err.code, status: err.status, message: err.message });
        throw new HttpsError(HTTPS_CODE_FOR[err.code] || "internal", err.code);
      }
      logger.error("analyzeInBody crashed", err);
      throw new HttpsError("internal", "ai_error");
    }
  }
);
