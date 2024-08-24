import React, { useEffect, useState } from 'react';
import { Layout, Typography, message, Card, Table, Row, Col } from 'antd';
import { useParams } from 'react-router-dom';
import { useSelector } from 'react-redux';
import LearnerService from '../../services/learner';
import moment from 'moment';

const { Content } = Layout;
const { Title, Paragraph } = Typography;

const OrderDetailsPage = () => {
    const { orderId } = useParams();
    const userId = useSelector((state) => state.user.userId);

    const [orderDetails, setOrderDetails] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        if (!userId || !orderId) {
            message.error('User ID or Order ID is missing');
            return;
        }

        const fetchOrderDetails = async () => {
            try {
                const data = await LearnerService.getOrderDetails(userId, orderId);
                setOrderDetails(data);
            } catch (error) {
                console.error('Failed to fetch order details:', error);
                message.error('Failed to load order details');
            } finally {
                setLoading(false);
            }
        };

        fetchOrderDetails();
    }, [orderId, userId]);

    const columns = [
        {
            title: 'Course Title',
            dataIndex: 'courseTitle',
            key: 'courseTitle',
        },
        {
            title: 'Price',
            dataIndex: 'coursePrice',
            key: 'coursePrice',
            width: 240,
            render: (text) => `$${text.toFixed(2)}`,
        },
    ];

    if (loading) return <p>Loading...</p>;

    return (
        // <Layout style={{ padding: '24px', backgroundColor: '#f0f2f5' }}>
        // <Content style={{ maxWidth: 1200, margin: '0 auto', padding: '24px' }}>
        <div className="bg-white p-5 mx-5 sm:px-15 md:px-25 lg:px-40 shadow-xl rounded-2xl pb-3">

            <Title level={2} style={{ marginBottom: 24 }}>Order Details</Title>
            {orderDetails ? (
                <Card
                    title={`Order ID: ${orderDetails.orderId}`}
                    style={{ marginBottom: 24, borderRadius: 8, boxShadow: '0 4px 8px rgba(0,0,0,0.1)' }}
                >
                    <Row gutter={[16, 16]}>
                        <Col xs={24} sm={12}>
                            <Paragraph><strong>Learner's Name:</strong> {orderDetails.learnerName}</Paragraph>
                            <Paragraph><strong>Date Paid:</strong> {moment(orderDetails.dateCreated).format('mm:HH DD/MM/YYYY')}</Paragraph>
                            {orderDetails.couponCode &&
                                (<>
                                    <Paragraph><strong>Coupon Code:</strong> {orderDetails.couponCode}</Paragraph>
                                </>)}
                        </Col>
                        <Col xs={24} sm={12}>
                            <Paragraph><strong>Payment Card Number:</strong> {orderDetails.paymentCardNumber}</Paragraph>
                            <Paragraph>
                                <strong>Total:</strong>
                                <span style={{ color: '#1890ff', fontWeight: 'bold' }}> ${orderDetails.total.toFixed(2)}</span>
                            </Paragraph>
                            {orderDetails.couponCode &&
                                (<>
                                    <Paragraph><strong>Discount Percent:</strong> {orderDetails.discountPercent}%</Paragraph>
                                </>)}
                        </Col>

                    </Row>
                    <Title level={4} style={{ marginTop: 24 }}>Courses</Title>
                    <Table
                        columns={columns}
                        dataSource={orderDetails.orderDetails}
                        rowKey="courseId"
                        pagination={false}
                        scroll={{ y: 400 }}
                        style={{ backgroundColor: '#fff', borderRadius: 8, overflow: 'auto' }}
                    />
                </Card>
            ) : (
                <p>No details available</p>
            )}
        </div>
        // </Content>
        // </Layout>
    );
};

export default OrderDetailsPage;
