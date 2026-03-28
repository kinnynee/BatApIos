const http = require("http");
const { loadEnvFile } = require("./config/env");
const { handleUsersRoute } = require("./routes/users.routes");
const { handleAuthRoute } = require("./routes/auth.routes");
const { handleCourtsRoute } = require("./routes/courts.routes");
const { handleVouchersRoute } = require("./routes/vouchers.routes");
const { handleBookingsRoute } = require("./routes/bookings.routes");
const { handlePaymentsRoute } = require("./routes/payments.routes");
const { notFound, readJsonBody, sendError, sendJson } = require("./utils/http");

loadEnvFile();

function applyCorsHeaders(res) {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "GET,POST,PATCH,OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
}

async function routeRequest(req, res) {
  const url = new URL(req.url, "http://localhost");
  const pathname = url.pathname;
  const query = url.searchParams;

  applyCorsHeaders(res);

  if (req.method === "OPTIONS") {
    sendJson(res, 200, { success: true });
    return;
  }

  if (req.method === "GET" && pathname === "/health") {
    sendJson(res, 200, {
      success: true,
      message: "Backend API is healthy"
    });
    return;
  }

  let body = {};
  if (req.method === "POST" || req.method === "PATCH") {
    body = await readJsonBody(req);
  }

  const handlers = [
    () => handleAuthRoute(req, res, pathname, query, body),
    () => handleUsersRoute(req, res, pathname, query, body),
    () => handleCourtsRoute(req, res, pathname, query, body),
    () => handleVouchersRoute(req, res, pathname, query, body),
    () => handleBookingsRoute(req, res, pathname, query, body),
    () => handlePaymentsRoute(req, res, pathname, query, body)
  ];

  for (const handler of handlers) {
    const handled = await handler();
    if (handled) {
      return;
    }
  }

  notFound(res);
}

function createServer() {
  return http.createServer(async (req, res) => {
    try {
      await routeRequest(req, res);
    } catch (error) {
      sendError(
        res,
        error.statusCode || 500,
        error.message || "Unexpected server error",
        error.details || null
      );
    }
  });
}

module.exports = {
  createServer
};
