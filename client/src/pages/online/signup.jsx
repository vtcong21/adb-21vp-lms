import React, { useState } from "react";
import { Form, Input, Select, DatePicker } from "antd";
import moment from "moment";
import OnlineService from "../../services/online";
import { ButtonGreen } from "../../components/button";
const layout = {
  labelCol: {
    span: 8,
  },
  wrapperCol: {
    span: 16,
  },
};

const DangKyTaiKhoan = () => {
  const [date, setDate] = useState("");
  const { formValue, setFormValue } = useState({});
  const [form] = Form.useForm();
  const initialValues = {
    user: {
      phone: "012345678",
      name: "",
      gender: "",
      address: "",
      date: "",
    },
  };
  const onFinish = async (values) => {
   
    const newUser = {
      ...values,
      ngaysinh: date,
    };
    OnlineService.taoTKKH(newUser).then((res) => {
      if (res.success === true) {
        message.success("Đăng ký thành công!");
      } else if (res.success === false) {
        message.error("Đăng ký thất bại!");
      }
    });
  };
  return (
    <div
      className="bg-white p-10 mx-10 sm:px-15 md:px-25 lg:px-40 shadow-xl "
      style={{
        borderRadius: "10px",
        boxShadow: "0px 3.111px 3.111px 0px rgba(0, 0, 0, 0.10)",
      }}
    >
      <Form
        {...layout}
        onFinish={onFinish}
        style={{ maxWidth: "95%" }}
        initialValues={initialValues}
      >
        <Form.Item
          name="sdt"
          label="Số điện thoại:"
          rules={[
            {
              required: true,
              message: "Vui lòng nhập số điện thoại!",
            },
            {
              pattern: /^[0-9]{10}$/,
              message: "Số điện thoại không hợp lệ!",
            },
          ]}
          labelCol={{
            span: 6,
          }}
          wrapperCol={{
            span: 18,
          }}
          validateTrigger={["onBlur"]}
        >
          <Input />
        </Form.Item>

        <Form.Item
          name="hoten"
          label="Họ tên:"
          rules={[
            {
              required: true,
              message: "Vui lòng nhập họ tên!",
            },
          ]}
          labelCol={{
            span: 6,
          }}
          wrapperCol={{
            span: 18,
          }}
        >
          <Input />
        </Form.Item>

        <Form.Item
          name="phai"
          label="Phái"
          rules={[
            {
              required: true,
              message: "Vui lòng chọn giới tính",
            },
          ]}
          labelCol={{
            span: 6,
          }}
          wrapperCol={{
            span: 18,
          }}
        >
          <Select>
            <Select.Option value="Nam">Nam</Select.Option>
            <Select.Option value="Nữ">Nữ</Select.Option>
          </Select>
        </Form.Item>

        <Form.Item
          name="ngaysinh"
          label="Ngày sinh"
          rules={[
            {
              required: true,
              message: "Vui lòng nhập ngày sinh!",
            },
          ]}
          labelCol={{
            span: 6,
          }}
          wrapperCol={{
            span: 18,
          }}
        >
          <DatePicker
            placeholder="Ngày sinh."
            format="YYYY-MM-DD"
            disabledDate={(currentDate) =>
              currentDate && currentDate >= moment().startOf("day")
            }
            onChange={(date, dateString) => {
              setDate(dateString);
            }}
          />
        </Form.Item>

        <Form.Item
          name="diachi"
          label="Địa chỉ:"
          rules={[
            {
              required: true,
              message: "Vui lòng nhập địa chỉ!",
            },
          ]}
          labelCol={{
            span: 6,
          }}
          wrapperCol={{
            span: 18,
          }}
        >
          <Input />
        </Form.Item>
        <Form.Item
          name="matkhau"
          label="Mật khẩu"
          rules={[
            {
              required: true,
              message: "Vui lòng nhập mật khẩu",
            },
            {
              min: 6,
              message: "Mật khẩu cần ít nhất 6 ký tự",
            },
          ]}
          labelCol={{ span: 6 }}
          wrapperCol={{ span: 18 }}
        >
          <Input.Password />
        </Form.Item>

        <Form.Item
          name="xacnhanmatkhau"
          label="Xác nhận mật khẩu"
          rules={[
            {
              required: true,
              message: "Vui lòng xác nhận mật khẩu!",
            },
            ({ getFieldValue }) => ({
              validator(_, value) {
                if (!value || getFieldValue("matkhau") === value) {
                  return Promise.resolve();
                }
                return Promise.reject("Mật khẩu xác nhận không khớp!");
              },
            }),
          ]}
          labelCol={{
            span: 6,
          }}
          wrapperCol={{
            span: 18,
          }}
          validateTrigger={["onBlur"]}
        >
          <Input.Password />
        </Form.Item>

        <Form.Item
          wrapperCol={{
            ...layout.wrapperCol,
            offset: 5,
          }}
          style={{ marginBottom: 0 }}
        >
          <ButtonGreen text={"Đăng Ký"} />
        </Form.Item>
      </Form>
    </div>
  );
};
export default DangKyTaiKhoan;
