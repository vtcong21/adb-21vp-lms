import getPool from "../utils/database";

export const getInstructorProfile = async (req, res) => {
  try {

      const { instructorId } = req.body;

      const pool = getPool('LMS');

      if (!pool) {
          return res.status(500).json({ message: "Database pool is not available" });
      }

      if (!instructorId) {
          return res.status(400).json({ message: "instructorId is required" });
      }
      const jsonResult = await pool.executeSP('sp_All_GetInstructorProfile', { id: instructorId });

      return res.status(200).json(jsonResult);

  } catch (err) {
      console.log("ERR ", err);
      return res.status(400).json({ error: err.message });
  }
};


export const updateInstructorInfo = async (req, res) => {
  try {
    const { instructorId, password, gender, phone, DOB, address, degress, workplace, scientificBackground } = req.body;

    const pool = getPool('LMS');

    if (!pool) {
      return res.status(500).json({ message: "Database pool is not available" });
    }

    if (!instructorId || !password) {
      return res.status(400).json({ message: "instructorId and password required" });
    }
    await pool.executeSP('sp_All_UpdateInstructorIndo', { instructorId, password, gender, phone, DOB, address, degress, workplace, scientificBackground  });

    return res.status(200).json({ message: "updated informations successfully" });

  } catch (err) {
    console.log("ERR ", err);
    return res.status(400).json({ error: err.message });
  }
};