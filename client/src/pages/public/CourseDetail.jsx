import React, { useEffect, useState } from "react";
import { useParams, Link, useNavigate } from "react-router-dom";
import { useSelector } from "react-redux";
import {
  Row,
  Col,
  Card,
  Typography,
  Button,
  Rate,
  Tabs,
  List,
  message,
  Collapse,
} from "antd";
import {
  TranslationOutlined,
  CheckCircleOutlined,
  YoutubeOutlined,
  FormOutlined,
} from "@ant-design/icons";
import GuestService from "../../services/public";
import LearnerService from "../../services/learner";

const { Title, Paragraph } = Typography;
const { TabPane } = Tabs;
const { Panel } = Collapse;

function formatTime(totalHours) {
  const hours = Math.floor(totalHours);
  const minutes = Math.round((totalHours - hours) * 60);
  return `${hours}hr ${minutes}min`;
}

const CourseDetail = () => {
  const navigate = useNavigate();
  const user = useSelector((state) => state.user);
  const learnerId = user?.userId;
  const { courseId } = useParams();
  const [course, setCourse] = useState(null);
  const [learnerReviews, setLearnerReviews] = useState([]);
  const [isEnrolled, setIsEnrolled] = useState(false);
  const [isInCart, setIsInCart] = useState(false);

  useEffect(() => {
    const fetchCourseData = async () => {
      try {
        const res = await GuestService.getCourseById(courseId);
        setCourse(res || {});
        setLearnerReviews(res.learnerReviews || []);
      } catch (error) {
        message.error("Cannot load course data.");
      }
    };

    const checkEnrollment = async () => {
      if (!learnerId) return;
      try {
        const enrolledCourses = await LearnerService.getLearnerEnrolledCourse(
          learnerId
        );
        const enrolled = enrolledCourses.some(
          (course) => course.id === parseInt(courseId, 10)
        );
        setIsEnrolled(enrolled);
      } catch (error) {
        message.error("Cannot check enrollment status.");
      }
    };

    const checkCart = async () => {
      if (!learnerId) return;
      try {
        const cartDetails = await LearnerService.getCartDetails(learnerId);
        const inCart = cartDetails.some(
          (cartItem) => cartItem.courseId === parseInt(courseId, 10)
        );
        setIsInCart(inCart);
      } catch (error) {
        message.error("Cannot check cart status.");
      }
    };

    fetchCourseData();
    checkEnrollment();
    checkCart();
  }, [courseId, learnerId]);

  const handleEnroll = async () => {
    if (!learnerId) {
      navigate("/signin"); // Redirect to login page if not logged in
    } else {
      if (!isEnrolled && !isInCart) {
        try {
          await LearnerService.addCourseToCart(learnerId, courseId);

          message.success("Course added to cart successfully!");
          setIsInCart(true); // Update the cart status
          navigate("/learner/cart"); // Redirect to cart page
        } catch (error) {
          message.error(
            "An error occurred while adding the course to the cart."
          );
        }
      }
    }
  };

  if (!course) return <p>Loading...</p>;
  const tabPanes = [
    {
      key: '1',
      label: "What You Will Learn",
      children: (
        <>
          <List
              dataSource={
                course.courseObjectives?.map((obj) => obj.objective) || []
              }
              renderItem={(item) => (
                <List.Item style={{ userSelect: "none" }}>
                  <div style={{ display: "inline-flex" }}>
                    <CheckCircleOutlined
                      style={{ color: "#52c41a", marginRight: 8 }}
                    />

                    <Paragraph style={{ userSelect: "none", margin: 0 }}>
                      {item}
                    </Paragraph>
                  </div>
                </List.Item>
              )}
            />
        </>
      )
    },
    {
      key: '2',
      label: 'Course Content',
      children: (
        <>
          {/* Course Requirements */}
          <Title level={3} style={{ fontWeight: "bold" }}>
            Requirements
          </Title>
          <List
            dataSource={
              course.courseRequirements?.map((req) => req.requirement) || []
            }
            renderItem={(item) => (
              <List.Item style={{ padding: 0 }}>
                <Paragraph style={{ margin: 0 }}>
                  <span style={{ marginRight: 8 }}>•</span>
                  {item}
                </Paragraph>
              </List.Item>
            )}
          />
  
          {/* Course Description */}
          <Title level={3} style={{ fontWeight: "bold", marginTop: 35 }}>
            Description
          </Title>
          <Paragraph>{course.description || "Course description"}</Paragraph>
  
          {/* Intended Learners */}
          <Title level={3} style={{ fontWeight: "bold" }}>
            This Course is For:
          </Title>
          <List
            dataSource={
              course.courseIntendedLearners?.map(
                (learner) => learner.intendedLearner
              ) || []
            }
            renderItem={(item) => (
              <List.Item style={{ padding: 0 }}>
                <Paragraph style={{ margin: 0 }}>
                  <span style={{ marginRight: 8 }}>•</span>
                  {item}
                </Paragraph>
              </List.Item>
            )}
          />
  
          {/* Course Content */}
          <Title level={3} style={{ fontWeight: "bold", marginTop: 35 }}>
            Course Content
          </Title>
  
          <Collapse
            defaultActiveKey={
              course.sections?.length > 0
                ? [course.sections[0].sectionId.toString()]
                : []
            }
            style={{ borderRadius: 0 }}
          >
            {course.sections?.map((section) => (
              <Panel
                header={
                  <div
                    style={{
                      display: "flex",
                      justifyContent: "space-between",
                      alignItems: "center",
                    }}
                  >
                    <span>{section.sectionTitle}</span>
                    <span>{`${
                      section.lectures ? section.lectures.length : 0
                    } lectures • ${formatTime(
                      section.sectionLearnTime || 0
                    )}`}</span>
                  </div>
                }
                key={section.sectionId}
                style={{ borderRadius: 0 }}
                className="bg-gray-50"
              >
                <div style={{ display: "flex", flexDirection: "column" }}>
                  {section.lectures?.map((lecture) => (
                    <div
                      key={lecture.lectureId}
                      style={{
                        display: "flex",
                        justifyContent: "space-between",
                        margin: "8px 0",
                        alignItems: "center",
                      }}
                    >
                      <p
                        style={{
                          margin: 0,
                          display: "flex",
                          alignItems: "center",
                        }}
                      >
                        <YoutubeOutlined style={{ marginRight: 6 }} />
                        {lecture.lectureTitle}
                      </p>
                      <span>{formatTime(lecture.lectureLearnTime || 0)}</span>
                    </div>
                  ))}
                  {section.exercises?.map((exercise) => (
                    <div
                      key={exercise.exerciseId}
                      style={{
                        display: "flex",
                        justifyContent: "space-between",
                        margin: "8px 0",
                        alignItems: "center",
                      }}
                    >
                      <p
                        style={{
                          margin: 0,
                          display: "flex",
                          alignItems: "center",
                        }}
                      >
                        <FormOutlined style={{ marginRight: 6 }} />
                        {exercise.exerciseTitle}
                      </p>
                      <span>
                        {formatTime(exercise.exerciseLearnTime || 0)}
                      </span>
                    </div>
                  ))}
                </div>
              </Panel>
            ))}
          </Collapse>
        </>
      )
    },
    {
      key: '3',
      label: 'Reviews',
      children: (
        <>
          <div style={{ minHeight: "200px" }}>
            {" "}
            {/* Adjust minHeight as needed */}
            {learnerReviews.length > 0 ? (
              <List
                itemLayout="horizontal"
                dataSource={learnerReviews}
                renderItem={(item) => (
                  <List.Item
                    style={{
                      display: "flex",
                      justifyContent: "space-between",
                      alignItems: "center",
                      padding: "8px 0",
                    }}
                  >
                    <List.Item.Meta
                      avatar={
                        item.profilePhoto ? (
                          <img
                            src={`http://localhost:8000/api/files/${item.profilePhoto}`}
                            alt={item.name || "Profile"}
                            style={{
                              width: 40,
                              height: 40,
                              borderRadius: "50%",
                              objectFit: "cover",
                            }}
                          />
                        ) : null
                      }
                      title={item.name || "Anonymous"}
                      description={item.review || "No review content"}
                      style={{ flex: 1 }}
                    />
                    <Rate
                      disabled
                      defaultValue={item.rating || 0}
                      style={{ fontSize: "12px" }}
                    />
                  </List.Item>
                )}
              />
            ) : (
              <p>No reviews yet.</p>
            )}
          </div>
        </>
      )
    }
  ];

  return (
    <>
      <Row
        gutter={[16, 16]}
        align="middle"
        style={{ padding: 16 }}
        className="bg-white"
      >
        <Col span={12}>
          <Card
            cover={
              course.video ? (
                <iframe
                  width="100%"
                  height="400"
                  src={`http://localhost:8000/api/files/${course.video}`}
                  title="Course Video"
                  frameBorder="0"
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                  allowFullScreen
                  style={{ borderRadius: 8 }}
                />
              ) : null
            }
            style={{
              borderRadius: 8,
              boxShadow: "none",
              border: "none",
              height: "100%",
              userSelect: "none",
            }}
          />
        </Col>

        <Col span={12}>
          <Card
            style={{
              borderRadius: 8,
              boxShadow: "none",
              border: "none",
              height: "100%",
            }}
          >
            <Title level={3} style={{ fontWeight: "bold", fontSize: "28px" }}>
              {course.courseTitle || "Course Title"}
            </Title>
            <Paragraph style={{ fontSize: "18px", fontStyle: "italic" }}>
              {course.subTitle || "Subtitle"}
            </Paragraph>
            <Paragraph>
              <span>
                <b>{course.courseAverageRating || 0}</b>
                <Rate
                  disabled
                  defaultValue={course.courseAverageRating || 0}
                  style={{ fontSize: 16, marginLeft: -20, marginRight: 30 }}
                />
              </span>
              <span style={{ marginLeft: 8 }}>
                {course.numberOfLearners || 0} learners
              </span>
              <br />
              <YoutubeOutlined style={{ marginRight: 4 }} />
              <strong>{formatTime(course.totalTime || 0)} video hours</strong>
            </Paragraph>
            <Paragraph style={{ marginTop: 24, fontSize: "13px" }}>
              <strong>
                <span style={{ marginRight: 4 }}>Created by</span>
                {course.instructorsOwnCourse?.map((instructor, index) => (
                  <React.Fragment key={instructor.instructorId}>
                    <Link
                      to={`/profile/${instructor.instructorId}`}
                      style={{ color: "inherit" }}
                    >
                      <span
                        style={{
                          color: "#1890ff",
                          textDecoration: "underline",
                        }}
                      >
                        {instructor.instructorName}
                      </span>
                    </Link>
                    {index < course.instructorsOwnCourse.length - 1 && ", "}
                  </React.Fragment>
                ))}
              </strong>
            </Paragraph>
            <Paragraph>
              <TranslationOutlined style={{ marginRight: 4 }} />
              <strong style={{ fontSize: "13px" }}>
                {course.language || "Language"}
              </strong>
            </Paragraph>
            <Paragraph>
              <b style={{ fontSize: 20 }}>${course.price || 0}</b>
            </Paragraph>
            <Button
              type="primary"
              size="large"
              style={{ width: "100%", userSelect: "none" }}
              disabled={isEnrolled || isInCart}
              onClick={handleEnroll} // Trigger the enrollment check
            >
              <b>
                {isEnrolled
                  ? "ENROLLED"
                  : isInCart
                  ? "COURSE IN CART"
                  : "ENROLL NOW"}
              </b>
            </Button>
          </Card>
        </Col>
        <Tabs
          defaultActiveKey="1"
          style={{ padding: 16, userSelect: "none", width: "100%" }}
          items={tabPanes}
        />
      </Row>
    </>
  );

};

export default CourseDetail;
