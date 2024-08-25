import Axios from "../Axios";
import { message } from "antd";

const AdminService = {
  getMonthlyRevenueForInstructor: async ( userId, duration ) => {
    const res = await Axios.get(`/api/instructor/revenue/monthly`, { userId, duration });
    if (res.status == 400) {
      message.error(res.message || res.error);
    }
    return res;

  },
  getAnnualRevenueForInstructor: async ( userId, duration ) => {
    const res = await Axios.get(`/api/instructor/revenue/annual`, { userId, duration });
    if (res.status == 400) {
      message.error(res.message || res.error);
    }
    return res;

  },
  getMonthlyRevenueForCourse: async ( courseId, duration ) => {
    const res = await Axios.get(`/api/course/revenue/monthly`, { courseId, duration });
    if (res.status == 400) {
      message.error(res.message || res.error);
    }
    return res;

  },
  getAnnualRevenueForCourse: async ( courseId, duration ) => {
    const res = await Axios.get(`/api/course/revenue/annual`, { courseId, duration });
    if (res.status == 400) {
      message.error(res.message || res.error);
    }
    return res;
  },
  getTop50CoursesByRevenue: async () => {
    const res = await Axios.get(`/api/course/top-50`, {});
    if (res.status == 400) {
      message.error(res.message || res.error);
    }
    return res;

  },
  getOwnCourses: async ( instructorId ) => {
    const res = await Axios.get(`/api/course/instructor-course`, { instructorId });
    if (res.status == 400) {
      message.error(res.message || res.error);
    }
    return res;
  },
  getLearnerInCourse: async ( courseId ) => {
    const res = await Axios.get(`/api/course/learners`, { courseId });
    if (res.status == 400) {
      message.error(res.message || res.error);
    }
    return res;
  },
};
export default AdminService;
