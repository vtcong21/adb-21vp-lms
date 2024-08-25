import React, { useEffect, useState } from 'react';
import { Layout, Typography, Divider, message } from 'antd';
import { useSelector } from 'react-redux';
import { useNavigate } from 'react-router-dom';
import LearnerService from '../../services/learner';
import OrdersTable from '../../components/orders/OrdersTable';

const { Content } = Layout;
const { Title } = Typography;

const OrdersPage = () => {
  const user = useSelector((state) => state.user);
  const [orders, setOrders] = useState([]);
  const navigate = useNavigate(); 

  useEffect(() => {
    LearnerService.getOrders(user.userId)
      .then((data) => {
        setOrders(data.orders || []);
      })
      .catch(error => {
        console.error('Failed to fetch orders:', error);
        message.error('Failed to load orders');
      });
  }, [user.userId]);

  const handleViewDetails = (orderId) => {
    navigate(`/order-details/${orderId}`); 
  };

  return (
    // <Layout style={{ padding: '24px', backgroundColor: '#fff' }}>
      // <Content className="content-wrapper">
      <>
      <div className="bg-white p-10 mx-10 sm:px-15 md:px-25 lg:px-40 shadow-xl rounded-2xl pb-3">

        <Title level={2}>Your Orders</Title>
        <Divider />
        <div className="min-h-[400px]">
          <OrdersTable orders={orders} onViewDetails={handleViewDetails} />
        </div>

      </div>
      </>
      // </Content>
    // </Layout>
  );
};

export default OrdersPage;
