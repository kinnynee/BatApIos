const {
  getProfile,
  loginWithEmailPassword,
  syncAuthUser
} = require("../services/auth.service");
const { sendError, sendJson } = require("../utils/http");
const { requireFields } = require("../utils/validation");

async function handleAuthRoute(req, res, pathname, _query, body) {
  const pathParts = pathname.split("/").filter(Boolean);
  if (pathParts[0] !== "api" || pathParts[1] !== "auth") {
    return false;
  }

  if (req.method === "POST" && pathParts[2] === "sync-user") {
    const validation = requireFields(body, ["uid", "email"]);
    if (!validation.valid) {
      sendError(res, 400, "Missing required auth sync fields", validation.missingFields);
      return true;
    }

    const user = await syncAuthUser(body);
    sendJson(res, 200, {
      success: true,
      data: user
    });
    return true;
  }

  if (req.method === "POST" && pathParts[2] === "login") {
    const validation = requireFields(body, ["email", "password"]);
    if (!validation.valid) {
      sendError(res, 400, "Missing required login fields", validation.missingFields);
      return true;
    }

    const loginResult = await loginWithEmailPassword(body);
    sendJson(res, 200, {
      success: true,
      data: loginResult
    });
    return true;
  }

  if (req.method === "GET" && pathParts[2] === "profile" && pathParts[3]) {
    const user = await getProfile(pathParts[3]);
    if (!user) {
      sendError(res, 404, "User profile not found");
      return true;
    }

    sendJson(res, 200, {
      success: true,
      data: user
    });
    return true;
  }

  return false;
}

module.exports = {
  handleAuthRoute
};
