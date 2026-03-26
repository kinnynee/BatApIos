const { getDb } = require("../config/firebase");
const { buildTimestampFields, serializeDocument } = require("../utils/firestore");

const COLLECTION = "users";

async function listUsers(filters = {}) {
  let query = getDb().collection(COLLECTION);

  if (filters.role) {
    query = query.where("role", "==", filters.role);
  }

  if (filters.status) {
    query = query.where("status", "==", filters.status);
  }

  const snapshot = await query.get();
  return snapshot.docs.map(serializeDocument);
}

async function getUserById(id) {
  const doc = await getDb().collection(COLLECTION).doc(id).get();
  if (!doc.exists) {
    return null;
  }

  return serializeDocument(doc);
}

async function createUser(id, payload) {
  const userRef = getDb().collection(COLLECTION).doc(id);
  await userRef.set({
    ...payload,
    ...buildTimestampFields(true)
  });

  const doc = await userRef.get();
  return serializeDocument(doc);
}

async function updateUser(id, payload) {
  const userRef = getDb().collection(COLLECTION).doc(id);
  const existing = await userRef.get();
  if (!existing.exists) {
    return null;
  }

  await userRef.set({
    ...payload,
    ...buildTimestampFields(false)
  }, { merge: true });

  const doc = await userRef.get();
  return serializeDocument(doc);
}

module.exports = {
  createUser,
  getUserById,
  listUsers,
  updateUser
};
