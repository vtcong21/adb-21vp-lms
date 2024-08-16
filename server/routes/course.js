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
 changeStateOfCourse,
 getMonthlyRevenueForCourse,
 getDailyRevenueForCourse,
 getAunnualRevenueOfACourse,
 getTop50CoursesByRevenue,
 getOwnCourses,
 createCourse,
 getAdminResponseInACourse,
 getLearnerInCourse,
} from "../controllers/course";

router.get("/course/category", getCourseByCategoryId);
router.get("/course/name", getCourseByName);
router.get("/course/id", getCourseById);
router.put("/course/state", changeStateOfCourse);
router.get("/course/revenue/daily", getDailyRevenueForCourse);
router.get("/course/revenue/monthly", getMonthlyRevenueForCourse);
router.get("/course/profile/annual", getAunnualRevenueOfACourse);
router.get("/course/top-50", getTop50CoursesByRevenue);
router.get("/course/instructor-course", getOwnCourses);
router.post("/course", createCourse);
router.get("/course/admin-responses", getAdminResponseInACourse);
router.get("/course/learners", getLearnerInCourse);

export default router;

