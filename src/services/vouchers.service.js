const { getDb } = require("../config/firebase");
const { buildTimestampFields, serializeDocument } = require("../utils/firestore");

const COLLECTION = "vouchers";

function normalizeCode(code) {
  return String(code || "").trim().toUpperCase();
}

function toIsoDateString(value) {
  if (!value) {
    return null;
  }

  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return null;
  }

  return date.toISOString();
}

function ensureVoucherIsUsable(voucher, context) {
  if (!voucher) {
    const error = new Error("Voucher not found");
    error.statusCode = 404;
    throw error;
  }

  if (voucher.status !== "active") {
    const error = new Error("Voucher is not active");
    error.statusCode = 400;
    throw error;
  }

  const now = new Date();
  const startDate = voucher.startDate ? new Date(voucher.startDate) : null;
  const endDate = voucher.endDate ? new Date(voucher.endDate) : null;

  if (startDate && now < startDate) {
    const error = new Error("Voucher is not available yet");
    error.statusCode = 400;
    throw error;
  }

  if (endDate && now > endDate) {
    const error = new Error("Voucher has expired");
    error.statusCode = 400;
    throw error;
  }

  if (
    typeof voucher.usageLimit === "number" &&
    typeof voucher.usedCount === "number" &&
    voucher.usedCount >= voucher.usageLimit
  ) {
    const error = new Error("Voucher usage limit reached");
    error.statusCode = 400;
    throw error;
  }

  if (
    typeof voucher.minOrderValue === "number" &&
    context.bookingAmount < voucher.minOrderValue
  ) {
    const error = new Error(`Booking amount must be at least ${voucher.minOrderValue}`);
    error.statusCode = 400;
    throw error;
  }

  if (
    Array.isArray(voucher.applicableCourtTypes) &&
    voucher.applicableCourtTypes.length > 0 &&
    !voucher.applicableCourtTypes.includes(context.courtType)
  ) {
    const error = new Error("Voucher is not applicable for this court type");
    error.statusCode = 400;
    throw error;
  }
}

function computeVoucherBenefit(voucher, context) {
  const bookingAmount = context.bookingAmount;
  let discountAmount = 0;

  if (voucher.discountType === "percentage") {
    discountAmount = Math.round((bookingAmount * voucher.discountValue) / 100);
  } else if (voucher.discountType === "fixed_amount") {
    discountAmount = voucher.discountValue || 0;
  }

  if (
    typeof voucher.maxDiscountAmount === "number" &&
    discountAmount > voucher.maxDiscountAmount
  ) {
    discountAmount = voucher.maxDiscountAmount;
  }

  if (discountAmount > bookingAmount) {
    discountAmount = bookingAmount;
  }

  const freeItems = Array.isArray(voucher.giftItems) ? voucher.giftItems : [];

  return {
    voucherId: voucher.id,
    voucherCode: voucher.code,
    voucherName: voucher.name,
    discountType: voucher.discountType,
    discountAmount,
    freeItems,
    originalAmount: bookingAmount,
    finalAmount: Math.max(bookingAmount - discountAmount, 0)
  };
}

async function listVouchers(filters = {}) {
  let query = getDb().collection(COLLECTION);

  if (filters.status) {
    query = query.where("status", "==", filters.status);
  }

  const snapshot = await query.get();
  let vouchers = snapshot.docs.map(serializeDocument);

  if (filters.code) {
    const normalizedCode = normalizeCode(filters.code);
    vouchers = vouchers.filter((voucher) => voucher.code === normalizedCode);
  }

  return vouchers;
}

async function getVoucherById(id) {
  const doc = await getDb().collection(COLLECTION).doc(id).get();
  if (!doc.exists) {
    return null;
  }

  return serializeDocument(doc);
}

async function getVoucherByCode(code) {
  const normalizedCode = normalizeCode(code);
  const snapshot = await getDb()
    .collection(COLLECTION)
    .where("code", "==", normalizedCode)
    .limit(1)
    .get();

  if (snapshot.empty) {
    return null;
  }

  return serializeDocument(snapshot.docs[0]);
}

async function createVoucher(id, payload) {
  const voucherRef = getDb().collection(COLLECTION).doc(id);
  await voucherRef.set({
    code: normalizeCode(payload.code),
    name: payload.name,
    description: payload.description ?? "",
    discountType: payload.discountType,
    discountValue: payload.discountValue ?? 0,
    minOrderValue: payload.minOrderValue ?? 0,
    maxDiscountAmount: payload.maxDiscountAmount ?? null,
    applicableCourtTypes: payload.applicableCourtTypes ?? [],
    giftItems: payload.giftItems ?? [],
    usageLimit: payload.usageLimit ?? null,
    usedCount: payload.usedCount ?? 0,
    startDate: toIsoDateString(payload.startDate),
    endDate: toIsoDateString(payload.endDate),
    status: payload.status ?? "active",
    ...buildTimestampFields(true)
  });

  const doc = await voucherRef.get();
  return serializeDocument(doc);
}

async function updateVoucher(id, payload) {
  const voucherRef = getDb().collection(COLLECTION).doc(id);
  const existing = await voucherRef.get();
  if (!existing.exists) {
    return null;
  }

  const updatePayload = {
    ...payload,
    ...buildTimestampFields(false)
  };

  if (payload.code !== undefined) {
    updatePayload.code = normalizeCode(payload.code);
  }

  if (payload.startDate !== undefined) {
    updatePayload.startDate = toIsoDateString(payload.startDate);
  }

  if (payload.endDate !== undefined) {
    updatePayload.endDate = toIsoDateString(payload.endDate);
  }

  await voucherRef.set(updatePayload, { merge: true });

  const doc = await voucherRef.get();
  return serializeDocument(doc);
}

async function previewVoucherApplication(input) {
  const voucher = await getVoucherByCode(input.code);
  ensureVoucherIsUsable(voucher, input);

  return {
    voucher,
    pricing: computeVoucherBenefit(voucher, input)
  };
}

module.exports = {
  createVoucher,
  getVoucherByCode,
  getVoucherById,
  listVouchers,
  previewVoucherApplication,
  updateVoucher
};
