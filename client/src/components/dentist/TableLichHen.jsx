import { Button } from "antd";
import React, { useState, useEffect } from "react";
import { message, Pagination } from "antd";
import moment from "moment";
import {
  TwoStateBlue,
  StatePink,
  StateGrey,
  TwoStateBorder,
} from "~/components/buttonTwoState";
import { ButtonGreen } from "~/components/button";
import { CloseCircleOutlined } from "@ant-design/icons";
import DentistService from "../../services/dentist/index";
import { useSelector, useDispatch } from "react-redux";

const datCa = [];
const huyCa = [];

function compareDates(dateA, dateB) {
  const date1 = new Date(dateA);
  const date2 = new Date(dateB);

  if (date1.getTime() === date2.getTime()) {
    return 0; // A = B
  } else if (date1.getTime() < date2.getTime()) {
    return -1; // A < B
  } else {
    return 1; // B > A
  }
  // Note hàm getTime() chuyển thành ký tự số theo mili giây tính từ 1/1/1970
}

function selectWeekDays(date) {
  const week = Array(7)
    .fill(new Date(date))
    .map((el, idx) => new Date(el.setDate(el.getDate() - el.getDay() + idx)));
  return week;
}

function separateDaysByComparison(date) {
  // Lấy từ thứ 2 đến thứ 6
  const week = selectWeekDays(date);
  const weekdays = week.slice(1, 7);
  const dayNow = moment(date).format("YYYY-MM-DD");

  const pastDays = [];
  const futureDays = [];
  const weekDayNames = [
    "THỨ HAI",
    "THỨ BA",
    "THỨ TƯ",
    "THỨ NĂM",
    "THỨ SÁU",
    "THỨ BẢY",
  ];
  let temp;

  weekdays.forEach((day, index) => {
    const formattedDay = moment(day).format("YYYY-MM-DD");
    if (
      moment(formattedDay, "YYYY-MM-DD", true).isValid() &&
      compareDates(formattedDay, dayNow) <= 0
    ) {
      temp = convertDateFormat(formattedDay);
      pastDays.push({ THU: weekDayNames[index], NGAY: temp });
    } else {
      temp = convertDateFormat(formattedDay);
      futureDays.push({ THU: weekDayNames[index], NGAY: temp });
    }
  });

  return [pastDays, futureDays];
}

function getNextSundays(startDate, numberOfSundays) {
  const sundays = [];
  const currentDate = new Date(startDate);

  while (sundays.length < numberOfSundays) {
    if (currentDate.getDay() === 0) {
      sundays.push(new Date(currentDate));
    }
    currentDate.setDate(currentDate.getDate() + 1);
  }

  return sundays;
}

function get5WeeksInfo(week) {
  const nextSundays = getNextSundays(today, 3);
  nextSundays.unshift(today);

  const next30Days = new Date(today);
  next30Days.setDate(today.getDate() + 30);
  nextSundays.push(next30Days);

  return nextSundays;
}

function createInfo30Days(week) {
  const sundaysInfo = get5WeeksInfo(week);
  const result = [];

  for (let i = 0; i < sundaysInfo.length; i++) {
    result.push([...separateDaysByComparison(sundaysInfo[i])]);
  }

  // result[4].reverse();
  return result;
}

const today = new Date();
const week = selectWeekDays(today);

const info30Days = createInfo30Days(week);

// Hàm chuyển đổi từ 'YYYY-MM-DD' sang 'DD/MM/YYYY'
function convertDateFormat(dateString) {
  return moment(dateString, "YYYY-MM-DD").format("DD/MM/YYYY");
}

function findIndexByDate(caMotNgayArray, targetDate) {
  for (let i = 0; i < caMotNgayArray.length; i++) {
    if (caMotNgayArray[i].NGAY === targetDate) {
      return i; // Trả về chỉ số của phần tử nếu tìm thấy
    }
  }

  return -1; // Trả về -1 nếu không tìm thấy
}

