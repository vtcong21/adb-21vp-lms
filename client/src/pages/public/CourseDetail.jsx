import React from "react";
import { Row, Col, Card, Typography, Button, Rate, Tabs, List } from "antd";
import { PlayCircleOutlined } from "@ant-design/icons";

const { Title, Paragraph } = Typography;
const { TabPane } = Tabs;

const CourseInfo = () => {
  return (
    <>
      <Row
        gutter={[16, 16]}
        align="middle"
        style={{ padding: 16 }}
        className="bg-white"
      >
        {/* Video Column */}
        <Col span={12}>
          <Card
            cover={
              <iframe
                width="100%"
                height="400"
                src="https://www.youtube.com/embed/ionizQJWsok"
                title="Course Video"
                frameBorder="0"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                allowFullScreen
                style={{ borderRadius: 8 }}
              />
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

        {/* Course Info Column */}
        <Col span={12}>
          <Card
            style={{
              borderRadius: 8,
              boxShadow: "none",
              border: "none",
              height: "100%",
            }}
          >
            <Title level={3}>courseTitle</Title>
            <Paragraph>courseSubTitle</Paragraph>
            <Paragraph>
              <strong>Free tutorial</strong>
            </Paragraph>
            <Paragraph>
              <Rate disabled defaultValue={3.8} />
              <span style={{ marginLeft: 8 }}>3.8 (14 ratings)</span>
            </Paragraph>
            <Paragraph>
              <strong>944 students</strong>
            </Paragraph>
            <Paragraph>
              <strong>40min of on-demand video</strong>
            </Paragraph>
            <Paragraph>
              <strong>Created by MUHAMMAD USMAN ALI</strong>
            </Paragraph>
            <Paragraph>
              <strong>English</strong>
            </Paragraph>
            <Paragraph>
              <strong>Current price: Free</strong>
            </Paragraph>
            <Button
              type="primary"
              size="large"
              icon={<PlayCircleOutlined />}
              style={{ userSelect: "none" }}
            >
              Đăng ký ngay
            </Button>
          </Card>
        </Col>
        {/* Tabs Section */}
        <Tabs defaultActiveKey="1" style={{ padding: 16, userSelect: "none" }}>
          <TabPane tab="What you'll learn" key="1">
            <List
              dataSource={[
                "Speak English with more confidence and clarity",
                "Use the target English with precision",
                "Understand the areas of English that must be mastered to become more fluent",
                "Have deeper knowledge of English and how it works",
              ]}
              renderItem={(item) => (
                <List.Item style={{ userSelect: "none" }}>
                  <Paragraph style={{ userSelect: "none" }}>{item}</Paragraph>
                </List.Item>
              )}
            />
          </TabPane>
          <TabPane tab="Course content" key="2">
            <Paragraph style={{ userSelect: "none" }}>
              Course content details will go here.
            </Paragraph>
          </TabPane>
          <TabPane tab="Reviews" key="3">
            <Paragraph style={{ userSelect: "none" }}>
              Reviews section will go here.
            </Paragraph>
          </TabPane>
          <TabPane tab="Instructors" key="4">
            <Paragraph style={{ userSelect: "none" }}>
              Instructors information will go here.
            </Paragraph>
          </TabPane>
        </Tabs>
      </Row>
    </>
  );
};

export default CourseInfo;
