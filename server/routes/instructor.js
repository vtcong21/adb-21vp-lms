import express from "express";
import { isAdmin, isAdminOrInstructor, isInstructor, requireSignin } from "../middlewares";


const router = express.Router();

// controllers
import {
    getInstructorProfile,
    updateInstructorInfo,
    getMonthlyRevenueForInstructor,
    getAunnualRevenueForInstructor,
    sendTaxForm,
    updateInstructorPaymentCard
} from "../controllers/instructor";

router.get("/instructor/profile",
    getInstructorProfile);
router.get("/instructor/revenue/monthly",
    // requireSignin,
    // isAdminOrInstructor,
    getMonthlyRevenueForInstructor);
router.get("/instructor/profile/annual",
    // requireSignin,
    // isAdminOrInstructor,
    getAunnualRevenueForInstructor);
router.put("/instructor/profile",
    // requireSignin,
    // isInstructor,
    updateInstructorInfo);
router.post("/instructor/tax-form",
    // requireSignin,
    // isInstructor,
    sendTaxForm);
router.post("/instructor/payment-card",
    // requireSignin,
    // isInstructor,
    updateInstructorPaymentCard);
    


export default router;

