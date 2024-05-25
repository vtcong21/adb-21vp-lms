import {
    AiOutlineClockCircle,
    AiOutlineEnvironment,
    AiOutlinePhone,
    AiOutlineMail,
    AiOutlinePlus,
    AiFillFacebook,
    AiFillTwitterCircle,
    AiFillInstagram,
} from "react-icons/ai";

const Footer = () => {
    return (
        <footer id="footer" className="bg-radial-gradient bg-cover bg-center text-white">
            <div className="container mx-auto py-10">
                <div className="">
                    <div className="footer-brand">
                        <p href="#" className="logo text-2xl font-bold font-serif">
                            PHÒNG KHÁM NHA KHOA HAHA
                        </p>

                        <div className="schedule flex items-center mt-4">
                            <div className="schedule-icon">
                                <AiOutlineClockCircle />
                            </div>

                            <span className="ml-2">Thứ hai - Thứ bảy: 9:00am - 10:00pm</span>
                        </div>
                    </div>
                </div>
            </div>

            <div className="footer-bottom bg-gray-700 py-4">
                <div className="container mx-auto flex justify-between items-center">
                    <p className="copyright text-sm">
                        &copy; 2023 All Rights Reserved by 21VP.
                    </p>

                    <ul className="social-list flex space-x-4">
                        <li>
                            <a href="#" className="social-link">
                                <AiFillFacebook />
                            </a>
                        </li>

                        <li>
                            <a href="#" className="social-link">
                                <AiFillTwitterCircle />
                            </a>
                        </li>

                        <li>
                            <a href="#" className="social-link">
                                <AiFillInstagram />
                            </a>
                        </li>
                    </ul>
                </div>
            </div>
        </footer>
    );
};

export default Footer;
