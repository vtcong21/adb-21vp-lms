import { AiOutlineMenuFold } from "react-icons/ai";
import { FaCalendarDays } from "react-icons/fa6";
import { FaBookMedical } from "react-icons/fa";
import { FaFileMedical } from "react-icons/fa";
import { ImProfile } from "react-icons/im";
import { BsBook, BsCalendar2PlusFill, BsPerson } from "react-icons/bs";
import { IoBook, IoPerson, IoStatsChart } from "react-icons/io5";

const menuInstructor = [
  {
    name: "Home",
    icon: <BsCalendar2PlusFill size={30} />,
    path: "/",
  },
  {
    name: "Create a course",
    icon: <BsCalendar2PlusFill size={30} />,
    path: "/createCourse",
  },
  {
    name: "Profile",
    icon: <BsCalendar2PlusFill size={30} />,
    path: "/profile",
  },
  {
    name: "Courses",
    icon: < IoBook size={22} />,
    path: "/instructor/courses",
  },
  {
    name: "Revenue",
    icon: < IoStatsChart size={22} />,
    path: "/instructor/revenue",
  },
];

const menuAdmin = [
  {
    name: "Instructors",
    icon: < IoPerson size={22} />,
    path: "/admin/instructors",
  },
  {
    name: "Courses",
    icon: < IoBook size={22} />,
    path: "/admin/courses",
  },
];
export { menuInstructor, menuAdmin};
