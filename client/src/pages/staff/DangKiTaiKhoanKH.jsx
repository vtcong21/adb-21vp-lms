import "../../assets/styles/staff.css";
import React, { useState } from "react";
import StaffService from "../../services/staff";
import {
  Button,
  Form,
  Input,
  Select,
  DatePicker,
  message,
} from "antd";
import dayjs from "dayjs";
import { ButtonGreen, ButtonPink } from "../../components/button";
import moment from "moment";

const layout = {
  labelCol: {
    span: 8,
  },
  wrapperCol: {
    span: 16,
  },
};

const DangKiTaiKhoanKhachHang = () => {
  const [formValues, setFormValues] = useState({}); // State để lưu giá trị của các trường đầu vào
  const [form] = Form.useForm(); // Sử dụng useForm() để tạo đối tượng form
  const [date, setDate] = useState("");
  const handleSubmit = async (values) => {
    const newValues = { ...values, ngaysinh: date };
    await StaffService.taoTaiKhoanKH(newValues).then((res) => {
      console.log(res);
    });
    form.resetFields();
    setFormValues({});
  };

  const handleReset = () => {
    form.resetFields();
    setFormValues({});
    message.success("Đã xóa trường!");
  };

  return (
    <div
      className="bg-white w-[1000px] h-fit pt-10 pl-8 pr-9 mx-10 sm:px-15 md:px-25 lg:px-40 shadow-2xl rounded-lg pb-0"
      style={{
        borderRadius: "27px",
        boxShadow: "0px 3.111px 3.111px 0px rgba(0, 0, 0, 0.10)",
      }}
    > 
      <h1 className="font-montserrat text-2xl mb-9 text-center font-black">TẠO TÀI KHOẢN KHÁCH HÀNG MỚI</h1>
      <Form
        {...layout}
        onSubmit={handleSubmit}
        form={form}
        name="registration-form"
        onFinish={handleSubmit}
      >
        <Form.Item
          label="Số điện thoại"
          name="sdt"
          rules={[
            {
              pattern: /^(0\d{6,9})$/,
              message: "Số điện thoại không hợp lệ",
            },
            {
              required: true,
              message: "Vui lòng nhập số điện thoại",
            },
          ]}
          labelCol={{
            span: 6,
          }}
          wrapperCol={{
            span: 18,
          }}
        >
          <Input placeholder="Số điện thoại khách hàng." />
        </Form.Item>

        <Form.Item
          name="hoten"
          label="Họ tên: "
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
          <Input placeholder="Họ và tên khách hàng." />
        </Form.Item>

        <Form.Item
          name="phai"
          label="Phái: "
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
          <Select placeholder="Chọn giới tính.">
            <Select.Option value="Nam">Nam</Select.Option>
            <Select.Option value="Nữ">Nữ</Select.Option>
          </Select>
        </Form.Item>

        <Form.Item
          name="ngaysinh"
          label="Ngày sinh: "
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
            placeholder="Chọn ngày sinh."
            format="YYYY-MM-DD"
            disabledDate={(currentDate) =>
              currentDate && currentDate > moment().startOf("day")
            }
            onChange={(date, dateString) => {
              setDate(dateString);
            }}
          />
        </Form.Item>

        <Form.Item
          name="diachi"
          label="Địa chỉ: "
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
          <Input placeholder="Địa chỉ thường trú." />
        </Form.Item>

        <Form.Item wrapperCol={{ offset: 6, span: 18 }}>
          <ButtonGreen text="ĐĂNG KÝ" func={""} />
          <Button
            onClick={handleReset}
            style={{ marginLeft: 10 }}
            type="danger"
          >
            ĐẶT LẠI
          </Button>
        </Form.Item>
      </Form>
    </div>
  );
};

export default DangKiTaiKhoanKhachHang;