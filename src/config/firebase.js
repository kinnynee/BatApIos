const fs = require("fs");
const path = require("path");
const admin = require("firebase-admin");
const { getEnv, loadEnvFile } = require("./env");

let dbInstance = null;

function createFirebaseApp() {
  loadEnvFile();

  if (admin.apps.length > 0) {
    return admin.app();
  }

  const serviceAccountPath = path.resolve(
    process.cwd(),
    getEnv("FIREBASE_SERVICE_ACCOUNT_PATH", "./serviceAccountKey.json")
  );

  if (!fs.existsSync(serviceAccountPath)) {
    throw new Error(`Missing service account file: ${serviceAccountPath}`);
  }

  const serviceAccount = require(serviceAccountPath);
  const projectId = getEnv("FIREBASE_PROJECT_ID", serviceAccount.project_id);

  return admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId
  });
}

function getDb() {
  if (dbInstance) {
    return dbInstance;
  }

  createFirebaseApp();
  dbInstance = admin.firestore();
  return dbInstance;
}

module.exports = {
  admin,
  getDb
};
