// import dv from "../../fakedata/dv";
import React, { memo } from "react";
import { Table, Modal, Button, message } from "antd";
import ColumnSearch from "~/hooks/useSortTable";
import { useState, useEffect } from "react";
import OnlineService from "~/services/online";
const DichVuTable = ({ data }) => {
  const formatCurrency = (amount) => {
    const formattedAmount = amount.toLocaleString("vi-VN");
    return `${formattedAmount} VND`;
  };

  const columns = [
    {
      title: "Mã Dich vụ",
      dataIndex: "MADV",
      key: "MADV",
      className: "text-center px-[60px] min-w-[120px] ",
      ...ColumnSearch("MADV", "Mã Dich vụ"),
    },
    {
      title: "Tên dich vụ",
      dataIndex: "TENDV",
      key: "TENDV",
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
      className: "text-center px-[60px] min-w-[120px] ",
      sorter: (a, b) => a.DONGIA - b.DONGIA,
      render: (text) => formatCurrency(text),
    },
  ];
  return (
    <Table
      className="table-striped w-full"
      columns={columns}
      dataSource={data.map((item, index) => ({ ...item, key: index }))}
      pagination={true}
      bordered
      size="middle"
    />
  );
};

const DanhSachDV = () => {
  const [dv, setDV] = useState([]);
  useEffect(() => {
    OnlineService.getAllDV().then((res) => {
      setDV(res);
    });
  }, []);
  return (
    <>
      <div className="w-full">
        <DichVuTable data={dv || []} />
      </div>
    </>
  );
};

export default memo(DanhSachDV);
