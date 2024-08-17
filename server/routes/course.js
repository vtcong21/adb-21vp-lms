import express from "express";
import formidable from "express-formidable";
import { isAdmin, isAdminOrInstructor, isInstructor, requireSignin } from "../middlewares";

const router = express.Router();

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

router.get("/course/category",
    getCourseByCategoryId);
router.get("/course/name",
    getCourseByName);
router.get("/course/id",
    getCourseById);
router.put("/course/state",
    // requireSignin,
    // isAdminOrInstructor,
    changeStateOfCourse);
router.get("/course/revenue/daily",
    // requireSignin,
    // isAdminOrInstructor,
    getDailyRevenueForCourse);
router.get("/course/revenue/monthly",
    // requireSignin,
    // isAdminOrInstructor,
    getMonthlyRevenueForCourse);
router.get("/course/profile/annual",
    // requireSignin,
    // isAdminOrInstructor,
    getAunnualRevenueOfACourse);
router.get("/course/top-50",
    // requireSignin,
    // isAdmin,
    getTop50CoursesByRevenue);
router.get("/course/instructor-course",
    // requireSignin,
    // isInstructor,
    getOwnCourses);
router.post("/course",
    // requireSignin,
    // isInstructor,
    createCourse);
router.get("/course/admin-responses",
    // requireSignin,
    // isInstructor,
    getAdminResponseInACourse);
router.get("/course/learners",
    // requireSignin,
    // isInstructor,
    getLearnerInCourse);

export default router;

