const { getDb } = require("../config/firebase");
const { buildTimestampFields, serializeDocument } = require("../utils/firestore");
const { getCourtById } = require("./courts.service");
const { previewVoucherApplication } = require("./vouchers.service");

const COLLECTION = "bookings";
const BLOCKING_STATUSES = new Set(["pending", "confirmed", "checked_in", "completed"]);

function rangesOverlap(startA, endA, startB, endB) {
  return startA < endB && startB < endA;
}

function roundMoney(value) {
  return Math.round(Number(value) || 0);
}

async function buildBookingPricing(payload) {
  const court = await getCourtById(payload.courtId);
  if (!court) {
    const error = new Error("Court not found for booking");
    error.statusCode = 404;
    throw error;
  }

  const pricePerHour = payload.pricePerHour ?? court.pricePerHour;
  const durationHours = payload.durationHours;
  const subTotal = roundMoney(pricePerHour * durationHours);

  let voucherPricing = {
    voucherId: null,
    voucherCode: null,
    voucherName: null,
    discountType: null,
    discountAmount: 0,
    freeItems: [],
    originalAmount: subTotal,
    finalAmount: subTotal
  };

  if (payload.voucherCode) {
    const result = await previewVoucherApplication({
      code: payload.voucherCode,
      bookingAmount: subTotal,
      courtType: court.courtType
    });
    voucherPricing = result.pricing;
  }

  return {
    courtType: court.courtType,
    pricePerHour,
    subTotal,
    voucherId: voucherPricing.voucherId,
    voucherCode: voucherPricing.voucherCode,
    voucherName: voucherPricing.voucherName,
    discountType: voucherPricing.discountType,
    discountAmount: voucherPricing.discountAmount,
    freeItems: voucherPricing.freeItems,
    totalAmount: voucherPricing.finalAmount
  };
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
  const pricing = await buildBookingPricing(payload);

  const bookingRef = getDb().collection(COLLECTION).doc(id);
  await bookingRef.set({
    ...payload,
    ...pricing,
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
  const pricing = await buildBookingPricing(mergedPayload);

  const bookingRef = getDb().collection(COLLECTION).doc(id);
  await bookingRef.set({
    ...payload,
    ...pricing,
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
