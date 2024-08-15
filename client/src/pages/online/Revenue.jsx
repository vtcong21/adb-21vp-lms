import React, { useEffect, useRef } from 'react';
import ReactDOM from 'react-dom';
import { Line, Column, Pie } from '@ant-design/plots';
import { Card, Col, Row, Space } from 'antd';
import styles from './Revenue.css'

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
  return (
    <>
      <Row gutter={16} style={{ height: '100%'}}>
        <Col span={16}>
          <Line {...config} />
        </Col>
        <Col span={8} style={{ display: "flex", flexDirection: "column", padding: '1em' }}>
          <Card bordered={false} style={{ display: "flex", flexDirection: "column", width: '100%', height: '100%', margin: '1em' }}>
              Total learner 1
            </Card>
            <Card bordered={false} style={{ display: "flex", flexDirection: "row", width: '100%', height: '100%', margin: '1em' }}>
              Total learner 2
            </Card>
            <Card bordered={false} style={{ display: "flex", flexDirection: "row", width: '100%', height: '100%', margin: '1em' }}>
              Total learner 3
            </Card>
        </Col>
      </Row>
      <Row gutter={16}>
        <Col span={12}>
          <Pie {...config_pie} />
        </Col>
        <Col span={12}>
          <Pie {...config_pie} />
        </Col>
      </Row>
      <Column {...config_bar} />
      {/* <Column {...config2} ref={chartRef} /> */}
    </>
  )

}

export default Revenue;
