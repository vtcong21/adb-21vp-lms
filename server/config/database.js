const sql = require('mssql-plus');

const PORT = Number(process.env.MSSQL_PORT);

let pools = {};
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
            case "QTV":
                user = process.env.MSSQL_USERNAME_QTV;
                password = process.env.MSSQL_PASSWORD_QTV;
                database = process.env.MSSQL_DATABASE;
                logMessage = "Login as QTV";
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

        let pool = new sql.ConnectionPool(connectionConfig);
        if (!pool.connected) {
            try {
                await pool.connect();
            } catch (error) {
                console.error(`Error connecting to SQL Server: ${error.message}`);
                return null;
            }
        }
        pool.executeSP = async (procedureName, params) => {
            const request = await pool.request();
            for (const paramName in params) {
                if (params.hasOwnProperty(paramName)) {
                    request.input(paramName, params[paramName]);
                }
            }
            try {
                const result = await request.execute(procedureName);
                return result.recordsets;
            } catch (error) {
                throw error;
            }
        };

        console.log(`🔥 SQL Server pool connection successful!!! ${logMessage}\n`);

        return pool;
    } catch (error) {
        console.log(error);
        console.error(`🔥 createPool connection error !!!!!\n`);
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
        const loginTypes = ["QTV"];
        const poolPromises = loginTypes.map(async (loginType) => {
            const pool = await createPool(loginType);
            if (pool) {
                pools[loginType] = pool;
            }
        });
        await Promise.all(poolPromises);
    } catch (error) {
        console.error('Error initializing pools', error);
    }
};

initializePools();

module.exports = { getPool };
