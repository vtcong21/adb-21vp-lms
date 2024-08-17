import React, { lazy, Suspense } from "react";
import "../../assets/styles/guest.css";
const HoSoBenh = lazy(() => import("~/components/HoSoBenh"));
import { useSelector } from "react-redux";
const XemHoSoBenh_KH = () => {
  const usersdt = useSelector((state) => state.user.SODT);
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <div className="w-[1200px] flex flex-col gap-5 mt-5">
        <HoSoBenh sdt={usersdt} isStaff={0} />
      </div>
    </Suspense>
  );
};

export default XemHoSoBenh_KH;
