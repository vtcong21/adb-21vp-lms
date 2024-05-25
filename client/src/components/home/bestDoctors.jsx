import React, { useState, useEffect } from 'react';
import OnlineService from '../../services/online';

const BestDoctors = () => {
  const [doctors, setDoctors] = useState([]);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const data = await OnlineService.getAllDSNS();

        const doctorsWithBanners = data.slice(0, 4).map((doctor, index) => ({
          ...doctor,
          banner: `./images/doctor-${index + 1}.png`,
        }));

        setDoctors(doctorsWithBanners);
      } catch (error) {
        console.error('Error fetching doctors:', error);
      }
    };

    fetchData();
  }, []);

  return (
    <section className="section doctor" aria-label="doctor">
      <div className="container">
        <p className="section-subtitle text-center">Đội Ngũ Nha Sĩ</p>
        <h2 className="h2 section-title text-center">Các Nha Sĩ Nổi Bật</h2>

        <ul className="has-scrollbar">
          {doctors.map((doctor, index) => (
            <li key={index} className="scrollbar-item">
              <div className="doctor-card">
                <div className="card-banner img-holder">
                  <img
                    src={doctor.banner}
                    width="460"
                    height="500"
                    loading="lazy"
                    alt={doctor.HOTEN}
                    className="img-cover"
                  />
                </div>

                <h3 className="h3">
                  <a href="#" className="card-title">
                    {doctor.HOTEN}
                  </a>
                </h3>

                <p className="card-subtitle">{doctor.MANS}</p>
              </div>
            </li>
          ))}
        </ul>
      </div>
    </section>
  );
};

export default BestDoctors;
