const { getDb } = require("../config/firebase");
const { listUsers, updateUser } = require("./users.service");
const { createCourt, listCourts, updateCourt } = require("./courts.service");
const { getBookingById, listBookings, updateBooking } = require("./bookings.service");

async function getAdminOverview() {
  const db = getDb();
  const [usersSnapshot, courtsSnapshot, bookingsSnapshot, paymentsSnapshot] =
    await Promise.all([
      db.collection("users").get(),
      db.collection("courts").get(),
      db.collection("bookings").get(),
      db.collection("payments").get()
    ]);

  const bookingStats = {
    pending: 0,
    confirmed: 0,
    checked_in: 0,
    completed: 0,
    cancelled: 0
  };

  let totalRevenue = 0;

  bookingsSnapshot.forEach((doc) => {
    const data = doc.data();
    const status = data.bookingStatus;
    if (bookingStats[status] !== undefined) {
      bookingStats[status] += 1;
    }
  });

  paymentsSnapshot.forEach((doc) => {
    const data = doc.data();
    if (data.paymentStatus === "paid") {
      totalRevenue += Number(data.amount || 0);
    }
  });

  return {
    totalUsers: usersSnapshot.size,
    totalCourts: courtsSnapshot.size,
    totalBookings: bookingsSnapshot.size,
    totalPayments: paymentsSnapshot.size,
    totalRevenue,
    bookingStats
  };
}

async function listAdminUsers(filters) {
  return listUsers(filters);
}

async function updateAdminUser(userId, payload) {
  return updateUser(userId, payload);
}

async function listAdminCourts(filters) {
  return listCourts(filters);
}

async function createAdminCourt(courtId, payload) {
  return createCourt(courtId, payload);
}

async function updateAdminCourt(courtId, payload) {
  return updateCourt(courtId, payload);
}

async function listAdminBookings(filters) {
  return listBookings(filters);
}

async function checkInBooking(bookingId, payload) {
  const booking = await getBookingById(bookingId);
  if (!booking) {
    return null;
  }

  if (booking.bookingStatus === "cancelled") {
    const error = new Error("Cancelled booking cannot be checked in");
    error.statusCode = 400;
    throw error;
  }

  return updateBooking(bookingId, {
    bookingStatus: "checked_in",
    checkInAt: new Date().toISOString(),
    checkedInBy: payload.checkedInBy,
    checkInNote: payload.checkInNote ?? ""
  });
}

module.exports = {
  checkInBooking,
  createAdminCourt,
  getAdminOverview,
  listAdminBookings,
  listAdminCourts,
  listAdminUsers,
  updateAdminCourt,
  updateAdminUser
};
