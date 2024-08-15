import express from "express";

const router = express.Router();

// // middleware
// import { requireSignin } from "../middlewares";

// controllers
import {
  login,
} from "../controllers/auth";

router.post("/login", login);

export default router;

