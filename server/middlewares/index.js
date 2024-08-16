import expressJwt from "express-jwt";

export const requireSignin = [
  expressJwt({
    getToken: (req, res) => req.cookies.token,
    secret: process.env.JWT_SECRET,
    algorithms: ["HS256"],
  }),
  (req, res, next) => {
    if (req.user) {
      req.body.userId = req.user.userId; 
    }
    next();
  }
];

export const isInstructor = async (req, res, next) => {
  try {
    const user = await pool.executeSP('sp_All_GetUserProfile', { id: req.user.userId });
    if (user.role != 'INS') {
      return res.sendStatus(403);
    } else {
      next();
    }
  } catch (err) {
    console.log(err);
  }
};

export const isAdmin = async (req, res, next) => {
  try {
    const user = await pool.executeSP('sp_All_GetUserProfile', { id: req.user.userId });
    if (user.role != 'AD') {
      return res.sendStatus(403);
    } else {
      next();
    }
  } catch (err) {
    console.log(err);
  }
};

export const isLearner = async (req, res, next) => {
  try {
    const user = await pool.executeSP('sp_All_GetUserProfile', { id: req.user.userId });
    if (user.role != 'LN') {
      return res.sendStatus(403);
    } else {
      next();
    }
  } catch (err) {
    console.log(err);
  }
};

export const isAdminOrInstructor = async (req, res, next) => {
  try {
    const user = await pool.executeSP('sp_All_GetUserProfile', { id: req.user.userId });
    if (user.role != 'AD' && user.role != 'INS') {
      return res.sendStatus(403);
    } else {
      next();
    }
  } catch (err) {
    console.log(err);
  }
}

export const isLearnerOrInstructor = async (req, res, next) => {
  try {
    const user = await pool.executeSP('sp_All_GetUserProfile', { id: req.user.userId });
    if (user.role != 'LN' && user.role != 'INS') {
      return res.sendStatus(403);
    } else {
      next();
    }
  } catch (err) {
    console.log(err);
  }
}

export const isEnrolled = async (req, res, next) => {
  try {
    // nên viết ko ta

  } catch (err) {
    console.log(err);
  }
};
