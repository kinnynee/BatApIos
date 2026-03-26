const { getDb } = require("../config/firebase");
const { buildTimestampFields, serializeDocument } = require("../utils/firestore");

const COLLECTION = "courts";

async function listCourts(filters = {}) {
  let query = getDb().collection(COLLECTION);

  if (filters.courtType) {
    query = query.where("courtType", "==", filters.courtType);
  }

  if (filters.status) {
    query = query.where("status", "==", filters.status);
  }

  const snapshot = await query.get();
  return snapshot.docs.map(serializeDocument);
}

async function getCourtById(id) {
  const doc = await getDb().collection(COLLECTION).doc(id).get();
  if (!doc.exists) {
    return null;
  }

  return serializeDocument(doc);
}

async function createCourt(id, payload) {
  const courtRef = getDb().collection(COLLECTION).doc(id);
  await courtRef.set({
    imageUrls: [],
    ...payload,
    ...buildTimestampFields(true)
  });

  const doc = await courtRef.get();
  return serializeDocument(doc);
}

async function updateCourt(id, payload) {
  const courtRef = getDb().collection(COLLECTION).doc(id);
  const existing = await courtRef.get();
  if (!existing.exists) {
    return null;
  }

  await courtRef.set({
    ...payload,
    ...buildTimestampFields(false)
  }, { merge: true });

  const doc = await courtRef.get();
  return serializeDocument(doc);
}

module.exports = {
  createCourt,
  getCourtById,
  listCourts,
  updateCourt
};
