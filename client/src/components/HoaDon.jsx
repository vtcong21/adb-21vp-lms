import React, { useState, useEffect, memo } from "react";
import { Table, Pagination, Empty, message } from "antd";

import "~/assets/styles/staff_invoice.css";
import { ButtonGreen, ButtonGrey } from "~/components/button";
import { PrinterOutlined } from "@ant-design/icons";
import StaffService from "../services/staff";
import { useSelector } from "react-redux";
import { useNavigate } from "react-router-dom";

const formatCurrency = (amount) => {
  const formattedAmount = new Intl.NumberFormat("vi-VN", {
    style: "currency",
    currency: "VND",
  }).format(amount);
  return formattedAmount.replace(/\u200B/g, ""); // Loại bỏ dấu 0 đặc biệt (nếu có)
};

const GuestInfo = ({ currentRecord }) => {
  if (!currentRecord) {
    return null;
  }

  const { HOTENKH, SODT, SOTTHD, NGAYXUAT } = currentRecord;
  return (
    <div>
      <div className="font-montserrat">
        <p className="text-lg text-blue font-[700]">NHA KHOA HAHA</p>
        <p className="text-[#adadad] italic text-sm">
          227 Đ.Nguyễn Văn Cừ, Quận 5
        </p>
        <p className="text-[#adadad] italic text-sm">nhakhoahaha.com</p>
      </div>
      <div className="font-montserrat text-2xl text-center font-[900] my-6">
        HÓA ĐƠN KHÁM BỆNH
      </div>
      <div className="grid grid-cols-2 gap-4">
        <div>
          <p className="leading-9 font-montserrat font-semibold text-base text-#4B4B4B">
            <span className="">Số điện thoại: </span>
            {SODT}
          </p>
          <p className="leading-9 font-montserrat font-semibold text-base text-#4B4B4B">
            <span className="">Họ tên: </span>
            {HOTENKH}
          </p>
        </div>
        <div>
          <p className="leading-9 font-montserrat font-semibold text-base text-#4B4B4B">
            <span className="">Hóa đơn số: </span>
            {SOTTHD}
          </p>
          <p className="leading-9 font-montserrat font-semibold text-base text-#4B4B4B">
            <span className="">Ngày xuất: </span>
            {NGAYXUAT}
          </p>
        </div>
      </div>
    </div>
  );
};

const DichVuTable = memo(({ dataDV, openDrawer }) => {
  const formatDVData = (dvData) => {
    if (!dvData || !Array.isArray(dvData) || dvData[0].MATHUOC === null) {
      return [];
    }
    return dvData.map((item) => {
      return {
        ...item,
      };
    });
  };

  const columnDV = [
    {
      title: "STT",
      key: "STT",
      width: "5%",
      render: (text, record, index) => index + 1,
    },
    {
      title: "Tên dịch vụ",
      dataIndex: "TENDV",
      key: "TENDV",
      width: "21%",
    },
    {
      title: "Số lượng",
      dataIndex: "SLDV",
      key: "SLDV",
      width: "33%",
    },
    {
      title: "Đơn giá",
      dataIndex: "DONGIADV",
      key: "DONGIADV",
      width: "17%",
      render: (text, record) => <p>{formatCurrency(record.DONGIADV)}</p>,
    },
    {
      title: "Thành tiền",
      key: "THANHTIEN",
      render: (text, record) => (
        <p>{formatCurrency(record.DONGIADV * record.SLDV)}</p>
      ),
    },
  ];
  return (
    <Table
      columns={columnDV}
      dataSource={formatDVData(dataDV).map((item, index) => ({
        ...item,
        key: index,
      }))}
      pagination={false}
    />
  );
});

const ThuocTable = memo(({ dataThuoc, openDrawer }) => {
  const formatThuocData = (dataThuoc) => {
    if (
      !dataThuoc ||
      !Array.isArray(dataThuoc) ||
      dataThuoc[0].MATHUOC === null
    ) {
      return [];
    }

    return dataThuoc.map((item, index) => {
      return {
        ...item,
        SLTHUOC: `${item.SLTHUOC}`,
      };
    });
  };

  const columnThuoc = [
    {
      title: "STT",
      key: "STT",
      width: "5%",
      render: (text, record, index) => index + 1,
    },
    {
      title: "Tên thuốc",
      dataIndex: "TENTHUOC",
      key: "TENTHUOC",
      width: "21%",
    },
    {
      title: "Số lượng",
      dataIndex: "SLTHUOC",
      key: "SLTHUOC",
      width: "15%",
    },
    {
      title: "Đơn vị tính",
      dataIndex: "DONVITINH",
      key: "DONVITINH",
      width: "18%",
    },
    {
      title: "Đơn giá",
      dataIndex: "DONGIATHUOC",
      key: "DONGIATHUOC",
      width: "17%",
      render: (text, record) => <p>{formatCurrency(record.DONGIATHUOC)}</p>,
    },
    {
      title: "Thành tiền",
      key: "THANHTIEN",
      render: (record) => (
        <p>{formatCurrency(record.DONGIATHUOC * record.SLTHUOC)}</p>
      ),
    },
  ];

  return (
    <Table
      columns={columnThuoc}
      dataSource={formatThuocData(dataThuoc).map((item, index) => ({
        ...item,
        key: index,
      }))}
      pagination={false}
    />
  );
});

