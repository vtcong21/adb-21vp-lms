import express from "express";

const router = express.Router();

// middleware
// import { requireSignin } from "../middlewares";

// controllers
import {
    getInstructorProfile,
    updateInstructorInfo
} from "../controllers/instructor";

router.post("/instructor/progile", getInstructorProfile);
router.put("/instructor/profile", updateInstructorInfo);


export default router;

