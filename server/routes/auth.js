import express from "express";

const router = express.Router();

// // middleware
// import { requireSignin } from "../middlewares";

// controllers
import {
  login,
  logout
} from "../controllers/auth";

router.post("/login", login);
router.post("/logout", logout);

export default router;

