import { message } from "antd";
import "../../assets/styles/index.scss";
import BestDoctors from "../../components/home/bestDoctors";
import Services from "../../components/home/services";

import { useSelector } from "react-redux";
import { useNavigate } from "react-router-dom";
const HomePage = () => {
  const user = useSelector((state) => state.user);
  const navigate = useNavigate();
  console.log(user);

  const handleDatLich = () => {
    message.info("Vui lòng đăng nhập để đặt lịch hẹn", 5);

    if (user.ROLE === "online") {
      setTimeout(() => {
        navigate("/signin");
      }, 1100);
    } else {
      navigate("/dat-lich");
    }
  };

  return (
    <>
      <div id="index">
        <div className="body">
          <main>
            <article>
              <section
                className="section hero"
                id="home"
                style={{ backgroundImage: `url('./images/hero-bg.png')` }}
                aria-label="hero"
              >
                <div className="container">
                  <div className="hero-content">
                    <p className="section-subtitle">
                      Chào mừng đến với TSITNED
                    </p>

                    <h1 className="h1 hero-title">
                      We Are Best Dental Service
                    </h1>

                    <p className="hero-text">
                      Chuyên gia Nha khoa hàng đầu, dịch vụ chăm sóc chất lượng,
                      đội ngũ chuyên nghiệp - chúng tôi cam kết sự thoải mái và
                      sức khỏe của bạn là ưu tiên hàng đầu.
                    </p>
                  </div>

                  <figure className="hero-banner">
                    <img
                      src="./images/hero-banner.png"
                      width="587"
                      height="839"
                      alt="hero banner"
                      className="w-100"
                    />
                  </figure>
                </div>
              </section>
              <Services />

              <section className="section about" id="about" aria-label="about">
                <div className="container">
                  <figure className="about-banner">
                    <img
                      src="./images/about-banner.png"
                      width="470"
                      height="538"
                      loading="lazy"
                      alt="about banner"
                      className="w-100"
                    />
                  </figure>

                  <div className="about-content">
                    <p className="section-subtitle">Về Chúng Tôi</p>

                    <h2 className="h2 section-title">
                      Chúng Tôi Quan Tâm Đến Bạn
                    </h2>

                    <p className="section-text section-text-1">
                      Aliquam ac sem et diam iaculis efficitur. Morbi in enim
                      odio. Nullam quis volutpat est, sed dapibus sapien. Cras
                      condimentum eu velit id tempor. Curabitur purus sapien,
                      cursus sed nisl tristique, commodo vehicula arcu.
                    </p>

                    <p className="section-text">
                      Aliquam erat volutpat. Aliquam enim massa, sagittis
                      blandit ex mattis, ultricies posuere sapien. Morbi a
                      dignissim enim. Fusce elementum, augue in elementum porta,
                      sapien nunc volutpat ex, a accumsan nunc lectus eu lectus.
                    </p>
                  </div>
                </div>
              </section>
              <BestDoctors />

              <section className="section cta" aria-label="cta">
                <div className="container">
                  <figure className="cta-banner">
                    <img
                      src="./images/cta-banner.png"
                      width="1056"
                      height="1076"
                      loading="lazy"
                      alt="cta banner"
                      className="w-100"
                    />
                  </figure>

                  <div className="cta-content">
                    <p className="section-subtitle">Đặt Lịch Hẹn</p>

                    <h2 className="h2 section-title">
                      Chúng Tôi Luôn Luôn Chào Đón Bệnh Nhân
                    </h2>

                    <a onClick={handleDatLich} className="btn">
                      Đặt lịch hẹn
                    </a>
                  </div>
                </div>
              </section>
            </article>
          </main>
        </div>
      </div>
    </>
  );
};
export default HomePage;
