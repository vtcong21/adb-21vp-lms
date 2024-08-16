import express from "express";
import { isAdmin } from "../middlewares";
import { requireSignin } from "../middlewares";

const router = express.Router();

// controllers
import {
    createCoupon,
    getAllCoupons
} from "../controllers/coupon";

router.post("/coupon",
//    requireSignin,
//    isAdmin,
    createCoupon);
router.get("/coupon", getAllCoupons);

export default router;

