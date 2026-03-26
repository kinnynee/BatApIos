const fs = require("fs");
const path = require("path");

let loaded = false;

function loadEnvFile() {
  if (loaded) {
    return;
  }

  const envPath = path.join(process.cwd(), ".env");
  if (!fs.existsSync(envPath)) {
    loaded = true;
    return;
  }

  const lines = fs.readFileSync(envPath, "utf8").split(/\r?\n/);
  for (const rawLine of lines) {
    const line = rawLine.trim();
    if (!line || line.startsWith("#")) {
      continue;
    }

    const separatorIndex = line.indexOf("=");
    if (separatorIndex === -1) {
      continue;
    }

    const key = line.slice(0, separatorIndex).trim();
    const value = line.slice(separatorIndex + 1).trim();

    if (key && process.env[key] === undefined) {
      process.env[key] = value;
    }
  }

  loaded = true;
}

function getEnv(name, fallback = undefined) {
  loadEnvFile();
  return process.env[name] ?? fallback;
}

module.exports = {
  getEnv,
  loadEnvFile
};
