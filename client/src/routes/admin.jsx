//  QTV
// import AdminLayout from "~/components/layout/adminLayout";
import { lazy } from "react";
const AdminLayout = lazy(() => import("~/components/layout/adminLayout"));
const AdminPage = lazy(() => import("~/pages/admin"));
const QuanLiKH = lazy(() => import("~/pages/admin/QuanLiKH"));
const QuanLiNS = lazy(() => import("~/pages/admin/QuanLiNS"));
const QuanLiDV = lazy(() => import("~/pages/admin/QuanLiDV"));
const QuanLiThuoc = lazy(() => import("~/pages/admin/QuanLiThuoc"));
const QuanLiNV = lazy(() => import("~/pages/admin/QuanLiNV"));
const QuanLiQTV = lazy(() => import("~/pages/admin/QuanLiQTV"));
const DoiMatKhau = lazy(() => import("../pages/admin/DoiMatKhau"));
const AdminRouter = [
  {
    path: "/",
    component: AdminPage,
    Layout: AdminLayout,
  }
];

export default AdminRouter;
