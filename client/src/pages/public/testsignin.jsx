import { setRole, updateUserInfo } from "~/redux/features/userSlice";
import { useDispatch } from "react-redux";
import { useNavigate } from "react-router-dom";
import { Form, Input, Button, message } from "antd";
import OnlineService from "~/services/online";

import useCookie from "~/hooks/useCookie";
const SignInPage = () => {
  const [cookie, setCookie] = useCookie("token", "");
  const [password, setPassword] = useCookie("password", "");
  const dispatch = useDispatch();
  const navigate = useNavigate();

  const onFinish = async (values) => {
    await OnlineService.dangnhap({
      matk: values.matk, //"QTV0001"
      matkhau: values.matkhau, //"21126054",
    })
      .then((res) => {
        setCookie(res.accessToken);
        setPassword(values.matkhau);
        dispatch(setRole(res.info.ROLE));
        dispatch(updateUserInfo(res.info));
        navigate("/");
      })
      .catch((err) => {
        // message.error("Sai tài khoản hoặc mật khẩu");
      });
  };
  const onFinishFailed = (errorInfo) => {
    console.log("Failed:", errorInfo);
  };
  return (
    <div className=" w-full h-[100vh] flex">
      <div className="w-[400px] h-[500px]  drop-shadow-md bg-gray-200 flex flex-col justify-center mx-auto  my-auto items-center">
        <Form
          name="signin_form"
          initialValues={{ remember: true }}
          onFinish={onFinish}
          onFinishFailed={onFinishFailed}
        >
          <Form.Item label="matk" name="matk">
            <Input />
          </Form.Item>

          <Form.Item
            label="Mật khẩu"
            name="matkhau"
            rules={[{ required: true, message: "Vui lòng nhập mật khẩu!" }]}
          >
            <Input.Password />
          </Form.Item>
          <Form.Item>
            <button
              htmlFor="submit"
              className=" bg-blue-400 h-9 w-24 rounded-lg"
            >
              Đăng nhập
            </button>
          </Form.Item>
        </Form>
      </div>
    </div>
  );
};
export default SignInPage;