const CreateAShift = ({ data, isPassDay, index, customKey }) => {
  const pushPopDatCa = (el) => {
    const changeStructure = {
      MACA: el.slice(0, 5),
      NGAY: el.slice(6),
    };

    const indexToRemove = datCa.findIndex(
      (item) =>
        item.MACA === changeStructure.MACA && item.NGAY === changeStructure.NGAY
    );

    if (indexToRemove !== -1) {
      datCa.splice(indexToRemove, 1);
      console.log(`Chuỗi "${el}" đã được xóa khỏi mảng datCa.`);
    } else {
      datCa.push(changeStructure);
      console.log(`Đã thêm chuỗi "${el}" vào mảng datCa.`);
    }
    console.log("datCa", datCa);
  };

  const pushPopHuyCa = (el) => {
    const changeStructure = {
      MACA: el.slice(0, 5),
      SOTT: data.SOTTLH,
    };

    if (huyCa == []) {
      huyCa.push(changeStructure);
    } else {
      const indexToRemove = huyCa.findIndex(
        (item) =>
          item.MACA === changeStructure.MACA &&
          item.NGAY === changeStructure.NGAY
      );

      if (indexToRemove !== -1) {
        huyCa.splice(indexToRemove, 1);
        console.log(`Chuỗi "${el}" đã được xóa khỏi mảng huyCa.`);
      } else {
        huyCa.push(changeStructure);
        console.log(`Đã thêm chuỗi "${el}" vào mảng huyCa.`);
      }
    }
    console.log("huyCa", huyCa);
  };

  let shiftContent, caContent;

  if (data != null && index == null) {
    switch (data.MACA) {
      case "CA001":
        caContent = <span>9:00</span>;
        break;
      case "CA002":
        caContent = <span>11:00</span>;
        break;
      case "CA003":
        caContent = <span>13:00</span>;
        break;
      case "CA004":
        caContent = <span>15:00</span>;
        break;
      case "CA005":
        caContent = <span>17:00</span>;
        break;
      case "CA006":
        caContent = <span>19:00</span>;
        break;
    }

    if (isPassDay === 1) {
      switch (data.STATUS) {
        case "waiting":
          shiftContent = (
            <TwoStateBlue
              text={caContent}
              func={pushPopHuyCa}
              id={customKey}
              array={huyCa}
            />
          );
          break;
        case "ordered":
          shiftContent = <StatePink text={caContent} />;
          break;
        case "full":
          shiftContent = <StateGrey text={caContent} />;
          break;
        default:
          shiftContent = (
            <TwoStateBorder
              text={caContent}
              func={pushPopDatCa}
              id={customKey}
              array={datCa}
            />
          );
          break;
      }
    } else {
      shiftContent = <StateGrey text={caContent} />;
    }
  } else if (index != null) {
    switch (index) {
      case 1:
        caContent = <span>9:00</span>;
        break;
      case 2:
        caContent = <span>11:00</span>;
        break;
      case 3:
        caContent = <span>13:00</span>;
        break;
      case 4:
        caContent = <span>15:00</span>;
        break;
      case 5:
        caContent = <span>17:00</span>;
        break;
      case 6:
        caContent = <span>19:00</span>;
        break;
    }

    shiftContent = (
      <TwoStateBorder
        text={caContent}
        func={pushPopDatCa}
        id={customKey}
        array={datCa}
      />
    );
  }

  return <div className="mb-3">{shiftContent}</div>;
};

