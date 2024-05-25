import React, { useState } from "react";
import { Form, Input } from "antd";
import { useSelector } from "react-redux";
import { ButtonBlue } from "~/components/button";
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
          alert("Đổi mật khẩu thành công");
        }
        if (res.data.status === 404) {
          alert("Mật khẩu cũ không đúng");
        }
      }
    });
  };
  const onFinishFailed = (errorInfo) => {
    console.log("Failed:", errorInfo);
  };
  return (
    <div className="bg-[#dddddd] w-[800px] h-[500px] rounded-lg p-2">
      <h1 className="text-2xl">Đổi mật khẩu nhân viên</h1>
      <div className="flex flex-col  min-h-[400px]">
        <Form
          name="basic"
          form={form}
          onFinish={onFinish}
          onFinishFailed={onFinishFailed}
          autoComplete="off"
        >
          <Form.Item label="MÃ Nha Sĩ" name="manv">
            <Input placeholder={MANV} disabled />
          </Form.Item>
          <Form.Item label="Họ Tên" name="hoten">
            <Input placeholder={HOTEN} disabled />
          </Form.Item>
          <Form.Item label="Phái" name="phai">
            <Input placeholder={PHAI} disabled />
          </Form.Item>
          <Form.Item label="Vị trí công việc" name="vitricv">
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
export default ProfileNV;
