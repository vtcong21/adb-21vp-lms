import { lazy } from "react";
import AdminLayout from "../components/layout/AdminLayout";

const AdminPage = lazy(() => import("~/pages/admin"));
const Revenue = lazy(() => import("../pages/admin/Revenue"));
const AdminCourses = lazy(() => import("../pages/admin/AdminCourses"));
const ReviewCourse = lazy(() => import("../pages/admin/ReviewCourse"));
const LearnerList = lazy(() => import("../pages/admin/LearnerList"));

const AdminRouter = [
    {
      path: "/",
      component: AdminPage,
      Layout: AdminLayout,
    },
    {
        path: "/admin/courses",
        component: AdminCourses,
        Layout: AdminLayout,
    },
    {
      path: "/admin/course/:courseId",
      component: ReviewCourse,
      Layout: AdminLayout,
    },
    {
      path: "/admin/instructors",
      component: AdminCourses,
      Layout: AdminLayout,
  },
    {
      path: "/admin/instructor/:instructorId",
      component: ReviewCourse,
      Layout: AdminLayout,
    },
  ];
  
  export default AdminRouter;
  