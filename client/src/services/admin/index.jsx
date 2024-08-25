import Axios from "../Axios";
import { message } from "antd";

const AdminService = {
  getMonthlyRevenueForInstructor: async ( instructorId, duration ) => {
    const res = await Axios.get(`/api/instructor/revenue/monthly`, { instructorId, duration });
    if (res.status == 400) {
      message.error(res.message || res.error);
    }
    return res;

  },
  getAnnualRevenueForInstructor: async ( instructorId, duration ) => {
    const res = await Axios.get(`/api/instructor/revenue/annual`, { instructorId, duration });
    if (res.status == 400) {
      message.error(res.message || res.error);
    }
    return res;

  },
  getDailyRevenueForCourse: async ( courseId, duration ) => {
    const res = await Axios.get(`/api/course/revenue/daily`, { courseId, duration });
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
  getTop50CoursesByRevenue: async () => {
    const res = await Axios.get(`/api/course/top-50`, {});
    if (res.status == 400) {
      message.error(res.message || res.error);
    }
    return res;

  },
};
export default AdminService;
