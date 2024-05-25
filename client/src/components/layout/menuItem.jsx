import { AiOutlineMenuFold } from "react-icons/ai";
import { FaCalendarDays } from "react-icons/fa6";
import { FaBookMedical } from "react-icons/fa";
import { FaFileMedical } from "react-icons/fa";
import { ImProfile } from "react-icons/im";
import { BsCalendar2PlusFill } from "react-icons/bs";

const menuDentist = [
  {
    name: "Đăng kí lịch rảnh",
    icon: <BsCalendar2PlusFill size={30} />,
    path: "/dang-ki-lich-ranh",
  },
  {
    name: "Xem lịch trực",
    icon: <FaCalendarDays size={30} />,
    path: "/xem-lich-truc",
  },
  {
    name: "Xem bệnh án cũ",
    icon: <FaBookMedical size={30} />,
    path: "/xem-benh-an-cu",
  },
  // {
  //   name: "Tạo bệnh án mới",
  //   icon: <FaFileMedical size={30} />,
  //   path: "/tao-benh-an-moi",
  // },
  {
    name: "Đổi mật khẩu",
    icon: <AiOutlineMenuFold size={30} />,
    path: "/doi-mat-khau",
  },
];
import { GiMedicines } from "react-icons/gi";
import { FaHospital } from "react-icons/fa";
import { HiUserGroup } from "react-icons/hi";
import { FaUserDoctor } from "react-icons/fa6";
import { MdShoppingCart } from "react-icons/md";
import { GrUserAdmin } from "react-icons/gr";
import { TbPasswordUser } from "react-icons/tb";

const menuAdmin = [
  {
    name: "Quản lí thuốc",
    icon: <GiMedicines size={30} />,
    path: "/quan-li-thuoc",
  },
  {
    name: "Quản lí dịch vụ",
    icon: <FaHospital size={30} />,
    path: "/quan-li-dich-vu",
  },
  {
    name: "Quản lí nhân viên",
    icon: <HiUserGroup size={30} />,
    path: "/quan-li-nhan-vien",
  },
  {
    name: "Quản lí nha sĩ",
    icon: <FaUserDoctor size={30} />,
    path: "/quan-li-nha-si",
  },
  {
    name: "Quản lí khách hàng",
    icon: <MdShoppingCart size={30} />,
    path: "/quan-li-khach-hang",
  },
  {
    name: "Quản lí quản trị viên",
    icon: <GrUserAdmin size={30} />,
    path: "/quan-li-quan-tri-vien",
  },
  {
    name: "Đổi mật khẩu",
    icon: <AiOutlineMenuFold size={30} />,
    path: "/doi-mat-khau",
  },
];
import { RiShoppingCartFill } from "react-icons/ri";
import { FaMoneyBillWheat } from "react-icons/fa6";

const menuStaff = [
  {
    name: "Đăng kí tài khoản KH",
    icon: <RiShoppingCartFill size={30} />,
    path: "/dang-ki-tk-kh",
  },
  {
    name: "Đặt lịch hẹn",
    icon: <BsCalendar2PlusFill size={30} />,
    path: "/dat-lich-hen",
  },
  {
    name: "Xem lịch hẹn",
    icon: <FaCalendarDays size={30} />,
    path: "/xem-lich-hen",
  },
  {
    name: "Xem thuốc",
    icon: <GiMedicines size={30} />,
    path: "/xem-thuoc",
  },
  {
    name: "Xem dịch vụ",
    icon: <FaHospital size={30} />,
    path: "/xem-dich-vu",
  },
  {
    name: "Hồ sơ bệnh án",
    icon: <ImProfile size={30} />,
    path: "/ho-so-benh-an",
  },
  {
    name: "Hóa đơn",
    icon: <FaMoneyBillWheat size={30} />,
    path: "/hoa-don",
  },
  {
    name: "Đổi mật khẩu",
    icon: <AiOutlineMenuFold size={30} />,
    path: "/doi-mat-khau",
  },
];

export { menuDentist, menuAdmin, menuStaff };
