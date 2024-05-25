import { lichhen5 } from "../../fakedata/lhnv";
import ns from "~/fakedata/nhasi";
import "../../assets/styles/staff.css";
import StaffService from "../../services/staff";
import { Empty } from "antd";

import React, { useState, useEffect } from "react";
import {
  Form,
  Input,
  Button,
  Select,
  InputNumber,
  Badge,
  Dropdown,
  Pagination,
} from "antd";
import { ButtonGreen } from "../../components/button";
const { Item } = Form;

const NhaSi = ({ mans, tenns }) => {
  return (
    <>
      <div className="flex w-[440px]  gap-6 ">
        <Input className=" w-[300px]" value={mans} disabled />
        <Input className="w-[130px]" value={tenns} disabled />
      </div>
    </>
  );
};

const TaoLichHen = ({ handleTaoLichHen }) => {
  const [form] = Form.useForm();
  const [nhaSiList, setNhaSiList] = useState([]);
  const [chonNhaSi, setChonNhaSi] = useState("");
  useEffect(() => {
    StaffService.getAllDSNhaSi().then((res) => {
      setNhaSiList(res);
    });
  }, []);
  const inputNhaSi = () => {
    const tenNS = nhaSiList.find((item) => item.MANS === MANS).HOTEN;
    const newData = {
      MANS,
      HOTEN: tenNS,
    };
    setChonNhaSi([...chonNhaSi, newData]);
    form.resetFields();
  };

  const onFinish = (values) => {
    const data ={
      sodt : values.phoneNumber,
      mans : values.dentist,
      sott : values.appointmentNumber,
      lydokham: values.reason,
    };
    StaffService.taoLichHen(data).then((res) => {
      // load lại
      handleTaoLichHen();
    });
  };

  const handleCancel = () => {
    form.resetFields();
  };

  return (
    <div className="bg-[#FFFFFF] w-[550px] h-fit rounded-2xl pt-8 pb-0 px-10">
      <h1 className="text-xl mb-3 font-montserrat font-black">TẠO LỊCH HẸN</h1>
      <Form
        name="appointmentForm"
        form={form}
        onFinish={onFinish}
        labelCol={{ span: 24 }}
      >
        <Item
          name="dentist"
          label="Nha sĩ"
          rules={[{ required: true, message: "Vui lòng nhập Nha sĩ!" }]}
          wrapperCol={{ span: 24 }}
        >
          <Select
            className="w-72"
            placeholder="Chọn một nha sĩ."
            options={nhaSiList.map((item) => ({
              value: item.MANS,
              label: item.HOTEN,
            }))}
          />
        </Item>
        <Form.Item
          name="appointmentNumber"
          label="Số thứ tự lịch hẹn"
          rules={[
            { required: true, message: "Vui lòng nhập số thứ tự lịch hẹn!" },
          ]}
          wrapperCol={{ span: 24 }}
        >
          <InputNumber placeholder="Số thứ tự lịch rảnh của nha sĩ." />
        </Form.Item>
        <Form.Item
          name="phoneNumber"
          label="Số điện thoại"
          rules={[{ required: true, message: "Vui lòng nhập số điện thoại !" }]}
          wrapperCol={{ span: 24 }}
        >
          <Input placeholder="Nhập số điện thoại khách hàng." />
        </Form.Item>
        <Form.Item
          name="reason"
          label="Lý do khám"
          rules={[{ required: true, message: "Vui lòng nhập lý do khám!" }]}
          wrapperCol={{ span: 24 }}
        >
          <Input.TextArea
            minLength={10}
            maxLength={200}
            rows={4}
            placeholder="Mô tả tình trạng hiện tại và lý do khám."
          />
        </Form.Item>
        <Form.Item style={{ display: "flex", justifyContent: "flex-end" }}>
          <Button
            onClick={handleCancel}
            style={{ marginRight: 10, marginTop: 10 }}
            type="danger"
          >
            ĐẶT LẠI
          </Button>
          <ButtonGreen text="TẠO" func="" />
        </Form.Item>
      </Form>
    </div>
  );
};

const OneWorkSchedule = ({ data }) => {
  const detail = ({ mans, sott }) => {
    return [
      {
        key: "1",
        label: "Mã NS: " + mans,
      },
      {
        key: "2",
        label: "STT lịch: " + sott,
      },
    ];
  };

  return (
    <>
      {data.SODTKH !== null ? (
        <Badge.Ribbon text="Bận" color="#ACACAC">
          <div className="border-2.4 border-[#b8b8b8] rounded-md h-[40px] flex items-center p-3 mb-2 cursor-auto select-none">
            <Dropdown
              menu={{
                items: detail({ mans: data.MANS, sott: data.SOTTLH }),
              }}
            >
              <div className="font-montserrat font-semibold text-base text-[#acacac]">
                NS.
                <span>{data.HOTENNS}</span>
              </div>
            </Dropdown>
          </div>
        </Badge.Ribbon>
      ) : (
        <Badge.Ribbon text="Rảnh" color="blue">
          <div className="border-2.4 border-[#b8b8b8] rounded-md h-[40px] flex items-center p-3 mb-2 cursor-auto select-none">
            <Dropdown
              menu={{
                items: detail({ mans: data.MANS, sott: data.SOTTLR }),
              }}
            >
              <div className="font-montserrat font-semibold text-base">
                NS.
                <span>{data.HOTENNS}</span>
              </div>
            </Dropdown>
          </div>
        </Badge.Ribbon>
      )}
    </>
  );
};

