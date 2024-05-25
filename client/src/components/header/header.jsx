import { useNavigate } from "react-router-dom";
import { useDispatch, useSelector } from "react-redux";
import { deleteRole } from "~/redux/features/userSlice";
import { UserOutlined } from "@ant-design/icons";
import { Avatar, Space, Button, Tag, Dropdown } from "antd";

const Account = () => {
  const user = useSelector((state) => state.user);
  const navigate = useNavigate();
  const dispath = useDispatch();
  const handleSignOut = async () => {
    await dispath(deleteRole());
    await navigate("/");
  };
  const items = [
    {
      key: "1",
      label: (
        <a className="text-red-600" onClick={handleSignOut}>
          Đăng xuất
        </a>
      ),
    },
  ];

  return (
    <>
      <div className="flex h-[90%] min-w-[200px] items-center">
        <Space className="ml-auto" wrap size={16}>
          <Dropdown
            menu={{
              items,
            }}
            placement="bottomLeft"
            arrow
            trigger={["click"]}
          >
            <Avatar
              className=" hover:cursor-pointer"
              size="large"
              icon={<UserOutlined />}
            />
          </Dropdown>
          <h1 className="">{user.HOTEN}</h1>
        </Space>
      
      </div>
    </>
  );
};
const Header = () => {
  const dispath = useDispatch();
  const navigate = useNavigate();
  const user = useSelector((state) => state.user);
  return (
    <>
      <div className="bg-radial-gradient bg-cover bg-center w-full h-16 flex gap-1  justify-end  px-5 drop-shadow-lg z-50">
        <div className=" h-full text-center  flex mr-auto ml-4">
          <h1 className="my-auto mr-3 text-white text-2xl font-serif">
              PHÒNG KHÁM NHA KHOA HAHA
          </h1>
        </div>

        {user.ROLE === "online" ? (
          <div className="flex">
            <button
              className="bg-blue-500 px-5 py-2 my-3 rounded-md text-white"
              onClick={() => {
                navigate("/signin");
              }}
            >
              Đăng nhập
            </button>
            <button
              className="bg-blue-500 px-5 py-2 my-3 rounded-lg text-white border-white border-2"
              onClick={() => {
                navigate("/signup");
              }}
            >
              Đăng ký
            </button>
          </div>
        ) : (
          <Account />
        )}
      </div>
    </>
  );
};

export default Header;
