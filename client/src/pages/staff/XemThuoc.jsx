// import thuoc from "../../fakedata/thuoc";
import "../../assets/styles/staff.css";
import StaffService from "../../services/staff";
import React from "react";
import {
  Table,
} from "antd";

import ColumnSearch from "~/hooks/useSortTable";

const ThuocTable = ({ medicine }) => {
  const columns = [
    {
      title: "Mã thuốc",
      dataIndex: "MATHUOC",
      key: "MATHUOC",
      fixed: "left",
      ...ColumnSearch("MATHUOC", "Mã thuốc"),
    },
    {
      title: "Tên thuốc",
      dataIndex: "TENTHUOC",
      key: "TENTHUOC",
      fixed: "left",
      ...ColumnSearch("TENTHUOC", "Tên thuốc"),
    },
    {
      title: "Đơn vị tính",
      dataIndex: "DONVITINH",
      key: "DONVITINH",
    },
    {
      title: "Chỉ định",
      dataIndex: "CHIDINH",
      key: "CHIDINH",
    },
    {
      title: "Số lượng tồn",
      dataIndex: "SLTON",
      key: "SLTON",
      sorter: (a, b) => a.SLTON - b.SLTON,
    },
    {
      title: "Số lượng nhập",
      dataIndex: "SLNHAP",
      key: "SLNHAP",
      sorter: (a, b) => a.SLNHAP - b.SLNHAP,
    },
    {
      title: "Số lượng đã hủy",
      dataIndex: "SLDAHUY",
      key: "SLDAHUY",
    },
    {
      title: "Ngày hết hạn",
      dataIndex: "NGAYHETHAN",
      key: "NGAYHETHAN",
      render: (text) => {
        const date = new Date(text);
        const dateString = date.toLocaleDateString();
        return dateString;
      },
    },
    {
      title: "Đơn giá",
      dataIndex: "DONGIA",
      key: "DONGIA",
      sorter: (a, b) => a.DONGIA - b.DONGIA,
      render: (text) => {
        const formattedAmount = text.toLocaleString("vi-VN");
        return `${formattedAmount} VND`;
      },
    },
  ];

  return (
    <>
      <Table
        columns={columns}
        dataSource={medicine.map((item, index) => ({ ...item, key: index }))}
        pagination={true}
        bordered
        size="middle"
        tableLayout="auto"
        scroll={{ x: "calc(900px + 50%)" }}
      />
    </>
  );
};

const XemThuoc = () => {
  const [thuoc, setThuoc] = React.useState([]);
  React.useEffect(() => {
    StaffService.getAllThuoc().then((res) => {
      setThuoc(res);
    });
  }, []);
  return (
    <>
      <div className="w-full">
        <ThuocTable medicine={thuoc || []} />
      </div>
    </>
  );
};

export default XemThuoc;
