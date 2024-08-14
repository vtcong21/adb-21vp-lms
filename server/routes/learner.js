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
  viewOrderDetails
} from "../controllers/learner";

router.post("/learner/cart/course", addCourseToCart);
router.delete("/learner/cart/course", removeCourseFromCart);
router.get("/learner/cart", getCartDetails);
router.post("/learner/order", makeOrder);
router.get("/learner/order", viewOrders);
router.get("/learner/order/:orderId", viewOrderDetails);


export default router;

