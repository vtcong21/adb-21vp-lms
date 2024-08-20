import React, { useEffect, useState } from 'react';
import { Layout, Row, Col, Table, Divider, Statistic, Button, Typography, Modal, Form, Select, message } from 'antd';
import { CreditCardOutlined, DeleteOutlined, GiftOutlined, CloseCircleOutlined } from '@ant-design/icons';
import { useSelector } from 'react-redux';
import LearnerService from '../../services/learner';
import PublicService from '../../services/public'; // Make sure you import PublicService

const { Content } = Layout;
const { Title } = Typography;
const { Option } = Select;

const Cart = () => {
  const user = useSelector((state) => state.user);
  const [cartData, setCartData] = useState([]);
  const [total, setTotal] = useState(0);
  const [originalTotal, setOriginalTotal] = useState(0);
  const [isModalVisible, setIsModalVisible] = useState(false);
  const [coupon, setCoupon] = useState(null);
  const [appliedCoupon, setAppliedCoupon] = useState(null);
  const [availableCoupons, setAvailableCoupons] = useState([]); // State to store coupons

  useEffect(() => {
    // Fetch cart details
    LearnerService.getCartDetails(user.userId)
      .then((data) => {
        setCartData(data);
        const totalPrice = data.reduce((acc, item) => acc + item.price, 0);
        setOriginalTotal(totalPrice);
        setTotal(totalPrice);
      })
      .catch(error => {
        console.error('Failed to fetch cart details:', error);
      });

    // Fetch available coupons
    PublicService.getCoupons(true)
      .then((data) => {
        console.log('Coupons fetched:', data);
        setAvailableCoupons(data);

      })
      .catch(error => {
        console.error('Failed to fetch coupons:', error);
      });
  }, [user.userId]);

  const columns = [
    {
      title: 'Name',
      dataIndex: 'title',
      key: 'title',
    },
    {
      title: 'Price',
      dataIndex: 'price',
      key: 'price',
      render: (text) => `$${text.toFixed(2)}`,
    },
  ];

  const showModal = () => {
    setIsModalVisible(true);
  };

  const handleApplyCoupon = () => {
    if (coupon) {
      const selectedCoupon = availableCoupons.find(c => c.code === coupon);
      if (selectedCoupon) {
        const discountPercent = selectedCoupon.discountPercent / 100;
        const discountedTotal = originalTotal - (originalTotal * discountPercent);

        setTotal(discountedTotal);
        setAppliedCoupon(coupon);
        message.success('Coupon applied successfully');
        setIsModalVisible(false);
      }
    } else {
      message.error('Please select a coupon');
    }
  };

  const handleCancelCoupon = () => {
    setTotal(originalTotal);
    setAppliedCoupon(null);
    message.info('Coupon removed');
  };

  const handleCancel = () => {
    setIsModalVisible(false);
  };

  return (
    <Layout style={{ padding: '24px', backgroundColor: '#fff' }}>
      <Content className="content-wrapper">
        <Title level={2}>Your Shopping Cart</Title>

        <Row justify="end">
          <Col>
            <Button type="danger">
              <DeleteOutlined />
              &nbsp; Delete Cart
            </Button>
          </Col>
        </Row>

        <Divider />
        <div style={{ maxHeight: '300px', overflowY: 'auto', paddingRight: '16px' }}>
          <Table columns={columns} dataSource={cartData} pagination={false} />
        </div>
        <Row justify="end" style={{ marginTop: 16 }}>
          <Col>
            {appliedCoupon && (
              <Button
                type="link"
                onClick={handleCancelCoupon}
                style={{ marginLeft: 16, color: 'red' }}
                icon={<CloseCircleOutlined />}
              >
                Remove Coupon
              </Button>
            )}
            <Button type="default" onClick={showModal} icon={<GiftOutlined />}>
              Apply Coupon
            </Button>
            <Divider />
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div>
                {originalTotal > total && (
                  <div>
                    <div style={{ textDecoration: 'line-through', color: 'gray' }}>
                      Original Price: ${originalTotal.toFixed(2)}
                    </div>
                    <div style={{ color: 'red' }}>
                      Discounted Price: ${total.toFixed(2)}
                    </div>
                  </div>
                )}
              </div>
              <div>
                <Statistic
                  title="Total (tax incl.)"
                  value={`$${total.toFixed(2)}`}
                  precision={2}
                />
              </div>
            </div>
            <Row justify="end" style={{ marginTop: 16 }}>
              <Col>
                <Button type="primary">
                  Pay Now <CreditCardOutlined />
                </Button>
              </Col>
            </Row>
          </Col>
        </Row>
      </Content>

      <Modal
        title="Apply Coupon"
        visible={isModalVisible}
        onOk={handleApplyCoupon}
        onCancel={handleCancel}
      >
        <Form layout="vertical">
          <Form.Item label="Select Coupon">
            <Select
              placeholder="Select a coupon"
              onChange={value => setCoupon(value)}
            >
              {availableCoupons.length > 0 ? (
                availableCoupons.map(coupon => (
                  <Option key={coupon.code} value={coupon.code}>
                    {coupon.code} - {coupon.discountPercent}% Off
                  </Option>
                ))
              ) : (

                <Option disabled>No coupons available</Option>
              )}
            </Select>
          </Form.Item>
        </Form>
      </Modal>
    </Layout>
  );
};

export default Cart;
