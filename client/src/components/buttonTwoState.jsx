import React, { useState, useEffect } from "react";
import "~/assets/styles/buttonTwoState.css";
import { dangkiLichRanh } from "~/redux/features/dkLichRanhNsSlice";
import { useDispatch, useSelector } from "react-redux";

const TwoStateBorder = ({ text, func, id, array }) => {
  const [isChecked, setIsChecked] = useState(false);

  useEffect(() => {
    // Kiểm tra xem id có trong mảng datCa không
    const isInArray = array.some((item) => item.MACA + "-" + item.NGAY === id);
    setIsChecked(isInArray);
  }, [id]);

  const changeState = () => {
    setIsChecked((prevChecked) => !prevChecked);
    if (func) {
      func(id);
    }
  };
  const dangky = useSelector((state) => state.dangky);
  // const newkey = dangky.maca + dangky.ngay;
  let color = "";
  // if (newkey === maca + convertDateFormat(ngay)) {
  //   color = "checked";
  // }
  const handleOnClick = () => {
    // dispatch(
    //   dangkiLichRanh({ mans: 1, maca: maca, ngay: convertDateFormat(ngay) })
    // );
    // message.info(`Đa chon thành công ca ${maca} ngày ${ngay}`);
  };
  return (
    <label id={id} className={`input-check ${isChecked ? "checked" : ""}`}>
      <input
        onChange={changeState}
        onClick={handleOnClick}
        type="checkbox"
        value="something"
        name="test"
        className="hidden"
        checked={isChecked}
      />
      {text}
    </label>
  );
};

const TwoStateBlue = ({ text, func, id, array }) => {
  const [isChecked, setIsChecked] = useState(true);

  useEffect(() => {
    // Kiểm tra xem id có trong mảng huyCa không
    const isInArray = array.some((item) => item.MACA + "-" + item.NGAY === id);
    setIsChecked(!isInArray);
  }, [id]);

  const changeState = () => {
    setIsChecked((prevChecked) => !prevChecked);
    if (func) {
      func(id);
    }
  };

  return (
    <label id={id} className={`input-check ${isChecked ? "checked" : ""}`}>
      <input
        onChange={changeState}
        type="checkbox"
        value="something"
        name="test"
        className="hidden"
      />
      {text}
    </label>
  );
};

const StatePink = ({ text, func, info }) => {
  return (
    <button className="input-planned" onClick={!func ? null : func}>
      {text}
    </button>
  );
};

const StateGrey = ({ text, func, info }) => {
  return (
    <button className="input-full2" onClick={!func ? null : func}>
      {text}
    </button>
  );
};

const ButtonBlue = ({ text, func, info }) => {
  return (
    <button className="btn-blue" onClick={!func ? null : func}>
      {text}
    </button>
  );
};

const ButtonGrey = ({ text, func, info }) => {
  return (
    <button className="btn-grey" onClick={!func ? null : func}>
      {text}
    </button>
  );
};

const ButtonPink = ({ text, func, info }) => {
  return (
    <button className="btn-pink" onClick={!func ? null : func}>
      {text}
    </button>
  );
};

export {
  TwoStateBlue,
  StatePink,
  StateGrey,
  TwoStateBorder,
  ButtonBlue,
  ButtonGrey,
  ButtonPink,
};
