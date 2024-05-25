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
    component: QuanLiKH,
    Layout: AdminLayout,
  },
  {
    path: "/quan-li-khach-hang",
    component: QuanLiKH,
    Layout: AdminLayout,
  },
  {
    path: "/quan-li-nha-si",
    component: QuanLiNS,
    Layout: AdminLayout,
  },
  {
    path: "/quan-li-dich-vu",
    component: QuanLiDV,
    Layout: AdminLayout,
  },
  {
    path: "/quan-li-thuoc",
    component: QuanLiThuoc,
    Layout: AdminLayout,
  },
  {
    path: "/quan-li-nhan-vien",
    component: QuanLiNV,
    Layout: AdminLayout,
  },
  {
    path: "/quan-li-quan-tri-vien",
    component: QuanLiQTV,
    Layout: AdminLayout,
  },
  {
    path: "/doi-mat-khau",
    component: DoiMatKhau,
    Layout: AdminLayout,
  },
];

export default AdminRouter;
