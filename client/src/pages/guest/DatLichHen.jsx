import React, { useEffect, useState } from "react";
import { message, Steps } from "antd";
import { Input } from "antd";
const { TextArea } = Input;
import GuestService from "../../services/guest";
import { useDispatch, useSelector } from "react-redux";
import { booking, deleteOder } from "../../redux/features/orderSlice";
import Buttons from "../../components/button";
import { ButtonBlue } from "../../components/button";
import { Spin } from "antd";
import { LoadingOutlined } from "@ant-design/icons";
import { useNavigate } from "react-router-dom";

const NhaSi = ({ TENNS, MAND }) => {
  let init = "";
  const order = useSelector((state) => state.order);
  if (order.mans === MAND) {
    init = "bg-[#1783D2] text-white";
  }
  const dispath = useDispatch();
  const handleOnClick = () => {
    dispath(booking({ mans: MAND, tenns: TENNS }));
    message.success(`Đã chọn nha sĩ ${TENNS}`);
  };
  return (
    <>
      <button
        style={{
          transition: "all 0.4s ",
        }}
        onClick={() => handleOnClick()}
        className={`p-4 border ${init} hover:border-[#86b6f8] hover:text-[17px] border-slate-400 h-16 min-w-[220px] rounded-sm hover:bg-sky-500  focus:bg-[#1783D2] focus:text-white   `}
      >
        <h1>{TENNS}</h1>
      </button>
    </>
  );
};

const Ca = ({ GIOBD, GIOKT, NGAY, SOTT, MANS }) => {
  const order = useSelector((state) => state.order);
  let color = "";
  if (order.sott + order.mans === SOTT + MANS) {
    color = "bg-[#1783D2] text-white";
  }

  const dispath = useDispatch();
  const handleOnClick = (sott) => {
    dispath(
      booking({
        sott: sott,
        GIOBATDAU: GIOBD,
        GIOKETTHUC: GIOKT,
        NGAY: NGAY,
        mans: MANS,
      })
    );
    message.success(`Đã chọn ca bắt đầu lúc ${GIOBD} ngày ${NGAY}`, 4);
  };

  return (
    <>
      <button
        style={{
          transition: "all 0.4s ",
        }}
        onClick={() => handleOnClick(SOTT)}
        className={`p-2 border      
         border-slate-400 min-h-16
          min-w-[20px] rounded-sm  
         hover:bg-sky-500
         hover:border-[#5184cc]
          focus:bg-[#1783D2]
            ${color}
          `}
      >
        <div className="flex flex-col ">
          <div className="flex gap-3 mb-3 ">
            Ngày : <h1 className="ml-auto ">{NGAY}</h1>
          </div>
          <div className="flex gap-3 ">
            Bắt đầu : <h1 className="ml-auto ">{GIOBD}</h1>
          </div>{" "}
          <div className="flex gap-3 ">
            Kết thúc : <h1 className="ml-auto ">{GIOKT}</h1>
          </div>
        </div>
      </button>
    </>
  );
};

const ChonNhaSi = () => {
  const [nhasi, setNhaSi] = useState([]);
  useEffect(() => {
    GuestService.getAllDSNS().then((res) => {
      setNhaSi(res);
    });
  }, []);
  return (
    <>
      <div className="flex justify-center ">
        <div className="grid grid-cols-3 grid-rows-3 gap-4">
          <NhaSi TENNS="Nha Si Bất Kỳ" MAND="" />
          {nhasi?.map((item, index) => (
            <NhaSi key={index} TENNS={item.HOTEN} MAND={item.MANS} />
          ))}
        </div>
      </div>
    </>
  );
};

const ChonCa = () => {
  const order = useSelector((state) => state.order);

  const [lichRanh, setLichRanh] = useState([]);
  function formatTime(inputDate) {
    const date = new Date(inputDate);
    const hours = date.getUTCHours().toString().padStart(2, "0"); // Lấy giờ theo múi giờ UTC
    const minutes = date.getUTCMinutes().toString().padStart(2, "0");
    return `${hours}:${minutes}`;
  }
  function formatDate(inputDate) {
    const date = new Date(inputDate);
    const day = date.getDate();
    const month = date.getMonth() + 1;
    const year = date.getFullYear();
    return `${day}/${month}/${year}`;
  }

  useEffect(() => {
    if (order.mans === "") {
      GuestService.xemLRChuaDatTatCaNSTheoNgay().then((res) => {
        setLichRanh(res);
      });
    } else {
      GuestService.lichRanh().then((res) => {
        const new_lichRanh = res.filter((item) => {
          return item.MANS === order.mans;
        });
        if (new_lichRanh.length === 0) {
          message.info("Nha sĩ không có lịch rảnh");
          return;
        }
        const new_lichRanhformat = new_lichRanh.map((item) => {
          return {
            ...item,
            NGAY: formatDate(new Date(item.NGAY)),
            GIOBATDAU: formatTime(new Date(item.GIOBATDAU)),
            GIOKETTHUC: formatTime(new Date(item.GIOKETTHUC)),
          };
        });
        setLichRanh(new_lichRanhformat);
      });
    }
  }, []);

  return (
    <>
      <div className="flex justify-center">
        <div className=" grid grid-cols-3 grid-rows-3 gap-4">
          {lichRanh?.map((item, index) => (
            <Ca
              key={index}
              NGAY={item.NGAY}
              GIOBD={item.GIOBATDAU}
              GIOKT={item.GIOKETTHUC}
              MANS={item.MANS}
              SOTT={item.SOTT}
            />
          ))}
        </div>
      </div>
    </>
  );
};

