import { Suspense, lazy } from "react";

// import Header from "~/components/header/header";
// import Nav from "~/components/header/nav";
const Header = lazy(() => import("~/components/header/header"));
const Nav = lazy(() => import("~/components/header/nav"));
const Footer = lazy(() => import("~/components/footer/footer"));

const DefaultLayout = ({ children }) => {
  return (
    <>
      <Suspense fallback={<div>Loading...</div>}>
        <div className="sticky top-0 bg-red-300 z-50">
          <Header />
          <Nav />
        </div>
      </Suspense>
      <div className="min-h-[90vh] pt-10 bg-[#DFEBFD] pb-10 z-0">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-10">
          <Suspense fallback={<div>Loading...</div>}>{children}</Suspense>
        </div>
      </div>
      <Footer/>
    </>
  );
};

export default DefaultLayout;
