const { describe, test, before } = require("node:test");
const assert = require("node:assert/strict");

function trimSlash(s) {
  return s.replace(/\/$/, "");
}

async function tryJsonArray(url) {
  try {
    const res = await fetch(url);
    if (res.status !== 200) return null;
    const text = await res.text();
    const data = JSON.parse(text);
    return Array.isArray(data) ? { res, data } : null;
  } catch {
    return null;
  }
}

async function findFrontendBase() {
  const candidates = [
    process.env.VITE_FRONTEND_PORT ? `http://127.0.0.1:${process.env.VITE_FRONTEND_PORT}` : null,
    "http://127.0.0.1:8088",
    "http://127.0.0.1:5173",
    "http://127.0.0.1",
  ]
    .filter(Boolean)
    .map(trimSlash);

  for (const base of candidates) {
    try {
      const res = await fetch(`${base}/`);
      if (res.status !== 200) continue;
      const html = await res.text();
      if (/id="root"/i.test(html)) return base;
    } catch {}
  }

  throw new Error(`Aucun frontend joignable. Testé: ${candidates.join(", ")}`);
}

async function findApiBase(frontendBase) {
  const apiCandidates = [
    process.env.E2E_API_URL,
    process.env.API_URL,
    `${frontendBase}/api/v1`,
    `${frontendBase}/api`,
    "http://127.0.0.1:3000",
    "http://127.0.0.1/api",
  ]
    .filter(Boolean)
    .map(trimSlash);

  for (const base of apiCandidates) {
    const ok = await tryJsonArray(`${base}/users`);
    if (ok) return base;
  }

  throw new Error(`Aucune API joignable. Testé: ${apiCandidates.join(", ")}`);
}

let appBase = "";
let apiBase = "";

describe("Stack — E2E", () => {
  before(async () => {
    appBase = await findFrontendBase();
    apiBase = await findApiBase(appBase);
  });

  test("GET / sert le shell Vite (index.html)", async () => {
    const res = await fetch(`${appBase}/`);
    const html = await res.text();
    assert.equal(res.status, 200, html.slice(0, 300));
    assert.match(html, /id="root"/i);
    assert.match(html, /Gestion des utilisateurs|utilisateurs/i);
  });

  test("GET /users via API configurée renvoie un tableau", async () => {
    const res = await fetch(`${apiBase}/users`);
    const text = await res.text();
    assert.equal(res.status, 200, text.slice(0, 400));
    const users = JSON.parse(text);
    assert.ok(Array.isArray(users));
  });
});
