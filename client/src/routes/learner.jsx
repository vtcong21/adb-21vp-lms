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
const Cart = lazy(() => import("../pages/learner/Cart"));
const OrdersPage = lazy(() => import("../pages/learner/OrdersPage"));
const OrderDetailsPage = lazy(()=> import("../pages/learner/OrderDetailsPage"));

const LearnerRouter = [{
  path: "/",
  component: LearnerPage,
  Layout: DefaultLayout
},
{
  path: "/cart",
  component: Cart,
  Layout: DefaultLayout
},

{
  path: "/orders",
  component: OrdersPage,
  Layout: DefaultLayout
},

{
  path: "/order-details/:orderId",
  component: OrderDetailsPage,
  Layout: DefaultLayout
}
];
export default LearnerRouter;