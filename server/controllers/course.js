// dont touch this

import { json } from "express";
import getPool from "../utils/database.js";

// import AWS from "aws-sdk";
// import { nanoid } from "nanoid";
// import slugify from "slugify";
// import { readFileSync } from "fs";
// const stripe = require("stripe")(process.env.STRIPE_SECRET);

// const awsConfig = {
//   accessKeyId: process.env.AWS_ACCESS_KEY_ID,
//   secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
//   region: process.env.AWS_REGION,
//   apiVersion: process.env.AWS_API_VERSION,
// };
// const S3 = new AWS.S3(awsConfig);
//---------------------------------


export const getCourseByName = async (req, res) => {
  try {
    const { courseName, courseState } = req.query;
    const pool = getPool('LMS');

    if (!pool) {
      return res.status(500).json({ message: "Database pool is not available" });
    }

    const jsonResult = await pool.executeSP('sp_All_GetCourseByName', { courseName, courseState});

    return res.status(200).json(jsonResult);

  } catch (err) {
    console.log("ERR ", err);
    return res.status(400).json({ error: err.message });
  }
};

export const getCourseById = async (req, res) => {
  try {
    const { courseId } = req.query;
    const pool = getPool('LMS');

    if (!pool) {
      return res.status(500).json({ message: "Database pool is not available" });
    }

    if (!courseId) {
      return res.status(400).json({ message: "courseId is required" });
    }
    const jsonResult = await pool.executeSP('sp_All_GetCourseById', { courseId });

    return res.status(200).json(jsonResult);

  } catch (err) {
    console.log("ERR ", err);
    return res.status(400).json({ error: err.message });
  }
};

export const getCourseByCategoryId = async (req, res) => {
  try {
    const { categoryId, subCategoryId } = req.query;
    const pool = getPool('LMS');

    if (!pool) {
      return res.status(500).json({ message: "Database pool is not available" });
    }

    if (!categoryId || !subCategoryId) {
      return res.status(400).json({ message: "categoryId and subCategoryId are required" });
    }
    const jsonResult = await pool.executeSP('sp_All_GetCourseByCategoryId', { categoryId, subCategoryId });

    return res.status(200).json(jsonResult);

  } catch (err) {
    console.log("ERR ", err);
    return res.status(400).json({ error: err.message });
  }
};


export const changeStateOfCourse = async (req, res) => {
  try {
    const { userId, courseId, vipState, responseText } = req.body;
    const pool = getPool('LMS');

    if (!pool) {
      return res.status(500).json({ message: "Database pool is not available" });
    }

    if (!vipState || !courseId) {
      return res.status(400).json({ message: "vipState and courseId are required" });
    }
    const jsonResult = await pool.executeSP('sp_AD_INS_ChangeStateOfCourse', { adminId: userId, courseId, vipState, responseText });

    return res.status(200).json(jsonResult);

  } catch (err) {
    console.log("ERR ", err);
    return res.status(400).json({ error: err.message });
  }
};


export const getDailyRevenueForCourse = async (req, res) => {
  try {
    const { courseId, duration } = req.query;

    const pool = getPool('LMS');

    if (!pool) {
      return res.status(500).json({ message: "Database pool is not available" });
    }

    if (!courseId || !duration) {
      return res.status(400).json({ message: "duration and courseId are required" });
    }
    const jsonResult = await pool.executeSP('sp_AD_INS_GetDailyRevenueOfACourse', { courseId, duration });

    return res.status(200).json(jsonResult);

  } catch (err) {
    console.log("ERR ", err);
    return res.status(400).json({ error: err.message });
  }
}


export const getMonthlyRevenueForCourse = async (req, res) => {
  try {
    const { courseId, duration } = req.query;
    
    const pool = getPool('LMS');

    if (!pool) {
      return res.status(500).json({ message: "Database pool is not available" });
    }

    if (!courseId || !duration) {
      return res.status(400).json({ message: "duration and courseId are required" });
    }
    const jsonResult = await pool.executeSP('sp_AD_INS_GetMonthlyRevenueOfACourse', { courseId, duration });

    return res.status(200).json(jsonResult);

  } catch (err) {
    console.log("ERR ", err);
    return res.status(400).json({ error: err.message });
  }
}


export const getAnnualRevenueOfACourse = async (req, res) => {
  try {
    const { courseId, duration } = req.query;

    const pool = getPool('LMS');

    if (!pool) {
      return res.status(500).json({ message: "Database pool is not available" });
    }

    if (!courseId || !duration) {
      return res.status(400).json({ message: "duration and courseId are required" });
    }
    const jsonResult = await pool.executeSP('sp_AD_INS_GetYearlyRevenueOfACourse', { courseId, duration });

    return res.status(200).json(jsonResult);

  } catch (err) {
    console.log("ERR ", err);
    return res.status(400).json({ error: err.message });
  }
}

