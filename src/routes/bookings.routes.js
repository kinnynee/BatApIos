const {
  createBooking,
  getBookingById,
  listBookings,
  updateBooking
} = require("../services/bookings.service");
const { sendError, sendJson } = require("../utils/http");
const {
  isPositiveNumber,
  isTimeRangeValid,
  requireFields
} = require("../utils/validation");

async function handleBookingsRoute(req, res, pathname, query, body) {
  const pathParts = pathname.split("/").filter(Boolean);
  if (pathParts[0] !== "api" || pathParts[1] !== "bookings") {
    return false;
  }

  const id = pathParts[2];

  if (req.method === "GET" && !id) {
    const bookings = await listBookings({
      userId: query.get("userId"),
      courtId: query.get("courtId"),
      bookingDate: query.get("bookingDate"),
      bookingStatus: query.get("bookingStatus")
    });
    sendJson(res, 200, { success: true, data: bookings });
    return true;
  }

  if (req.method === "GET" && id) {
    const booking = await getBookingById(id);
    if (!booking) {
      sendError(res, 404, "Booking not found");
      return true;
    }

    sendJson(res, 200, { success: true, data: booking });
    return true;
  }

  if (req.method === "POST" && !id) {
    const validation = requireFields(body, [
      "id",
      "userId",
      "courtId",
      "bookingCode",
      "bookingDate",
      "startTime",
      "endTime",
      "durationHours",
      "bookingStatus",
      "paymentStatus",
      "createdBy"
    ]);
    if (!validation.valid) {
      sendError(res, 400, "Missing required booking fields", validation.missingFields);
      return true;
    }

    if (!isTimeRangeValid(body.startTime, body.endTime)) {
      sendError(res, 400, "startTime must be earlier than endTime");
      return true;
    }

    if (
      !isPositiveNumber(body.durationHours) ||
      (body.pricePerHour !== undefined && !isPositiveNumber(body.pricePerHour))
    ) {
      sendError(res, 400, "Booking price and duration fields must be non-negative numbers");
      return true;
    }

    const booking = await createBooking(body.id, body);
    sendJson(res, 201, { success: true, data: booking });
    return true;
  }

  if (req.method === "PATCH" && id) {
    if (
      body.startTime !== undefined &&
      body.endTime !== undefined &&
      !isTimeRangeValid(body.startTime, body.endTime)
    ) {
      sendError(res, 400, "startTime must be earlier than endTime");
      return true;
    }

    const numericFields = ["durationHours", "pricePerHour"];
    for (const field of numericFields) {
      if (body[field] !== undefined && !isPositiveNumber(body[field])) {
        sendError(res, 400, `${field} must be a non-negative number`);
        return true;
      }
    }

    const booking = await updateBooking(id, body);
    if (!booking) {
      sendError(res, 404, "Booking not found");
      return true;
    }

    sendJson(res, 200, { success: true, data: booking });
    return true;
  }

  return false;
}

module.exports = {
  handleBookingsRoute
};
