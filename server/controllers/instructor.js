import queryString from "query-string";
const stripe = require("stripe")(process.env.STRIPE_SECRET);

export const makeInstructor = async (req, res) => {
  try {
    // code here

  } catch (err) {
    console.log("MAKE INSTRUCTOR ERR ", err);
  }
};

export const getAccountStatus = async (req, res) => {
  try {
    // code here

  } catch (err) {
    console.log(err);
  }
};

export const currentInstructor = async (req, res) => {
  try {
    // code here

  } catch (err) {
    console.log(err);
  }
};

export const instructorCourses = async (req, res) => {
  try {
    // code here

  } catch (err) {
    console.log(err);
  }
};

export const studentCount = async (req, res) => {
  try {
    // code here

  } catch (err) {
    console.log(err);
  }
};

export const instructorBalance = async (req, res) => {
  try {
    // code here

  } catch (err) {
    console.log(err);
  }
};

export const instructorPayoutSettings = async (req, res) => {
  try {
    // code here

  } catch (err) {
    console.log("stripe payout settings login link err => , err");
  }
};
