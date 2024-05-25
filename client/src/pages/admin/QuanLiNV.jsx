import "../../assets/styles/admin.css";
import AdminService from "../../services/admin";
import React, { useState, useCallback, useEffect, memo } from "react";
import { changeState } from "~/redux/features/dataSlice";
import { useSelector, useDispatch } from "react-redux";
import {
  Table,
  Button,
  Tag,
  Modal,
  Popconfirm,
  Form,
  Input,
  Select,
  Space,
} from "antd";

import { EditOutlined, LockOutlined, UnlockOutlined } from "@ant-design/icons";
import ColumnSearch from "~/hooks/useSortTable";
import TextArea from "antd/es/input/TextArea";

import { ButtonGreen, ButtonPink } from "../../components/button";

const ModalCapNhatNV = ({ data }) => {
  const [formValues, setFormValues] = useState(data);
  const [form] = Form.useForm();
  const dispatch = useDispatch();
  useEffect(() => {
    form.setFieldsValue(data);
  }, [data, form]);

  const handleSubmit = async (values) => {
    console.log("Success:", values);
    await AdminService.suaNV({
      manv: values.MANV,
      vitricv: values.VITRICV,
    }).then((res) => {
      console.log(res);
    });
    dispatch(changeState());
    form.resetFields();
    setFormValues({});
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
        <Form.Item label="Mã nhân viên" name="MANV" style={{ width: "100%" }}>
          <Input disabled />
        </Form.Item>
        <Form.Item label="Họ tên" name="HOTEN" style={{ width: "100%" }}>
          <Input disabled />
        </Form.Item>
        <Form.Item label="Phái" name="PHAI" style={{ width: "100%" }}>
          <Input disabled />
        </Form.Item>
        <Form.Item
          label="Vị trí công việc"
          name="VITRICV"
          style={{ width: "100%" }}
          rules={[
            {
              required: true,
              message: "Vị trí công việc không được để trống!",
            },
          ]}
        >
          <TextArea
            showCount
            minLength={10}
            maxLength={50}
            // style={{ height: 50 }}
          />
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

const TableNhanVien = ({ staff }) => {
  const [openEditModal, setOpenEditModal] = useState(false);
  const dispatch = useDispatch();

  const [data, setData] = useState({});
  const handleEdit = (record) => {
    setOpenEditModal(true);
    setData({ ...record });
  };
  const handleCancelEdit = useCallback(() => {
    setOpenEditModal(false);
  }, []);

  const handleLock = async (key) => {
    await AdminService.blockNhanVien({ manv: key }).then((res) => {
      console.log(res);
    });
    dispatch(changeState());
   
  };

  const handleUnlock = async (key) => {
    await AdminService.unblockNhanVien({ manv: key }).then((res) => {
      console.log(res);
    });
    dispatch(changeState());

  };

  const columns = [
    {
      title: "Mã nhân viên",
      dataIndex: "MANV",
      key: "MANV",
      ...ColumnSearch("MANV", "Mã nhân viên"),
    },
    {
      title: "Họ tên",
      dataIndex: "HOTEN",
      key: "HOTEN",
      ...ColumnSearch("HOTEN", "Họ tên"),
    },
    {
      title: "Giới tính",
      dataIndex: "PHAI",
      key: "PHAI",
    },
    {
      title: "Vị trí công việc",
      dataIndex: "VITRICV",
      key: "VITRICV",
      ...ColumnSearch("VITRICV", "Vị trí công việc"),
    },
    {
      title: "Tình trạng",
      dataIndex: "_DAKHOA",
      key: "_DAKHOA",
      render: (_, record) => {
        const tags = record._DAKHOA ? ["Đã khóa"] : ["Hoạt động"]; // Cập nhật với các giá trị trạng thái tùy chỉnh của bạn
        return (
          <>
            {tags.map((tag) => {
              let color = tag === "Đã khóa" ? "volcano" : "green"; // Tùy chỉnh màu sắc dựa trên trạng thái
              return (
                <Tag color={color} key={tag}>
                  {tag.toUpperCase()}
                </Tag>
              );
            })}
          </>
        );
      },
    },
    {
      title: "Quản lí",
      key: "action",
      fixed: "right",
      width: "10%",
      className: "px-[60px] min-w-[100px] ",
      render: (_, record) => {
        const handleAction = record._DAKHOA == 0 ? handleLock : handleUnlock;
        const buttonText = record._DAKHOA == 0 ? "Khóa" : "Mở khóa";
        const buttonIcon =
          record._DAKHOA == 0 ? <LockOutlined /> : <UnlockOutlined />;

        return (
          <Space size="middle">
            <button
              className="text-blue font-montserrat hover:text-darkblue"
              onClick={() => handleEdit(record)}
            >
              <EditOutlined />
            </button>
            <Popconfirm
              title={`${buttonText} tài khoản này?`}
              onConfirm={() => handleAction(record.MANV)}
            >
              <a className="text-blue font-montserrat text-sm hover:text-darkblue">
                {buttonIcon}
              </a>
            </Popconfirm>
          </Space>
        );
      },
    },
  ];

  return (
    <>
      <Table
        columns={columns}
        dataSource={staff.map((item, index) => ({ ...item, key: index }))}
        pagination={true}
        bordered
        size="middle"
        scroll={{ x: "max-content" }}
      />

      <Modal
        title={
          <h1 className="font-montserrat text-xl mb-3 mt-2 font-extrabold">
            CẬP NHẬT THÔNG TIN NHÂN VIÊN
          </h1>
        }
        open={openEditModal}
        onCancel={handleCancelEdit}
        // onOk={handleSubmitEdit}
        footer={[]}
      >
        <ModalCapNhatNV data={data} />
      </Modal>
    </>
  );
};

const TaoNhanVienMoi = () => {
  const dispatch = useDispatch();
  const [formValues, setFormValues] = useState({});
  const [form] = Form.useForm();

  const handleSubmit = async (values) => {
    await AdminService.themNhanVien(values).then((res) => {
      console.log(res);
    });
    dispatch(changeState());
    form.resetFields();
    setFormValues({});
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
        // initialValues={formValues}
      >
        <Form.Item
          label="Họ tên"
          name="hoten"
          style={{ width: "100%" }}
          rules={[
            { required: true, message: "Vui lòng nhập họ tên nhân viên!" },
          ]}
        >
          <Input placeholder="Họ và tên nhân viên." />
        </Form.Item>
        <Form.Item
          label="Phái"
          name="phai"
          style={{ width: "100%" }}
          rules={[{ required: true, message: "Vui lòng chọn giới tính!" }]}
        >
          <Select placeholder="Chọn giới tính.">
            <Select.Option value="Nam">Nam</Select.Option>
            <Select.Option value="Nữ">Nữ</Select.Option>
          </Select>
        </Form.Item>
        <Form.Item
          label="Vị trí công việc"
          name="vitricv"
          style={{ width: "100%" }}
          rules={[
            { required: true, message: "Vui lòng ghi rõ vị trí công việc!" },
          ]}
        >
          <TextArea
            showCount
            minLength={5}
            maxLength={50}
            // style={{ height: 120 }}
            placeholder="Vị trí công việc được giao."
          />
        </Form.Item>
        <Form.Item style={{ display: "flex", justifyContent: "flex-end" }}>
          <Button
            onClick={handleReset}
            style={{ marginRight: 10 }}
            type="danger"
          >
            ĐẶT LẠI
          </Button>
          <ButtonGreen text="TẠO" func={""} />
        </Form.Item>
      </Form>
    </>
  );
};

const TaoNhanVienMoiButton = () => {
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
      <ButtonGreen text="TẠO TÀI KHOẢN MỚI" func={showModal}></ButtonGreen>

      <Modal
        title={
          <h1 className="font-montserrat text-lg mb-3 mt-2 font-extrabold">
            TẠO TÀI KHOẢN NHÂN VIÊN
          </h1>
        }
        open={isModalOpen}
        onCancel={handleCancel}
        footer={[]}
      >
        <TaoNhanVienMoi />
      </Modal>
    </>
  );
};

const QuanLiNV = () => {
  const [nhanvien, setNhanvien] = useState([]);
  const state = useSelector((state) => state.stateData.value);
  useEffect(() => {
    AdminService.getAllNhanVien().then((res) => {
      setNhanvien(res);
    });
  }, [state]);
  return (
    <>
      <div className=" w-full">
        <TaoNhanVienMoiButton />
        <TableNhanVien staff={nhanvien || []} />
      </div>
    </>
  );
};
export default memo(QuanLiNV);
