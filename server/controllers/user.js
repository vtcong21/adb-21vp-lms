import getPool from "../utils/database";

export const getUserProfile = async (req, res) => {
    try {

        const { learnerId } = req.body;

        const pool = getPool('LMS');

        if (!pool) {
            return res.status(500).json({ message: "Database pool is not available" });
        }

        if (!learnerId) {
            return res.status(400).json({ message: "learnerId is required" });
        }
        const jsonResult = await pool.executeSP('sp_All_GetUserProfile', { id: learnerId });

        return res.status(200).json(jsonResult);

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

export const updateUserInfo = async (req, res) => {
    try {
        const { userId, email, name, password, profilePhoto } = req.body;

        const pool = getPool('LMS');

        if (!pool) {
            return res.status(500).json({ message: "Database pool is not available" });
        }

        if (!userId || !password) {
            return res.status(400).json({ message: "userId and password required" });
        }
        await pool.executeSP('sp_All_UpdateUserInfo', { userId, email, name, password, profilePhoto });

        return res.status(200).json({ message: "updated informations successfully" });

    } catch (err) {
        console.log("ERR ", err);
        return res.status(400).json({ error: err.message });
    }
};

