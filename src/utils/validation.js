function requireFields(payload, fields) {
  const missingFields = fields.filter((field) => {
    const value = payload[field];
    return value === undefined || value === null || value === "";
  });

  return {
    valid: missingFields.length === 0,
    missingFields
  };
}

function isPositiveNumber(value) {
  return typeof value === "number" && Number.isFinite(value) && value >= 0;
}

function isTimeRangeValid(startTime, endTime) {
  return typeof startTime === "string" &&
    typeof endTime === "string" &&
    startTime < endTime;
}

module.exports = {
  isPositiveNumber,
  isTimeRangeValid,
  requireFields
};
