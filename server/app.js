import express from "express";
import cors from "cors";
import { readdirSync } from "fs";
import csrf from "csurf";
import cookieParser from "cookie-parser";
import { createRouteHandler } from "uploadthing/express";
import { ourFileRouter } from "./uploadthing/core.js";
import morgan from 'morgan';
import dotenv from 'dotenv';

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
// route
app.use('/api', authRouter);
app.use('/api', learnerRouter);
app.use('/api', courseRouter);
app.use('/api', couponRouter);
app.use('/api', instructorRouter);
app.use('/api', userRouter);
import "dotenv/config";
app.use(
  "/api/uploadthing",
  createRouteHandler({
    router: ourFileRouter,
    config: {
      uploadthingId: process.env.UPLOADTHING_APP_ID,
      uploadthingSecret: process.env.UPLOADTHING_SECRET,
      logLevel: "trace"
    }
    //secret: process.env.UPLOADTHING_SECRET,
  }),
);


// // csrf
// app.use(csrfProtection);

// app.get("/api/csrf-token", (req, res) => {
//   res.json({ csrfToken: req.csrfToken() });
// });

// port
const port = process.env.PORT || 8000;



app.listen(port, () => console.log(`Server is running on port ${port}`));


