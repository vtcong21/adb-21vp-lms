import React, { useState, useEffect, useRef } from 'react';
import ReactDOM from 'react-dom';
import { Line, Column, Pie } from '@ant-design/plots';
import { Card, Col, message, Row, Segmented, Space, Table, Typography } from 'antd';
import styles from '../../assets/styles/Revenue.css?inline'
import InstructorService from '../../services/admin';
import { useParams } from 'react-router-dom';
import { useSelector } from 'react-redux';

const { Text, Title } = Typography;

const InstructorRevenue = () => {
    const user = useSelector((state) => state.user);
    const { role, name, gender, userId } = user;
    const [courseCount, setCourseCount] = useState(3);
    const [monthCount, setMonthCount] = useState(0);
    const [totalRevenue, setTotalRevenue] = useState(0);
    const [duration, setDuration] = useState(36);
    const [revenueData, setRevenueData] = useState([])
    const [revenueType, setRevenueType] = useState('monthly')
    const chartRef = useRef(null);

    const columns = [
        {
            title: 'Time',
            dataIndex: 'time',
            defaultSortOrder: 'descend',
            sorter: (a, b) => {
                const dateA = new Date(`1/${a.time}`)
                const dateB = new Date(`1/${b.time}`)
                return dateA - dateB;
            }
        },
        {
            title: 'Revenue',
            dataIndex: 'revenue',
            defaultSortOrder: 'descend',
            sorter: (a, b) => { return a - b; }
        }
    ]
    useEffect(() => {
        const fetchRevenueData = async () => {
        try {
            // if (revenueType === 'daily' ) {
            //   const res = await InstructorService.getDailyRevenueForCourse( courseId, duration );
            //   console.log("FIX");
            // }
            if (revenueType === 'monthly') {
            const res = await InstructorService.getMonthlyRevenueForInstructor( userId, duration );
            const resFormatted = res.map((data, index) => {
                setMonthCount(monthCount + 1);
                setTotalRevenue(totalRevenue + data.revenue);
                return ({
                    key: index,
                    time: `${data.month}/${data.year}`,
                    revenue: data.revenue
                });
            });
            setRevenueData(resFormatted);
            }
            else if (revenueType === 'annual') {
            const res = await InstructorService.getAnnualRevenueForInstructor( userId, duration );
            const resFormatted = res.map((data, index) => ({
                key: index,
                time: `${data.year}`,
                revenue: data.totalRevenue
            }));
            setRevenueData(resFormatted);
            }
            console.log(res);
        } catch (error) {
            message.error("Cannot load course revenue data.");
        }
        };

        fetchRevenueData();
    }, [revenueType]);
    const config_bar = {
        data: revenueData,
        xField: 'time',
        yField: 'revenue',
        slider: {
        x: {
            values: [0.1, 0.9],
        },
        },
        onReady: (plot) => console.log(plot)
    };
    const tabListFixed = [
        {
        key: 'graph',
        label: 'Graph',
        children: (
            <>
            <Column {...config_bar} ref={chartRef} />
            </>
        )
        },
        {
        key: 'table',
        label: 'Table',
        children: (
            <>
            <Table dataSource={revenueData} columns={columns} />
            </>
        )
        },
    ]
    return (
        <div className='px-20'>
        <Segmented 
            value={revenueType}
            onChange={(value) => setRevenueType(value)}
            options={[
            // {
            //   label: 'Daily',
            //   value: 'daily'
            // },
            {
                label: 'Monthly',
                value: 'monthly'
            },
            {
                label: 'Annual',
                value: 'annual'
            }
            ]}
        />
        <Row gutter={[16, 16]}>
            <Col xs={24} sm={12} md={8} lg={8}>
            <Card title='Total revenue' bordered={false} style={{ textAlign: "right", display: "flex", flexDirection: "column", width: '100%', margin: '1em', justifyContent: 'center' }}>
                <Title level={2}>${totalRevenue}</Title>
            </Card>
            </Col>
            
            <Col xs={24} sm={12} md={8} lg={8}>
            <Card title='Total courses' bordered={false} style={{ textAlign: "right", display: "flex", flexDirection: "column", width: '100%', margin: '1em', justifyContent: 'center' }}>
                <Title level={2}>{courseCount}</Title>
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
                tabList={tabListFixed}
                style={{ textAlign: "right", display: "flex", flexDirection: "column", width: '100%', height: '100%', margin: '1em', justifyContent: 'center' }}>
                <div style={{ flex: 1, minWidth: 0 }}>
                </div>
            </Card>
            </Col>
        </Row>
        </div>
    )
}

export default InstructorRevenue;
