import React, { useState, useEffect } from "react";
import {
  Card,
  Rate,
  Row,
  Col,
  Input,
  Checkbox,
  Radio,
  Collapse,
  Pagination,
  Empty,
} from "antd";
import { useNavigate } from "react-router-dom";
import GuestService from "../../services/public";

const { Meta } = Card;
const { Search } = Input;
const { Panel } = Collapse;

const Filter = ({
  onSearch,
  onRatingChange,
  onPriceChange,
  onSubcategoryChange,
}) => {
  const [subcategories, setSubcategories] = useState([]);

  useEffect(() => {
    GuestService.getTopHotCategories().then((res) => {
      setSubcategories(res || []);
    });
  }, []);

  return (
    <div>
      {/* Search */}
      <Search
        style={{ marginBottom: 16 }}
        placeholder="Input course title"
        enterButton
        onSearch={onSearch}
      />

      <Collapse>
        {/* Ratings */}
        <Panel header="Ratings" key="1" className="bg-gray-50">
          <Radio.Group onChange={(e) => onRatingChange(e.target.value)}>
            <Radio value={4.5}>
              <span style={{ display: "inline-flex", alignItems: "center" }}>
                <Rate
                  allowHalf
                  defaultValue={4.5}
                  disabled
                  style={{ fontSize: 16, marginRight: 6 }}
                />
                4.5 & up
              </span>
            </Radio>

            <br />

            <Radio value={4}>
              <span style={{ display: "inline-flex", alignItems: "center" }}>
                <Rate
                  allowHalf
                  defaultValue={4}
                  disabled
                  style={{ fontSize: 16, marginRight: 6 }}
                />
                4.0 & up
              </span>
            </Radio>

            <br />

            <Radio value={3.5}>
              <span style={{ display: "inline-flex", alignItems: "center" }}>
                <Rate
                  allowHalf
                  defaultValue={3.5}
                  disabled
                  style={{ fontSize: 16, marginRight: 6 }}
                />
                3.5 & up
              </span>
            </Radio>

            <br />

            <Radio value={3}>
              <span style={{ display: "inline-flex", alignItems: "center" }}>
                <Rate
                  allowHalf
                  defaultValue={3}
                  disabled
                  style={{ fontSize: 16, marginRight: 6 }}
                />
                3 & up
              </span>
            </Radio>

            <Radio value={0}>
              <span style={{ display: "inline-flex", alignItems: "center" }}>
                None
              </span>
            </Radio>
          </Radio.Group>
        </Panel>

        {/* Subcategory */}
        <Panel header="Hot categories" key="3" className="bg-gray-50">
          <Checkbox.Group onChange={onSubcategoryChange}>
            <div style={{ display: "flex", flexDirection: "column" }}>
              {subcategories.map((subcategory) => (
                <Checkbox
                  key={`${subcategory.subCategoryId}_${subcategory.categoryId}`}
                  value={`${subcategory.subCategoryId}_${subcategory.categoryId}`}
                  style={{ marginBottom: 8 }}
                >
                  {subcategory.subCategoryName}
                </Checkbox>
              ))}
            </div>
          </Checkbox.Group>
        </Panel>

        {/* Price */}
        <Panel header="Price" key="4" className="bg-gray-50">
          <Checkbox onChange={() => onPriceChange("paid")}>Paid</Checkbox>
          <br />
          <Checkbox onChange={() => onPriceChange("free")}>Free</Checkbox>
          <br />
        </Panel>
      </Collapse>
    </div>
  );
};

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
      window.open(`/course-detail/${courseId}`, "_blank", "noopener,noreferrer");
    } else if (e.button === 0) {
      // Left mouse button
      navigate(`/course-detail/${courseId}`);
    }
  };

  return (
    <Card
      hoverable
      style={{ marginBottom: 16, cursor: "default" }}
      onClick={(e) => {
        if (e.button === 0) {
          // Left mouse button
          navigate(`/course-detail/${courseId}`);
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
              cursor: "pointer",
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
              color: "red",
            }}
          >
            ${price}
          </div>
        </Col>
      </Row>
    </Card>
  );
};

const CourseList = ({ courseName, rating, price, selectedSubcategories }) => {
  const [currentPage, setCurrentPage] = useState(1);
  const [courses, setCourses] = useState([]);
  const coursesPerPage = 15;

  useEffect(() => {
    if (courseName.trim() !== "") {
      GuestService.getCourseByName(courseName, "public").then((res) => {
        setCourses(res || []);
      });
    }
  }, [courseName]);

  // Apply filters
  const filteredCourses = courses
    .filter((course) => !rating || course.courseAverageRating >= rating)
    .filter(
      (course) =>
        !price || (price === "paid" ? course.price > 0 : course.price === 0)
    )
    .filter(
      (course) =>
        selectedSubcategories.length === 0 ||
        selectedSubcategories.includes(
          `${course.subCategoryId}_${course.categoryId}`
        )
    );

  const indexOfLastCourse = currentPage * coursesPerPage;
  const indexOfFirstCourse = indexOfLastCourse - coursesPerPage;
  const currentCourses = filteredCourses.slice(
    indexOfFirstCourse,
    indexOfLastCourse
  );

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
          total={filteredCourses.length}
          onChange={onChangePage}
          style={{ textAlign: "center", marginTop: 16 }}
        />
      )}
    </div>
  );
};

const CourseFilter = () => {
  const [courseName, setCourseName] = useState("");
  const [rating, setRating] = useState(null);
  const [price, setPrice] = useState(null);
  const [selectedSubcategories, setSelectedSubcategories] = useState([]);

  const handleSearch = (value) => {
    setCourseName(value);
  };

  return (
    <Row gutter={[16, 16]} style={{ padding: 16 }}>
      <Col span={6}>
        <Filter
          onSearch={handleSearch}
          onRatingChange={setRating}
          onPriceChange={setPrice}
          onSubcategoryChange={setSelectedSubcategories}
        />
      </Col>
      <Col span={18}>
        <CourseList
          courseName={courseName}
          rating={rating}
          price={price}
          selectedSubcategories={selectedSubcategories}
        />
      </Col>
    </Row>
  );
};

export default CourseFilter;
