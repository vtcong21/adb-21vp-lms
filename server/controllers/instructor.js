import { hashPassword } from "../utils/auth.js";
import getPool from "../utils/database.js";

export const getInstructorProfile = async (req, res) => {
  try {
    const {userId} = req.query;
    const pool = getPool('LMS');

    if (!pool) {
      return res.status(500).json({ message: "Database pool is not available" });
    }

    if (!userId) {
      return res.status(400).json({ message: "instructorId is required" });
    }
    const jsonResult = await pool.executeSP('sp_All_GetInstructorProfile', { id: userId });

    return res.status(200).json(jsonResult);

  } catch (err) {
    console.log("ERR ", err);
    return res.status(400).json({ error: err.message });
  }
};


export const updateInstructorInfo = async (req, res) => {
  try {
    const { userId, password, gender, phone, DOB, address, degress, workplace, scientificBackground } = req.body;

    const pool = getPool('LMS');

    if (!pool) {
      return res.status(500).json({ message: "Database pool is not available" });
    }

    if (!userId || !password) {
      return res.status(400).json({ message: "userId and password required" });
    }

    password = hashPassword(password);
    await pool.executeSP('sp_All_UpdateInstructorIndo', { instructorId:userId, password, gender, phone, DOB, address, degress, workplace, scientificBackground });

    return res.status(200).json({ message: "updated informations successfully" });

  } catch (err) {
    console.log("ERR ", err);
    return res.status(400).json({ error: err.message });
  }
};

export const getMonthlyRevenueForInstructor = async (req, res) => {
  try {
    const { userId, duration } = req.query;

    const pool = getPool('LMS');

    if (!pool) {
      return res.status(500).json({ message: "Database pool is not available" });
    }

    if (!userId || !duration) {
      return res.status(400).json({ message: "duration and userId art required" });
    }
    const jsonResult = await pool.executeSP('sp_AD_INS_GetMonthlyRevenueOfAnInstructor', { instructorId: userId, duration });

    return res.status(200).json(jsonResult);

  } catch (err) {
    console.log("ERR ", err);
    return res.status(400).json({ error: err.message });
  }
}


export const getAunnualRevenueForInstructor = async (req, res) => {
  try {
    const { userId, duration } = req.query;

    const pool = getPool('LMS');

    if (!pool) {
      return res.status(500).json({ message: "Database pool is not available" });
    }

    if (!userId || !duration) {
      return res.status(400).json({ message: "duration and userId art required" });
    }
    const jsonResult = await pool.executeSP('sp_AD_INS_GetAnnualRevenueOfAnInstructor', { instructorId: userId, duration });

    return res.status(200).json(jsonResult);

  } catch (err) {
    console.log("ERR ", err);
    return res.status(400).json({ error: err.message });
  }
}


export const sendTaxForm = async (req, res) => {
  try {
    const { submissionDate,
      fullName,
      address,
      phone,
      taxCode,
      identityNumber,
      postCode,
      vipInstructorId } = req.body;

    const pool = getPool('LMS');

    if (!pool) {
      return res.status(500).json({ message: "Database pool is not available" });
    }

    if (!submissionDate ||
      !fullName ||
      !address ||
      !phone ||
      !taxCode ||
      !identityNumber ||
      !postCode ||
      !vipInstructorId) {
      return res.status(400).json({ message: "missing fields" });
    }
    await pool.executeSP('sp_INS_SendTaxForm', {
      submissionDate,
      fullName,
      address,
      phone,
      taxCode,
      identityNumber,
      postCode,
      vipInstructorId
    });

    return res.status(200).json({ message: "Sent tax form successfully" });

  } catch (err) {
    console.log("ERR ", err);
    return res.status(400).json({ error: err.message });
  }
}

export const updateInstructorPaymentCard = async (req, res) => {
  try {
    const { userId,
      number,
      type,
      name,
      CVC,
      expireDate } = req.body;

    const pool = getPool('LMS');

    if (!pool) {
      return res.status(500).json({ message: "Database pool is not available" });
    }

    if (!userId||
      !number||
      !type||
      !name||
      !CVC||
      !expireDate ) {
      return res.status(400).json({ message: "missing fields" });
    }
    await pool.executeSP('sp_INS_UpdateInstructorPaymentCard', { instructorId: userId,
      number,
      type,
      name,
      CVC,
      expireDate } );

    return res.status(200).json({ message: "Update instructor's payment card successfully" });

  } catch (err) {
    console.log("ERR ", err);
    return res.status(400).json({ error: err.message });
  }
}
