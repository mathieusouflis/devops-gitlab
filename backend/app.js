const express = require("express");
const cors = require("cors");
const usersRouter = require("./routes/users");

function createApp() {
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

  return app;
}

module.exports = { createApp };
