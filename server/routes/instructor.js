import express from "express";

const router = express.Router();

// middleware
// import { requireSignin } from "../middlewares";

// controllers
import {
    getInstructorProfile,
    updateInstructorInfo,
    getMonthlyRevenueForInstructor,
    getAunnualRevenueForInstructor
} from "../controllers/instructor";

router.get("/instructor/profile", getInstructorProfile);
router.get("/instructor/revenue/monthly", getMonthlyRevenueForInstructor);
router.get("/instructor/profile/annual", getAunnualRevenueForInstructor);
router.put("/instructor/profile", updateInstructorInfo);


export default router;

