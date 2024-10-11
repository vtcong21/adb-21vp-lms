import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Layout, Row, Col, Button, Typography, Divider, Statistic, message } from 'antd';
import { CreditCardOutlined, DeleteOutlined, GiftOutlined, CloseCircleOutlined } from '@ant-design/icons';
import LearnerService from '../../services/learner';
import PublicService from '../../services/public';
import CartTable from "../../components/cart/CartTable";
import CouponModal from "../../components/cart/CouponModal";
import PaymentModal from "../../components/cart/PaymentModal";

const { Content } = Layout;
const { Title } = Typography;

import { useSelector } from 'react-redux';
const Cart = () => {
  const user = useSelector((state) => state.user);
  const navigate = useNavigate();
  const [cartData, setCartData] = useState([]);
  const [total, setTotal] = useState(0);
  const [originalTotal, setOriginalTotal] = useState(0);
  const [isCouponModalVisible, setIsCouponModalVisible] = useState(false);
  const [isPaymentModalVisible, setIsPaymentModalVisible] = useState(false);
  const [coupon, setCoupon] = useState(null);
  const [appliedCoupon, setAppliedCoupon] = useState(null);
  const [availableCoupons, setAvailableCoupons] = useState([]);
  const [paymentCards, setPaymentCards] = useState([]);
  const [selectedCard, setSelectedCard] = useState(null);
  const [isPaying, setIsPaying] = useState(false);

  useEffect(() => {
    LearnerService.getCartDetails(user.userId)
      .then((data) => {
        setCartData(data);
        const totalPrice = data.reduce((acc, item) => acc + item.price, 0);
        setOriginalTotal(totalPrice);
        setTotal(totalPrice);
      })
      .catch(error => console.error('Failed to fetch cart details:', error));

    PublicService.getCoupons(true)
      .then((data) => setAvailableCoupons(data))
      .catch(error => console.error('Failed to fetch coupons:', error));
  }, [user.userId]);

  const handleRemoveCourse = (courseId) => {
    LearnerService.removeCorseFromCart(user.userId, courseId)
      .then(() => {
        // Update cart data locally after removal
        const updatedCartData = cartData.filter(item => item.courseId !== courseId);
        const totalPrice = updatedCartData.reduce((acc, item) => acc + item.price, 0);
        setCartData(updatedCartData);
        setOriginalTotal(totalPrice);
        setTotal(totalPrice);
      })
      .catch((error) => {
        console.error('Failed to remove course from cart:', error);
        message.error('Failed to remove course from cart');
      });
  };

  const showCouponModal = () => setIsCouponModalVisible(true);
  const handleApplyCoupon = () => {
    if (coupon) {
      const selectedCoupon = availableCoupons.find(c => c.code === coupon);
      if (selectedCoupon) {
        const discountPercent = selectedCoupon.discountPercent / 100;
        const discountedTotal = originalTotal - (originalTotal * discountPercent);

        setTotal(discountedTotal);
        setAppliedCoupon(coupon);
        message.success('Coupon applied successfully');
        setIsCouponModalVisible(false);
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
  const handleCancelCouponModal = () => setIsCouponModalVisible(false);

  const showPaymentModal = () => {
    LearnerService.getPaymentCards(user.userId)
      .then((data) => {
        setPaymentCards(data);
        setIsPaymentModalVisible(true);
      })
      .catch(error => {
        console.error('Failed to fetch payment cards:', error);
        message.error('Failed to load payment cards');
      });
  };
  const handlePayNow = async () => {
    if (selectedCard) {
      setIsPaying(true);
      try {
        const res = await LearnerService.makeOrder(user.userId, selectedCard.number, appliedCoupon);

        message.success(`Payment processed with card ending in ${selectedCard.number.slice(-4)}`);
        setIsPaymentModalVisible(false);

        // Wait for 3 seconds before navigating to "/"
        setTimeout(() => {
          navigate('/');
        }, 3000);

      } catch (error) {
        message.error('Failed to process payment. Please try again later.');
        console.error(error);
        setIsPaying(false);
      }
    } else {
      message.error('Please select a payment card');
    }
  };
  const handleCancelPaymentModal = () => setIsPaymentModalVisible(false);

  return (
    // <Layout style={{ padding: '24px', backgroundColor: '#fff' }}>
    <div className="bg-white p-4 mx-4 sm:px-15 md:px-25 lg:px-40 shadow-xl rounded-2xl pb-3">
      {/* <Content className="content-wrapper"> */}
      <Title level={2}>Your Shopping Cart</Title>
      <Divider />
      <CartTable
        cartData={cartData}
        onRemoveCourse={handleRemoveCourse}
      />
      {cartData.length > 0 &&
        (<>
          <Row justify="end" style={{ marginTop: 16 }}>
            <Col>
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
              <Button type="default" onClick={showCouponModal} icon={<GiftOutlined />}>
                Apply Coupon
              </Button>

              <Row justify="end" style={{ marginTop: 16 }}>
                <Col>
                  <Button type="primary" onClick={showPaymentModal} disabled={isPaying}>
                    Pay Now <CreditCardOutlined />
                  </Button>
                </Col>
              </Row>
            </Col>
          </Row>
        </>)
      }
      {/* </Content> */}

      <CouponModal
        isVisible={isCouponModalVisible}
        availableCoupons={availableCoupons}
        setCoupon={setCoupon}
        handleApplyCoupon={handleApplyCoupon}
        handleCancel={handleCancelCouponModal}
      />

      <PaymentModal
        isVisible={isPaymentModalVisible}
        paymentCards={paymentCards}
        setSelectedCard={setSelectedCard}
        handlePayNow={handlePayNow}
        handleCancel={handleCancelPaymentModal}
      />
    </div>
    // </Layout>
  );
};

export default Cart;
