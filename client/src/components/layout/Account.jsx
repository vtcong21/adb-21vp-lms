import { useDispatch, useSelector } from "react-redux";
import { deleteRole } from "~/redux/features/userSlice";
import { UserOutlined } from "@ant-design/icons";
import { Avatar, Space, Button, Tag, Dropdown } from "antd";
import { useNavigate } from "react-router-dom";

const Account = () => {
  const user = useSelector((state) => state.user);
  const dispatch = useDispatch();
  const navigate = useNavigate();

  const handleSignOut = async () => {
    await dispatch(deleteRole());
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
        <Tag className="mr-10 hover:cursor-pointer" color="magenta">
          <button
            className="mx-auto text-2xl uppercase"
            onClick={() => navigate("/")}
          >
            {user.ROLE}
          </button>
        </Tag>

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

export default Account;