const OneDay = ({ caMotNgay }) => {
  const temp = [
    { MACA: "CA001", STATUS: "" },
    { MACA: "CA002", STATUS: "" },
    { MACA: "CA003", STATUS: "" },
    { MACA: "CA004", STATUS: "" },
    { MACA: "CA005", STATUS: "" },
    { MACA: "CA006", STATUS: "" },
  ];

  const pageSize = 1; // Số lượng phần tử trên mỗi trang
  const [currentPage, setCurrentPage] = useState(1);

  const onChangePage = (page) => {
    setCurrentPage(page);
  };

  const slicedInfo30Days = info30Days.slice(
    (currentPage - 1) * pageSize,
    currentPage * pageSize
  );

  return (
    <div>
      {slicedInfo30Days.map((subArray, jndex) => (
        <div key={jndex}>
          {/* Nếu là 4 tuần đầu thì vô đây */}
          {currentPage < info30Days.length ? (
            <div className="grid grid-cols-6 col-span-2 gap-2 text-center">
              {/* Các ngày trong quá khứ thì tô xám */}
              {subArray[0].map((element, index) => (
                <div key={index}>
                  <h5 className="font-montserrat text-md">{element.THU}</h5>
                  <div className="font-montserrat text-md mb-5">
                    {element.NGAY.slice(0, 5)}
                  </div>
                  <span key={`${jndex}-pass1-4`}>
                    {temp.map((shift, index2) => (
                      <CreateAShift
                        key={`${jndex}-${index2}`}
                        customKey={shift.MACA + "-" + element.NGAY}
                        maca={shift.MACA}
                        ngay={element.NGAY}
                        data={shift}
                        isPassDay={0}
                      />
                    ))}
                  </span>
                </div>
              ))}
              {/* Các ngày trong tương lai thì có 2 dạng */}
              {subArray[1].map((element, index) => (
                <div key={index}>
                  <h5 className="font-montserrat text-md">{element.THU}</h5>
                  <div className="font-montserrat text-md mb-5">
                    {element.NGAY.slice(0, 5)}
                  </div>
                  <span key={`${jndex}-futur1-4`}>
                    {(() => {
                      let index3 = findIndexByDate(caMotNgay, element.NGAY);
                      // Dạng 1 : Nếu ngày có xuất hiện trong db thì thực hiện điều này
                      if (index3 === -1) {
                        let divs = [];
                        for (let k = 1; k < 7; k++) {
                          divs.push(
                            <div>
                              <CreateAShift
                                key={`${jndex}-${k}`}
                                customKey={
                                  temp[k - 1].MACA + "-" + element.NGAY
                                }
                                maca={temp[k - 1].MACA}
                                ngay={element.NGAY}
                                data={null}
                                isPassDay={1}
                                index={k}
                              />
                            </div>
                          );
                        }
                        return divs;
                      } else {
                        // Dạng 2 : Nếu ngày không xuất hiện trong db thì tô xanh hết
                        return caMotNgay[index3].CA.map((shift, index4) => (
                          <CreateAShift
                            key={`${jndex}-${index4}`}
                            customKey={shift.MACA + "-" + element.NGAY}
                            maca={shift.MACA}
                            ngay={element.NGAY}
                            data={shift}
                            isPassDay={1}
                          />
                        ));
                      }
                    })()}
                  </span>
                </div>
              ))}
            </div>
          ) : (
            // Nếu là tuần cuối thì vô đây
            <div className="grid grid-cols-6 col-span-2 gap-2 text-center">
              {/* Nếu trong 30 ngày kể từ ngày hiện tại thì ở đây */}
              {subArray[0].map((element, index) => (
                <div key={index}>
                  <h5 className="font-montserrat text-md">{element.THU}</h5>
                  <div className="font-montserrat text-md mb-5">
                    {element.NGAY.slice(0, 5)}
                  </div>
                  <span key={`${jndex}-pass5`}>
                    {(() => {
                      let index5 = findIndexByDate(caMotNgay, element.NGAY);
                      // Dạng 1 : Nếu ngày có xuất hiện trong db thì thực hiện điều này
                      if (index5 === -1) {
                        let divs = [];
                        for (let k = 1; k < 7; k++) {
                          divs.push(
                            <div>
                              <CreateAShift
                                key={`${jndex}-${k}`}
                                customKey={
                                  temp[k - 1].MACA + "-" + element.NGAY
                                }
                                maca={temp[k - 1].MACA}
                                ngay={element.NGAY}
                                data={null}
                                isPassDay={1}
                                index={k}
                              />
                            </div>
                          );
                        }
                        return divs;
                      } else {
                        // Dạng 2 : Nếu ngày không xuất hiện trong db thì tô xanh hết
                        return caMotNgay[index5].CA.map((shift, index6) => (
                          <div key={`${jndex}-${index6}`}>
                            <CreateAShift
                              key={`${jndex}-${index6}`}
                              customKey={shift.MACA + "-" + element.NGAY}
                              maca={shift.MACA}
                              ngay={element.NGAY}
                              data={shift}
                              isPassDay={1}
                            />
                          </div>
                        ));
                      }
                    })()}
                  </span>
                </div>
              ))}
              {/* Nếu quá 30 ngày thì ở đây */}
              {subArray[1].map((element, index) => (
                <div key={index}>
                  <h5 className="font-montserrat text-md">{element.THU}</h5>
                  <div className="font-montserrat text-md mb-5">
                    {element.NGAY.slice(0, 5)}
                  </div>
                  <span key={`${jndex}-futur5`}>
                    {temp.map((shift, index7) => (
                      <CreateAShift
                        key={`${jndex}-${index7}`}
                        customKey={shift.MACA + "-" + element.NGAY}
                        maca={shift.MACA}
                        ngay={element.NGAY}
                        data={shift}
                        isPassDay={0}
                      />
                    ))}
                  </span>
                </div>
              ))}
            </div>
          )}
        </div>
      ))}
      <Pagination
        current={currentPage}
        pageSize={pageSize}
        total={info30Days.length}
        onChange={onChangePage}
        className="flex justify-center mt-3 text-md font-montserrat"
      />
    </div>
  );
};

