import express from "express";
import cors from "cors";
import csrf from "csurf";
import cookieParser from "cookie-parser";
import morgan from 'morgan';
import dotenv from 'dotenv';
import multer from "multer";

dotenv.config();

// const csrfProtection = csrf({ cookie: true });

// create express app
const app = express();
// db

// apply middlewares
app.use(cors({
  origin: "*",
  methods: ["GET", "POST", "PUT", "DELETE"],
  allowedHeaders: "*"
}));
app.use(express.json({ limit: "200mb" }));
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());
app.use(morgan("dev"));

import authRouter from "./routes/auth.js";
import learnerRouter from "./routes/learner.js";
import courseRouter from "./routes/course.js";
import couponRouter from "./routes/coupon.js";
import instructorRouter from "./routes/instructor.js";
import userRouter from "./routes/user.js";
import uploadRouter from "./routes/upload.js";
// route
app.use('/api', authRouter);
app.use('/api', learnerRouter);
app.use('/api', courseRouter);
app.use('/api', couponRouter);
app.use('/api', instructorRouter);
app.use('/api', userRouter);
app.use('/api', uploadRouter);
app.use((err, req, res, next) => {
  if (err instanceof multer.MulterError) {
      
      switch (err.code) {
          case 'LIMIT_FILE_SIZE':
              return res.status(400).json({ error: 'File is too large. Please upload a smaller file.' });
          case 'LIMIT_UNEXPECTED_FILE':
              return res.status(400).json({ error: 'Unexpected file type. Please upload the correct file type.' });
          default:
              return res.status(400).json({ error: `Multer error: ${err.message}` });
      }
  } else if (err) {
      
      return res.status(400).json({ error: err.message });
  }
  next();
});

// // csrf
// app.use(csrfProtection);

// app.get("/api/csrf-token", (req, res) => {
//   res.json({ csrfToken: req.csrfToken() });
// });

// port
const port = process.env.PORT || 8000;



app.listen(port, () => console.log(`Server is running on port ${port}`));


