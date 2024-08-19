import React, { useState, useEffect, useRef } from 'react';
import ReactDOM from 'react-dom';
import { Line, Column, Pie } from '@ant-design/plots';
import { Card, Col, Row, Space, Table, Typography } from 'antd';
import styles from './Revenue.css'

const { Text, Title } = Typography;

const instructors = [
  {
      "id": "INS001",
      "gender": "M",
      "phone": "1234567890",
      "DOB": "1985-02-15",
      "address": "123 Elm St, Springfield, IL",
      "degrees": "PhD in Computer Science",
      "workplace": "University of Springfield",
      "scientificBackground": "Machine Learning, Artificial Intelligence",
      "vipState": "vip",
      "totalRevenue": 120000.00
  }
]

const instructorRevenueByMonth = [
  {
    'instructorId': "INS001",
    'year': 2024,
    'month': 7,
    'revenue': 184000
  },
  {
    'instructorId': "INS001",
    'year': 2024,
    'month': 8,
    'revenue': 192000
  },
  {
    'instructorId': "INS001",
    'year': 2024,
    'month': 9,
    'revenue': 176000
  },
  {
    'instructorId': "INS001",
    'year': 2024,
    'month': 10,
    'revenue': 188000
  },
  {
    'instructorId': "INS001",
    'year': 2024,
    'month': 11,
    'revenue': 200000
  },
  {
    'instructorId': "INS001",
    'year': 2024,
    'month': 12,
    'revenue': 210000
  },
  {
    'instructorId': "INS001",
    'year': 2025,
    'month': 1,
    'revenue': 180000
  },
  {
    'instructorId': "INS001",
    'year': 2025,
    'month': 2,
    'revenue': 175000
  },
  {
    'instructorId': "INS001",
    'year': 2025,
    'month': 3,
    'revenue': 185000
  },
  {
    'instructorId': "INS001",
    'year': 2025,
    'month': 4,
    'revenue': 190000
  },
  {
    'instructorId': "INS001",
    'year': 2025,
    'month': 5,
    'revenue': 195000
  }
];

const courses = []

const courseRevenueByMonth = []

const Revenue = () => {
  const [activeTabKey, setActiveTabKey] = useState('graph');

  const data = [
    { year: '1991', value: 3 },
    { year: '1992', value: 4 },
    { year: '1993', value: 3.5 },
    { year: '1994', value: 5 },
    { year: '1995', value: 4.9 },
    { year: '1996', value: 6 },
    { year: '1997', value: 7 },
    { year: '1998', value: 9 },
    { year: '1999', value: 13 },
  ];

  const config = {
    data,
    height: 400,
    xField: 'year',
    yField: 'value',
  };

  // const chartRef = useRef();
  // useEffect(() => {
  //   console.log({ chartRef });
  //   if (chartRef.current) {
  //   }
  // }, []);
  
  const config_bar = {
    data: instructorRevenueByMonth,
    xField: 'month',
    yField: 'revenue',
    slider: {
      x: {
        values: [0.1, 0.2],
      },
    },
  };
  const tabList = [
    {
      key: 'graph',
      tab: 'graph'
    },
    {
      key: 'table',
      tab: 'table'
    }
  ]
  const tabContentList = {
    'graph': <Column {...config_bar} />,
    'table': <p>table</p>
  }
  
  const config_pie = {
    data,
    angleField: 'value',
    colorField: 'year',
    radius: 0.8,
    label: {
      text: (d) => `${d.type}\n ${d.value}`,
      position: 'spider',
    },
    legend: {
      color: {
        title: false,
        position: 'bottom',
        rowPadding: 5,
      },
    },
  };

  const onTabChange = (key) => {
    setActiveTabKey(key);
  };
  return (
    <div className='px-20'>
      <Row gutter={[16, 16]}>
        <Col xs={24} sm={12} md={8} lg={8}>
          <Card title='Total revenue' bordered={false} style={{ textAlign: "right", display: "flex", flexDirection: "column", width: '100%', margin: '1em', justifyContent: 'center' }}>
            <Title level={2}>$104.56</Title>
          </Card>
        </Col>
        
        <Col xs={24} sm={12} md={8} lg={8}>
          <Card title='Total courses' bordered={false} style={{ textAlign: "right", display: "flex", flexDirection: "column", width: '100%', margin: '1em', justifyContent: 'center' }}>
            <Title level={2}>103</Title>
          </Card>
        </Col>
        
        <Col xs={24} sm={12} md={8} lg={8}>
          <Card title='Total months of activity' bordered={false} style={{ textAlign: "right", display: "flex", flexDirection: "column", width: '100%', margin: '1em', justifyContent: 'center' }}>
            <Title level={2}>36</Title>
          </Card>
        </Col>
      </Row>
      <Space/>
      <div style={{ margin: '2em 0' }} />

      <Row gutter={[16, 16]}>
        <Col xs={24}>
          <Card 
            bordered={false} 
            tabList={tabList}
            activeTabKey={activeTabKey}
            onTabChange={onTabChange}
            style={{ textAlign: "right", display: "flex", flexDirection: "column", width: '100%', height: '100%', margin: '1em', justifyContent: 'center' }}>
            <div style={{ flex: 1, minWidth: 0 }}>
              {tabContentList[activeTabKey]}
            </div>
          </Card>
        </Col>
      </Row>
    </div>
  )

}

export default Revenue;
