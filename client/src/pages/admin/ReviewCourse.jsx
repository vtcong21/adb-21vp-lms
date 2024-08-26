import { InfoCircleOutlined } from "@ant-design/icons";
import { Form, Card, Button, Input, Space, Modal } from "antd";
import { useForm } from "antd/es/form/Form";
import TextArea from "antd/es/input/TextArea";
import { useEffect, useState } from "react";
import LearnerList from "../../components/course/LearnerList";
import Revenue from "../../components/course/CourseRevenue";
import CourseDetail from "../public/CourseDetail"
import { useLocation } from "react-router-dom";

const ReviewCourse = () => {
    const [form] = useForm();
    const location = useLocation();
    const courseDetails = location.state || {};
    const [comment, setComment] = useState('');
    const [reviewState, setReviewState] = useState('');

    const [textAreaHelp, setTextAreaHelp] = useState('');
    const [textAreaStatus, setTextAreaStatus] = useState('');
    const [isAccepted, setIsAccepted] = useState(false);
    const [isPrivated, setIsPrivated] = useState(false);
    const [isRefused, setIsRefused] = useState(false);
    const [isDisabledButton, setIsDisabledButton] = useState(true);

    const [isModalOpen, setIsModalOpen] = useState(false);
    const [isSubmitted, setIsSubmitted] = useState(false);

    const [activeTabKey, setActiveTabKey] = useState('course_details');

    const showModal = () => {
        setIsModalOpen(true);
    }
    const handlePrivate = () => {
        setIsPrivated(true);
    }
    const handleRefuse = () => {
        setIsRefused(true);
    }   
    const handleAccept = () => {
        setIsAccepted(true);
    }
    const handleSubmit = () => {
        setIsSubmitted(true);
    }
    const handleCancel = () => {
        setIsModalOpen(false);
    }
    const onTabChange = (key) => {
        setActiveTabKey(key);
    }

    const tabList = [
        {
            key: 'course_details',
            tab: 'Course Details',
        },
        {
            key: 'course_learners',
            tab: 'Learners',
        },
        {
            key: 'course_revenue',
            tab: 'Revenue',
        },
    ]
    
    const contentList = {
        course_details: 
        <>
            <CourseDetail />
            <Modal 
                title='Submit Response' 
                open={isModalOpen} 
                onOk={handleSubmit} 
                onCancel={handleCancel}
                okText='Submit'
                okButtonProps={{ disabled: isDisabledButton }}
            >
                <Form
                    form={form}
                    layout="vertical"
                    >
                    <Form.Item
                        label="Reason"
                        required
                        tooltip="Reason for your decision"
                        validateStatus={textAreaStatus}
                        help={textAreaHelp}
                    >
                        <TextArea 
                            rows={4} 
                            // status={textAreaStatus}
                            placeholder="Because this course is ..." 
                            onChange={(e) => setComment(e.target.value)} />
                    </Form.Item>
                </Form>
            </Modal>
            {/* <Course/> */}
            {(courseDetails.state === 'public') ? (
                    <div className="flex justify-end">
                        <Space size='large'>
                            <Button 
                                type="primary" 
                                danger
                                onClick={handlePrivate}
                            >
                                Private the course
                            </Button>
                        </Space>
                </div>
                ) : (courseDetails.state === 'pendingReview' || courseDetails.state === 'public') ? (
                    <div className="flex justify-end">
                        <Space size='large'>
                        <Button 
                            type="primary" 
                            danger
                            onClick={handleRefuse}
                        >
                            Refuse
                        </Button>
                        <Button 
                            type="primary"
                            onClick={handleAccept}
                        >
                            Accept
                        </Button>
                        </Space>
                    </div>
                ) : (<></>)}
        </>,
        course_learners:
        <>
            <LearnerList/>
        </>,
        course_revenue:
        <>
            <Revenue />
        </>
    };
    

    useEffect(() => {
        if (comment.length >= 1) {
            setIsDisabledButton(false);
            setTextAreaStatus('');
            setTextAreaHelp('')
        }
        else {
            setIsDisabledButton(true);
            setTextAreaStatus('error');
            setTextAreaHelp("The message should not be empty");
        }
    }, [comment])

    useEffect(() => {
        if (isPrivated) {
            setReviewState('draft');
            showModal();
        }
    }, [isPrivated]);

    useEffect(() => {
        if (isRefused) {
            setReviewState('draft');
            showModal();
        }
    }, [isRefused]);

    useEffect(() => {
        if (isAccepted) {
            setReviewState('public');
            setIsSubmitted(true);
            console.log('Accepted.');
        }
    }, [isAccepted])

    useEffect(() => {
        if (isSubmitted) {
            console.log('Submitting ' + reviewState);
            console.log('Response: '+comment)
            courseDetails.state = reviewState;
            if (isModalOpen) {
                setIsModalOpen(false);
            }
        }
    }, [isSubmitted]);

    return (
        <>
            <Card
                tabList={tabList}
                activeTabKey={activeTabKey}
                onTabChange={onTabChange}    
            > 
                {contentList[activeTabKey]}
            </Card>
        </>
    )
}

export default ReviewCourse;