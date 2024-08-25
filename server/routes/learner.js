import express from "express";

const router = express.Router();

// middleware
//import { requireSignin } from "../middlewares";

// controllers
import {
  addCourseToCart,
  removeCourseFromCart,
  getCartDetails,
  makeOrder,
  viewOrders,
  viewOrderDetails,
  completeLesson,
  getLearnerProgressInCourse
} from "../controllers/learner";
import { isLearner, requireSignin } from "../middlewares";

router.post("/learner/cart/course", 
  // requireSignin,
  // isLearner,
  addCourseToCart);
router.delete("/learner/cart/course", 
  // requireSignin,
  // isLearner,
  removeCourseFromCart);
router.get("/learner/cart", 
  // requireSignin,
  // isLearner,
  getCartDetails);
router.post("/learner/order", 
  // requireSignin,
  // isLearner,
  makeOrder);
router.get("/learner/order", 
  // requireSignin,
  // isLearner,
  viewOrders);
router.get("/learner/order/details", 
  // requireSignin,
  // isLearner,
  viewOrderDetails);
router.put("/learner/lesson/complete", 
  // requireSignin,
  // isLearner,
  completeLesson);

router.get(
    "/learner/course-progress",
    // requireSignin,
    // isLearner,
    getLearnerProgressInCourse
);

export default router;

