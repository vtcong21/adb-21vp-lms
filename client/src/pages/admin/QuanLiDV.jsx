import "../../assets/styles/admin.css";
import AdminService from "../../services/admin";
import React, { useState, useCallback, useEffect } from "react";
import {
  Table,
  Button,
  message,
  Modal,
  Form,
  Input,
  Space,
  InputNumber,
} from "antd";

import { SearchOutlined, EditOutlined } from "@ant-design/icons";
import ColumnSearch from "~/hooks/useSortTable";
import TextArea from "antd/es/input/TextArea";
import { changeState } from "~/redux/features/dataSlice";
import { useSelector, useDispatch } from "react-redux";
import { ButtonGreen, ButtonPink } from "../../components/button";

const ModalCapNhatDV = ({ data }) => {
  const [formValues, setFormValues] = useState(data);
  const [form] = Form.useForm();
  const dispatch = useDispatch();
  useEffect(() => {
    form.setFieldsValue(data);
  }, [data, form]);

  const handleSubmit = async (values) => {
    await AdminService.suaDV({
      madv: values.MADV,
      tendv: values.TENDV,
      mota: values.MOTA,
      dongia: values.DONGIA,
    }).then((res) => {
      console.log(res);
    });
    form.resetFields();
    setFormValues({});
    dispatch(changeState());
  };

  const handleReset = () => {
    form.resetFields();
    message.success("Hoàn tác quá trình cập nhật!");
  };

  return (
    <>
      <Form
        onSubmit={handleSubmit}
        form={form}
        name="registration-form"
        layout="vertical"
        onFinish={handleSubmit}
        initialValues={formValues}
      >
        <Form.Item label="Mã dịch vụ" name="MADV" style={{ width: "100%" }}>
          <Input disabled />
        </Form.Item>
        <Form.Item
          label="Tên dịch vụ"
          name="TENDV"
          style={{ width: "100%" }}
          rules={[
            { required: true, message: "Tên dịch vụ không được để trống!" },
          ]}
        >
          <Input />
        </Form.Item>
        <Form.Item
          label="Mô tả"
          name="MOTA"
          style={{ width: "100%" }}
          rules={[
            { required: true, message: "Mô tả dịch vụ không được để trống!" },
          ]}
        >
          <TextArea
            showCount
            minLength={10}
            maxLength={500}
            style={{ height: 120 }}
          />
        </Form.Item>
        <Form.Item
          label="Đơn giá"
          name="DONGIA"
          style={{ width: "100%" }}
          rules={[{ required: true, message: "Đơn giá không được để trống!" }]}
        >
          <InputNumber />
        </Form.Item>
        <Form.Item style={{ display: "flex", justifyContent: "flex-end" }}>
          <Button
            onClick={handleReset}
            style={{ marginRight: 10 }}
            type="danger"
            // initialValues={formValues}
          >
            ĐẶT LẠI
          </Button>
          <ButtonGreen text="CẬP NHẬT" func={""} />
        </Form.Item>
      </Form>
    </>
  );
};

const DichVuTable = ({ service }) => {
  const [openEditModal, setOpenEditModal] = useState(false);
  const [data, setData] = useState({});
  const handleEdit = (record) => {
    setOpenEditModal(true);
    setData({ ...record });
  };

  const handleCancelEdit = useCallback(() => {
    setOpenEditModal(false);
  }, []);

  const columns = [
    {
      title: "Mã dịch vụ",
      dataIndex: "MADV",
      key: "MADV",
      fixed: "left",
      className: "px-[60px] min-w-[120px] ",
      ...ColumnSearch("MADV", "Mã Dich vụ"),
    },
    {
      title: "Tên dich vụ",
      dataIndex: "TENDV",
      key: "TENDV",
      fixed: "left",
      ...ColumnSearch("TENDV", "Tên dich vụ"),
    },
    {
      title: "Mô tả",
      dataIndex: "MOTA",
      key: "MOTA",
      ...ColumnSearch("MOTA", "Mô tả"),
    },
    {
      title: "Đơn giá",
      dataIndex: "DONGIA",
      key: "DONGIA",
      className: "px-[60px] min-w-[120px] ",
      sorter: (a, b) => a.DONGIA - b.DONGIA,
      render: (text) => {
        if (text === null) {
          return "null";
        }
        const formattedAmount = text.toLocaleString("vi-VN");
        return `${formattedAmount} VND`;
      },
    },
    {
      title: "Quản lí",
      key: "action",
      fixed: "right",
      width: "6%",
      render: (text, record) => (
        <Space size="middle">
          <button
            className="text-blue font-montserrat hover:text-darkblue"
            onClick={() => handleEdit(record)}
          >
            <EditOutlined />
          </button>
        </Space>
      ),
    },
  ];
  return (
    <>
      <Table
        columns={columns}
        dataSource={service.map((item, index) => ({ ...item, key: index }))}
        pagination={true}
        bordered
        size="middle"
        tableLayout="auto"
        scroll={{ x: "calc(900px + 50%)" }}
      />

      <Modal
        title={
          <h1 className="font-montserrat text-xl mb-3 mt-2 font-extrabold">
            CẬP NHẬT THÔNG TIN DỊCH VỤ
          </h1>
        }
        open={openEditModal}
        onCancel={handleCancelEdit}
        // onOk={handleSubmitEdit}
        footer={[]}
      >
        <ModalCapNhatDV data={data} />
      </Modal>
    </>
  );
};

