import { useNavigate } from "react-router-dom";
import { useDispatch, useSelector } from "react-redux";
import { deleteRole } from "~/redux/features/userSlice";
import { UserOutlined, SearchOutlined } from "@ant-design/icons";
import { Avatar, Space, Button, Dropdown, Input } from "antd";
import { useState } from "react";
import { IoCartOutline } from "react-icons/io5";

const Account = () => {
  const user = useSelector((state) => state.user);
  const navigate = useNavigate();
  const dispatch = useDispatch();

  const handleSignOut = async () => {
    await dispatch(deleteRole());
    navigate("/");
  };

  const items = [
    {
      key: "1",
      label: (
        <a className="text-red-600" onClick={handleSignOut}>
          Logout
        </a>
      ),
    },
  ];

  return (
    <div className="flex h-[90%] min-w-[200px] items-center">
      <Space className="ml-auto" wrap size={16}>
        <Dropdown
          menu={{ items }}
          placement="bottomLeft"
          arrow
          trigger={["click"]}
        >
          <Avatar
            className="hover:cursor-pointer"
            size="large"
            icon={<UserOutlined />}
          />
        </Dropdown>
        <h1>{user.HOTEN}</h1>
      </Space>
    </div>
  );
};

const Header = () => {
  const navigate = useNavigate();
  const user = useSelector((state) => state.user);
  const [searchTerm, setSearchTerm] = useState("");

  const handleLogoClick = () => {
    navigate("/");
  };

  const handleSearch = (value) => {
    if (value.trim()) {
      navigate(`/course-filter?search=${encodeURIComponent(value)}`);
    }
  };

  return (
    <div className="bg-radial-gradient bg-cover bg-center w-full h-16 flex gap-1 justify-end px-5 drop-shadow-lg z-50">
      <div className="h-full text-center flex mr-auto ml-4 hover:cursor-pointer" onClick={handleLogoClick}>
        <h1 className="my-auto mr-3 text-white text-xl font-sans font-bold tracking-widest">
          Udemy
        </h1>
      </div>

    
      {user.role === "public" ? (
        <div className="flex">
          <button
            className="bg-blue-500 px-5 py-2 my-3 rounded-md text-white"
            onClick={() => {
              navigate("/signin");
            }}
          >
            Login
          </button>
        </div>
      ) : (
        <Account />
      )}
    </div>
  );
};

export default Header;
