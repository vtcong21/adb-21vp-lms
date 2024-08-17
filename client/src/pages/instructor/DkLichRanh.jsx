import React, { useState, useEffect } from "react";
import TableLichHen from "~/components/dentist/TableLichHen";
import DentistService from "../../services/dentist";
import { useSelector } from "react-redux";

const DangKiLichRanh = () => {
  const [lichhen, setLichHen] = useState([]);
  const user = useSelector((state) => state.user);
  const state = useSelector((state) => state.stateData.value);

  useEffect(() => {
    DentistService.xemTableLichNS(user.MANS).then((res) => {
      // console.log(res);
      setLichHen(res || []);
    });
  }, [state]);
  return (
    <>
      <div>
        <TableLichHen data={lichhen} />
      </div>
    </>
  );
};
export default DangKiLichRanh;