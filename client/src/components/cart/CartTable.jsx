import React from 'react';
import { Table, Button } from 'antd';
import { DeleteOutlined } from '@ant-design/icons';

const CartTable = ({ cartData, onRemoveCourse }) => {
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
    {
      title: 'Action',
      key: 'action',
      width:240,
      render: (_, record) => (
        <Button
          type="link"
          icon={<DeleteOutlined />}
          onClick={() => onRemoveCourse(record.courseId)}
        >
          Remove
        </Button>
      ),
    },
  ];

  return (
    
      <Table
        columns={columns}
        dataSource={cartData}
        pagination={false}
        rowKey="courseId"
        scroll={{ y: 'calc(80vh - 140px)' }} 
      />
    
  );
};

export default CartTable;
