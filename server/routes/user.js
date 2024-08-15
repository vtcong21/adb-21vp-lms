import express from "express";

const router = express.Router();

// middleware
//import { requireSignin } from "../middlewares";

// controllers
import {
    getUserProfile,
    updateUserInfo,
    getAllCoupons
} from "../controllers/user";

router.get("/user/profile", getUserProfile);
router.put("/user/profile", updateUserInfo);
router.get("/coupon", getAllCoupons);

export default router;

