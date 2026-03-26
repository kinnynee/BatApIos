const {
  createPayment,
  getPaymentById,
  listPayments,
  updatePayment
} = require("../services/payments.service");
const { sendError, sendJson } = require("../utils/http");
const { isPositiveNumber, requireFields } = require("../utils/validation");

async function handlePaymentsRoute(req, res, pathname, query, body) {
  const pathParts = pathname.split("/").filter(Boolean);
  if (pathParts[0] !== "api" || pathParts[1] !== "payments") {
    return false;
  }

  const id = pathParts[2];

  if (req.method === "GET" && !id) {
    const payments = await listPayments({
      userId: query.get("userId"),
      bookingId: query.get("bookingId"),
      paymentStatus: query.get("paymentStatus")
    });
    sendJson(res, 200, { success: true, data: payments });
    return true;
  }

  if (req.method === "GET" && id) {
    const payment = await getPaymentById(id);
    if (!payment) {
      sendError(res, 404, "Payment not found");
      return true;
    }

    sendJson(res, 200, { success: true, data: payment });
    return true;
  }

  if (req.method === "POST" && !id) {
    const validation = requireFields(body, [
      "id",
      "bookingId",
      "userId",
      "amount",
      "paymentMethod",
      "paymentStatus",
      "transactionCode"
    ]);
    if (!validation.valid) {
      sendError(res, 400, "Missing required payment fields", validation.missingFields);
      return true;
    }

    if (!isPositiveNumber(body.amount)) {
      sendError(res, 400, "amount must be a non-negative number");
      return true;
    }

    const payment = await createPayment(body.id, body);
    sendJson(res, 201, { success: true, data: payment });
    return true;
  }

  if (req.method === "PATCH" && id) {
    if (body.amount !== undefined && !isPositiveNumber(body.amount)) {
      sendError(res, 400, "amount must be a non-negative number");
      return true;
    }

    const payment = await updatePayment(id, body);
    if (!payment) {
      sendError(res, 404, "Payment not found");
      return true;
    }

    sendJson(res, 200, { success: true, data: payment });
    return true;
  }

  return false;
}

module.exports = {
  handlePaymentsRoute
};
