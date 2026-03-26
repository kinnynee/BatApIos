const { getDb } = require("../config/firebase");
const { buildTimestampFields, serializeDocument } = require("../utils/firestore");

const COLLECTION = "payments";

async function listPayments(filters = {}) {
  let query = getDb().collection(COLLECTION);

  if (filters.userId) {
    query = query.where("userId", "==", filters.userId);
  }

  if (filters.bookingId) {
    query = query.where("bookingId", "==", filters.bookingId);
  }

  if (filters.paymentStatus) {
    query = query.where("paymentStatus", "==", filters.paymentStatus);
  }

  const snapshot = await query.get();
  return snapshot.docs.map(serializeDocument);
}

async function getPaymentById(id) {
  const doc = await getDb().collection(COLLECTION).doc(id).get();
  if (!doc.exists) {
    return null;
  }

  return serializeDocument(doc);
}

async function createPayment(id, payload) {
  const paymentRef = getDb().collection(COLLECTION).doc(id);
  await paymentRef.set({
    ...payload,
    ...buildTimestampFields(true)
  });

  const doc = await paymentRef.get();
  return serializeDocument(doc);
}

async function updatePayment(id, payload) {
  const paymentRef = getDb().collection(COLLECTION).doc(id);
  const existing = await paymentRef.get();
  if (!existing.exists) {
    return null;
  }

  await paymentRef.set({
    ...payload,
    ...buildTimestampFields(false)
  }, { merge: true });

  const doc = await paymentRef.get();
  return serializeDocument(doc);
}

module.exports = {
  createPayment,
  getPaymentById,
  listPayments,
  updatePayment
};
