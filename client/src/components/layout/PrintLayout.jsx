import { BsFillPrinterFill } from "react-icons/bs";
import { useNavigate } from "react-router-dom";
const PrintLayout = ({ children }) => {
  const navigate = useNavigate();
  const handleCancel = () => {
    navigate(-1);
  };
  return (
    <>
      <div className=" p-5   ">{children}</div>
      <div className=" p-5 px-96 flex justify-end gap-5">
        <button
          onClick={handleCancel}
          className=" bg-gray-500 h-12 w-40 flex justify-center items-center gap-7 rounded-lg"
        >
          <h1 className="text-xl">Cancel</h1>
        </button>
        <button
          className=" bg-grin h-12 w-40 flex justify-center items-center gap-7 rounded-lg  hover:bg-darkgrin"
          onClick={() => window.print()}
        >
          <BsFillPrinterFill size={30} />
          <h1 className="text-xl">Print</h1>
        </button>
      </div>
    </>
  );
};

export default PrintLayout;
