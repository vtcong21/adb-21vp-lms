// Nha si
import { lazy } from "react";
const AdminLayout = lazy(() => import("~/components/layout/adminLayout"));
const DentistPage = lazy(() => import("~/pages/instructor"));
const DangKiLichRanh = lazy(() => import("~/pages/instructor/DkLichRanh"));
const XemBenhAnCu = lazy(() => import("~/pages/instructor/XemBenhAnCu"));
const XemLichTruc = lazy(() => import("~/pages/instructor/XemLichTruc"));
const DoiMatKhau = lazy(() => import("../pages/instructor/DoiMatKhau"));
const InstructorRouter = [{
  path: "/",
  component: DentistPage,
  Layout: AdminLayout
}
];
export default InstructorRouter;