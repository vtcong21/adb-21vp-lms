// Nha si
import { lazy } from "react";
const AdminLayout = lazy(() => import("~/components/layout/adminLayout"));

const DentistPage = lazy(() => import("~/pages/dentist"));
const DangKiLichRanh = lazy(() => import("~/pages/dentist/DkLichRanh"));
const XemBenhAnCu = lazy(() => import("~/pages/dentist/XemBenhAnCu"));
const XemLichTruc = lazy(() => import("~/pages/dentist/XemLichTruc"));
const DoiMatKhau = lazy(() => import("../pages/dentist/DoiMatKhau"));

const DentistRouter = [
  {
    path: "/",
    component: DangKiLichRanh,
    Layout: AdminLayout,
  },
  {
    path: "/dang-ki-lich-ranh",
    component: DangKiLichRanh,
    Layout: AdminLayout,
  },
  {
    path: "/xem-lich-truc",
    component: XemLichTruc,
    Layout: AdminLayout,
  },

  {
    path: "/xem-benh-an-cu",
    component: XemBenhAnCu,
    Layout: AdminLayout,
  },
  {
    path: "/xem-benh-an-cu/:sdt",
    component: XemBenhAnCu,
    Layout: AdminLayout,
  },

  // {
  //   path: "/tao-benh-an-moi/",
  //   component: ThemBenhAnMoi,
  //   Layout: AdminLayout,
  // },
  // {
  //   path: "/tao-benh-an-moi/:sdt",
  //   component: ThemBenhAnMoi,
  //   Layout: AdminLayout,
  // },
  {
    path: "/doi-mat-khau",
    component: DoiMatKhau,
    Layout: AdminLayout,
  },
];

export default DentistRouter;
