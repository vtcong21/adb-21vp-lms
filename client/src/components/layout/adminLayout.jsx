import React, { useState,Suspense } from "react";
import { AiOutlineMenuFold, AiOutlineMenuUnfold } from "react-icons/ai";
import { useNavigate, useLocation } from "react-router-dom";
import { useSelector } from "react-redux";
import Bread from "./breadCrumb";
import {menuAdmin,menuInstructor } from "./menuItem";
import Account from "./Account";
import { FaGraduationCap } from "react-icons/fa6";


const Menu = ({ name, icon, path, toggle }) => {
  const navigate = useNavigate();
  const location = useLocation();
  const isActive = location.pathname === path;
  const handleClick = () => {
    navigate(path);
  };
  return (
    <button
      onClick={handleClick}
      className={`flex items-center justify-start align-middle h-14 cursor-pointer rounded-md bg-slate-100 mx-2 transition-all duration-300 hover:bg-slate-500 
      ${isActive ? "bg-slate-400" : "bg-slate-100"}
       `}
    >
      <div
        className={`flex items-center justify-center align-middle h-14 w-14 transition-all duration-300 ${
          toggle ? "ml-5" : ""
        }`}
      >
        {icon}
      </div>
      <div
        className={`flex items-center justify-start align-middle h-14 w-100 relative overflow-hidden	 ${
          toggle ? "invisible" : ""
        }`}
        style={{ transition: "opacity 1s ease" }}
      >
        <h1 className="whitespace-nowrap  text-ellipsis">{name}</h1>
      </div>
    </button>
  );
};

const Sidebar = (props) => {
  const toggle = props.toggle;
  const user = useSelector((state) => state.user);
  const Veryrole = () => {
    const role = user.role;
    switch (role) {
      case "AD":
        return menuAdmin;
      case "INS":
        return menuInstructor;
      default:
        return menuInstructor;
    }
  };

  return (
    <>
      <div className="h-[100px] p-7">< FaGraduationCap size={25} /></div>
      <div className="flex flex-col gap-2">
        {Veryrole().map((item, index) => (
          <Menu
            key={index}
            name={item.name}
            icon={item.icon}
            path={item.path}
            toggle={toggle}
          />
        ))}
      </div>
    </>
  );
};

const AdminLayout = ({ children }) => {
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);

  const toggleSidebar = () => {
    setSidebarCollapsed(!sidebarCollapsed);
  };
  const user = useSelector((state) => state.user);
  const location = useLocation();

  return (
    <>
      <div className="flex min-h-screen ">
      <div
        className={`bg-slate-50 h-screen overflow-y-auto sticky top-0 transition-all duration-300 min-w-[${
          sidebarCollapsed ? "80px]" : "200px]"
        } ${
          sidebarCollapsed ? "w-0" : "w-[50vw]"
        }`}
      >
          <Sidebar toggle={sidebarCollapsed} />
        </div>
        <div className="w-full  flex flex-col">
          <div className="bg-slate-50 h-[70px] sticky top-0 flex justify-between items-center px-5 shadow-lg shadow-gray-500/50 z-50">
            <div className="flex items-center">
              <button className="" onClick={toggleSidebar}>
                {sidebarCollapsed ? (
                  <AiOutlineMenuUnfold size={30} />
                ) : (
                  <AiOutlineMenuFold size={30} />
                )}
              </button>
              <Bread />
            </div>
            <Account />
          </div>
          {/* bg-[rgb(251,254,251)] */}
          {/* chinh mau o day */}
          
          <div className=" bg-slate-200 flex-auto justify-center min-h-[120vh] p-8 overflow-y-auto z-0">
          <Suspense fallback={<div>Loading...</div>}>
            {children}
            </Suspense>
          </div>
        </div>
      </div>
    </>
  );
};
export default AdminLayout;
