// Nha si
import { lazy } from "react";
import OwnCourses from "../pages/instructor/OwnCourses";
import ViewCourse from "../pages/instructor/ViewCourse";
import InstructorRevenue from "../pages/instructor/InstructorRevenue";
const AdminLayout = lazy(() => import("~/components/layout/adminLayout"));
const InstructorPage = lazy(() => import("~/pages/instructor"));
const CreateCourse = lazy(() => import("../pages/instructor/CreateCourse"));
const Profile = lazy(() => import("../pages/instructor/Profile"));

const InstructorRouter = [{
    path: "/",
    component: OwnCourses,
    Layout: AdminLayout
  }, 
  {
    path: "/instructor/create-course",
    component: CreateCourse,
    Layout: AdminLayout
  },
  {
    path: "/instructor/profile",
    component: Profile,
    Layout: AdminLayout
  },
  {
    path: "/instructor/courses",
    component: OwnCourses,
    Layout: AdminLayout,
  },
  {
    path: "/instructor/courses/:courseId",
    component: ViewCourse,
    Layout: AdminLayout,
  },
  {
    path: "/instructor/revenue",
    component: InstructorRevenue,
    Layout: AdminLayout,
  },
];
export default InstructorRouter;