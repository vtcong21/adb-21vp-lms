import express from "express";
import { isAdmin } from "../middlewares/index.js";
import { requireSignin } from "../middlewares/index.js";

const router = express.Router();

// controllers
import {
    createCoupon,
    getAllCoupons
} from "../controllers/coupon.js";

router.post("/coupon",
//    requireSignin,
//    isAdmin,
    createCoupon);
router.get("/coupon", getAllCoupons);

export default router;

