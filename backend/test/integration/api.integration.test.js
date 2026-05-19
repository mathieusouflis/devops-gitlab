const { describe, test, before } = require("node:test");
const assert = require("node:assert/strict");

function trimSlash(s) {
  return s.replace(/\/$/, "");
}

async function findApiBase() {
  const candidates = [
    ...(process.env.VITE_FRONTEND_API_URL
      ? [/^\d+$/.test(process.env.VITE_FRONTEND_API_URL)
          ? `http://127.0.0.1:${process.env.VITE_FRONTEND_API_URL}`
          : process.env.VITE_FRONTEND_API_URL.startsWith("/")
            ? `http://127.0.0.1${process.env.VITE_FRONTEND_API_URL}`
            : process.env.VITE_FRONTEND_API_URL]
      : []),
    "http://127.0.0.1:3000",
    "http://127.0.0.1/api",
  ]
    .filter(Boolean)
    .map(trimSlash);

  for (const base of candidates) {
    try {
      const res = await fetch(`${base}/users`);
      if (res.status !== 200) continue;
      const data = await res.json();
      if (Array.isArray(data)) return base;
    } catch {}
  }

  throw new Error(`Aucune API joignable. Testé: ${candidates.join(", ")}`);
}

let apiBase = "";

describe("API — intégration", () => {
  before(async () => {
    apiBase = await findApiBase();
    const res = await fetch(`${apiBase}/`);
    assert.equal(res.status, 200);
    const body = await res.json();
    assert.equal(body.ok, true);
  });

  test("GET /users renvoie un tableau", async () => {
    const res = await fetch(`${apiBase}/users`);
    assert.equal(res.status, 200);
    const users = await res.json();
    assert.ok(Array.isArray(users));
  });

  test("cycle CRUD sur /users", async () => {
    const email = `ci-${Date.now()}@example.com`;
    const createRes = await fetch(`${apiBase}/users`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email, name: "CI User" }),
    });
    assert.equal(createRes.status, 201);
    const created = await createRes.json();
    assert.equal(created.email, email);

    const getRes = await fetch(`${apiBase}/users/${created.id}`);
    assert.equal(getRes.status, 200);

    const deleteRes = await fetch(`${apiBase}/users/${created.id}`, {
      method: "DELETE",
    });
    assert.equal(deleteRes.status, 204);
  });
});
