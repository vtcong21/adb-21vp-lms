// khach hang
import { lazy } from "react"; // import DefaultLayout from "~/components/layout/defaultLayout";

const DefaultLayout = lazy(() => import("~/components/layout/defaultLayout"));
const LearnerPage = lazy(() => import("../pages/learner"));
const CapNhatTaiKhoan = lazy(() => import("../pages/learner/CapNhatTk"));
const DatLichHen = lazy(() => import("../pages/learner/DatLichHen"));
const HoSoBenhKH = lazy(() => import("../pages/learner/HoSoBenh"));
const XemLichHenKH = lazy(() => import("../pages/learner/XemLichHen"));
const DoiMatKhau = lazy(() => import("../pages/learner/DoiMatKhau"));
const Cart = lazy(() => import("../pages/learner/cart"));
const LearnCourse = lazy(() => import("../pages/learner/LearnCourse"));
const CourseFilter = lazy(() => import("../pages/public/CourseFilter"));
const CourseDetail = lazy(() => import("../pages/public/CourseDetail"));

const LearnerRouter = [
  {
    path: "/",
    component: LearnerPage,
    Layout: DefaultLayout,
  },
  {
    path: "/cart",
    component: Cart,
    Layout: DefaultLayout,
  },
  {
    path: "/courseFilter",
    component: CourseFilter,
    Layout: DefaultLayout,
  },
  {
    path: "/courseDetail/:courseId",
    component: CourseDetail,
    Layout: DefaultLayout,
  },
  {
    path: "/learnCourse/:courseId",
    component: LearnCourse,
    Layout: DefaultLayout,
  },
];
export default LearnerRouter;
