import getPool from "../utils/database.js";

export const addCourseToCart = async (req, res) => {
  try {

    const { userId, courseId } = req.body;
    //console.log(req.body);

    const pool = getPool('LMS');

    if (!pool) {
      return res.status(500).json({ error: "Database pool is not available" });
    }

    if (!userId || !courseId) {
      return res.status(400).json({ error: "userId and courseId are required" });
    }
    await pool.executeSP('sp_LN_AddCourseToCart', { learnerId: userId, courseId });

    return res.status(200).json({ message: "Course added to cart successfully" });

  } catch (err) {
    console.log("ERR ", err);
    return res.status(400).json({ error: err.message });
  }
};

export const removeCourseFromCart = async (req, res) => {
  try {

    const { userId, courseId } = req.body;
    //console.log(req.body);

    const pool = getPool('LMS');

    if (!pool) {
      return res.status(500).json({ message: "Database pool is not available" });
    }

    if (!userId || !courseId) {
      return res.status(400).json({ message: "userId and courseId are required" });
    }
    await pool.executeSP('sp_LN_RemoveCourseFromCart', { learnerId: userId, courseId });

    return res.status(200).json({ message: "Course remove from cart successfully" });

  } catch (err) {
    console.log("ERR ", err);
    return res.status(400).json({ error: err.message });
  }
};

export const getCartDetails = async (req, res) => {
  try {
    const { userId } = req.query;
   
    const pool = getPool('LMS');

    if (!pool) {
      return res.status(500).json({ message: "Database pool is not available" });
    }

    if (!userId) {
      return res.status(400).json({ message: "userId is required" });
    }
    const jsonResult = await pool.executeSP('sp_LN_GetCartDetails', { learnerId: userId });

    return res.status(200).json(jsonResult);

  } catch (err) {
    console.log("ERR ", err);
    return res.status(400).json({ error: err.message });
  }
};

export const makeOrder = async (req, res) => {
  try {
    const { userId, paymentCardNumber, couponCode } = req.query;
    const pool = getPool('LMS');

    if (!pool) {
      return res.status(500).json({ message: "Database pool is not available" });
    }

    if (!userId || !paymentCardNumber) {
      return res.status(400).json({ message: "userId and payment card are required" });
    }
    await pool.executeSP('sp_LN_MakeOrder', { learnerId: userId, paymentCardNumber, couponCode });

    return res.status(200).json({ message: "Paid successfully" });

  } catch (err) {
    console.log("ERR ", err);
    return res.status(400).json({ error: err.message });
  }
};

export const viewOrders = async (req, res) => {
  try {
    const { userId } = req.query;
    const pool = getPool('LMS');

    if (!pool) {
      return res.status(500).json({ message: "Database pool is not available" });
    }

    if (!userId) {
      return res.status(400).json({ message: "userId is required" });
    }
    const jsonResult = await pool.executeSP('sp_LN_ViewOrders', { learnerId: userId });

    return res.status(200).json(jsonResult);

  } catch (err) {
    console.log("ERR ", err);
    return res.status(400).json({ error: err.message });
  }
};

export const viewOrderDetails = async (req, res) => {
  try {
    const { userId, orderId } = req.query;
    const pool = getPool('LMS');

    if (!pool) {
      return res.status(500).json({ message: "Database pool is not available" });
    }

    if (!userId || !orderId) {
      return res.status(400).json({ message: "userId and orderId are required" });
    }
    const jsonResult = await pool.executeSP('sp_LN_ViewOrderDetails', { learnerId: userId, orderId });

    return res.status(200).json(jsonResult);

  } catch (err) {
    console.log("ERR ", err);
    return res.status(400).json({ error: err.message });
  }
};

export const completeLesson = async (req, res) => {
  try {
    const { userId, courseId, sectionId, lessonId } = req.body;

    const pool = getPool('LMS');

    if (!pool) {
      return res.status(500).json({ message: "Database pool is not available" });
    }

    if (!userId || !courseId || !sectionId || !lessonId) {
      return res.status(400).json({ message: "userId, courseId, sectionId, lessonId are required" });
    }
    await pool.executeSP('sp_LN_CompleteLesson', { learnerId: userId, courseId, sectionId, lessonId });

    return res.status(200).json({ message: "Paid successfully" });

  } catch (err) {
    console.log("ERR ", err);
    return res.status(400).json({ error: err.message });
  }
};


export const getPaymentCards = async (req, res) => {
  try {
    const { userId } = req.query;

    const pool = getPool('LMS');

    if (!pool) {
      return res.status(500).json({ message: "Database pool is not available" });
    }

    if (!userId) {
      return res.status(400).json({ message: "userId is required" });
    }
    const jsonResult =await pool.executeSP('sp_LN_GetLearnerPaymentCards', { learnerId: userId });

    return res.status(200).json(jsonResult);

  } catch (err) {
    console.log("ERR ", err);
    return res.status(400).json({ error: err.message });
  }
};

