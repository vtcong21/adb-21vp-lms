import { setRole, updateUserInfo } from "~/redux/features/userSlice";
import { useDispatch } from "react-redux";
import { useNavigate } from "react-router-dom";
import { Form, Input, Button, message } from "antd";
import PublicService from "~/services/public";
import "../../assets/styles/signin.scss";

import useCookie from "~/hooks/useCookie";
const SignInPage = () => {
  const [cookie, setCookie] = useCookie("token", "");
  const [password, setPassword] = useCookie("password", "");
  const dispatch = useDispatch();
  const navigate = useNavigate();

  const onFinish = async (values) => {
    
    await PublicService.login({
      userId: values.userId, //"QTV0001"
      password: values.password, //"21126054",
    })
      .then((res) => {
        
        setCookie(res.token);
        setPassword(values.password);
        dispatch(setRole(res.role));
        dispatch(updateUserInfo(res));
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

    <div className="login-page">
      <div className="login-box">
        <div className="illustration-wrapper">
          <img src="https://mixkit.imgix.net/art/preview/mixkit-left-handed-man-sitting-at-a-table-writing-in-a-notebook-27-original-large.png?q=80&auto=format%2Ccompress&h=700" alt="Login" />
        </div>
        <Form
          name="login-form"
          initialValues={{ remember: true }}
          onFinish={onFinish}
          onFinishFailed={onFinishFailed}
        >
          <p className="form-title">Welcome back</p>
          <p>Sing in Udemy.</p>
          <Form.Item
            name="userId"
            rules={[{ required: true, message: 'Vui lòng nhập mã tài khoản / số điện thoại!' }]}
          >
            <Input
              placeholder="Mã tài khoản / Số điện thoại"
            />
          </Form.Item>

          <Form.Item
            name="password"
            rules={[{ required: true, message: 'Vui lòng nhập mật khẩu!' }]}
          >
            <Input.Password
              placeholder="Mật khẩu"
            />
          </Form.Item>



          <Form.Item>
            <Button type="primary" htmlType="submit" className="font-semibold login-form-button">
              Sign in
            </Button>
          </Form.Item>

          {/* <p className="mb-0 mt-2 pt-1 text-sm font-semibold text-center">
            Chưa có tài khoản?{" "}
            <a
              onClick={() => navigate("/signup")}
              className="text-blue transition duration-150 ease-in-out hover:text-danger-600 focus:text-danger-600 active:text-danger-700"
            >
              Đăng ký
            </a>
          </p> */}

        </Form>

      </div>
    </div>
  );
};


export default SignInPage;
