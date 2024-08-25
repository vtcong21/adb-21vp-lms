import Axios from "../Axios";
import { message } from "antd";

const InstructorService = {
  createCourse: async (instructorId1, instructorId2, title, subTitle, description, image, video, subCategoryId, categoryId, language, price) => {
    try {
      const res = await Axios.post("/api/instructor/course", {
        instructorId1,
        instructorId2,
        title,
        subTitle,
        description,
        image,
        video,
        subCategoryId,
        categoryId,
        language,
        price
      });

      if (res.status === 200) {
        return res.data.courseId;
      } else {
        message.error(res.data.message || "Error creating course.");
      }
    } catch (error) {
      message.error(error.response?.data?.message || "An unexpected error occurred.");
    }
  },
  createInstructorOwnCourse: async (courseId, instructorId, percentageInCome) => {
    try {
      const res = await Axios.post("/api/instructor/owncourse", {
        courseId,
        instructorId,
        percentageInCome
      });

      if (res.status === 200) {
        return res.data;
      } else {
        message.error(res.data.message || "Error creating instructor-own-course record.");
      }
    } catch (error) {
      message.error(error.response?.data?.message || "An unexpected error occurred.");
    }
  },
  createCourseRequirement: async (courseId, requirement) => {
    try {
      const res = await Axios.post("/api/course/requirement", {
        courseId,
        requirement
      });

      if (res.status === 200) {
        return res.data;
      } else {
        message.error(res.data.message || "Error adding course requirement.");
      }
    } catch (error) {
      message.error(error.response?.data?.message || "An unexpected error occurred.");
    }
  },
  createCourseObjective: async (courseId, objective) => {
    try {
      const res = await Axios.post("/api/course/objective", {
        courseId,
        objective
      });

      if (res.status === 200) {
        return res.data;
      } else {
        message.error(res.data.message || "Error adding course objective.");
      }
    } catch (error) {
      message.error(error.response?.data?.message || "An unexpected error occurred.");
    }
  },
  createSection: async (courseId, title) => {
    try {
      const res = await Axios.post("/api/section", {
        courseId,
        title
      });

      if (res.status === 200) {
        return res.data.sectionId;
      } else {
        message.error(res.data.message || "Error adding section.");
      }
    } catch (error) {
      message.error(error.response?.data?.message || "An unexpected error occurred.");
    }
  },
  createLesson: async (courseId, sectionId, title, learnTime, type) => {
    try {
      const res = await Axios.post("/api/lesson", {
        courseId,
        sectionId,
        title,
        learnTime,
        type
      });

      if (res.status === 200) {
        return res.data.lessonId;
      } else {
        message.error(res.data.message || "Error adding lesson.");
      }
    } catch (error) {
      message.error(error.response?.data?.message || "An unexpected error occurred.");
    }
  },
  createLecture: async (courseId, sectionId, lessonId, resource) => {
    try {
      const res = await Axios.post("/api/lecture", {
        courseId,
        sectionId,
        lessonId,
        resource
      });

      if (res.status === 200) {
        return res.data;
      } else {
        message.error(res.data.message || "Error adding lecture.");
      }
    } catch (error) {
      message.error(error.response?.data?.message || "An unexpected error occurred.");
    }
  },
  createQuestion: async (courseId, sectionId, exerciseId, question) => {
    try {
      const res = await Axios.post("/api/question", {
        courseId,
        sectionId,
        exerciseId,
        question
      });

      if (res.status === 200) {
        return res.data.questionId;
      } else {
        message.error(res.data.message || "Error adding question.");
      }
    } catch (error) {
      message.error(error.response?.data?.message || "An unexpected error occurred.");
    }
  },
  createQuestionAnswer: async (courseId, sectionId, exerciseId, questionId, questionAnswers, isCorrect) => {
    try {
      const res = await Axios.post("/api/question/answer", {
        courseId,
        sectionId,
        exerciseId,
        questionId,
        questionAnswers,
        isCorrect
      });

      if (res.status === 200) {
        return res.data;
      } else {
        message.error(res.data.message || "Error adding question answer.");
      }
    } catch (error) {
      message.error(error.response?.data?.message || "An unexpected error occurred.");
    }
  },
  getMonthlyRevenueForInstructor: async ( userId, duration ) => {
    const res = await Axios.get(`/api/instructor/revenue/monthly`, { userId, duration });
    if (res.status == 400) {
      message.error(res.message || res.error);
    }
    return res;

  },
  getAnnualRevenueForInstructor: async ( userId, duration ) => {
    const res = await Axios.get(`/api/instructor/revenue/annual`, { userId, duration });
    if (res.status == 400) {
      message.error(res.message || res.error);
    }
    return res;

  },
  getMonthlyRevenueForCourse: async ( courseId, duration ) => {
    const res = await Axios.get(`/api/course/revenue/monthly`, { courseId, duration });
    if (res.status == 400) {
      message.error(res.message || res.error);
    }
    return res;

  },
  getAnnualRevenueForCourse: async ( courseId, duration ) => {
    const res = await Axios.get(`/api/course/revenue/annual`, { courseId, duration });
    if (res.status == 400) {
      message.error(res.message || res.error);
    }
    return res;
  },
  getTop50CoursesByRevenue: async () => {
    const res = await Axios.get(`/api/course/top-50`, {});
    if (res.status == 400) {
      message.error(res.message || res.error);
    }
    return res;

  },
  getOwnCourses: async ( userId ) => {
    const res = await Axios.get(`/api/course/instructor-course`, { userId });
    if (res.status == 400) {
      message.error(res.message || res.error);
    }
    return res;
  },
  getLearnerInCourse: async ( courseId ) => {
    const res = await Axios.get(`/api/course/learners`, { courseId });
    if (res.status == 400) {
      message.error(res.message || res.error);
    }
    return res;
  },
};

export default InstructorService;