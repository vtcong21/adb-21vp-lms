import express from "express";
import formidable from "express-formidable";

const router = express.Router();

// // middleware
// import { requireSignin, isInstructor, isEnrolled } from "../middlewares";

// // controllers
import {
 getCourseByCategoryId,
 getCourseByName,
 getCourseById,
 changeStateOfCourse 
} from "../controllers/course";

router.get("/course/category", getCourseByCategoryId);
router.get("/course/name", getCourseByName);
router.get("/course/id", getCourseById);
router.put("/course/state", changeStateOfCourse);

export default router;

