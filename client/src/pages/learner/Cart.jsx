import React, { useEffect, useState } from 'react';
import { Layout, Row, Col, Table, Divider, Statistic, Button, Typography, Modal, Form, Select, message } from 'antd';
import { CreditCardOutlined, DeleteOutlined, GiftOutlined, CloseCircleOutlined } from '@ant-design/icons';
import { useSelector } from 'react-redux';
import LearnerService from '../../services/learner';

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

  useEffect(() => {
    LearnerService.getCartDetails()
      .then((data) => {
        setCartData(data);
        const totalPrice = data.reduce((acc, item) => acc + item.price, 0);
        setOriginalTotal(totalPrice);
        setTotal(totalPrice);
      })
      .catch(error => {
        console.error('Failed to fetch cart details:', error);
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
      const discountPercent = parseFloat(coupon) / 100;
      const discountedTotal = originalTotal - (originalTotal * discountPercent);

      setTotal(discountedTotal);
      setAppliedCoupon(coupon);
      message.success('Coupon applied successfully');
      setIsModalVisible(false);
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

        <Table columns={columns} dataSource={cartData} pagination={false} />
        
        <Row justify="end" style={{ marginTop: 16 }}>
          <Col>
            <Button type="default" onClick={showModal} icon={<GiftOutlined />}>
              Apply Coupon
            </Button>
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
            <Divider />
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
            <Statistic
              title="Total (tax incl.)"
              value={`$${total.toFixed(2)}`}
              precision={2}
              style={{ marginTop: 16 }}
            />
            <Button style={{ marginTop: 16 }} type="primary">
              Pay Now <CreditCardOutlined />
            </Button>
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
              <Option value="10">10% Off</Option>
              <Option value="20">20% Off</Option>
              <Option value="30">30% Off</Option>
              
            </Select>
          </Form.Item>
        </Form>
      </Modal>
    </Layout>
  );
};

export default Cart;
