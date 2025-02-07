//public
// import DefaultLayout from "~/components/layout/defaultLayout";
import { lazy } from "react";
const DefaultLayout = lazy(() => import("~/components/layout/defaultLayout"));
const HomePage = lazy(() => import("~/pages/public/homepage"));
const SignInPage = lazy(() => import("~/pages/public/signin"));
const SignIns = lazy(() => import("../pages/public/signinss"));
const CourseFilter = lazy(() => import("../pages/public/CourseFilter"));
const CourseDetail = lazy(() => import("../pages/public/CourseDetail"));
const Profile = lazy(() => import("../pages/instructor/Profile"));

const PublicRouter = [
  {
    path: "/",
    component: HomePage,
    Layout: DefaultLayout,
  },
  {
    path: "/signin",
    component: SignInPage,
    Layout: null,
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
    path: "/profile/:instructorId",
    component: Profile,
    Layout: DefaultLayout,
  },
  

  
];
export default PublicRouter;
