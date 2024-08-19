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
import GuestService from "../../services/public";

const { Meta } = Card;
const { Search } = Input;
const { Panel } = Collapse;

const Filter = () => {
  const [subcategories, setSubcategories] = useState([]);

  useEffect(() => {
    GuestService.getTopHotCategories().then((res) => {
      console.log(res);
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
      />

      <Collapse>
        {/* Ratings */}
        <Panel header="Ratings" key="1" className="bg-gray-50">
          <Radio.Group>
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
          </Radio.Group>
        </Panel>

        {/* Subcategory */}
        <Panel header="Hot categories" key="3" className="bg-gray-50">
          <Checkbox.Group>
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
          <Checkbox>Paid</Checkbox>
          <br />
          <Checkbox>Free</Checkbox>
          <br />
        </Panel>
      </Collapse>
    </div>
  );
};

const CourseCard = ({
  title,
  subTitle,
  instructor,
  rating,
  totalTime,
  numOfLessons,
  price,
  imgSrc,
}) => (
  <Card hoverable style={{ marginBottom: 16 }}>
    <Row gutter={[16, 16]}>
      <Col span={5} style={{ textAlign: "right" }}>
        <img
          alt="course"
          src={imgSrc}
          style={{ width: 150, height: 150, objectFit: "cover" }}
        />
      </Col>

      <Col span={16}>
        {/* Title */}
        <div style={{ fontSize: 18, fontWeight: "bold" }}>{title}</div>

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
                {rating}
                <Rate
                  allowHalf
                  defaultValue={rating}
                  disabled
                  style={{ fontSize: 16, marginLeft: 6 }}
                />
              </div>

              {/* Total hours */}
              <div style={{ marginTop: 8, color: "gray", fontSize: 14 }}>
                {totalTime} total hours <span>•</span> {numOfLessons} lessons{" "}
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
          {price}
        </div>
      </Col>
    </Row>
  </Card>
);

const CourseList = () => {
  const [currentPage, setCurrentPage] = useState(1);
  const coursesPerPage = 5;

  const courses = [
    // Thêm các đối tượng CourseCard tại đây
  ];

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

const CourseFilter = () => (
  <Row gutter={[16, 16]} style={{ padding: 16 }}>
    <Col span={6}>
      <Filter />
    </Col>
    <Col span={18}>
      <CourseList />
    </Col>
  </Row>
);

export default CourseFilter;
