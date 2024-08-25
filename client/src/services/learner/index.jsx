import Axios from "../Axios";
import { message } from "antd";

const LearnerService = {
  getCartDetails: async (userId) => {
    const res = await Axios.get(`/api/learner/cart`, { userId });
    if (res.status == 400) {
      message.error(res.message || res.error);
    }
    return res;

  },
  addCourseToCart: async (userId, courseId) => {
    const res = await Axios.post("/api/learner/course", { userId, courseId });
    if (res.status == 400) {
      message.error(res.message || res.error);
    }
    return res;
  },
  removeCourseFromCart: async (userId, courseId) => {
    const res = await Axios.delete("/api/learner/course", {
      userId, courseId
    });
    if (res.status == 400) {
      message.error(res.message || res.error);
    }
    return res;
  },
  makeOrder: async (userId, paymentCardNumber, couponCode) => {
    const res = await Axios.post("/api/learner/order", { userId, paymentCardNumber, couponCode });
    if (res.status == 400) {
      message.error(res.message || res.error);
    }
    return res;
  },
  viewOrders: async () => {
    const res = await Axios.get("/api/learner/order", { userId });
    if (res.status == 400) {
      message.error(res.message || res.error);
    }
    return res;
  },
  viewOrderDetails: async (userId, orderId) => {
    const res = await Axios.get("/api/learner/order/details", { userId, orderId });
    if (res.status == 400) {
      message.error(res.message || res.error);
    }
    return res;
  },
  completeLesson: async (userId, courseId, sectionId, lessonId) => {
    const res = await Axios.put(`/api/learner/lesson/complete`, { userId, courseId, sectionId, lessonId });
    if (res.status == 400) {
      message.error(res.message || res.error);
    }
    return res;
  },
  getLearnerProgressInCourse: async (learnerId, courseId) => {
    const res = await Axios.get(`/api/learner/course-progress`, { learnerId, courseId });

    if (res.status == 400) {
      message.error(res.message || res.error);
    }
    return res;
  },
};

export default LearnerService;
