const express = require("express");
const cors = require("cors");
const usersRouter = require("./routes/users");
const { ensureUsersTable, waitForDb } = require("./db");

const app = express();

const allowedOrigins = process.env.CORS_ORIGIN
  ? process.env.CORS_ORIGIN.split(",").map((o) => o.trim())
  : [];

app.use(
  cors({
    origin: allowedOrigins.length ? allowedOrigins : false,
    methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization"],
    credentials: true,
  }),
);

app.use(express.json());

app.get("/", (_req, res) => {
  res.json({ ok: true, service: "api", users: "/users" });
});

app.get("/health", (_req, res) => {
  res.status(200).json({ ok: true });
});

app.use("/users", usersRouter);

app.use((err, _req, res, _next) => {
  console.error(err);
  res.status(500).json({ error: "Erreur serveur" });
});

const port = Number(process.env.BACKEND_PORT) || 3000;

async function main() {
  await waitForDb();
  await ensureUsersTable();
  app.listen(port, "0.0.0.0", () => {
    console.log(`API sur http://0.0.0.0:${port}`);
  });
}

main().catch((err) => {
  console.error("Impossible de démarrer le serveur:", err);
  process.exit(1);
});
