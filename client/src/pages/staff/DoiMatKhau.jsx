import "../../assets/styles/staff.css";
import React from "react";
import { Form, Input, message, Space } from "antd";
import { useSelector } from "react-redux";
import { ButtonGreen } from "~/components/button";
import StaffService from "../../services/staff";


const ProfileNV = () => {
  const user = useSelector((state) => state.user);
  const { ROLE, HOTEN, PHAI, MANV, VITRICV } = user;
  const [form] = Form.useForm();
  const onFinish = async (values) => {
    const newInfo = {
      manv: MANV,
      matkhaucu: values.matkhaucu,
      matkhaumoi: values.matkhaumoi,
    };
    StaffService.doiMatKhau(newInfo).then((res) => {
      if (res && res.data) {
        if (res.data.status === 200) {
          message.success("Đổi mật khẩu thành công");
        }
        if (res.data.status === 404) {
          message.error("Mật khẩu cũ không đúng");
        }
      }
    });
  };
  const onFinishFailed = (errorInfo) => {
    console.log("Failed:", errorInfo);
  };
  return (
    <div
      className="bg-white w-[600px] h-fit pt-10 mx-10 sm:px-6 md:px-8 lg:px-11 shadow-2xl rounded-lg pb-2"
      style={{
        borderRadius: "27px",
        boxShadow: "0px 3.111px 3.111px 0px rgba(0, 0, 0, 0.10)",
      }}
    > 
      <h1 className="font-montserrat text-2xl mb-7 text-center font-black">ĐỔI MẬT KHẨU</h1>
        <Form
          name="registration-form"
          form={form}
          onFinish={onFinish}
          onFinishFailed={onFinishFailed}
          autoComplete="off"
          layout="vertical"
        >
          <Form.Item label="Mã Nhân viên" name="manv">
            <Input placeholder={MANV} disabled />
          </Form.Item>
          <Form.Item label="Họ Tên" name="hoten" >
            <Input placeholder={HOTEN} disabled />
          </Form.Item>
          <Form.Item label="Phái" name="phai" >
            <Input placeholder={PHAI} disabled />
          </Form.Item>
          <Form.Item label="Vị trí công việc" name="vitricv" >
            <Input placeholder={VITRICV} disabled />
          </Form.Item>
          <Form.Item
            label="Mật Khẩu Cũ"
            name="matkhaucu"
            rules={[
              {
                required: true,
                message: "Vui lòng nhập mật khẩu!",
              },
            ]}
            
          >
            <Input.Password />
          </Form.Item>
          <Form.Item
            label="Mật Khẩu Mới"
            name="matkhaumoi"
            rules={[
              {
                required: true,
                message: "Vui lòng nhập mật khẩu!",
              },
            ]}
            
          >
            <Input.Password />
          </Form.Item>
          <Form.Item
            label="Xác Nhận Mật Khẩu Mới"
            name="xacnhanmatkhaumoi"
            rules={[
              {
                required: true,
                message: "Vui lòng xác nhận mật khẩu!",
              },
              ({ getFieldValue }) => ({
                validator(_, value) {
                  if (!value || getFieldValue("matkhaumoi") === value) {
                    return Promise.resolve();
                  }
                  return Promise.reject(
                    new Error(
                      "Mật khẩu xác nhận không trùng khớp với mật khẩu mới!"
                    )
                  );
                },
              }),
            ]}
            
          >
            <Input.Password />
          </Form.Item>
          <Form.Item className="flex justify-end">
            <Space className="mt-2">
              <ButtonGreen
                text="XÁC NHẬN"
                htmlType="submit"
              />
            </Space>
          </Form.Item>
        </Form>
      </div>
  );
};
export default ProfileNV;
