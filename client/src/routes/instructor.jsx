// Nha si
import { lazy } from "react";
const AdminLayout = lazy(() => import("~/components/layout/adminLayout"));
const InstructorPage = lazy(() => import("~/pages/instructor"));
const CreateCourse = lazy(() => import("../pages/instructor/CreateCourse"));
const Profile = lazy(() => import("../pages/instructor/Profile"));

const InstructorRouter = [{
    path: "/",
    component: InstructorPage,
    Layout: AdminLayout
  }, 
  {
    path: "/createCourse",
    component: CreateCourse,
    Layout: AdminLayout
  },
  {
    path: "/profile",
    component: Profile,
    Layout: AdminLayout
  },
];
export default InstructorRouter;