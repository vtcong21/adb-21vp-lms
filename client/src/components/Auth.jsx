import React from "react";
import { useDispatch, useSelector } from "react-redux";
import Public from "~/services/public";
import Axios from "~/services/axios.config";
import GetCookie from "~/hooks/GetCookie";
import {
  setRole,
  updateUserInfo,
  deleteRole,
} from "~/redux/features/userSlice";
const Auth = () => {
  const state = useSelector((state) => state.stateData);
  const user = useSelector((state) => state.user);
  console.log(user);
  const dispatch = useDispatch();
  const pass = GetCookie("password");
  React.useEffect(() => {
    Axios.post("/api/public/login", {
      userId: user.userId,
      matkhau: pass,
    })
      .then((resp) => {
        dispatch(setRole(resp.data.info.role));
        dispatch(updateUserInfo(resp.data.info));
      })
      .catch((error) => {
        dispatch(deleteRole());
        console.log("err", error);
      });
  }, [state]);
  return <></>;
};

export default Auth;
