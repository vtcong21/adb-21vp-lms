import React, { useState, useEffect } from "react";
import { Card, Rate, Row, Col, Pagination, Empty } from "antd";
import { useNavigate } from "react-router-dom";
import { useSelector } from "react-redux"; // Import useSelector
import LearnerService from "../../services/learner";
import GuestService from "../../services/public";

const { Meta } = Card;

const CourseCard = ({
  courseId,
  title,
  subTitle,
  instructor,
  courseAverageRating,
  totalTime,
  numberOfLectures,
  price,
  image,
}) => {
  const navigate = useNavigate();

  const handleClickTitle = (e) => {
    e.preventDefault(); // Prevent default link behavior

    if (e.button === 1) {
      // Middle mouse button
      window.open(`/learner/learn-course/${courseId}`, "_blank", "noopener,noreferrer");
    } else if (e.button === 0) {
      // Left mouse button
      navigate(`/learner/learn-course/${courseId}`);
    }
  };

  return (
    <Card
      hoverable
      style={{ marginBottom: 16, cursor: "pointer" }} // Set cursor to pointer
      onClick={(e) => {
        if (e.button === 0) {
          // Left mouse button
          navigate(`/learner/learn-course/${courseId}`);
        }
      }}
    >
      <Row gutter={[16, 16]}>
        <Col span={5} style={{ textAlign: "right" }}>
          <img
            alt="course"
            src={`http://localhost:8000/api/files/${image}`}
            style={{ width: 150, height: 150, objectFit: "cover" }}
          />
        </Col>

        <Col span={16}>
          {/* Title */}
          <div
            onMouseDown={handleClickTitle} // Use onMouseDown to capture the click
            style={{
              fontSize: 18,
              fontWeight: "bold",
              textDecoration: "underline",
              cursor: "pointer", // Set cursor to pointer
            }}
          >
            {title}
          </div>

          {/* Subtitle */}
          <div
            style={{
              fontSize: 14,
              color: "gray",
              marginTop: 4,
              marginBottom: 7,
            }}
          >
            {subTitle}
          </div>

          <Meta
            description={
              <>
                {/* Instructor */}
                <div>{instructor}</div>

                {/* Rating */}
                <div style={{ marginTop: 8 }}>
                  {courseAverageRating}
                  <Rate
                    allowHalf
                    defaultValue={courseAverageRating}
                    disabled
                    style={{ fontSize: 16, marginLeft: 6 }}
                  />
                </div>

                {/* Total hours */}
                <div style={{ marginTop: 8, color: "gray", fontSize: 14 }}>
                  {totalTime} total hours <span>•</span> {numberOfLectures}{" "}
                  lessons{" "}
                </div>
              </>
            }
          />
        </Col>

        <Col span={3} style={{ textAlign: "left" }}>
          <div
            style={{
              marginTop: 0,
              fontSize: 16,
              fontWeight: "bold",
              color: "green",
            }}
          >
            Purchased
          </div>
        </Col>
      </Row>
    </Card>
  );
};

const CourseList = ({ learnerId }) => {
  const [currentPage, setCurrentPage] = useState(1);
  const [courses, setCourses] = useState([]);
  const coursesPerPage = 15;

  useEffect(() => {
    const fetchCourses = async () => {
      try {
        const enrolledCoursesRes =
          await LearnerService.getLearnerEnrolledCourse(learnerId);
        const enrolledCourses = enrolledCoursesRes;

        const courseDetails = await Promise.all(
          enrolledCourses.map(async (course) => {
            const courseDetailRes = await GuestService.getCourseById(course.id);
            return courseDetailRes;
          })
        );
        console.log(courseDetails);

        setCourses(courseDetails);
      } catch (error) {
        console.error("Error fetching courses: ", error);
      }
    };

    fetchCourses();
  }, [learnerId]);

  const indexOfLastCourse = currentPage * coursesPerPage;
  const indexOfFirstCourse = indexOfLastCourse - coursesPerPage;
  const currentCourses = courses.slice(indexOfFirstCourse, indexOfLastCourse);

  const onChangePage = (page) => {
    setCurrentPage(page);
  };

  return (
    <div>
      {currentCourses.length > 0 ? (
        currentCourses.map((course, index) => (
          <CourseCard key={index} {...course} />
        ))
      ) : (
        <Empty
          image={Empty.PRESENTED_IMAGE_SIMPLE}
          description={<span>No courses found</span>}
          style={{ marginTop: 32 }}
        />
      )}
      {currentCourses.length > 0 && (
        <Pagination
          current={currentPage}
          pageSize={coursesPerPage}
          total={courses.length}
          onChange={onChangePage}
          style={{ textAlign: "center", marginTop: 16 }}
        />
      )}
    </div>
  );
};

const MyCourse = () => {
  const learnerId = useSelector((state) => state.user.userId); // Get learnerId from the Redux store

  return (
    <Row gutter={[16, 16]} style={{ padding: 16 }}>
      <Col span={24}>
        <CourseList learnerId={learnerId} />
      </Col>
    </Row>
  );
};

export default MyCourse;
