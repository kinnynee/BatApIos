const {
  createUser,
  getUserById,
  updateUser
} = require("./users.service");
const { getEnv, loadEnvFile } = require("../config/env");

function getAdminEmails() {
  const raw = process.env.ADMIN_EMAILS || "";
  return new Set(
    raw
      .split(",")
      .map((item) => item.trim().toLowerCase())
      .filter(Boolean)
  );
}

function resolveInitialRole(email) {
  const adminEmails = getAdminEmails();
  if (email && adminEmails.has(String(email).toLowerCase())) {
    return "admin";
  }

  return "user";
}

async function syncAuthUser(payload) {
  const existingUser = await getUserById(payload.uid);

  if (existingUser) {
    const updatedUser = await updateUser(payload.uid, {
      fullName: payload.fullName ?? existingUser.fullName ?? "",
      email: payload.email ?? existingUser.email ?? "",
      phone: payload.phone ?? existingUser.phone ?? "",
      avatarUrl: payload.avatarUrl ?? existingUser.avatarUrl ?? "",
      role: existingUser.role || "user",
      status: existingUser.status || "active"
    });

    return updatedUser;
  }

  return createUser(payload.uid, {
    fullName: payload.fullName ?? "",
    email: payload.email ?? "",
    phone: payload.phone ?? "",
    avatarUrl: payload.avatarUrl ?? "",
    role: resolveInitialRole(payload.email),
    status: "active"
  });
}

async function getProfile(uid) {
  return getUserById(uid);
}

async function loginWithEmailPassword(payload) {
  loadEnvFile();

  const apiKey = getEnv("FIREBASE_WEB_API_KEY");
  if (!apiKey) {
    const error = new Error("Missing FIREBASE_WEB_API_KEY in environment");
    error.statusCode = 500;
    throw error;
  }

  const response = await fetch(
    `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${apiKey}`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        email: payload.email,
        password: payload.password,
        returnSecureToken: true
      })
    }
  );

  const result = await response.json();

  if (!response.ok) {
    const message =
      result?.error?.message || "Unable to login with Firebase Auth";
    const error = new Error(message);
    error.statusCode = 401;
    error.details = result?.error || null;
    throw error;
  }

  const user = await syncAuthUser({
    uid: result.localId,
    fullName: result.displayName || payload.fullName || "",
    email: result.email,
    phone: payload.phone || "",
    avatarUrl: payload.avatarUrl || ""
  });

  return {
    uid: result.localId,
    email: result.email,
    idToken: result.idToken,
    refreshToken: result.refreshToken,
    expiresIn: result.expiresIn,
    registered: result.registered,
    profile: user
  };
}

module.exports = {
  getProfile,
  loginWithEmailPassword,
  syncAuthUser
};
