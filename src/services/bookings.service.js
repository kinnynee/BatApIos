const { getDb } = require("../config/firebase");
const { buildTimestampFields, serializeDocument } = require("../utils/firestore");

const COLLECTION = "bookings";
const BLOCKING_STATUSES = new Set(["pending", "confirmed", "completed"]);

function rangesOverlap(startA, endA, startB, endB) {
  return startA < endB && startB < endA;
}

async function listBookings(filters = {}) {
  let query = getDb().collection(COLLECTION);

  if (filters.userId) {
    query = query.where("userId", "==", filters.userId);
  }

  if (filters.courtId) {
    query = query.where("courtId", "==", filters.courtId);
  }

  if (filters.bookingDate) {
    query = query.where("bookingDate", "==", filters.bookingDate);
  }

  if (filters.bookingStatus) {
    query = query.where("bookingStatus", "==", filters.bookingStatus);
  }

  const snapshot = await query.get();
  return snapshot.docs.map(serializeDocument);
}

async function getBookingById(id) {
  const doc = await getDb().collection(COLLECTION).doc(id).get();
  if (!doc.exists) {
    return null;
  }

  return serializeDocument(doc);
}

async function ensureCourtAvailability(payload, excludeBookingId = null) {
  const snapshot = await getDb()
    .collection(COLLECTION)
    .where("courtId", "==", payload.courtId)
    .where("bookingDate", "==", payload.bookingDate)
    .get();

  const conflicts = snapshot.docs
    .map(serializeDocument)
    .filter((booking) => booking.id !== excludeBookingId)
    .filter((booking) => BLOCKING_STATUSES.has(booking.bookingStatus))
    .filter((booking) =>
      rangesOverlap(
        payload.startTime,
        payload.endTime,
        booking.startTime,
        booking.endTime
      )
    );

  if (conflicts.length > 0) {
    const error = new Error("Court is already booked in this time range");
    error.statusCode = 409;
    error.details = conflicts;
    throw error;
  }
}

async function createBooking(id, payload) {
  await ensureCourtAvailability(payload);

  const bookingRef = getDb().collection(COLLECTION).doc(id);
  await bookingRef.set({
    ...payload,
    ...buildTimestampFields(true)
  });

  const doc = await bookingRef.get();
  return serializeDocument(doc);
}

async function updateBooking(id, payload) {
  const current = await getBookingById(id);
  if (!current) {
    return null;
  }

  const mergedPayload = {
    ...current,
    ...payload
  };

  await ensureCourtAvailability(mergedPayload, id);

  const bookingRef = getDb().collection(COLLECTION).doc(id);
  await bookingRef.set({
    ...payload,
    ...buildTimestampFields(false)
  }, { merge: true });

  const doc = await bookingRef.get();
  return serializeDocument(doc);
}

module.exports = {
  createBooking,
  getBookingById,
  listBookings,
  updateBooking
};
