import React, { useState, useEffect } from "react";
import { Card, Pagination, Modal, Button, Empty } from "antd";
import { useSelector, useDispatch } from "react-redux";
import moment from "moment";
import lichhen from "../../fakedata/lichhen";
import GuestService from "../../services/guest";

import "../../assets/styles/guest.css";

const isDaKham = (gioKetThuc) => {
  const gioHienTai = new Date();
  const gioKetThucDate = new Date(gioKetThuc);
  return gioKetThuc > gioHienTai;
};

function isoDateToLocalDate(ISOTimeString, offsetInMinutes) {
  var newTime = new Date(ISOTimeString);
  return new Date(newTime.getTime() - offsetInMinutes * 60000);
}

function formatTime(inputDate) {
  const date = new Date(inputDate);
  const hours = date.getUTCHours().toString().padStart(2, '0'); // Lấy giờ theo múi giờ UTC
  const minutes = date.getUTCMinutes().toString().padStart(2, '0');
  return `${hours}:${minutes}`;
}

const XemLichHen = () => {
  const [fetchedAppointment, setFetchedAppointment] = useState([]);
  const [currentPage, setCurrentPage] = useState(1);
  const [cancelModalVisible, setCancelModalVisible] = useState(false);
  const [cancelingAppointment, setCancelingAppointment] = useState(null);
  const appointmentsPerPage = 6;
  const dispatch = useDispatch();
  const user = useSelector((state) => state.user);

  useEffect(() => {
    GuestService.lichHen(user.SODT).then((res) => {
      setFetchedAppointment(res || []);
    });
  }, [currentPage]);

  // Sắp xếp lịch hẹn chưa khám lên trước
  const sortedAppointments = fetchedAppointment?.sort((a, b) => {
    const isDaKhamA = isDaKham(a.NGAY);
    const isDaKhamB = isDaKham(b.NGAY);

    // Sắp xếp theo trạng thái "đã khám" và ngày
    return isDaKhamA === isDaKhamB
      ? new Date(a.NGAY) - new Date(b.NGAY)
      : isDaKhamA - isDaKhamB;
  });

  const indexOfLastAppointment = currentPage * appointmentsPerPage;
  const indexOfFirstAppointment = indexOfLastAppointment - appointmentsPerPage;
  const currentAppointments = sortedAppointments.slice(
    indexOfFirstAppointment,
    indexOfLastAppointment
  );

  const showCancelModal = (appointment) => {
    setCancelingAppointment(appointment);
    setCancelModalVisible(true);
  };

  const handleCancel = async () => {
    try {
      // Lấy thông tin MANS và SOTT từ lịch đang hủy
      const { MANS, SOTT } = cancelingAppointment;
      const data = {
        sdt: user.SODT,
        stt: SOTT,
        mans: MANS,
      };

      GuestService.deleteLichHen(data).then((res) => {
        if (res.success) {
          // Cập nhật lại state sau khi xóa
          setFetchedAppointment((prevAppointments) =>
            prevAppointments.filter((appointment) => appointment.SOTT !== SOTT)
          );
        }
      });

      // Đóng modal
      setCancelModalVisible(false);
    } catch (error) {
      // Xử lý lỗi nếu cần
      console.error("Error cancelling appointment:", error);
    }
  };

  return (
    <div>
      {sortedAppointments.length === 0 ? (
        <Empty description="Không có lịch hẹn khám nào." />
      ) : (
        <>
          <div className="grid lg:grid-cols-3 gap-5 md:grid-cols-2 grid-cols-1">
            {currentAppointments.map((lich, index) => (
              <Card
                key={index}
                style={{
                  borderRadius: "30px",
                  boxShadow: "0px 4px 4px 0px rgba(0, 0, 0, 0.10)",
                  overflow: "hidden",
                  padding: "0.8em",
                  height: "100%",
                }}
              >
                <p className="leading-7 font-montserrat font-semibold text-base text-#4B4B4B mb-3 break-words">
                  <span className="text-grey">Ngày, giờ: </span>
                  {moment(lich.NGAY).format("DD/MM/yyyy")} -{" "}
                  {formatTime(isoDateToLocalDate(lich.GIOBATDAU, 0))}
                </p>
                <p className="leading-7 font-montserrat font-semibold text-base text-#4B4B4B mb-3 break-words">
                  <span className="text-grey">Nha sĩ: </span>
                  {lich.TENNS}
                </p>
                <p className="leading-7 font-montserrat font-semibold text-base text-#4B4B4B mb-3 break-words">
                  <span className="text-grey">Họ tên khách: </span>
                  {user.HOTEN}
                </p>
                <p className="leading-7 font-montserrat font-semibold text-base text-#4B4B4B mb-14 break-words">
                  <span className="text-grey">
                    Lý do khám: <br />
                  </span>
                  {lich.LYDOKHAM}
                </p>
                <div className="absolute bottom-7 right-10">
                  {isDaKham(lich.NGAY) ? (
                    <p className="rounded-md text-grin font-montserrat p-2 underline decoration-auto cursor-default">
                      ĐÃ KHÁM
                    </p>
                  ) : (
                    <button
                      className="rounded-md text-rose-500 font-montserrat p-2 underline decoration-auto border-2 border-rose-500 hover:bg-rose-500 hover:text-white"
                      onClick={() => showCancelModal(lich)}
                    >
                      HỦY LỊCH HẸN
                    </button>
                  )}
                </div>
              </Card>
            ))}
          </div>
          <div className="flex justify-center py-3">
            {sortedAppointments.length > 0 && (
              <Pagination
                simple
                defaultCurrent={1}
                total={sortedAppointments.length}
                pageSize={appointmentsPerPage}
                onChange={(page) => setCurrentPage(page)}
              />
            )}
          </div>
        </>
      )}
      <Modal
        title={<div className="mt-2 font-black">Xác nhận hủy lịch hẹn</div>}
        open={cancelModalVisible}
        onOk={handleCancel}
        onCancel={() => setCancelModalVisible(false)}
        footer={[
          <div className="mt-10 mb-3">
            <Button
              key="back"
              onClick={() => setCancelModalVisible(false)}
              className="bg-gray-300 custom-button-cancel font-montserrat"
            >
              Quay lại
            </Button>
            ,
            <Button
              key="submit"
              style={{ color: "white", border: "none" }}
              onClick={handleCancel}
              className="text-white bg-rose-500 hover:bg-rose-600 hover:text-white custom-button-accept font-montserrat"
            >
              Xác nhận hủy lịch
            </Button>
            ,
          </div>,
        ]}
      >
        <p className="mt-4">Bạn có chắc chắn muốn hủy lịch hẹn?</p>
      </Modal>
    </div>
  );
};
export default XemLichHen;
