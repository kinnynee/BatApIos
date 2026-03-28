const {
  createVoucher,
  getVoucherById,
  listVouchers,
  previewVoucherApplication,
  updateVoucher
} = require("../services/vouchers.service");
const { sendError, sendJson } = require("../utils/http");
const { isPositiveNumber, requireFields } = require("../utils/validation");

function isVoucherValueValid(body) {
  if (body.discountType === "free_item") {
    return true;
  }

  return isPositiveNumber(body.discountValue);
}

async function handleVouchersRoute(req, res, pathname, query, body) {
  const pathParts = pathname.split("/").filter(Boolean);
  if (pathParts[0] !== "api" || pathParts[1] !== "vouchers") {
    return false;
  }

  const id = pathParts[2];

  if (req.method === "POST" && id === "apply") {
    const validation = requireFields(body, ["code", "bookingAmount"]);
    if (!validation.valid) {
      sendError(res, 400, "Missing required voucher apply fields", validation.missingFields);
      return true;
    }

    if (!isPositiveNumber(body.bookingAmount)) {
      sendError(res, 400, "bookingAmount must be a non-negative number");
      return true;
    }

    const result = await previewVoucherApplication({
      code: body.code,
      bookingAmount: body.bookingAmount,
      courtType: body.courtType ?? null
    });

    sendJson(res, 200, { success: true, data: result });
    return true;
  }

  if (req.method === "GET" && !id) {
    const vouchers = await listVouchers({
      status: query.get("status"),
      code: query.get("code")
    });
    sendJson(res, 200, { success: true, data: vouchers });
    return true;
  }

  if (req.method === "GET" && id) {
    const voucher = await getVoucherById(id);
    if (!voucher) {
      sendError(res, 404, "Voucher not found");
      return true;
    }

    sendJson(res, 200, { success: true, data: voucher });
    return true;
  }

  if (req.method === "POST" && !id) {
    const validation = requireFields(body, ["id", "code", "name", "discountType", "status"]);
    if (!validation.valid) {
      sendError(res, 400, "Missing required voucher fields", validation.missingFields);
      return true;
    }

    if (!isVoucherValueValid(body)) {
      sendError(res, 400, "discountValue must be a non-negative number");
      return true;
    }

    const voucher = await createVoucher(body.id, body);
    sendJson(res, 201, { success: true, data: voucher });
    return true;
  }

  if (req.method === "PATCH" && id) {
    if (
      body.discountValue !== undefined &&
      body.discountType !== "free_item" &&
      !isPositiveNumber(body.discountValue)
    ) {
      sendError(res, 400, "discountValue must be a non-negative number");
      return true;
    }

    const voucher = await updateVoucher(id, body);
    if (!voucher) {
      sendError(res, 404, "Voucher not found");
      return true;
    }

    sendJson(res, 200, { success: true, data: voucher });
    return true;
  }

  return false;
}

module.exports = {
  handleVouchersRoute
};
