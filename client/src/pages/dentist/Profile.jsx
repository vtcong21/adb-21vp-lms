import React, { useState } from "react";
import { Form, Input } from "antd";
import DentistService from "../../services/dentist";
import { useSelector } from "react-redux";
import { ButtonBlue } from "~/components/button";
const ProfileNS = () => {
  const user = useSelector((state) => state.user);
  const { ROLE, HOTEN, PHAI, MANS } = user;
  const [form] = Form.useForm();

  const onFinish = async (values) => {
    const newInfo = {
      mans: MANS,
      matkhaucu: values.matkhaucu,
      matkhaumoi: values.matkhaumoi,
    };
    DentistService.doiMatKhau(newInfo).then((res) => {
      if (res.success === true) {
        message.success("Đổi mật khẩu thành công!");
      } else if (res.success === false) {
        message.error("Đổi mật khẩu thất bại!");
      }
    });
  };
  const onFinishFailed = (errorInfo) => {
    console.log("Failed:", errorInfo);
  };
  return (
    <div className="bg-[#dddddd] w-[800px] h-[500px] rounded-lg p-2">
      <h1 className="text-2xl">Đổi mật khẩu </h1>
      <div className="flex flex-col  min-h-[400px]">
        <Form
          name="basic"
          form={form}
          onFinish={onFinish}
          onFinishFailed={onFinishFailed}
          autoComplete="off"
        >
          <Form.Item label="MÃ Nha Sĩ" name="mans">
            <Input placeholder={MANS} disabled />
          </Form.Item>
          <Form.Item label="Họ Tên" name="hoten">
            <Input placeholder={HOTEN} disabled />
          </Form.Item>
          <Form.Item label="Phái" name="phai">
            <Input placeholder={PHAI} disabled />
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
          <Form.Item>
            <ButtonBlue text="Đổi mật khẩu" htmlType="submit" />
          </Form.Item>
        </Form>
      </div>
    </div>
  );
};
export default ProfileNS;