export const getTop50CoursesByRevenue = async (req, res) => {
  try {

    const pool = getPool('LMS');

    if (!pool) {
      return res.status(500).json({ message: "Database pool is not available" });
    }

    const jsonResult = await pool.executeSP('sp_AD_GetTop50CoursesByRevenue');

    return res.status(200).json(jsonResult);

  } catch (err) {
    console.log("ERR ", err);
    return res.status(400).json({ error: err.message });
  }
}

export const getOwnCourses = async (req, res) => {
  try {
    const { userId } = req.query;

    const pool = getPool('LMS');

    if (!pool) {
      return res.status(500).json({ message: "Database pool is not available" });
    }

    if (!userId) {
      return res.status(400).json({ message: "userId is required" });
    }
    const jsonResult = await pool.executeSP('sp_INS_GetOwnCourses', { userId: userId });

    return res.status(200).json(jsonResult);

  } catch (err) {
    console.log("ERR ", err);
    return res.status(400).json({ error: err.message });
  }
}

export const createCourse = async (req, res) => {
  try {
    const { instructorId1,
      instructorId2,
      title,
      subTitle,
      description,
      image,
      video,
      subCategoryId,
      language,
      price
    } = req.body;

    const pool = getPool('LMS');

    if (!pool) {
      return res.status(500).json({ message: "Database pool is not available" });
    }

    if (!instructorId1 || !title || !subTitle || !description
      || !image || !video || !subCategoryId || !language
    ) {
      return res.status(400).json({ message: "All field except instructorId2 and price are required" });
    }
    await pool.executeSP('sp_INS_CreateCourse', {
      instructorId1,
      instructorId2,
      title,
      subTitle,
      description,
      image,
      video,
      subCategoryId,
      language,
      price
    });

    return res.status(200).json({ message: "Create course successfully" });

  } catch (err) {
    console.log("ERR ", err);
    return res.status(400).json({ error: err.message });
  }
}


export const getAdminResponseInACourse = async (req, res) => {
  try {
    const { courseId } = req.query;

    const pool = getPool('LMS');

    if (!pool) {
      return res.status(500).json({ message: "Database pool is not available" });
    }

    if (courseId) {
      return res.status(400).json({ message: "courseId is required" });
    }
    const jsonResult = await pool.executeSP('sp_INS_GetAdminResponseInACourse', { courseId });

    return res.status(200).json(jsonResult);

  } catch (err) {
    console.log("ERR ", err);
    return res.status(400).json({ error: err.message });
  }
}


export const getLearnerInCourse = async (req, res) => {
  try {
    const { courseId } = req.query;
    console.log('server: ' + courseId);

    const pool = getPool('LMS');

    if (!pool) {
      return res.status(500).json({ message: "Database pool is not available" });
    }

    if (!courseId) {
      return res.status(400).json({ message: "courseId is required" });
    }
    const jsonResult = await pool.executeSP('sp_INS_GetLearnersInCourse', { courseId });

    return res.status(200).json(jsonResult);

  } catch (err) {
    console.log("ERR ", err);
    return res.status(400).json({ error: err.message });
  }
}



export const uploadImage = async (req, res) => {

  try {
    // code here

  } catch (err) {
    console.log(err);
  }
};

export const removeImage = async (req, res) => {
  try {
    // code here

  } catch (err) {
    console.log(err);
  }
};

export const uploadVideo = async (req, res) => {
  try {
    // code here

  } catch (err) {
    console.log(err);
  }
};

export const removeVideo = async (req, res) => {
  try {
    // code here

  } catch (err) {
    console.log(err);
  }
};

export const addLesson = async (req, res) => {
  try {
    // code here

  } catch (err) {
    console.log(err);
    return res.status(400).send("Add lesson failed");
  }
};

export const update = async (req, res) => {
  try {
    // code here

  } catch (err) {
    console.log(err);
    return res.status(400).send(err.message);
  }
};

export const removeLesson = async (req, res) => {
  try {
    // code here

  } catch (err) {
    console.log(err);
    return res.status(400).send("Remove lesson failed");
  }
};

export const updateLesson = async (req, res) => {
  try {
    // code here

  } catch (err) {
    console.log(err);
    return res.status(400).send("Update lesson failed");
  }
};

export const getTopHotCategories = async (req, res) => {
  try {
    const pool = getPool('LMS');

    if (!pool) {
      return res.status(500).json({ message: "Database pool is not available" });
    }

    const jsonResult = await pool.executeSP('sp_INS_GetTopHotCategories', { });

    return res.status(200).json(jsonResult);

  } catch (err) {
    console.log("ERR ", err);
    return res.status(400).json({ error: err.message });
  }
};
