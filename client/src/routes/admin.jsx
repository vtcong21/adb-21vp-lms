import { lazy } from "react";
import AdminLayout from "../components/layout/adminLayout";

const AdminPage = lazy(() => import("~/pages/admin"));
const AdminCourses = lazy(() => import("../pages/admin/AdminCourses"));
const ReviewCourse = lazy(() => import("../pages/admin/ReviewCourse"));

const AdminRouter = [
    {
      path: "/",
      component: AdminCourses,
      Layout: AdminLayout,
    },
    {
        path: "/admin/courses",
        component: AdminCourses,
        Layout: AdminLayout,
    },
    {
      path: "/admin/courses/:courseId",
      component: ReviewCourse,
      Layout: AdminLayout,
    },
    {
      path: "/admin/instructors",
      component: AdminCourses,
      Layout: AdminLayout,
    },
    {
      path: "/admin/instructors/:instructorId",
      component: ReviewCourse,
      Layout: AdminLayout,
    },
  ];
  
  export default AdminRouter;
  