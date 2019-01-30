const express = require("express");
const app = express();
const port = 3000;

const commitRef = process.env.APP_COMMIT_REF || "N/A";
const buildDate = process.env.APP_BUILD_DATE || "N/A";

app.get("/", (req, res) => {
  const text = `Hello from GKE! We're at commit ${commitRef} which was built at ${buildDate}`;
  res.send(text);
});

app.listen(port, () => console.log(`Example app listening on port ${port}!`));