const TaoDichVuMoi = () => {
  const dispatch = useDispatch();
  const [formValues, setFormValues] = useState({});
  const [form] = Form.useForm();

  const handleSubmit = async (values) => {
    console.log(values);
    await AdminService.themDV(values).then((res) => {
      console.log(res);
    });

    form.resetFields();
    setFormValues({});
    dispatch(changeState());
  };

  const handleReset = () => {
    form.resetFields();
    setFormValues({});
    message.success("Đã xóa thông tin!");
  };

  return (
    <>
      <Form
        onSubmit={handleSubmit}
        form={form}
        name="registration-form"
        layout="vertical"
        onFinish={handleSubmit}
        initialValues={formValues}
      >
        <Form.Item
          label="Tên dịch vụ"
          name="tendv"
          style={{ width: "100%" }}
          rules={[{ required: true, message: "Vui lòng nhập tên dịch vụ!" }]}
        >
          <Input placeholder="Tên dịch vụ." />
        </Form.Item>
        <Form.Item
          label="Mô tả"
          name="mota"
          style={{ width: "100%" }}
          rules={[{ required: true, message: "Vui lòng nhập mô tả!" }]}
        >
          <TextArea
            showCount
            minLength={10}
            maxLength={500}
            style={{ height: 120 }}
            placeholder="Mô tả dịch vụ nha khoa."
          />
        </Form.Item>
        <Form.Item
          label="Đơn giá"
          name="dongia"
          placeholder="VND"
          style={{ width: "100%" }}
          rules={[{ required: true, message: "Vui lòng nhập đơn giá!" }]}
        >
          <InputNumber min={500} placeholder="Đơn giá dịch vụ" />
        </Form.Item>
        <Form.Item style={{ display: "flex", justifyContent: "flex-end" }}>
          <Button
            onClick={handleReset}
            style={{ marginRight: 10 }}
            type="danger"
          >
            ĐẶT LẠI
          </Button>
          <ButtonGreen text="THÊM DỊCH VỤ" func={""} />
        </Form.Item>
      </Form>
    </>
  );
};

const ThemDichVuMoiButton = () => {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const showModal = () => {
    setIsModalOpen(true);
  };
  const handleOk = () => {
    setIsModalOpen(false);
  };
  const handleCancel = () => {
    setIsModalOpen(false);
  };
  return (
    <>
      <ButtonGreen text="THÊM LOẠI DỊCH VỤ MỚI" func={showModal} />

      <Modal
        title={
          <h1 className="font-montserrat text-xl mb-3 mt-2 font-extrabold">
            THÊM LOẠI THUỐC MỚI
          </h1>
        }
        open={isModalOpen}
        onCancel={handleCancel}
        footer={[]}
      >
        <TaoDichVuMoi />
      </Modal>
    </>
  );
};

const QuanliDV = () => {
  const state = useSelector((state) => state.stateData.value);

  const [dv, setDV] = useState([]);

  useEffect(() => {
    AdminService.getAllDV().then((res) => {
      setDV(res);
    });
  }, [state]);
  return (
    <>
      <div className=" w-full">
        <ThemDichVuMoiButton />
        <DichVuTable service={dv || []} />
      </div>
    </>
  );
};

export default QuanliDV;
