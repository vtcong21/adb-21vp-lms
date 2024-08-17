// import nhasi from "../../fakedata/nhasi";
import React, { memo } from "react";

import { Table, Tag } from "antd";
import ColumnSearch from "~/hooks/useSortTable";
import { useState, useEffect } from "react";

import OnlineService from "~/services/online";
const NhaSiTable = ({ data }) => {
  const format = (text) => {
    const replacedText = text.replace(/\\n/g, "\n");
    const lines = replacedText.split("\n");
    return lines.map((line, index) => (
      <React.Fragment key={index}>
        {line}
        <br />
      </React.Fragment>
    ));
  };
  const columns = [
    {
      title: "Mã NS",
      dataIndex: "MANS",
      key: "MANS",
      className: "text-center  min-w-[100px] ",
      ...ColumnSearch("MANS", "Mã NS"),
    },
    {
      title: "Họ và tên",
      dataIndex: "HOTEN",
      key: "HOTEN",
      className: "text-center  min-w-[100px] ",

      ...ColumnSearch("HOTEN", "Họ và tên"),
    },
    {
      title: "Giới tính",
      dataIndex: "PHAI",
      className: "text-center  min-w-[100px] ",
      key: "PHAI",
    },
    {
      title: "Giới thiệu",
      dataIndex: "GIOITHIEU",
      key: "GIOITHIEU",
      render: (text) => format(text),
    },
  ];

  const paginationOptions = {
    pageSize: 4,
    total: data.length,
    showSizeChanger: true,
    showQuickJumper: true,
  };

  return (
    <Table
      className="table-striped w-full"
      columns={columns}
      dataSource={data.map((item, index) => ({ ...item, key: index }))}
      pagination={paginationOptions}
      bordered
      size="middle"
    />
  );
};

const DanhSachNS = () => {
  const [nhasi, setNhaSi] = useState([]);

  useEffect(() => {
    OnlineService.getAllDSNS().then((res) => {
      setNhaSi(res);
    });
  }, []);
  return (
    <>
      <div className=" w-full z-0">
        <NhaSiTable data={nhasi || []} />
      </div>
    </>
  );
};

export default memo(DanhSachNS);
