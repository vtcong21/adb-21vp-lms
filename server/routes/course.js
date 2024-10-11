import express from "express";
import formidable from "express-formidable";
import {
  isAdmin,
  isAdminOrInstructor,
  isInstructor,
  requireSignin,
} from "../middlewares/index.js";

const router = express.Router();

// // controllers
import {
  getCourseByCategoryId,
  getCourseByName,
  getCourseById,
  changeStateOfCourse,
  getMonthlyRevenueForCourse,
  getDailyRevenueForCourse,
  getAnnualRevenueOfACourse,
  getTop50CoursesByRevenue,
  getOwnCourses,
  createCourse,
  createCourseObjective,
  createCourseRequirement,
  createCourseSection,
  getAdminResponseInACourse,
  getLearnerInCourse,
  getTopHotCategories,
} from "../controllers/course.js";

router.get("/course/category", getCourseByCategoryId);
router.get("/course/name", getCourseByName);
router.get("/course/id", getCourseById);
router.get("/course/topHotCategories", getTopHotCategories);
router.put(
  "/course/state",
  // requireSignin,
  // isAdminOrInstructor,
  changeStateOfCourse
);
router.get(
  "/course/revenue/daily",
  // requireSignin,
  // isAdminOrInstructor,
  getDailyRevenueForCourse
);
router.get(
  "/course/revenue/monthly",
  // requireSignin,
  // isAdminOrInstructor,
  getMonthlyRevenueForCourse
);
router.get(
  "/course/revenue/annual",
  // requireSignin,
  // isAdminOrInstructor,
  getAnnualRevenueOfACourse
);
router.get(
  "/course/top-50",
  // requireSignin,
  // isAdmin,
  getTop50CoursesByRevenue
);
router.get(
  "/course/instructor-course",
  // requireSignin,
  // isInstructor,
  getOwnCourses
);
router.post(
  "/course",
  // requireSignin,
  // isInstructor,
  createCourse
);
router.post(
  "/course/objective",
  // requireSignin,
  // isInstructor,
  createCourseObjective
);
router.post(
  "/course/requirement",
  // requireSignin,
  // isInstructor,
  createCourseRequirement
);
router.post(
  "/course/section",
  // requireSignin,
  // isInstructor,
  createCourseSection
);
router
router.get(
  "/course/admin-responses",
  // requireSignin,
  // isInstructor,
  getAdminResponseInACourse
);
router.get(
  "/course/learners",
  // requireSignin,
  // isInstructor,
  getLearnerInCourse
);

export default router;