const TableLichHen = ({ data }) => {
  const dispatch = useDispatch();
  const user = useSelector((state) => state.user);
  const handleSubmit = async () => {
    // Đặt lịch
    for (const ca of datCa) {
      const resCa = await DentistService.dangKyLichRanh({
        mans: user.MANS,
        maca: ca.MACA,
        ngay: moment(ca.NGAY, "DD/MM/YYYY").format("YYYY-MM-DD"),
      });
      //Kiểm tra lỗi khi thêm đặt lịch
      if (!resCa) {
        message.error("Lỗi khi đặt lịch");
        console.error("Lỗi khi đặt lịch");
        return;
      }
    }
    for (const ca of huyCa) {
      const resCa = await DentistService.huyLichRanh({
        mans: user.MANS,
        stt: ca.SOTT,
      });

      // Kiểm tra lỗi khi hủy lịch
      if (!resCa) {
        message.error("Lỗi khi hủy lịch");
        console.error("Lỗi khi hủy lịch");
        return;
      }
    }
    datCa.splice(0, datCa.length);
    huyCa.splice(0, huyCa.length);
    dispatch(changeState());
  };

  const cancelData = () => {
    datCa.splice(0, datCa.length);
    huyCa.splice(0, huyCa.length);
  };
  return (
    <>
      <div className=" bg-white rounded-3xl h-fit w-[1030px] mx-2 py-8 px-12">
        <h1 className="text-2xl font-montserrat mb-8 text-center">
          ĐĂNG KÝ LỊCH TRỰC
        </h1>
        <OneDay caMotNgay={data} />
        <div className="mt-9 grid grid-cols-2 gap-0">
          {/* left */}
          <div className="col-span-1">
            <div className="flex my-3">
              <div className="bg-white border-3 border-[#A1A1A1] w-[29px] h-[29px] rounded-lg"></div>
              <div className="font-montserrat ml-3">
                {" "}
                Đã đủ số lượng nha sĩ trực ca
              </div>
            </div>
            <div className="flex my-3">
              <div className="bg-white border-3 border-blue border-dashed w-[29px] h-[29px] rounded-lg"></div>
              <div className="font-montserrat ml-3"> Ca trực có thể chọn</div>
            </div>
            <div className="flex my-3">
              <div className="bg-blue border-3 border-blue w-[29px] h-[29px] rounded-lg"></div>
              <div className="font-montserrat ml-3"> Ca trực đang chọn</div>
            </div>
            <div className="flex my-3">
              <div className="bg-pinkk border-3 border-pinkk w-[29px] h-[29px] rounded-lg"></div>
              <div className="font-montserrat ml-3">
                {" "}
                Khách hàng đã đặt lịch này
              </div>
            </div>
          </div>
          {/* right */}
          <div className="col-span-1 justify-self-end self-end">
            <ButtonGreen
              text="ĐĂNG KÝ"
              className="w-[150px] rounded-2xl"
              func={() => handleSubmit()}
            />
          </div>
        </div>
      </div>
    </>
  );
};

export default TableLichHen;
