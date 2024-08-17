// khach hang
import { lazy } from "react"; // import DefaultLayout from "~/components/layout/defaultLayout";

const DefaultLayout = lazy(() => import("~/components/layout/defaultLayout"));
const LearnerPage = lazy(() => import("../pages/learner"));
const CapNhatTaiKhoan = lazy(() => import("../pages/learner/CapNhatTk"));
const DatLichHen = lazy(() => import("../pages/learner/DatLichHen"));
const HoSoBenhKH = lazy(() => import("../pages/learner/HoSoBenh"));
const XemLichHenKH = lazy(() => import("../pages/learner/XemLichHen"));
const DoiMatKhau = lazy(() => import("../pages/learner/DoiMatKhau"));
const LearnerRouter = [{
  path: "/",
  component: LearnerPage,
  Layout: DefaultLayout
}];
export default LearnerRouter;