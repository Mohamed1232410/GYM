"use strict";
// Runs the real handlers against in-memory stand-ins for Firebase and Gmail.
const test = require("node:test");
const assert = require("node:assert");
const Module = require("module");

const store = new Map();
const users = { u1: { email: "a@b.com", displayName: "Ali", emailVerified: false } };
const sent = [];

const stubs = {
  "firebase-admin/app": { initializeApp() {} },
  "firebase-admin/auth": {
    getAuth: () => ({
      getUser: async (uid) => ({ uid, ...users[uid] }),
      updateUser: async (uid, patch) => { Object.assign(users[uid], patch); },
    }),
  },
  "firebase-admin/firestore": {
    getFirestore: () => ({
      collection: (name) => ({
        doc: (id) => {
          const key = `${name}/${id}`;
          return {
            get: async () => ({ exists: store.has(key), data: () => store.get(key) }),
            set: async (d) => { store.set(key, { ...d }); },
            update: async (p) => { store.set(key, { ...store.get(key), ...p }); },
            delete: async () => { store.delete(key); },
          };
        },
      }),
    }),
  },
  nodemailer: { createTransport: () => ({ sendMail: async (m) => { sent.push(m); } }) },
};

const originalLoad = Module._load;
Module._load = function (request, ...rest) {
  if (stubs[request]) return stubs[request];
  return originalLoad.call(this, request, ...rest);
};
process.env.GMAIL_USER = "me@gmail.com";
process.env.GMAIL_APP_PASSWORD = "x";

const fns = require("../index.js");
const authed = (data = {}) => ({ auth: { uid: "u1" }, data });
const codeFromMail = () => sent[sent.length - 1].text.match(/code is (\d{6})/)[1];
const rejects = (p, msg) => assert.rejects(p, (e) => e.message === msg);

test("needs sign-in", async () => {
  await rejects(fns.sendVerificationCode.run({ data: {} }), "unauthenticated");
});

test("sends a 6-digit code, then enforces the 60s cooldown", async () => {
  const res = await fns.sendVerificationCode.run(authed());
  assert.equal(res.sent, true);
  assert.equal(sent.length, 1);
  assert.match(codeFromMail(), /^\d{6}$/);
  assert.equal(sent[0].to, "a@b.com");
  await rejects(fns.sendVerificationCode.run(authed()), "cooldown");
});

test("wrong code is rejected and counted, right code verifies", async () => {
  const good = codeFromMail();
  const bad = good === "000000" ? "111111" : "000000";
  await rejects(fns.verifyCode.run(authed({ code: bad })), "wrong_code");
  assert.equal(store.get("emailCodes/u1").attempts, 1);
  await rejects(fns.verifyCode.run(authed({ code: "12ab" })), "wrong_code");

  const res = await fns.verifyCode.run(authed({ code: good }));
  assert.equal(res.verified, true);
  assert.equal(users.u1.emailVerified, true);
  assert.equal(store.has("emailCodes/u1"), false, "code is deleted after use");
});

test("expired code", async () => {
  users.u1.emailVerified = false;
  store.set("emailCodes/u1", { salt: "s", hash: "00", expiresAt: Date.now() - 1, attempts: 0 });
  await rejects(fns.verifyCode.run(authed({ code: "123456" })), "expired");
});

test("burns the code after 5 wrong attempts", async () => {
  users.u1.emailVerified = false;
  store.set("emailCodes/u1", { salt: "s", hash: "00", expiresAt: Date.now() + 60000, attempts: 5 });
  await rejects(fns.verifyCode.run(authed({ code: "123456" })), "too_many_attempts");
  assert.equal(store.has("emailCodes/u1"), false);
});

test("no code requested", async () => {
  await rejects(fns.verifyCode.run(authed({ code: "123456" })), "no_code");
});

test("max 5 sends per hour", async () => {
  users.u1.emailVerified = false;
  store.set("emailCodes/u1", { sentAt: Date.now() - 120000, hourStart: Date.now() - 1000, hourCount: 5 });
  await rejects(fns.sendVerificationCode.run(authed()), "too_many_requests");
});

test("already verified users get no email", async () => {
  users.u1.emailVerified = true;
  store.delete("emailCodes/u1");
  const before = sent.length;
  const res = await fns.sendVerificationCode.run(authed());
  assert.equal(res.alreadyVerified, true);
  assert.equal(sent.length, before);
});


test("analyzeInBody: needs sign-in, validates input, counts usage, enforces the daily limit", async () => {
  const input = { attachments: [{ kind: "image", data: "AAAA" }], goal: "build_muscle", daysPerWeek: 4, notes: "", language: "en" };
  await rejects(fns.analyzeInBody.run({ data: input }), "unauthenticated");
  await rejects(fns.analyzeInBody.run(authed({ ...input, goal: "nope" })), "bad_goal");
  await rejects(fns.analyzeInBody.run(authed({ ...input, daysPerWeek: 9 })), "bad_days");
  await rejects(fns.analyzeInBody.run(authed({ ...input, attachments: [] })), "bad_attachments");

  const reading = { is_body_composition_report: true, weight_kg: 70, bmi: 22, body_fat_percent: 15 };
  const exercises = Array.from({ length: 6 }, (_, i) => ({ name: `E${i}`, sets: 3, reps: "10", rest_seconds: 60, note: "" }));
  const plan = {
    assessment: "ok", findings: ["a"], targets: { calories: 2000, protein_g: 120, carbs_g: 200, fat_g: 60, water_liters: 3, calc_note: "x" },
    workout_plan: Array.from({ length: 4 }, (_, i) => ({ day: `Day ${i + 1}`, focus: "f", exercises })),
    meals: Array.from({ length: 4 }, (_, i) => ({ name: `M${i}`, time: "", items: ["x"], calories: 500, protein_g: 30 })),
    recommendations: ["1", "2", "3", "4", "5"],
  };
  const answers = [JSON.stringify(reading), JSON.stringify(plan)];
  global.fetch = async () => {
    const text = answers.shift();
    return { ok: true, status: 200, json: async () => ({ content: [{ type: "text", text }] }), text: async () => text };
  };
  process.env.ANTHROPIC_API_KEY = "k";

  const out = await fns.analyzeInBody.run(authed(input));
  assert.equal(out.plan.workout_plan.length, 4);
  assert.equal(store.get("usage/u1").count, 1);

  store.set("usage/u1", { day: new Date().toISOString().slice(0, 10), count: 10 });
  await rejects(fns.analyzeInBody.run(authed(input)), "daily_limit");
});
