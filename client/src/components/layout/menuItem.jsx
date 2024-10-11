import { IoBook, IoCreate, IoHome, IoPerson, IoStatsChart } from "react-icons/io5";

const menuInstructor = [
  {
    name: "Home",
    icon: <IoHome size={22} />,
    path: "/",
  },
  {
    name: "Create a course",
    icon: <IoCreate size={22} />,
    path: "/instructor/create-course",
  },
  {
    name: "Profile",
    icon: <IoPerson size={22} />,
    path: "/instructor/profile",
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