const HoaDon = ({ sdt }) => {
  const [currentPage, setCurrentPage] = useState(1);
  const [medicalRecords, setMedicalRecords] = useState([]);
  const [isPaymentConfirmed, setIsPaymentConfirmed] = useState(false);
  const recordsPerPage = 1;
  const user = useSelector((state) => state.user);
  const navigate = useNavigate();

  useEffect(() => {
    // Kiểm tra trạng thái xác nhận thanh toán trước khi tải dữ liệu
    if (!isPaymentConfirmed) {
      loadInvoiceData(sdt);
    } else {
      // Nếu đã xác nhận, đặt lại trạng thái về false
      setIsPaymentConfirmed(false);
    }
  }, [currentPage, sdt, isPaymentConfirmed]);
  
  

  const indexOfLastRecord = currentPage * recordsPerPage;
  const indexOfFirstRecord = indexOfLastRecord - recordsPerPage;
  const currentRecords = medicalRecords.slice(
    indexOfFirstRecord,
    indexOfLastRecord
  );

  const loadInvoiceData = async (sdt) => {
    try {
      const res = await StaffService.getHoaDon(sdt);
      console.log(res);
  
      if (res === undefined) {
        message.info("Không tìm thấy thông tin hồ sơ bệnh!");
      }
  
      setMedicalRecords(res ? res : []);
    } catch (error) {
      console.error("Lỗi khi tải lại hóa đơn:", error);
    }
  };  

  const paying = async ({ sdt, sott }) => {
    const newData = {
      sdt,
      stt: sott,
      manv: user.MANV
    };
    try {
      const res = await StaffService.xacNhanThanhToan(newData);
      console.log(res);
      // Chỉ cập nhật state khi chưa xác nhận thanh toán
      if (!isPaymentConfirmed) {
        setIsPaymentConfirmed(true);
      }
      else{
        console.log("done")
      }
    } catch (error) {
      console.error("Lỗi khi xác nhận thanh toán:", error);
    }
  };
  
  

  const print = () => {
    navigate(`/print-hoa-don/${sdt}`);
  };

  return (
    <div className="">
      {medicalRecords.length > 0 ? (
        <div
          className="bg-white p-10"
          style={{
            borderRadius: "35px",
            boxShadow: "0px 4px 4px 0px rgba(0, 0, 0, 0.10)",
          }}
        >
          <div className="mb-3">
            <GuestInfo currentRecord={currentRecords[0]} />
          </div>
          <div className="mb-5">
            <DichVuTable dataDV={currentRecords[0]?.DICHVU} openDrawer="" />
          </div>
          <div className="mb-5">
            <ThuocTable dataThuoc={currentRecords[0]?.THUOC} openDrawer="" />
          </div>
          <div className="grid grid-cols-[2.3fr,0.7fr] gap-5">
            <p className="text-right">TỔNG CỘNG: </p>
            <p>{formatCurrency(currentRecords[0].TONGCHIPHI)}</p>
          </div>
          <div className="mt-5">
            <p>Nhân viên phụ trách: {currentRecords[0].HOTENNV} </p>

            {currentRecords[0].DATHANHTOAN === false ? (
              <p className="text-pinkk italic">
                *Hóa đơn chưa được thanh toán
              </p>
            ) : (
              <p className="text-pinkk italic">*Hóa đơn đã được thanh toán</p>
            )}
          </div>
        </div>
      ) : (
        <Empty />
      )}
      <div className="grid grid-cols-[2fr,1fr] gap-4 mt-6 ">
        {medicalRecords.length > 0 ? (
          <div className="flex justify-start">
            <p className="me-4">
              <ButtonGrey
                text={
                  <>
                    <PrinterOutlined /> IN HÓA ĐƠN
                  </>
                }
                func={() => print()}
              />
            </p>
            {currentRecords[0].DATHANHTOAN === false ? (
              <p>
                <ButtonGreen
                  text="XÁC NHẬN THANH TOÁN"
                  func={() => paying({ sdt, sott: currentRecords[0].SOTTHD })}
                />
              </p>
            ) : null}
          </div>
        ) : null}
        <div className="flex justify-end py-3">
          {medicalRecords.length > 0 && (
            <Pagination
              simple
              defaultCurrent={1}
              total={medicalRecords.length}
              pageSize={recordsPerPage}
              onChange={(page) => setCurrentPage(page)}
            />
          )}
        </div>
      </div>
    </div>
  );
};

export default HoaDon;
