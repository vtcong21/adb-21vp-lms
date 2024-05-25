import "../../assets/styles/staff.css";
import StaffService from "../../services/staff";

import React, { useState, useCallback, useEffect } from "react";
import { Table, message, Modal, Form, Input, Space } from "antd";
import moment from "moment";

import { StopOutlined } from "@ant-design/icons";
import ColumnSearch from "~/hooks/useSortTable";

import { ButtonPink } from "../../components/button";

const ModalHuyHen = ({ data }) => {
  const [formValues, setFormValues] = useState(data);
  const [form] = Form.useForm();
  const [formattedTime, setFormattedTime] = useState("");

  useEffect(() => {
    form.setFieldsValue(data);
    if (data && data.GIOBATDAU) {
      const time = moment.utc(data.GIOBATDAU);
      const formattedTime = time.format("HH:mm");
      setFormattedTime(formattedTime);
      console.log(formattedTime);
    }

    // Set giá trị mặc định cho NGAY và GIOBATDAU
    form.setFieldsValue({
      GIOBATDAU: formattedTime,
      NGAY: moment(data.NGAY).format("DD/MM/YYYY"),
    });
  }, [data, form, formattedTime]);

  const handleSubmit = (values) => {
    const lichHen = {
      sdt: data.SODTKH,
      stt: data.SOTTLH,
      mans: data.MANS,
    };
    StaffService.deleteLichHen(lichHen).then((res) => {
      console.log(res);
    });
    form.resetFields();
    setFormValues({});
  };

  return (
    <>
      <Form
        onSubmit={handleSubmit}
        form={form}
        name="registration-form"
        layout="vertical"
        onFinish={handleSubmit}
      >
        <Form.Item label="Khách hàng" name="HOTENKH" style={{ width: "100%" }}>
          <Input disabled />
        </Form.Item>
        <Form.Item label="Ngày hẹn" name="NGAY" style={{ width: "100%" }}>
          <Input disabled />
        </Form.Item>
        <Form.Item label="Giờ hẹn" name="GIOBATDAU" style={{ width: "100%" }}>
          <Input disabled />
        </Form.Item>
        <Form.Item
          label="Nha sĩ đã hẹn"
          name="HOTENNS"
          style={{ width: "100%" }}
        >
          <Input disabled />
        </Form.Item>
        <Form.Item style={{ display: "flex", justifyContent: "flex-end" }}>
          <ButtonPink text="HỦY LỊCH NÀY" func={""} />
        </Form.Item>
      </Form>
    </>
  );
};

const LichhenTabble = ({ appointment }) => {
  const options = {
    hour: "numeric",
    minute: "numeric",
    hour12: false,
  };

  const [openDeleteModal, setOpenDeleteModal] = useState(false);

  const [data1, setData1] = useState({});

  const handleDelete = (record) => {
    console.log("record", record);
    setOpenDeleteModal(true);
    setData1(record);
  };

  const handleCancelDelete = useCallback(() => {
    setOpenDeleteModal(false);
  }, []);

  console.log(appointment);

  const columns = [
    {
      title: "Mã ca",
      dataIndex: "MACA",
      key: "MACA",
      width: "5%",
      ...ColumnSearch("MACA", "Mã ca"),
    },
    {
      title: "Ngày khám",
      dataIndex: "NGAY",
      key: "NGAY",
      width: "6%",
      render: (text) => {
        const date = new Date(text);
        const formattedDate = date.toLocaleDateString();
        return formattedDate;
      },
      sorter: (a, b) => a.NGAY - b.NGAY,
    },
    {
      title: "Giờ Bắt Đầu",
      dataIndex: "GIOBATDAU",
      key: "GIOBATDAU",
      width: "6%",
      render: (text) => {
        const time = new Date(text);
        const formattedTime = time.toLocaleTimeString("en-US", options);
        return formattedTime;
      },
      sorter: (a, b) => a.GIOBATDAU - b.GIOBATDAU,
    },
    {
      title: "Giờ Kết Thúc",
      dataIndex: "GIOKETTHUC",
      key: "GIOKETTHUC",
      width: "7%",
      render: (text) => {
        const time = new Date(text);
        const formattedTime = time.toLocaleTimeString("en-US", options);
        return formattedTime;
      },
      sorter: (a, b) => a.GIOKETTHUC - b.GIOKETTHUC,
    },
    {
      title: "Mã NS",
      dataIndex: "MANS",
      key: "MANS",
      width: "7%",
      ...ColumnSearch("MANS", "Mã nha sĩ"),
    },
    {
      title: "Tên nha sĩ",
      dataIndex: "HOTENNS",
      key: "HOTENNS",
      width: "11%",
    },
    {
      title: "Mã NS",
      dataIndex: "MANS",
      key: "MANS",
    },
    {
      title: "Số TT",
      dataIndex: "SOTTLH",
      key: "SOTTLH",
      width: "4%",
      sorter: (a, b) => a.SOTTLH - b.SOTTLH,
    },
    {
      title: "Số ĐT khách",
      dataIndex: "SODTKH",
      key: "SODTKH",
      width: "7%",
      ...ColumnSearch("SODTKH", "Số điện thoại"),
    },
    {
      title: "Tên khách hàng",
      dataIndex: "HOTENKH",
      key: "HOTENKH",
      width: "11%",
      ...ColumnSearch("HOTENKH", "Tên khách hàng"),
    },
    {
      title: "Lý do khám",
      dataIndex: "LYDOKHAM",
      key: "LYDOKHAM",
      // with: "50%",
    },

    {
      title: "Quản lí",
      key: "action",
      fixed: "right",
      width: "7%",

      render: (text, record) => (
        <Space size="middle">
          <button
            className="text-orange font-montserrat hover:text-darkorange hover:underline mx-1"
            onClick={() => handleDelete(record)}
          >
            <StopOutlined /> Hủy hẹn
          </button>
        </Space>
      ),
    },
  ];

  return (
    <>
      <Table
        columns={columns}
        dataSource={appointment.map((item, index) => ({ ...item, key: index }))}
        pagination={true}
        bordered
        size="middle"
        tableLayout="auto"
        scroll={{ x: "calc(1600px + 50%)" }}
      />

      <Modal
        title={
          <h1 className="font-montserrat text-xl mb-3 mt-2 font-extrabold">
            XÁC NHẬN HỦY HẸN
          </h1>
        }
        open={openDeleteModal}
        onCancel={handleCancelDelete}
        footer={[]}
      >
        <ModalHuyHen data={data1} />
      </Modal>
    </>
  );
};

const XemLichHen = () => {
  const [lichHen, setLichHen] = useState([]);
  useEffect(() => {
    StaffService.getLichHenNS().then((res) => {
      console.log(res);
      setLichHen(res);
    });
  }, []);
  return (
    <>
      <div className=" rounded-lg w-full">
        <LichhenTabble appointment={lichHen || []} />
      </div>
    </>
  );
};

export default XemLichHen;