const TitleSchedule = ({ maca }) => {
  let caContent = null;

  switch (maca) {
    case "CA001":
      caContent = <span>CA 1 | 9:00 - 11:00</span>;
      break;
    case "CA002":
      caContent = <span>CA 2 | 11:00 - 13:00</span>;
      break;
    case "CA003":
      caContent = <span>CA 3 | 13:00 - 15:00</span>;
      break;
    case "CA004":
      caContent = <span>CA 4 | 15:00 - 17:00</span>;
      break;
    case "CA005":
      caContent = <span>CA 5 | 17:00 - 19:00</span>;
      break;
    case "CA006":
      caContent = <span>CA 6 | 19:00 - 21:00</span>;
      break;
  }

  return caContent;
};

const ListLichhen = ({ data }) => {
  return (
    <div className="gap-0">
      <h1 className="text-montserrat text-blue font-bold text-base pb-1">
        <TitleSchedule maca={data.MACA} />
      </h1>
      {data.NHASI.map((item, index) => (
        <OneWorkSchedule key={index} data={item} />
      ))}
    </div>
  );
};

const XemLichTruc = (schedule) => {
  // ---------------------------------------
  // Sort ngày
  // Hàm so sánh ngày để sắp xếp
  const compareDates = (a, b) => {
    const dateA = new Date(a.NGAY.split("/").reverse().join("/"));
    const dateB = new Date(b.NGAY.split("/").reverse().join("/"));
    return dateA - dateB;
  };
  // Sắp xếp mảng lichhen5 theo ngày
  const sortedSchedule = schedule.schedule.sort(compareDates);

  // ---------------------------------------
  // Phân trang
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 1;

  const startIndex = (currentPage - 1) * itemsPerPage;
  const currentSchedule = sortedSchedule.slice(
    startIndex,
    startIndex + itemsPerPage
  );

  const onChange = (page) => {
    setCurrentPage(page);
  };

  // ---------------------------------------
  // Hàm sort Mã Ca
  const sortByMACA = (a, b) => {
    return a.MACA.localeCompare(b.MACA);
  };
  if (!currentSchedule[0] || !currentSchedule[0].CA) {
    // Viết gì đó vô đây đi
    return (
      <div>
        <Empty />
      </div>
    );
  }
  currentSchedule[0].CA.sort(sortByMACA);

  return (
    <div className="w-[480px]">
      <div className="bg-[#FFFFFF] w-[480px] rounded-2xl py-8 px-10">
        <h1 className="text-xl mb-4 font-montserrat font-black">
          LỊCH TRỰC NGÀY {currentSchedule[0].NGAY}
        </h1>
        <div className="rounded-none flex flex-col gap-6">
          {currentSchedule[0].CA.map((item, index) => (
            <ListLichhen data={item} key={index} />
          ))}
        </div>
      </div>
      <div className="flex justify-center mt-4">
        <Pagination
          simple
          current={currentPage}
          onChange={onChange}
          total={schedule.schedule.length}
          pageSize={itemsPerPage}
        />
      </div>
    </div>
  );
};

const DatLich = () => {
  const [lichHenData, setLichHenData] = useState(null);
  const fetchData = async () => {
    try {
      const res = await StaffService.getLichRanhNS();
      setLichHenData(res);
    } catch (error) {
      console.error("Lỗi khi lấy dữ liệu lịch hẹn:", error);
    }
  };

  const handleTaoLichHen = () => {
    fetchData(); // Gọi hàm fetchData để cập nhật lại dữ liệu lịch hẹn
  };

  useEffect(() => {
    fetchData(); // Gọi hàm fetchData để lấy dữ liệu khi component được tạo
  }, []);

  return (
    <>
      <div className="  min-h-[700px] flex gap-6 justify-center">
        <TaoLichHen handleTaoLichHen={handleTaoLichHen} />
        {lichHenData !== null ? (
          <XemLichTruc schedule={lichHenData || []} />
        ) : (
          <div className="w-[480px]">
            <div className="bg-[#FFFFFF] w-[480px] rounded-2xl py-8 px-10">
              <Empty />
            </div>
          </div>
        )}

      </div>
    </>
  );
};

export default DatLich;
