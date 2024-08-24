import React, { useState, useEffect } from "react";
import { Layout, Collapse, message, Button } from "antd";
import ReactPlayer from "react-player";
import { useParams } from "react-router-dom";
import GuestService from "../../services/public"; // Adjust the import path as needed
import { YoutubeOutlined, FormOutlined } from "@ant-design/icons";

const { Sider, Content } = Layout;
const { Panel } = Collapse;

const LearnCourse = () => {
  const { courseId } = useParams();
  const [course, setCourse] = useState(null);
  const [selectedResource, setSelectedResource] = useState(null);
  const [selectedAnswers, setSelectedAnswers] = useState({}); // Track selected answers
  const [submittedAnswers, setSubmittedAnswers] = useState({}); // Track submitted answers

  useEffect(() => {
    const fetchCourseData = async () => {
      try {
        const res = await GuestService.getCourseById(courseId);
        setCourse(res || {});
      } catch (error) {
        message.error("Cannot load course data.");
      }
    };

    fetchCourseData();
  }, [courseId]);

  const handleLectureClick = (lecture) => {
    setSelectedResource({
      type: 'lecture',
      url: lecture.lectureResource,
    });
  };

  const handleExerciseClick = (exercise) => {
    setSelectedResource({
      type: 'exercise',
      questions: exercise.questions,
    });
    // Clear any previously submitted answers
    setSubmittedAnswers({});
  };

  const handleAnswerSelect = (questionId, answerId) => {
    if (!submittedAnswers[questionId]) {
      setSelectedAnswers(prev => ({
        ...prev,
        [questionId]: answerId,
      }));
    }
  };

  const handleSubmit = () => {
    setSubmittedAnswers(selectedAnswers);
  };

  return (
    <Layout style={{ height: "100vh" }}>
      <Content style={{ padding: "20px", backgroundColor: "#000" }}>
        {selectedResource && selectedResource.type === 'lecture' ? (
          <ReactPlayer
            url={selectedResource.url}
            width="100%"
            height="100%"
            controls
          />
        ) : selectedResource && selectedResource.type === 'exercise' ? (
          <div style={{ color: "#fff", padding: "20px", overflowY: "auto" }}>
            <h2 style={{ marginBottom: "20px" }}>Exercises</h2>
            {selectedResource.questions.map(question => (
              <div key={question.questionId} style={{ marginBottom: "20px", border: "1px solid #444", borderRadius: "8px", padding: "15px", backgroundColor: "#333" }}>
                <h3 style={{ margin: "0 0 10px", fontSize: "16px" }}>{question.question}</h3>
                <ul style={{ paddingLeft: "20px" }}>
                  {question.questionAnswers.map(answer => (
                    <li key={answer.questionAnswerId} style={{ marginBottom: "5px" }}>
                      <Button
                        type={selectedAnswers[question.questionId] === answer.questionAnswerId ? 'primary' : 'default'}
                        style={{ marginRight: "10px", pointerEvents: submittedAnswers[question.questionId] ? 'none' : 'auto' }}
                        onClick={() => handleAnswerSelect(question.questionId, answer.questionAnswerId)}
                      >
                        {answer.questionAnswers}
                      </Button>
                      {submittedAnswers[question.questionId] === answer.questionAnswerId && (
                        <span style={{ marginLeft: "10px", color: answer.isCorrect ? "green" : "red" }}>
                          {answer.isCorrect ? "Correct" : "Incorrect"}
                        </span>
                      )}
                    </li>
                  ))}
                </ul>
              </div>
            ))}
            <Button
              type="primary"
              onClick={handleSubmit}
              style={{ marginTop: "20px" }}
            >
              Submit
            </Button>
          </div>
        ) : (
          <div style={{ color: "#fff" }}>Please select a lecture or exercise to view details.</div>
        )}
      </Content>
      <Sider width={400} style={{ backgroundColor: "#fff" }}>
        <Collapse
          defaultActiveKey={
            course?.sections?.length > 0
              ? [course.sections[0].sectionId.toString()]
              : []
          }
          style={{ borderRadius: 0, width: "100%" }}
          accordion
        >
          {course?.sections?.map((section) => (
            <Panel
              header={
                <div
                  style={{
                    display: "flex",
                    justifyContent: "space-between",
                    alignItems: "center",
                    fontSize: "15px",
                    padding: "10px",
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
              style={{
                borderRadius: 0,
                padding: "10px",
                backgroundColor: "#f7f7f7",
              }}
            >
              <div style={{ display: "flex", flexDirection: "column" }}>
                {section.lectures?.map((lecture) => (
                  <div
                    key={lecture.lectureId}
                    style={{
                      display: "flex",
                      justifyContent: "space-between",
                      margin: "10px 0",
                      alignItems: "center",
                    }}
                  >
                    <p
                      style={{
                        margin: 0,
                        display: "flex",
                        alignItems: "center",
                        fontSize: "14px",
                      }}
                    >
                      <YoutubeOutlined style={{ marginRight: 6 }} />
                      {lecture.lectureTitle}
                    </p>
                    <span>{formatTime(lecture.lectureLearnTime || 0)}</span>
                    <Button onClick={() => handleLectureClick(lecture)} type="link">
                      View
                    </Button>
                  </div>
                ))}
                {section.exercises?.map((exercise) => (
                  <div
                    key={exercise.exerciseId}
                    style={{
                      display: "flex",
                      justifyContent: "space-between",
                      margin: "10px 0",
                      alignItems: "center",
                    }}
                  >
                    <p
                      style={{
                        margin: 0,
                        display: "flex",
                        alignItems: "center",
                        fontSize: "14px",
                      }}
                    >
                      <FormOutlined style={{ marginRight: 6 }} />
                      {exercise.exerciseTitle}
                    </p>
                    <span>{formatTime(exercise.exerciseLearnTime || 0)}</span>
                    <Button onClick={() => handleExerciseClick(exercise)} type="link">
                      View
                    </Button>
                  </div>
                ))}
              </div>
            </Panel>
          ))}
        </Collapse>
      </Sider>
    </Layout>
  );
};

function formatTime(totalHours) {
  const hours = Math.floor(totalHours);
  const minutes = Math.round((totalHours - hours) * 60);
  return `${hours}hr ${minutes}min`;
}

export default LearnCourse;
