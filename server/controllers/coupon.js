import getPool from "../utils/database";

export const createCoupon = async (req, res) => {
  try {

      const { code, quantity, startDate, adminId, discountPercent } = req.body;

      const pool = getPool('LMS');

      if (!pool) {
          return res.status(500).json({ message: "Database pool is not available" });
      }

      if (!instructorId) {
          return res.status(400).json({ message: "adminId is required" });
      }
      await pool.executeSP('sp_AD_InsertCoupon', { code, quantity, startDate, adminId, discountPercent } );

      return res.status(200).json({ message: "created coupon successfully" });

  } catch (err) {
      console.log("ERR ", err);
      return res.status(400).json({ error: err.message });
  }
};


export const getAllCoupons = async (req, res) => {
    try {
        const { isAvailable } = req.body;

        const pool = getPool('LMS');

        if (!pool) {
            return res.status(500).json({ message: "Database pool is not available" });
        }

        if (!isAvailable) {
            return res.status(400).json({ message: "isAvailable is required" });
        }
        const jsonResult = await pool.executeSP('sp_All_GetCoupons', { isAvailable });

        return res.status(200).json(jsonResult);

    } catch (err) {
        console.log("ERR ", err);
        return res.status(400).json({ error: err.message });
    }
};