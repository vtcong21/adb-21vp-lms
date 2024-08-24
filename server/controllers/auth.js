import { hashPassword, comparePassword } from "../utils/auth.js";
import jwt from "jsonwebtoken";
// import { nanoid } from "nanoid";
import AWS from "aws-sdk";
import getPool from "../utils/database.js";


export const login = async (req, res) => {
  try {
    const { userId, password } = req.body;

    const pool = getPool("LMS");
    if (!pool) {
      return res.status(500).send("Database connection failed.");
    }

    let user = await pool.executeSP("sp_All_GetUserProfile", {id: userId});
    
    
    const isMatch = await comparePassword(password, user.password);

    if (!isMatch) {
      return res.status(400).send("Invalid password.");
    }

    if(user.role == 'INS') user = await pool.executeSP("sp_All_GetInstructorProfile", {id: userId});

    const token = jwt.sign({ userId: user.id, role: user.role }, process.env.JWT_SECRET, {
      expiresIn: "30d",
    });

    user.password = undefined;

    res.cookie("token", token, {
      httpOnly: true,
      // secure: true, // Uncomment this if you're using HTTPS
    });

   
    res.status(200).json(user);
  } catch (err) {
    console.log(err);
    return res.status(400).send(err.message);
  }
};

export const logout = async (req, res) => {
  try {
    res.clearCookie("token");
    return res.send("Signout success" );
  } catch (err) {
    console.log(err);
  }
};

export const currentUser = async (req, res) => {
  try {
     // code here



    //-----------
    return res.json({ ok: true });
  } catch (err) {
    console.log(err);
  }
};