const LyDoKham = () => {
  const order = useSelector((state) => state.order);
  const [lydokham, setLyDoKham] = useState(order.lydokham);
  const [isLoading, setIsLoading] = useState(false);
  const user = useSelector((state) => state.user);
  const dispatch = useDispatch();
  const timeoutRef = React.useRef(null);

  useEffect(() => {
    clearTimeout(timeoutRef.current);
    if (lydokham !== "") {
      setIsLoading(true);

      timeoutRef.current = setTimeout(() => {
        dispatch(booking({ lydokham: lydokham, sodt: user.SODT }));
        setIsLoading(false);
      }, 1000);
    }
  }, [lydokham, dispatch, user.SODT]);

  return (
    <>
      <div className=" flex justify-center mb-3">
        <h1 className=" ">Xin vui lòng nhập lý do khám</h1>
        {isLoading ? (
          <Spin
            indicator={
              <LoadingOutlined className="text-sm ml-3 text-gray-600" spin />
            }
          />
        ) : (
          <></>
        )}
      </div>
      <div className="flex justify-center">
        <div className="w-[60%]">
          <TextArea
            className="w-full"
            rows={4}
            value={lydokham}
            onChange={(e) => setLyDoKham(e.target.value)}
          />
        </div>
      </div>
    </>
  );
};

const MenuItem = ({ text, content }) => {
  return (
    <>
      <div className="flex gap-4">
        <div className="w-[210px]">
          <h1 className="text-lg font-medium text-gray-600">{text}: </h1>
        </div>
        <div className=" w-[650px]">
          <h1 className="text-lg font-semibold text-black">{content} </h1>
        </div>
      </div>
    </>
  );
};

const XacNhan = () => {
  const order = useSelector((state) => state.order);
  const [nhasi, setNhaSi] = useState([]);
  useEffect(() => {
    GuestService.getAllDSNS().then((res) => {
      setNhaSi(res);
    });
  }, []);
  let result = nhasi.filter((item) => item.MANS === order.mans);
  const newHoten = result[0]?.HOTEN;
  return (
    <>
      <div className="flex justify-center flex-col text-neutral-900">
        <div className="mx-auto  w-[900px] p-4">
          <h1 className="text-2xl font-bold mb-5">Đây là thông tin của bạn:</h1>
          <MenuItem text="Số  điên thoại của bạn" content={order.sodt} />
          <MenuItem text="Tên nha sĩ" content={newHoten} />
          <MenuItem text="Mã nha sĩ" content={order.mans} />
          <MenuItem text="Ngày khám" content={order.CA.NGAY} />
          <MenuItem text="Bắt đầu" content={order.CA.GIOBATDAU} />
          <MenuItem text="Kết thúc" content={order.CA.GIOKETTHUC} />
          <MenuItem text="Lý do khám" content={order.lydokham} />
        </div>
      </div>
    </>
  );
};
const steps = [
  {
    title: "Chọn Nha Sĩ",
    content: <ChonNhaSi />,
  },
  {
    title: "Chọn Ngày",
    content: <ChonCa />,
  },
  {
    title: "Lý do khám",
    content: <LyDoKham />,
  },
  {
    title: "Xác nhận",
    content: <XacNhan />,
  },
];

const DatLichContainer = () => {
  const [current, setCurrent] = useState(0);
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const order = useSelector((state) => state.order);
  const next = () => {
    if (current === 0 && order.mans === "") {
      message.info("Bạn đã chọn nha sĩ bất kỳ");
    }
    if (current === 1 && order.sott === "") {
      message.error("Vui lòng chọn ca khám");
      return;
    }
    setCurrent(current + 1);
  };
  const prev = () => {
    setCurrent(current - 1);
  };
  const items = steps.map((item) => ({
    key: item.title,
    title: item.title,
    content: item.content,
  }));

  const handleBooking = async () => {
    if (order.mans === "") {
      message.error("Vui lòng chọn nha sĩ");
      return;
    }
    if (order.sott === "") {
      message.error("Vui lòng chọn ca khám");
      return;
    }
    if (order.lydokham === "") {
      message.error("Vui lòng nhập lý do khám");
      return;
    }
    if (order.sodt === "") {
      message.error("Vui lòng nhập số điện thoại");
      return;
    }

    await GuestService.taoLichHen(order).then((res) => {
      if (res.success) {
        setTimeout(() => {
          dispatch(deleteOder());
        }, 500);
        setTimeout(() => {
          navigate("/xem-lich-hen");
        }, 500);
      }
    });
  };

  return (
    <div className=" ">
      <Steps current={current} items={items} />
      <div className=" min-h-[300px] bg-[#FEFFFE] mt-4 p-4 rounded-lg border max-h-[500px] overflow-y-auto">
        {steps[current].content}
      </div>
      <div className="flex justify-center mt-6">
        {current > 0 && (
          <Buttons
            className="mr-2 border-dashed border-2 border-blue-500 hover:bg-gray-400 hover:border-solid bg-slate-300 "
            onClick={() => prev()}
            text="Quay lại"
          />
        )}
        {current < steps.length - 1 && (
          <ButtonBlue
            className="bg-blue-500 "
            func={() => next()}
            text="Tiếp tục"
          />
        )}
        {current === steps.length - 1 && (
          <Buttons
            className="bg-green-600 hover:bg-green-700 ml-2"
            text="Đặt lịch"
            onClick={() => handleBooking()}
          />
        )}
      </div>
    </div>
  );
};

const DatLichHen = () => {
  return (
    <>
      <div className="">
        <h1 className="mx-auto mb-5 text-2xl">Đặt lịch hẹn</h1>
        <DatLichContainer />
      </div>
    </>
  );
};
export default DatLichHen;
