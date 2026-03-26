const {
  createCourt,
  getCourtById,
  listCourts,
  updateCourt
} = require("../services/courts.service");
const { sendError, sendJson } = require("../utils/http");
const { isPositiveNumber, requireFields } = require("../utils/validation");

async function handleCourtsRoute(req, res, pathname, query, body) {
  const pathParts = pathname.split("/").filter(Boolean);
  if (pathParts[0] !== "api" || pathParts[1] !== "courts") {
    return false;
  }

  const id = pathParts[2];

  if (req.method === "GET" && !id) {
    const courts = await listCourts({
      courtType: query.get("courtType"),
      status: query.get("status")
    });
    sendJson(res, 200, { success: true, data: courts });
    return true;
  }

  if (req.method === "GET" && id) {
    const court = await getCourtById(id);
    if (!court) {
      sendError(res, 404, "Court not found");
      return true;
    }

    sendJson(res, 200, { success: true, data: court });
    return true;
  }

  if (req.method === "POST" && !id) {
    const validation = requireFields(body, [
      "id",
      "name",
      "courtType",
      "pricePerHour",
      "status"
    ]);
    if (!validation.valid) {
      sendError(res, 400, "Missing required court fields", validation.missingFields);
      return true;
    }

    if (!isPositiveNumber(body.pricePerHour)) {
      sendError(res, 400, "pricePerHour must be a non-negative number");
      return true;
    }

    const court = await createCourt(body.id, body);
    sendJson(res, 201, { success: true, data: court });
    return true;
  }

  if (req.method === "PATCH" && id) {
    if (
      body.pricePerHour !== undefined &&
      !isPositiveNumber(body.pricePerHour)
    ) {
      sendError(res, 400, "pricePerHour must be a non-negative number");
      return true;
    }

    const court = await updateCourt(id, body);
    if (!court) {
      sendError(res, 404, "Court not found");
      return true;
    }

    sendJson(res, 200, { success: true, data: court });
    return true;
  }

  return false;
}

module.exports = {
  handleCourtsRoute
};
