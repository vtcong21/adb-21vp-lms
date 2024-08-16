import express from "express";

const router = express.Router();

// middleware
// import { requireSignin } from "../middlewares";

// controllers
import {
    createCoupon,
    getAllCoupons
} from "../controllers/coupon";

router.post("/coupon", createCoupon);
router.get("/coupon", getAllCoupons);

export default router;

