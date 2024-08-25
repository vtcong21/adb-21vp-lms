import React, { useState, useEffect } from "react";
import { Layout, Collapse, message, Button, Progress } from "antd";
import ReactPlayer from "react-player";
import { useParams } from "react-router-dom";
import GuestService from "../../services/public";
import LearnerService from "../../services/learner";
import { YoutubeOutlined, FormOutlined } from "@ant-design/icons";

const { Sider, Content } = Layout;
const { Panel } = Collapse;

const LearnCourse = () => {
  const learnerId = "learner000021";
  const { courseId } = useParams();
  const [course, setCourse] = useState(null);
  const [selectedResource, setSelectedResource] = useState(null);
  const [selectedAnswers, setSelectedAnswers] = useState({});
  const [submittedAnswers, setSubmittedAnswers] = useState({});
  const [sectionProgress, setSectionProgress] = useState([]);
  const [currentSectionId, setCurrentSectionId] = useState(null);
  const [currentLessonId, setCurrentLessonId] = useState(null);
  const [completedLessons, setCompletedLessons] = useState(new Set()); // Track completed lessons and exercises

  useEffect(() => {
    const fetchCourseData = async () => {
      try {
        const courseRes = await GuestService.getCourseById(courseId);
        setCourse(courseRes || {});

        // Fetch progress data
        const progressRes = await LearnerService.getLearnerProgressInCourse(learnerId, courseId);
        setSectionProgress(progressRes || []);
        // Extract completed lessons and exercises
        const completed = new Set();
        progressRes.forEach(section => {
          section.LessonProgress.forEach(lesson => {
            if (lesson.isCompletedLesson) {
              completed.add(lesson.lessonId);
            }
          });
        });
        setCompletedLessons(completed);
      } catch (error) {
        message.error("Cannot load course data.");
      }
    };

    fetchCourseData();
  }, [courseId]);

  const markLessonAsCompleted = async (sectionId, lessonId) => {
    if (completedLessons.has(lessonId)) return; // Skip if already completed
    try {
      await LearnerService.completeLesson(learnerId, courseId, sectionId, lessonId);
      message.success("Lesson marked as completed.");
      setCompletedLessons(prev => new Set(prev).add(lessonId)); // Update completed lessons
    } catch (error) {
      message.error("Failed to mark lesson as completed.");
    }
  };

  const handleLectureClick = (lecture, sectionId) => {
    setSelectedResource({
      type: 'lecture',
      url: lecture.lectureResource,
    });
    setCurrentSectionId(sectionId);
    setCurrentLessonId(lecture.lectureId);
    if (!completedLessons.has(lecture.lectureId)) {
      markLessonAsCompleted(sectionId, lecture.lectureId);
    }
  };

  const handleExerciseClick = (exercise, sectionId) => {
    setSelectedResource({
      type: 'exercise',
      questions: exercise.questions,
    });
    setSelectedAnswers({});
    setSubmittedAnswers({});
    setCurrentSectionId(sectionId);
    setCurrentLessonId(exercise.exerciseId);
  };

  const handleAnswerSelect = (questionId, answerId) => {
    if (!submittedAnswers[questionId]) {
      setSelectedAnswers(prev => ({
        ...prev,
        [questionId]: answerId,
      }));
    }
  };

  const handleSubmit = async () => {
    setSubmittedAnswers(selectedAnswers);
    if (completedLessons.has(currentLessonId)) return; // Skip if already completed
    try {
      await LearnerService.completeLesson(learnerId, courseId, currentSectionId, currentLessonId);
      message.success("Exercise marked as completed.");
      setCompletedLessons(prev => new Set(prev).add(currentLessonId)); // Update completed lessons
    } catch (error) {
      message.error("Failed to mark exercise as completed.");
    }
  };

  const getProgressForSection = (sectionId) => {
    const section = sectionProgress.find(sec => sec.sectionId === sectionId);
    return section ? section.completionPercentSection : 0;
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
          <div style={{ color: "#fff", padding: "20px", overflowY: "auto", maxHeight: "500px" }}>
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
                    flexDirection: "column",
                    justifyContent: "center",
                    alignItems: "flex-start",
                    fontSize: "15px",
                    padding: "10px",
                  }}
                >
                  <span>{section.sectionTitle}</span>
                  <Progress 
                    percent={getProgressForSection(section.sectionId)} 
                    strokeColor="#52c41a" 
                    style={{ marginTop: "10px", width: "100%" }} 
                  />
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
                    <Button 
                      onClick={() => handleLectureClick(lecture, section.sectionId)} 
                      type="link"
                    >
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
                    <Button 
                      onClick={() => handleExerciseClick(exercise, section.sectionId)} 
                      type="link"
                    >
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
