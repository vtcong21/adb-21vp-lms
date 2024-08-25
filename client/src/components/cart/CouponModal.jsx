import React from 'react';
import { Modal, Form, Select } from 'antd';
const { Option } = Select;

const CouponModal = ({ isVisible, availableCoupons, setCoupon, handleApplyCoupon, handleCancel }) => (
  <Modal
    title="Apply Coupon"
    visible={isVisible}
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
);

export default CouponModal;
