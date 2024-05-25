import { Empty } from "antd";
import { AudioOutlined } from "@ant-design/icons";
import { Input } from "antd";
import { useState, Suspense, lazy } from "react";
import { useLocation } from "react-router-dom";
import "../../assets/styles/staff.css";

const HoaDon = lazy(() => import("~/components/HoaDon"));
const { Search } = Input;
const XemHoaDon = () => {
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
            className="w-[820px] rounded-2xl font-montserrat text-base"
            placeholder="Tìm kiếm hóa đơn bằng số điện thoại khách hàng"
            allowClear
            onSearch={onSearch}
            suffix={<AudioOutlined />}
            size="large"
            defaultValue={lastPath === "hoa-don" ? "" : lastPath}
          />
        </div>

        {searchResults === "" ? (
          <Empty className="w-[820px] mt-6 rounded-3xl border border-spacing-4" />
        ) : (
          <div className="flex flex-col gap-5 mt-5">
            <HoaDon sdt={searchResults} />
          </div>
        )}
      </div>
    </Suspense>
  );
};

export default XemHoaDon;
