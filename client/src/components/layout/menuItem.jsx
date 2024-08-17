import { AiOutlineMenuFold } from "react-icons/ai";
import { FaCalendarDays } from "react-icons/fa6";
import { FaBookMedical } from "react-icons/fa";
import { FaFileMedical } from "react-icons/fa";
import { ImProfile } from "react-icons/im";
import { BsCalendar2PlusFill } from "react-icons/bs";

const menuInstructor = [
  {
    name: "do-st",
    icon: <BsCalendar2PlusFill size={30} />,
    path: "/instructor/do-st",
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
    name: "do-st",
    icon: <GiMedicines size={30} />,
    path: "/admin/do-st",
  },
];
export { menuInstructor, menuAdmin};
