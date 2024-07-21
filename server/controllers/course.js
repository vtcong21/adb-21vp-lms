import AWS from "aws-sdk";
import { nanoid } from "nanoid";
import Course from "../models/course";
import Completed from "../models/completed";
import slugify from "slugify";
import { readFileSync } from "fs";
import User from "../models/user";
const stripe = require("stripe")(process.env.STRIPE_SECRET);

const awsConfig = {
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  region: process.env.AWS_REGION,
  apiVersion: process.env.AWS_API_VERSION,
};

const S3 = new AWS.S3(awsConfig);

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

export const create = async (req, res) => {
  try {
    // code here

  } catch (err) {
    console.log(err);
    return res.status(400).send("Course create failed. Try again.");
  }
};

export const read = async (req, res) => {
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

export const publishCourse = async (req, res) => {
  try {
    // code here
    
  } catch (err) {
    console.log(err);
    return res.status(400).send("Publish course failed");
  }
};

export const unpublishCourse = async (req, res) => {
  try {
   // code here
    
  } catch (err) {
    console.log(err);
    return res.status(400).send("Unpublish course failed");
  }
};

export const courses = async (req, res) => {
  try {
    // code here
    
  } catch (err) {
    console.log(err);
    return res.status(400).send("Get courses failed");
  }
};

export const checkEnrollment = async (req, res) => {
  try {
    // code here
    
  } catch (err) {
    console.log(err);
    return res.status(400).send("check enrollment failed");
  }
};

export const freeEnrollment = async (req, res) => {
  try {
    // code here

  } catch (err) {
    console.log("free enrollment err", err);
    return res.status(400).send("Enrollment create failed");
  }
};

export const paidEnrollment = async (req, res) => {
  try {
    // code here
    
  } catch (err) {
    console.log("PAID ENROLLMENT ERR", err);
    return res.status(400).send("Enrollment create failed");
  }
};


export const userCourses = async (req, res) => {
  // code here
    
};

export const markCompleted = async (req, res) => {
  // code here
    
};

export const listCompleted = async (req, res) => {
  // code here
    
};

export const markIncomplete = async (req, res) => {
 // code here
    
};
