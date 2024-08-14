//import queryString from "query-string";
import getPool from "../utils/database";
//const stripe = require("stripe")(process.env.STRIPE_SECRET);

export const addCourseToCart = async (req, res) => {
  try {
    // code here
    const { learnerId, courseId } = req.body;
    //console.log(req.body);

    const pool = getPool('LMS');

    if (!pool) {
      return res.status(500).json({ message: "Database pool is not available" });
    }

    if (!learnerId || !courseId) {
      return res.status(400).json({ message: "learnerId and courseId are required" });
    }
    await pool.executeSP('sp_LN_AddCourseToCart', { learnerId, courseId });

    return res.status(200).json({ message: "Course added to cart successfully" });

  } catch (err) {
    console.log("ERR ", err);
    return res.status(400).json({ error: err.message });
  }
};

export const removeCourseFromCart = async (req, res) => {
  try {
    // code here
    const { learnerId, courseId } = req.body;
    //console.log(req.body);

    const pool = getPool('LMS');

    if (!pool) {
      return res.status(500).json({ message: "Database pool is not available" });
    }

    if (!learnerId || !courseId) {
      return res.status(400).json({ message: "learnerId and courseId are required" });
    }
    await pool.executeSP('sp_LN_RemoveCourseFromCart', { learnerId, courseId });

    return res.status(200).json({ message: "Course remove from cart successfully" });

  } catch (err) {
    console.log("ERR ", err);
    return res.status(400).json({ error: err.message });
  }
};

export const getCartDetails = async (req, res) => {
  try {
    const { learnerId } = req.body;
    const pool = getPool('LMS');

    if (!pool) {
      return res.status(500).json({ message: "Database pool is not available" });
    }

    if (!learnerId) {
      return res.status(400).json({ message: "learnerId are required" });
    }
    const jsonResult = await pool.executeSP('sp_LN_GetCartDetails', { learnerId });

    return res.status(200).json(jsonResult);

  } catch (err) {
    console.log("ERR ", err);
    return res.status(400).json({ error: err.message });
  }
};

export const makeOrder = async (req, res) => {
  try {
    const { learnerId, paymentCardNumber, couponCode } = req.body;
    const pool = getPool('LMS');

    if (!pool) {
      return res.status(500).json({ message: "Database pool is not available" });
    }

    if (!learnerId || !paymentCardNumber) {
      return res.status(400).json({ message: "learnerId and payment card are required" });
    }
    await pool.executeSP('sp_LN_MakeOrder', { learnerId, paymentCardNumber, couponCode });

    return res.status(200).json({ message: "Paid successfully" });

  } catch (err) {
    console.log("ERR ", err);
    return res.status(400).json({ error: err.message });
  }
};

export const viewOrders = async (req, res) => {
  try {
    const { learnerId } = req.body;
    const pool = getPool('LMS');

    if (!pool) {
      return res.status(500).json({ message: "Database pool is not available" });
    }

    if (!learnerId) {
      return res.status(400).json({ message: "learnerId are required" });
    }
    const jsonResult = await pool.executeSP('sp_LN_ViewOrders', { learnerId });

    return res.status(200).json(jsonResult);

  } catch (err) {
    console.log("ERR ", err);
    return res.status(400).json({ error: err.message });
  }
};

export const viewOrderDetails = async (req, res) => {
  try {
    const { learnerId } = req.body;
    const { orderId } = req.params;
    const pool = getPool('LMS');

    if (!pool) {
      return res.status(500).json({ message: "Database pool is not available" });
    }

    if (!learnerId || !orderId) {
      return res.status(400).json({ message: "learnerId and orderId are required" });
    }
    const jsonResult = await pool.executeSP('sp_LN_ViewOrderDetails', { learnerId, orderId });

    return res.status(200).json(jsonResult);

  } catch (err) {
    console.log("ERR ", err);
    return res.status(400).json({ error: err.message });
  }
};

export const instructorPayoutSettings = async (req, res) => {
  try {
    // code here

  } catch (err) {
    console.log("stripe payout settings login link err => , err");
  }
};
