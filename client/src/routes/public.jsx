//public
// import DefaultLayout from "~/components/layout/defaultLayout";
import { lazy } from "react";
const DefaultLayout = lazy(() => import("~/components/layout/defaultLayout"));
const HomePage = lazy(() => import("~/pages/public"));
const DanhSachNhaSi = lazy(() => import("~/pages/public/ListNhaSi"));
const DanhSachDichVu = lazy(() => import("~/pages/public/ListDV"));
const SignUpPage = lazy(() => import("../pages/public/signup"));
const SignInPage = lazy(() => import("~/pages/public/signin"));
const SignIns = lazy(() => import("../pages/public/signinss"));
const PublicRouter = [{
  path: "/",
  component: HomePage,
  Layout: DefaultLayout
}, {
  path: "/signin",
  component: SignInPage,
  Layout: null
}];
export default PublicRouter;