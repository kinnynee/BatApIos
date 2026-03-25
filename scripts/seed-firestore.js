const fs = require("fs");
const path = require("path");
const projectId = process.env.FIREBASE_PROJECT_ID;
const serviceAccountPath =
  process.env.FIREBASE_SERVICE_ACCOUNT_PATH ||
  path.join(process.cwd(), "serviceAccountKey.json");
const seedPath = path.join(process.cwd(), "data", "seed-data.json");
const isDryRun = process.argv.includes("--dry-run");
let admin = null;

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function normalizeValue(value) {
  if (value === null || value === undefined) {
    return null;
  }

  if (typeof value === "string") {
    const isoDateTimePattern = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/;
    if (isoDateTimePattern.test(value) && admin) {
      return admin.firestore.Timestamp.fromDate(new Date(value));
    }
  }

  if (Array.isArray(value)) {
    return value.map(normalizeValue);
  }

  if (typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value).map(([key, item]) => [key, normalizeValue(item)])
    );
  }

  return value;
}

function initializeFirebase() {
  if (!projectId) {
    throw new Error("Missing FIREBASE_PROJECT_ID in environment.");
  }

  if (!fs.existsSync(serviceAccountPath)) {
    throw new Error(`Missing service account file at ${serviceAccountPath}`);
  }

  const serviceAccount = readJson(serviceAccountPath);
  admin = require("firebase-admin");

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId
  });
}

async function seedCollection(db, collectionName, docs) {
  const batch = db.batch();

  docs.forEach((doc) => {
    const { id, ...rest } = doc;
    const ref = db.collection(collectionName).doc(id);
    batch.set(ref, normalizeValue(rest), { merge: true });
  });

  if (isDryRun) {
    console.log(`[dry-run] ${collectionName}: ${docs.length} docs ready`);
    return;
  }

  await batch.commit();
  console.log(`[seeded] ${collectionName}: ${docs.length} docs`);
}

async function main() {
  const seedData = readJson(seedPath);

  if (isDryRun) {
    console.log("Running in dry-run mode. No data will be written.");
  } else {
    initializeFirebase();
  }

  const db = isDryRun ? null : admin.firestore();
  const collections = ["users", "courts", "bookings", "payments"];

  for (const collectionName of collections) {
    const docs = seedData[collectionName] || [];
    if (docs.length === 0) {
      console.log(`[skip] ${collectionName}: no docs`);
      continue;
    }

    if (isDryRun) {
      console.log(`[dry-run] ${collectionName}: ${docs.length} docs ready`);
      continue;
    }

    await seedCollection(db, collectionName, docs);
  }
}

main().catch((error) => {
  console.error("Seed failed:", error.message);
  process.exit(1);
});
