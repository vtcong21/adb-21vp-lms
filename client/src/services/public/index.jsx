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

};
export default OnlineService;
