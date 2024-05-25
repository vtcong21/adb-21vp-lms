import {
  OnlineRouter,
  AdminRouter,
  GuestRouter,
  StaffRouter,
  DentistRouter,
} from "~/routes";
import React, { Fragment, Suspense, lazy } from "react";

import { useSelector } from "react-redux";
import { BrowserRouter as Router, Route, Routes } from "react-router-dom";
import Loading from "./components/err/loading";
const NotfoundError = lazy(() => import("~/components/err"));

import Auth from "./components/Auth";
// import Test from "./test";

function App() {
  const user = useSelector((state) => state.user);

  const VerifyRoure = () => {
    switch (user.ROLE) {
      case "QTV":
        return AdminRouter;
      case "KH":
        return GuestRouter;
      case "NV":
        return StaffRouter;
      case "NS":
        return DentistRouter;
      default:
        return OnlineRouter;
    }
  };

  return (
    <>
      {/* <Test /> */}
      <Auth />
      <Router>
        <Suspense fallback={<Loading />}>
          <Routes>
            {VerifyRoure().map((route, index) => {
              const Layout = route.Layout === null ? Fragment : route.Layout;
              const Page = route.component;
              return (
                <Route
                  key={index}
                  path={route.path}
                  element={
                    <Layout>
                      <Page />
                    </Layout>
                  }
                />
              );
            })}
            <Route
              path="*"
              element={
                <Fragment>
                  <NotfoundError />
                </Fragment>
              }
            />
          </Routes>
        </Suspense>
      </Router>
    </>
  );
}

export default App;
