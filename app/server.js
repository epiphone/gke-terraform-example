const express = require("express");
const pg = require("pg");

const commitRef = process.env.APP_COMMIT_REF || "N/A";
const buildDate = process.env.APP_BUILD_DATE || "N/A";
const port = process.env.PORT || 3000;

const app = express();
const client = new pg.Client();
client.connect();

app.get("/", (req, res) => {
  const text = `Hello from GKE! We're at commit ${commitRef} which was built at ${buildDate}`;
  res.send(text);
});

app.get("/api/health", (req, res) => {
  client
    .query("SELECT NOW() as now")
    .then(({ rows }) => {
      res.json({ status: "ok", commitRef, buildDate, now: rows[0].now });
    })
    .catch(e => {
      res.status(503).json({ status: "error", stack: e.stack });
    });
});

app.listen(port, () => console.log(`Example app listening on port ${port}!`));
