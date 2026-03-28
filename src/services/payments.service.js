const { getDb } = require("../config/firebase");
const { buildTimestampFields, serializeDocument } = require("../utils/firestore");
const { getBookingById, updateBooking } = require("./bookings.service");

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

async function submitPaymentRequest(id, payload) {
  const booking = await getBookingById(payload.bookingId);
  if (!booking) {
    const error = new Error("Booking not found for payment");
    error.statusCode = 404;
    throw error;
  }

  const amount = payload.amount ?? booking.totalAmount ?? 0;
  const payment = await createPayment(id, {
    bookingId: payload.bookingId,
    userId: payload.userId,
    amount,
    paymentMethod: payload.paymentMethod,
    paymentStatus: "pending",
    transactionCode: payload.transactionCode,
    paymentProofUrl: payload.paymentProofUrl ?? "",
    customerNote: payload.customerNote ?? "",
    submittedAt: new Date().toISOString(),
    paidAt: null
  });

  await updateBooking(payload.bookingId, {
    paymentStatus: "pending"
  });

  return payment;
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

async function confirmPayment(id, payload) {
  const payment = await getPaymentById(id);
  if (!payment) {
    return null;
  }

  const confirmedPayment = await updatePayment(id, {
    paymentStatus: "paid",
    paidAt: payload.paidAt ?? new Date().toISOString(),
    confirmedAt: new Date().toISOString(),
    confirmedBy: payload.confirmedBy,
    adminNote: payload.adminNote ?? ""
  });

  await updateBooking(payment.bookingId, {
    paymentStatus: "paid",
    bookingStatus: payload.bookingStatusAfterConfirm ?? "confirmed"
  });

  return confirmedPayment;
}

module.exports = {
  createPayment,
  confirmPayment,
  getPaymentById,
  listPayments,
  submitPaymentRequest,
  updatePayment
};
