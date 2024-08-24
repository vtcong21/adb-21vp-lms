import Axios from "../Axios";
import { message } from "antd";

const OnlineService = {
  login: async (data) => {
    const res = await Axios.post("/api/public/login", {
      userId: data.userId,
      password: data.password,
    });
    if (res && res.response) {
      if (res.response.status === 400) {
        message.error(res.response.data.error);
      }
    }
    return res;
  },
  getCoupons: async (isAvailable) => {
    const res = await Axios.get("/api/coupon", {
      isAvailable
    });
    if (res && res.response) {
      if (res.response.status === 400) {
        message.error(res.response.data.error);
      }

    }
    return res;
  }
  ,
  getTopHotCategories: async () => {
    const res = await Axios.get("/api/course/topHotCategories", {});
    if (res && res.response) {
      if (res.response.status === 400) {
        message.error(res.response.data.error);
      }
    }
    return res;
  },

  getCourseByName: async (courseName, courseState) => {
    const res = await Axios.get("/api/course/name", {
      courseName,
      courseState,
    });
    if (res && res.response) {
      if (res.response.status === 400) {
        message.error(res.response.data.error);
      }
    }
    return res;
  },

  getCourseById: async (courseId) => {
    const res = await Axios.get("/api/course/id", { courseId });
    if (res && res.response) {
      if (res.response.status === 400) {
        message.error(res.response.data.error);
      }
    }
    return res;
  },

};
export default OnlineService;
