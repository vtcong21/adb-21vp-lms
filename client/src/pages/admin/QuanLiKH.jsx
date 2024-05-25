import khachhangs from "../../fakedata/khachhang";

import AdminService from "../../services/admin";
import React, { useEffect } from "react";
import { Table, Tag, Popconfirm } from "antd";

import "../../assets/styles/admin.css";
import { LockOutlined, UnlockOutlined } from "@ant-design/icons";
import { changeState } from "~/redux/features/dataSlice";
import { useSelector, useDispatch } from "react-redux";

const KhahHangTable = ({ data }) => {

  const dispatch = useDispatch();
  const formatDateString = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleDateString();
  };

  const columns = [
    {
      title: "Số điện thoại",
      dataIndex: "SODT",
      key: "SODT",
      fixed: "left",
    },
    {
      title: "Họ và tên",
      dataIndex: "HOTEN",
      key: "HOTEN",
      fixed: "left",
    },
    {
      title: "Giới tính",
      dataIndex: "PHAI",
      key: "PHAI",
    },
    {
      title: "Ngày sinh",
      dataIndex: "NGAYSINH",
      key: "NGAYSINH",
      render: (text) => formatDateString(text),
    },
    {
      title: "Địa chỉ",
      dataIndex: "DIACHI",
      key: "DIACHI",
      width: "30%",
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
      width: "6%",
      className: "px-[60px] min-w-[100px] ",
      render: (_, record) => {
        const handleAction = record._DAKHOA == 0 ? handleLock : handleUnlock;
        const buttonText = record._DAKHOA == 0 ? "Khóa" : "Mở khóa";
        const buttonIcon =
          record._DAKHOA == 0 ? <LockOutlined /> : <UnlockOutlined />;

        return (
          <Popconfirm
            title={`${buttonText} tài khoản này?`}
            onConfirm={() => handleAction(record.SODT)}
          >
            <a className="text-blue font-montserrat text-sm hover:text-darkblue">
              {buttonIcon}
            </a>
          </Popconfirm>
        );
      },
    },
  ];

  const handleLock = async (key) => {
    await AdminService.blockKH({ sdt: key });
    dispatch(changeState());
  };

  const handleUnlock = async (key) => {
    await AdminService.unblockKH({ sdt: key });
    dispatch(changeState());
  };

  const paginationOptions = {
    pageSize: 10,
    total: data.length,
    showSizeChanger: true,
    showQuickJumper: true,
  };

  return (
    <Table
      columns={columns}
      dataSource={data.map((item, index) => ({ ...item, key: index }))}
      pagination={paginationOptions}
      bordered
      size="middle"
      scroll={{ x: "max-content" }}
    />
  );
};

const QuanliKH = () => {
  const state = useSelector((state) => state.stateData.value);

  const [khachhang, setKhachHang] = React.useState([]);
  useEffect(() => {
    AdminService.getAllKhachHang().then((res) => {
      setKhachHang(res || khachhangs);
    });
  }, [state]);
  return (
    <>
      <div className=" w-full ">
        <KhahHangTable data={khachhang || []} />
      </div>
    </>
  );
};

export default QuanliKH;
