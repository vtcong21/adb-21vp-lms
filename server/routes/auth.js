import express from "express";

const router = express.Router();

// // middleware
// import { requireSignin } from "../middlewares";

// controllers
import {
  login,
  logout
} from "../controllers/auth";

router.post("/public/login", login);
router.post("/public/logout", logout);

export default router;

