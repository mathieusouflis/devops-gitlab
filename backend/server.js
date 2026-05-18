const { createApp } = require("./app");
const { ensureUsersTable, waitForDb } = require("./db");

const app = createApp();
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
