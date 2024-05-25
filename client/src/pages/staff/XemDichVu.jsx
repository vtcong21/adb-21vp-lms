// import dv from "../../fakedata/dv";
import "../../assets/styles/staff.css";
import StaffService from "../../services/staff";
import React, { memo } from "react";
import { Table } from "antd";

import ColumnSearch from "~/hooks/useSortTable";

const DichVuTable = memo(
  ({ service }) => {
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
          const formattedAmount = text.toLocaleString("vi-VN");
          return `${formattedAmount} VND`;
        },
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
      </>
    );
  },
  (prevProps, nextProps) => prevProps.service === nextProps.service
);

const XemDichVu = () => {
  const [dv, setDv] = React.useState([]);
  React.useEffect(() => {
    StaffService.getAllDV().then((res) => {
      setDv(res);
    });
  }, []);

  return (
    <>
      <div className=" w-full">
        <DichVuTable service={dv || []} />
      </div>
    </>
  );
};

export default memo(XemDichVu);
