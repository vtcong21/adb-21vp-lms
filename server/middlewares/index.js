import expressJwt from "express-jwt";
import User from "../models/user";
import Course from "../models/course";

export const requireSignin = async (req, res, next) => {
  try {
    const token = req.cookies['auth_token']; 

    if (!token) {
      return res.status(401).json({ error: "Authentication token is missing." });
    }

    jwt.verify(token, process.env.JWT_SECRET, async (err, decoded) => {
      if (err) {
        return res.status(401).json({ error: "Invalid or expired token." });
      }

      req.body.userId = decoded.userId;
      req.body.role = decoded.role; 

      try {
        const pool = await sql.connect(process.env.DB_CONNECTION_STRING);
        const result = await pool
          .request()
          .input('userId', sql.Int, decoded._id)
          .query('SELECT id FROM [user] WHERE id = @userId');

        if (result.recordset.length === 0) {
          return res.status(401).json({ error: "User not found." });
        }

        next();
      } catch (dbErr) {
        console.error(dbErr);
        res.status(500).json({ error: "Database error." });
      }
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error." });
  }
};


export const isAdmin = async(req, res, next)=>{
  
}

export const isInstructor = async (req, res, next) => {
  try {
   
  } catch (err) {
    console.log(err);
  }
};

export const isEnrolled = async (req, res, next) => {
  try {
   
  } catch (err) {
    console.log(err);
  }
};
