import React from 'react';
import { Table, Button } from 'antd';
import { InfoCircleOutlined } from '@ant-design/icons';
import moment from 'moment';

// Function to format dates to dd/mm/yyyy
const formatDate = (dateString) => {
  return moment(dateString).format('mm:HH DD/MM/YYYY');
};

const OrdersTable = ({ orders, onViewDetails }) => {
  const columns = [
    {
      title: 'Date Created',
      dataIndex: 'dateCreated',
      key: 'dateCreated',
      render: (text) => formatDate(text),
    },
    {
      title: 'Total',
      dataIndex: 'total',
      key: 'total',
      render: (text) => `$${text.toFixed(2)}`,
    },
    {
      title: 'Action',
      key: 'action',
      width: 240,
      render: (_, record) => (
        <Button
          type="link"
          icon={<InfoCircleOutlined />}
          onClick={() => onViewDetails(record.id)}
        >
          View Details
        </Button>
      ),
    },
  ];

  return (
    <div className="min-h-[180px]"> 
      <Table
        columns={columns}
        dataSource={orders}
        rowKey="id"
        pagination={false} 
      />
    </div>
  );
};

export default OrdersTable;
