import { Empty } from "antd";
import { AudioOutlined } from "@ant-design/icons";
import { Input, Space } from "antd";
import { useState, Suspense, lazy } from "react";
import { useLocation } from "react-router-dom";
import '../../assets/styles/staff.css'

const HoSoBenh = lazy(() => import("~/components/HoSoBenh"));
const { Search } = Input;
const XemHoSoBenh_NV = () => {
  const location = useLocation();
  const currentPath = location.pathname;
  const lastPath = currentPath.substring(currentPath.lastIndexOf("/") + 1);
  const [searchResults, setSearchResults] = useState("");
  const onSearch = (value) => {
    setSearchResults(value);
  };

  return (
    <Suspense fallback={<div>Loading...</div>}>
      <div>
        <div className="text-center">
          <Search
            className="w-[1100px] rounded-2xl font-montserrat text-base"
            placeholder="Tìm kiếm hồ sơ bệnh án bằng số điện thoại khách hàng"
            allowClear
            onSearch={onSearch}
            suffix={<AudioOutlined />}
            size="large"
            defaultValue={lastPath === "ho-so-benh-an" ? "" : lastPath}
          />
        </div>

        {searchResults === "" ? (
          <Empty className="w-[1100px] mt-6 rounded-3xl border border-spacing-4" />
        ) : (
          <div className="w-[1200px] flex flex-col gap-5 mt-5">
            <HoSoBenh sdt={searchResults} isStaff={1} />
          </div>
        )}
      </div>
    </Suspense>
  );
};
export default XemHoSoBenh_NV;
