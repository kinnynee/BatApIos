const {
  checkInBooking,
  confirmAdminPayment,
  createAdminCourt,
  getAdminOverview,
  listAdminBookings,
  listAdminCourts,
  listAdminPayments,
  listAdminUsers,
  updateAdminCourt,
  updateAdminUser
} = require("../services/admin.service");
const { sendError, sendJson } = require("../utils/http");
const { isPositiveNumber, requireFields } = require("../utils/validation");

async function handleAdminRoute(req, res, pathname, query, body) {
  const pathParts = pathname.split("/").filter(Boolean);
  if (pathParts[0] !== "api" || pathParts[1] !== "admin") {
    return false;
  }

  if (req.method === "GET" && pathParts[2] === "overview") {
    const overview = await getAdminOverview();
    sendJson(res, 200, { success: true, data: overview });
    return true;
  }

  if (pathParts[2] === "users") {
    const userId = pathParts[3];

    if (req.method === "GET" && !userId) {
      const users = await listAdminUsers({
        role: query.get("role"),
        status: query.get("status")
      });
      sendJson(res, 200, { success: true, data: users });
      return true;
    }

    if (req.method === "PATCH" && userId) {
      const user = await updateAdminUser(userId, body);
      if (!user) {
        sendError(res, 404, "User not found");
        return true;
      }

      sendJson(res, 200, { success: true, data: user });
      return true;
    }
  }

  if (pathParts[2] === "courts") {
    const courtId = pathParts[3];

    if (req.method === "GET" && !courtId) {
      const courts = await listAdminCourts({
        courtType: query.get("courtType"),
        status: query.get("status")
      });
      sendJson(res, 200, { success: true, data: courts });
      return true;
    }

    if (req.method === "POST" && !courtId) {
      const validation = requireFields(body, ["id", "name", "courtType", "status"]);
      if (!validation.valid) {
        sendError(res, 400, "Missing required court fields", validation.missingFields);
        return true;
      }

      if (
        body.pricePerHour !== undefined &&
        !isPositiveNumber(body.pricePerHour)
      ) {
        sendError(res, 400, "pricePerHour must be a non-negative number");
        return true;
      }

      const court = await createAdminCourt(body.id, body);
      sendJson(res, 201, { success: true, data: court });
      return true;
    }

    if (req.method === "PATCH" && courtId) {
      if (
        body.pricePerHour !== undefined &&
        !isPositiveNumber(body.pricePerHour)
      ) {
        sendError(res, 400, "pricePerHour must be a non-negative number");
        return true;
      }

      const court = await updateAdminCourt(courtId, body);
      if (!court) {
        sendError(res, 404, "Court not found");
        return true;
      }

      sendJson(res, 200, { success: true, data: court });
      return true;
    }
  }

  if (pathParts[2] === "bookings") {
    const bookingId = pathParts[3];
    const action = pathParts[4];

    if (req.method === "GET" && !bookingId) {
      const bookings = await listAdminBookings({
        userId: query.get("userId"),
        courtId: query.get("courtId"),
        bookingDate: query.get("bookingDate"),
        bookingStatus: query.get("bookingStatus")
      });
      sendJson(res, 200, { success: true, data: bookings });
      return true;
    }

    if (req.method === "POST" && bookingId && action === "check-in") {
      const validation = requireFields(body, ["checkedInBy"]);
      if (!validation.valid) {
        sendError(res, 400, "Missing checkedInBy for check-in", validation.missingFields);
        return true;
      }

      const booking = await checkInBooking(bookingId, body);
      if (!booking) {
        sendError(res, 404, "Booking not found");
        return true;
      }

      sendJson(res, 200, { success: true, data: booking });
      return true;
    }
  }

  if (pathParts[2] === "payments") {
    const paymentId = pathParts[3];
    const action = pathParts[4];

    if (req.method === "GET" && !paymentId) {
      const payments = await listAdminPayments({
        userId: query.get("userId"),
        bookingId: query.get("bookingId"),
        paymentStatus: query.get("paymentStatus")
      });
      sendJson(res, 200, { success: true, data: payments });
      return true;
    }

    if (req.method === "POST" && paymentId && action === "confirm") {
      const validation = requireFields(body, ["confirmedBy"]);
      if (!validation.valid) {
        sendError(res, 400, "Missing confirmedBy for payment confirmation", validation.missingFields);
        return true;
      }

      const payment = await confirmAdminPayment(paymentId, body);
      if (!payment) {
        sendError(res, 404, "Payment not found");
        return true;
      }

      sendJson(res, 200, { success: true, data: payment });
      return true;
    }
  }

  return false;
}

module.exports = {
  handleAdminRoute
};
