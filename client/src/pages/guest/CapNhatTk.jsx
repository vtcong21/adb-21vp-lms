import React, { useEffect, useState } from "react";
import { Form, Input, Select, DatePicker } from "antd";
import GuestService from "../../services/guest";
import dayjs from "dayjs";
import { changeState } from "../../redux/features/dataSlice";
import { useSelector, useDispatch } from "react-redux";

const layout = {
  labelCol: {
    span: 8,
  },
  wrapperCol: {
    span: 16,
  },
};

const convertBackToDate = (inputDate) => {
  const dateObject = new Date(inputDate);
  const day = dateObject.getDate();
  const month = dateObject.getMonth() + 1;
  const year = dateObject.getFullYear();

  const formattedDate = `${day.toString().padStart(2, "0")}/${month
    .toString()
    .padStart(2, "0")}/${year}`;

  return formattedDate;
};

const dateFormatList = ["DD/MM/YYYY", "DD/MM/YY", "DD-MM-YYYY", "DD-MM-YY"];

const CapNhatTaiKhoan = () => {
  const dispatch = useDispatch();
  const user = useSelector((state) => state.user);
  const [initialValues, setInitialValues] = useState({
    user: {
      phone: user.SODT,
      name: user.HOTEN,
      gender: user.PHAI,
      address: user.DIACHI,
      date: dayjs(convertBackToDate(user.NGAYSINH), dateFormatList[0]),
    },
  });

  useEffect(() => {
    setInitialValues({
      user: {
        phone: user.SODT,
        name: user.HOTEN,
        gender: user.PHAI,
        address: user.DIACHI,
        date: dayjs(convertBackToDate(user.NGAYSINH), dateFormatList[0]),
      },
    });
  }, [user]);

  const onFinish = async (values) => {
    const formData = new FormData();
    const formattedDate = dayjs(values.user.date, dateFormatList[0]).format(
      "YYYY-MM-DD"
    );

    Object.entries(values.user).forEach(([key, value]) => {
      if (key === "date") {
        formData.append(key, formattedDate);
      } else {
        formData.append(key, value);
      }
    });
    console.log("heree")
    GuestService.capnhatKH({
      userId: formData.get("phone"),
      hoten: formData.get("name"),
      phai: formData.get("gender"),
      ngaysinh: formData.get("date"),
      diachi: formData.get("address"),
      matkhaucu: formData.get("verify-password"),
    }).then((res)=>{
      dispatch(changeState());
    });
  };

  return (
    <div className="bg-white p-10 mx-10 sm:px-15 md:px-25 lg:px-40 shadow-xl rounded-2xl pb-3">
      <Form
        {...layout}
        name="nest-messages"
        onFinish={onFinish}
        style={{ maxWidth: "95%" }}
        initialValues={initialValues}
      >
        <Form.Item
          name={["user", "phone"]}
          label="Số điện thoại:"
          rules={[
            {
              required: true,
              message: "Vui lòng nhập số điện thoại!",
            },
          ]}
          labelCol={{
            span: 6,
          }}
          wrapperCol={{
            span: 17,
          }}
        >
          <Input disabled={true} />
        </Form.Item>

        <Form.Item
          name={["user", "name"]}
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
            span: 17,
          }}
        >
          <Input />
        </Form.Item>

        <Form.Item
          name={["user", "gender"]}
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
            span: 17,
          }}
        >
          <Select>
            <Select.Option value="Nam">Nam</Select.Option>
            <Select.Option value="Nữ">Nữ</Select.Option>
          </Select>
        </Form.Item>

        <Form.Item
          name={["user", "date"]}
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
            span: 17,
          }}
        >
          <DatePicker format={dateFormatList} placeholder="Chọn ngày" />
        </Form.Item>

        <Form.Item
          name={["user", "address"]}
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
            span: 17,
          }}
        >
          <Input />
        </Form.Item>

        <Form.Item
          name={["user", "verify-password"]}
          label="Xác nhận mật khẩu"
          rules={[
            {
              required: true,
              message: "Vui lòng xác nhận mật khẩu!",
            },
          ]}
          labelCol={{
            span: 6,
          }}
          wrapperCol={{
            span: 17,
          }}
        >
          <Input.Password />
        </Form.Item>

        <Form.Item
          wrapperCol={{
            ...layout.wrapperCol,
            offset: 6,
          }}
          style={{ marginBottom: 0 }}
        >
          <button className="bg-grin font-montserrat font-bold text-base text-white py-2 px-5 rounded-lg hover:bg-darkgrin active:bg-grin mt-2">
            CẬP NHẬT
          </button>
        </Form.Item>
      </Form>
    </div>
  );
};

export default CapNhatTaiKhoan;
