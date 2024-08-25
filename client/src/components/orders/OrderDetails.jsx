// src/components/orders/OrderDetails.js
import React from 'react';
import { Modal, Table } from 'antd';

const OrderDetails = ({ isVisible, orderDetails, onClose }) => {
  const columns = [
    {
      title: 'Course Title',
      dataIndex: 'courseTitle',
      key: 'courseTitle',
    },
    {
      title: 'Course Price',
      dataIndex: 'coursePrice',
      key: 'coursePrice',
      render: (text) => `$${text.toFixed(2)}`,
    },
  ];

  return (
    <Modal
      title={`Order Details - ID: ${orderDetails.orderId}`}
      visible={isVisible}
      onCancel={onClose}
      footer={null}
      width={600}
    >
      <div>
        <p><strong>Order ID:</strong> {orderDetails.orderId}</p>
        <p><strong>Learner Name:</strong> {orderDetails.learnerName}</p>
        <p><strong>Date Created:</strong> {new Date(orderDetails.dateCreated).toLocaleDateString()}</p>
        <p><strong>Total:</strong> ${orderDetails.total.toFixed(2)}</p>
        <p><strong>Payment Card Number:</strong> **** **** **** {orderDetails.paymentCardNumber.slice(-4)}</p>
        <p><strong>Coupon Code:</strong> {orderDetails.couponCode || 'N/A'}</p>
        <p><strong>Discount Percent:</strong> {orderDetails.discountPercent || '0'}%</p>
        <Table
          columns={columns}
          dataSource={orderDetails.orderDetails}
          rowKey="courseId"
          pagination={false}
        />
      </div>
    </Modal>
  );
};

export default OrderDetails;
