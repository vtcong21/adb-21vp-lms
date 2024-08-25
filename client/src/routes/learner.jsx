// khach hang
import { Layout } from "antd";
import { lazy } from "react"; // import DefaultLayout from "~/components/layout/defaultLayout";

const DefaultLayout = lazy(() => import("~/components/layout/defaultLayout"));
const LearnerPage = lazy(() => import("../pages/learner"));
const CapNhatTaiKhoan = lazy(() => import("../pages/learner/CapNhatTk"));
const DatLichHen = lazy(() => import("../pages/learner/DatLichHen"));
const HoSoBenhKH = lazy(() => import("../pages/learner/HoSoBenh"));
const XemLichHenKH = lazy(() => import("../pages/learner/XemLichHen"));
const DoiMatKhau = lazy(() => import("../pages/learner/DoiMatKhau"));
const LearnCourse = lazy(() => import("../pages/learner/LearnCourse"));
const CourseFilter = lazy(() => import("../pages/public/CourseFilter"));
const CourseDetail = lazy(() => import("../pages/public/CourseDetail"));
const Cart = lazy(() => import("../pages/learner/Cart"));
const OrdersPage = lazy(() => import("../pages/learner/OrdersPage"));
const OrderDetailsPage = lazy(() => import("../pages/learner/OrderDetailsPage"));
const MyCourse = lazy(() => import("../pages/learner/MyCourse"));
const HomePage = lazy(() => import("~/pages/public/homepage"));
const Profile = lazy(() => import("../pages/instructor/Profile"));

const LearnerRouter = [{
  path: "/",
  component: HomePage,
  Layout: DefaultLayout
},
{
  path: "/learner/cart",
  component: Cart,
  Layout: DefaultLayout
},

{
  path: "/learner/orders",
  component: OrdersPage,
  Layout: DefaultLayout
},

{
  path: "/learner/order-details/:orderId",
  component: OrderDetailsPage,
  Layout: DefaultLayout
},
{
  path: "/course-filter",
  component: CourseFilter,
  Layout: DefaultLayout,
},
{
  path: "/course-detail/:courseId",
  component: CourseDetail,
  Layout: DefaultLayout,
},
{
  path: "/learner/learn-course/:courseId",
  component: LearnCourse,
  Layout: DefaultLayout,
},
{
  path: "/learner/my-course",
  component: MyCourse,
  Layout: DefaultLayout,
},
{
  path: "/profile/:instructorId",
  component: Profile,
  Layout: DefaultLayout,
},

];
export default LearnerRouter;
