//public
// import DefaultLayout from "~/components/layout/defaultLayout";
import { lazy } from "react";
const DefaultLayout = lazy(() => import("~/components/layout/defaultLayout"));
const HomePage = lazy(() => import("~/pages/public/homepage"));
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