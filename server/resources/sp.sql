-- CREATE OR ALTER PROC sp_CM_proc (
-- 	@senderId NVARCHAR(128),
-- 	@receiverId NVARCHAR(128),
-- 	@messageContent NVARCHAR(MAX)
-- )
-- BEGIN TRAN
-- 	SET XACT_ABORT ON
-- 	-- SET NOCOUNT ON
-- 	BEGIN TRY
-- 		IF NOT EXISTS()
-- 		BEGIN
-- 			THROW 51000, 'Receiver does not exist', 1;
-- 		END;
		
-- 	END TRY;
-- 	BEGIN CATCH
-- 		THROW 50000, 'An error occured', 1;
-- 	END CATCH;
-- COMMIT TRAN;


CREATE OR ALTER PROC sp_AD_createAdmin (
	@id NVARCHAR(128),
	@email NVARCHAR(256),
	@name NVARCHAR(128),
	@password VARCHAR(128),
    @profilePhoto NVARCHAR(256)
)
BEGIN TRAN
	SET XACT_ABORT ON
	-- SET NOCOUNT ON
	BEGIN TRY
		IF (@id IS NULL OR @email IS NULL OR @name IS NULL OR @password IS NULL OR @profilePhoto IS NULL)
		BEGIN
			THROW 52000, 'ID, Email, Name, Password and ProfilePhoto is required', 1
		END;
		
		INSERT INTO [user](id, email, name, password, profilePhoto, role)
		VALUES (@id, @email, @name, @password, @profilePhoto, 'AD')

		RETURN (SELECT id, email, name, profilePhoto, role FROM [user] WHERE id = @id)
	END TRY;
	BEGIN CATCH
		THROW 50000, 'An error occured', 1;
	END CATCH;
COMMIT TRAN;

CREATE OR ALTER PROC sp_AD_getVIPInstructorQueue ()
BEGIN TRAN
	SET XACT_ABORT ON
	-- SET NOCOUNT ON
	BEGIN TRY
		IF NOT EXISTS()
		BEGIN
			THROW 51000, 'Receiver does not exist', 1;
		END;
		
	END TRY;
	BEGIN CATCH
		THROW 50000, 'An error occured', 1;
	END CATCH;
COMMIT TRAN;

CREATE OR ALTER PROC sp_AD_getTaxForm (
	@instructorId NVARCHAR(128)
)
BEGIN TRAN
	SET XACT_ABORT ON
	-- SET NOCOUNT ON
	BEGIN TRY
		IF NOT EXISTS()
		BEGIN
			THROW 51000, 'Receiver does not exist', 1;
		END;
		
	END TRY;
	BEGIN CATCH
		THROW 50000, 'An error occured', 1;
	END CATCH;
COMMIT TRAN;

CREATE OR ALTER PROC sp_AD_verifyVIPInstructor (
	@senderId NVARCHAR(128),
	@receiverId NVARCHAR(128),
	@messageContent NVARCHAR(MAX)
)
BEGIN TRAN
	SET XACT_ABORT ON
	-- SET NOCOUNT ON
	BEGIN TRY
		IF NOT EXISTS()
		BEGIN
			THROW 51000, 'Receiver does not exist', 1;
		END;
		
	END TRY;
	BEGIN CATCH
		THROW 50000, 'An error occured', 1;
	END CATCH;
COMMIT TRAN;

CREATE OR ALTER PROC sp_CM_sendMessage (
	@senderId NVARCHAR(128),
	@receiverId NVARCHAR(128),
	@messageContent NVARCHAR(MAX)
)
BEGIN TRAN
	SET XACT_ABORT ON
	-- SET NOCOUNT ON
	BEGIN TRY
		IF @senderId IS NULL OR @receiverId IS NULL OR @messageContent IS NULL
		BEGIN
			THROW 52000, 'SenderID, ReceiverID and MessageContent is required', 1
		END;

		IF NOT EXISTS(SELECT * FROM [user] WHERE id = @senderId)
		BEGIN
			THROW 51000, 'Sender does not exist', 1;
		END;

		IF NOT EXISTS(SELECT * FROM [user] WHERE id = @receiverId)
		BEGIN
			THROW 51000, 'Receiver does not exist', 1;
		END;
		
		INSERT INTO [message](senderId, receiverId, content)
		VALUES (@senderId, @receiverId, @messageContent)
	END TRY;
	BEGIN CATCH
		THROW 50000, 'An error occured', 1;
	END CATCH;
COMMIT TRAN;

CREATE OR ALTER PROC sp_CM_readMessage (
	@senderId NVARCHAR(128),
	@receiverId NVARCHAR(128)
)
BEGIN TRAN
	SET XACT_ABORT ON
	-- SET NOCOUNT ON
	BEGIN TRY
		IF NOT EXISTS()
		BEGIN
			THROW 51000, 'Receiver does not exist', 1;
		END;
		
	END TRY;
	BEGIN CATCH
		THROW 50000, 'An error occured', 1;
	END CATCH;
COMMIT TRAN;

CREATE OR ALTER PROC sp_CM_createPost (
	@senderId NVARCHAR(128),
	@receiverId NVARCHAR(128)
)
BEGIN TRAN
	SET XACT_ABORT ON
	-- SET NOCOUNT ON
	BEGIN TRY
		IF NOT EXISTS()
		BEGIN
			THROW 51000, 'Receiver does not exist', 1;
		END;
		
	END TRY;
	BEGIN CATCH
		THROW 50000, 'An error occured', 1;
	END CATCH;
COMMIT TRAN;
