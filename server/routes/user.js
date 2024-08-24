import express from "express";
import { requireSignin } from "../middlewares/index.js";

const router = express.Router();

// controllers
import {
    getUserProfile,
    updateUserInfo,
    
} from "../controllers/user.js";

router.get("/user/profile",
    // requireSignin,
    getUserProfile);
router.put("/user/profile",
    // requireSignin,
    updateUserInfo);


export default router;

