import React, { useState, useEffect } from 'react';
import OnlineService from '../../services/online';

const Services = () => {
  const [services, setServices] = useState([]);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const data = await OnlineService.getAllDV();
    
        const servicesWithIcons = data.slice(0, 6).map((service, index) => ({
          ...service,
          icon: `./images/service-icon-${index + 1}.png`,
        }));

        setServices(servicesWithIcons);
      } catch (error) {
        console.error('Error fetching services:', error);
      }
    };

    fetchData();
  }, []);

  return (
    <section className="section service" id="service" aria-label="service">
      <div className="container">
        <p className="section-subtitle text-center">Dịch vụ</p>
        <h2 className="h2 section-title text-center">DỊCH VỤ NỔI BẬT</h2>

        <ul className="service-list">
          {services.slice(0, 3).map((service, index) => (
            <li key={index}>
              <div className="service-card">
                <div className="card-icon">
                  <img
                    src={service.icon}
                    width="100"
                    height="100"
                    loading="lazy"
                    alt={`service icon ${index + 1}`}
                    className="w-100"
                  />
                </div>

                <div>
                  <h3 className="h3 card-title">{service.TENDV}</h3>
                  <p className="card-text">{service.MOTA}</p>
                </div>
              </div>
            </li>
          ))}

          <li className="service-banner">
            <figure>
              <img
                src="./images/service-banner.png"
                width="409"
                height="467"
                loading="lazy"
                alt="service banner"
                className="w-100"
              />
            </figure>
          </li>

          {services.slice(3, 6).map((service, index) => (
            <li key={index + 3}>
              <div className="service-card">
                <div className="card-icon">
                  <img
                    src={service.icon}
                    width="100"
                    height="100"
                    loading="lazy"
                    alt={`service icon ${index + 4}`}
                    className="w-100"
                  />
                </div>

                <div>
                  <h3 className="h3 card-title">{service.TENDV}</h3>
                  <p className="card-text">{service.MOTA}</p>
                </div>
              </div>
            </li>
          ))}
        </ul>
      </div>
    </section>
  );
};

export default Services;
