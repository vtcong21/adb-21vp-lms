import React, { memo, useState, useEffect } from "react";
import { message, Empty } from "antd";
import { useNavigate } from "react-router-dom";
import DentistService from "../../services/dentist";
import { ButtonGreen, ButtonBorderGreen } from "../../components/button";
import TaoBenhAnMoi from "../../components/dentist/TaoBenhAnMoi";
import WorkSchedule from "../../components/dentist/WorkSchedule";
import { useSelector } from "react-redux";

function mergeStringDateTime(gioBatDau, ngay) {
  const gioBatDauMoi = gioBatDau.slice(0, 5);

  return `${ngay} - ${gioBatDauMoi} `;
}

//----------------------------------------------------------------------

const ThongTinLichHen = memo(({ props, funcTaoHSB }) => {
  const sdtkh = props.SODTKH;

  const navigate = useNavigate();
  const HandleBenhAnCu = () => {
    navigate(`/xem-benh-an-cu/${sdtkh}`);
    message.success("Đã chuyển đến trang xem bệnh án cũ", 5);
  };

  const dateTime = mergeStringDateTime(props.GIOBATDAU, props.NGAY);

  return (
    <>
      <div
        className="bg-white w-[440px] h-[100%] rounded-3xl mx-2 py-4 px-8 grid grid-rows-[1fr auto]"
        style={{
          borderRadius: "35px",
          boxShadow: "0px 4px 4px 0px rgba(0, 0, 0, 0.08)",
        }}
      >
        <div>
          <h1 className="text-2xl font-montserrat mt-2 mb-6 text-center">
            THÔNG TIN LỊCH HẸN
          </h1>
          <div>
            <p className="leading-9 font-montserrat font-semibold text-base text-#4B4B4B">
              <span className="text-grey">Ngày, giờ: </span>
              {dateTime}
            </p>
            <p className="leading-9 font-montserrat font-semibold text-base text-#4B4B4B">
              <span className="text-grey">Số điện thoại: </span>
              {props.SODTKH}
            </p>
            <p className="leading-9 font-montserrat font-semibold text-base text-#4B4B4B">
              <span className="text-grey">Họ tên: </span>
              {props.HOTENKH}
            </p>
            <p className="leading-9 font-montserrat font-semibold text-base text-#4B4B4B">
              <span className="text-grey">Lý do khám: </span>
            </p>
            <p className="leading-7 font-montserrat font-semibold text-base text-#4B4B4B">
              {props.LYDOKHAM}
            </p>
          </div>
        </div>
        <div className="flex justify-between mt-5 items-end">
          <ButtonBorderGreen text="Bệnh án cũ" func={() => HandleBenhAnCu()} />
          <ButtonGreen text="Tạo bệnh án mới" func={() => funcTaoHSB(props)} />
        </div>
      </div>
    </>
  );
});

const XemLichTruc = () => {
  const user = useSelector((state) => state.user);
  const [detail, setDetail] = useState(null);
  const [newMeidcalRecord, setNewMeidcalRecord] = useState(null);
  const [lichhen4, setTableLH] = useState([]);
  const [dataLoaded, setDataLoaded] = useState(false);
  useEffect(() => {
    DentistService.xemTableLichNS(user.MANS).then((res) => {
      setTableLH(res || []);
    });
  }, []);
  const changeDetail = (info) => {
    setDetail(info);
  };

  const changeNewMeidcalRecord = (infoClient) => {
    setNewMeidcalRecord(infoClient);
  };
  return (
    <>
      <div className="flex flex-col">
        <div className="flex flex-row gap-2">
          {lichhen4 !== null ? (
            <WorkSchedule data={lichhen4} func={changeDetail} />
          ) : (
            <div
              className="bg-white w-[440px] h-[100%] rounded-3xl mx-2 py-6 px-8"
              style={{
                borderRadius: "35px",
                boxShadow: "0px 4px 4px 0px rgba(0, 0, 0, 0.10)",
              }}
            >
              <h1 className="text-2xl font-montserrat mb-5 text-center">
                THÔNG TIN LỊCH HẸN
              </h1>
              <Empty />
            </div>
          )}
          {detail !== null ? (
            <ThongTinLichHen
              props={detail || []}
              funcTaoHSB={changeNewMeidcalRecord}
            />
          ) : (
            <div
              className="bg-white w-[440px] h-fit rounded-3xl mx-2 py-6 px-8"
              style={{
                borderRadius: "35px",
                boxShadow: "0px 4px 4px 0px rgba(0, 0, 0, 0.08)",
              }}
            >
              <h1 className="text-2xl font-montserrat mb-5 text-center">
                THÔNG TIN LỊCH HẸN
              </h1>
              <Empty />
            </div>
          )}
        </div>
        <div className="mt-5">
          {newMeidcalRecord !== null && (
            <div>
              <TaoBenhAnMoi props={newMeidcalRecord || []} />
            </div>
          )}
        </div>
      </div>
    </>
  );
};
export default XemLichTruc;
