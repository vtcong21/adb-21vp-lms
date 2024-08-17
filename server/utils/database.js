import sql from 'mssql-plus';
require("dotenv").config();

const PORT = Number(process.env.MSSQL_PORT);

const pools = {};

const config = {
    server: process.env.MSSQL_SERVER,
    port: PORT,
    options: {
        enableArithAbort: true,
        trustServerCertificate: true,
        encrypt: true,
    },
    pool: {
        max: 100,
        min: 0,
        idleTimeoutMillis: 60000,
    },
};

const createPool = async (loginType) => {
    try {
        let user, password, database, logMessage;

        switch (loginType) {
            case "LMS":
                user = process.env.MSSQL_USERNAME;
                password = process.env.MSSQL_PASSWORD;
                database = process.env.MSSQL_DATABASE;
                logMessage = "Login to db";
                break;
            default:
                console.error(`Unsupported login type: ${loginType}`);
                return null;
        }

        const connectionConfig = {
            ...config,
            user,
            password,
            database,
        };

       
        const pool = new sql.ConnectionPool(connectionConfig);
        
        try {
            await pool.connect();
        } catch (error) {
            console.error(`Error connecting to SQL Server: ${error.message}`);
            return null;
        }

        pool.executeSP = async (procedureName, params) => {
            const request = await pool.request();
            for (const [paramName, paramValue] of Object.entries(params)) {
                request.input(paramName, paramValue);
            }
            try {
                const result = await request.execute(procedureName);
                
                if (result.recordset && Array.isArray(result.recordset)) {
                    const recordset = result.recordset;
                    if (recordset.length > 0) {
                        const firstRow = recordset[0];
                        const columnName = Object.keys(firstRow)[0];
                        const jsonResult = firstRow[columnName];
                        return JSON.parse(jsonResult);
                    }
                }
        
                return []; 
            } catch (error) {
                throw error;
            }
        };

        console.log(`🔥 SQL Server pool connection successful!!! ${logMessage}\n`);
        return pool;
    } catch (error) {
        console.error(`🔥 createPool connection error: ${error.message}\n`);
        return null;
    }
};

const getPool = (loginType) => {
    const pool = pools[loginType];
    if (!pool) {
        console.error(`No pool found for login type: ${loginType}`);
        return null;
    }
    return pool;
};

const initializePools = async () => {
    try {
        const loginTypes = ["LMS"];
        const poolPromises = loginTypes.map((loginType) => createPool(loginType));
        const results = await Promise.all(poolPromises);
        
        loginTypes.forEach((loginType, index) => {
            if (results[index]) {
                pools[loginType] = results[index];
            }
        });
    } catch (error) {
        console.error('Error initializing pools:', error);
    }
};
initializePools();

export default getPool;
