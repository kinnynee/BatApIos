const {
  createUser,
  getUserById,
  listUsers,
  updateUser
} = require("../services/users.service");
const { sendError, sendJson } = require("../utils/http");
const { requireFields } = require("../utils/validation");

async function handleUsersRoute(req, res, pathname, query, body) {
  const pathParts = pathname.split("/").filter(Boolean);
  if (pathParts[0] !== "api" || pathParts[1] !== "users") {
    return false;
  }

  const id = pathParts[2];

  if (req.method === "GET" && !id) {
    const users = await listUsers({
      role: query.get("role"),
      status: query.get("status")
    });
    sendJson(res, 200, { success: true, data: users });
    return true;
  }

  if (req.method === "GET" && id) {
    const user = await getUserById(id);
    if (!user) {
      sendError(res, 404, "User not found");
      return true;
    }

    sendJson(res, 200, { success: true, data: user });
    return true;
  }

  if (req.method === "POST" && !id) {
    const validation = requireFields(body, ["id", "fullName", "email"]);
    if (!validation.valid) {
      sendError(res, 400, "Missing required user fields", validation.missingFields);
      return true;
    }

    const user = await createUser(body.id, {
      fullName: body.fullName,
      email: body.email,
      phone: body.phone ?? "",
      avatarUrl: body.avatarUrl ?? "",
      role: body.role ?? "user",
      status: body.status ?? "active"
    });
    sendJson(res, 201, { success: true, data: user });
    return true;
  }

  if (req.method === "PATCH" && id) {
    const user = await updateUser(id, body);
    if (!user) {
      sendError(res, 404, "User not found");
      return true;
    }

    sendJson(res, 200, { success: true, data: user });
    return true;
  }

  return false;
}

module.exports = {
  handleUsersRoute
};
