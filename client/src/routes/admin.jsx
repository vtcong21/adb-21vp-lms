const Revenue = lazy(() => import("../pages/admin/Revenue"));
const AdminCourses = lazy(() => import("../pages/admin/AdminCourses"));
const ReviewCourse = lazy(() => import("../pages/admin/ReviewCourse"));
const LearnerList = lazy(() => import("../pages/admin/LearnerList"));

const AdminRouter = [
    {
        path: "/",
        component: AdminCourses,
        Layout: AdminLayout,
    },
    {
      path: "/course/:courseId",
      component: ReviewCourse,
      Layout: AdminLayout,
    },
    {
        path: "/course/:courseId/learners",
        component: LearnerList,
        Layout: AdminLayout,
    },
    {
        path: "/revenue",
        component: Revenue,
        Layout: AdminLayout,
    },
  ];
  
  export default AdminRouter;
  