USE master;
GO
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'LoginLMS')
BEGIN
    DROP LOGIN LoginLMS;
END
GO

EXEC sp_addlogin 'LoginLMS', '123';
GO

USE LMS;
GO
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'userLMS')
BEGIN
    DROP USER userLMS;
END
GO

CREATE USER userLMS FOR LOGIN LoginLMS;
GO

EXEC sp_addrolemember 'db_owner', 'userLMS';
GO
