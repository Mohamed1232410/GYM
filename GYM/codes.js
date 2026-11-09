"use strict";
const crypto = require("crypto");

// 6-digit code, cryptographically random, keeps leading zeros
function generateCode() {
  return String(crypto.randomInt(0, 1000000)).padStart(6, "0");
}

function newSalt() {
  return crypto.randomBytes(16).toString("hex");
}

// We never store the code itself, only a salted hash
function hashCode(salt, uid, code) {
  return crypto.createHash("sha256").update(`${salt}:${uid}:${code}`).digest("hex");
}

function hashesMatch(a, b) {
  const x = Buffer.from(String(a), "hex");
  const y = Buffer.from(String(b), "hex");
  return x.length === y.length && x.length > 0 && crypto.timingSafeEqual(x, y);
}

module.exports = { generateCode, newSalt, hashCode, hashesMatch };
