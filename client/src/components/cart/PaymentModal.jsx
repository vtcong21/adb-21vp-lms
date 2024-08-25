import React from 'react';
import { Modal, Form, Select } from 'antd';
const { Option } = Select;

const PaymentModal = ({ isVisible, paymentCards, setSelectedCard, handlePayNow, handleCancel }) => (
  <Modal
    title="Select Payment Card"
    visible={isVisible}
    onOk={handlePayNow}
    onCancel={handleCancel}
  >
    <Form layout="vertical">
      <Form.Item label="Select Card">
        <Select
          placeholder="Select a payment card"
          onChange={value => setSelectedCard(paymentCards.find(card => card.number === value))}
        >
          {paymentCards.length > 0 ? (
            paymentCards.map(card => (
              <Option key={card.number} value={card.number}>
                {card.type} - **** **** **** {card.number.slice(-4)}
              </Option>
            ))
          ) : (
            <Option disabled>No payment cards available</Option>
          )}
        </Select>
      </Form.Item>
    </Form>
  </Modal>
);

export default PaymentModal;
