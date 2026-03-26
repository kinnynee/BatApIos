const { admin } = require("../config/firebase");

function isTimestamp(value) {
  return (
    value &&
    typeof value === "object" &&
    typeof value.toDate === "function" &&
    typeof value.toMillis === "function"
  );
}

function serializeValue(value) {
  if (value === null || value === undefined) {
    return value;
  }

  if (isTimestamp(value)) {
    return value.toDate().toISOString();
  }

  if (Array.isArray(value)) {
    return value.map(serializeValue);
  }

  if (typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value).map(([key, item]) => [key, serializeValue(item)])
    );
  }

  return value;
}

function serializeDocument(doc) {
  return {
    id: doc.id,
    ...serializeValue(doc.data())
  };
}

function buildTimestampFields(isCreate = false) {
  const now = admin.firestore.FieldValue.serverTimestamp();
  if (isCreate) {
    return {
      createdAt: now,
      updatedAt: now
    };
  }

  return {
    updatedAt: now
  };
}

module.exports = {
  buildTimestampFields,
  serializeDocument,
  serializeValue
};
