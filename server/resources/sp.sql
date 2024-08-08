-- CREATE OR ALTER PROC sp_Role_ProcName (
-- 	@senderId NVARCHAR(128),
-- 	@receiverId NVARCHAR(128),
-- 	@messageContent NVARCHAR(MAX)
-- )
-- AS
-- BEGIN TRAN
-- 	SET XACT_ABORT ON
-- 	SET NOCOUNT ON
-- 	BEGIN TRY
-- 		IF NOT EXISTS()
-- 		BEGIN
-- 			THROW 51000, 'Receiver does not exist', 1;
-- 		END
		
-- 	END TRY
-- 	BEGIN CATCH
-- 		ROLLBACK TRAN;
-- 		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
-- 		THROW 51000, @errorMessage, 1;
-- 		RETURN
-- 	END CATCH
-- COMMIT TRAN
-- GO


-- finished
CREATE OR ALTER PROC sp_AD_CreateAdmin (
	@id NVARCHAR(128),
	@email NVARCHAR(256),
	@name NVARCHAR(128),
	@password VARCHAR(128),
    @profilePhoto NVARCHAR(256)
)
BEGIN TRAN
	SET XACT_ABORT ON
	SET NOCOUNT ON
	BEGIN TRY
		IF (@id IS NULL OR @email IS NULL OR @name IS NULL OR @password IS NULL OR @profilePhoto IS NULL)
		BEGIN
			THROW 52000, 'ID, Email, Name, Password and ProfilePhoto is required', 1
		END
		
		INSERT INTO [user](id, email, name, password, profilePhoto, role)
		VALUES (@id, @email, @name, @password, @profilePhoto, 'AD')

		RETURN (SELECT id, email, name, profilePhoto, role FROM [user] WHERE id = @id)
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN
GO


-- finished
CREATE OR ALTER PROC sp_AD_GetVIPInstructorQueue ()
BEGIN TRAN
	SET XACT_ABORT ON
	SET NOCOUNT ON
	BEGIN TRY		
		RETURN (
			SELECT [instructor].*, 
			FROM [instructor]
			WHERE vipState = 'pending';
		)
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN


-- finished
CREATE OR ALTER PROC sp_AD_GetTaxForm (
	@instructorId NVARCHAR(128)
)
BEGIN TRAN
	SET XACT_ABORT ON
	SET NOCOUNT ON
	BEGIN TRY
		IF (@instructorId IS NULL)
		BEGIN
			THROW 52000, 'InstructorID is required.', 1
		END
		IF NOT EXISTS(SELECT 1 FROM [instructor] WHERE id = @instructorId)
		BEGIN
			THROW 51000, 'Instructor does not exist.', 1;
		END
		IF NOT EXISTS(SELECT 1 FROM [taxForm] WHERE vipInstructorId = @instructorId)
		BEGIN
			THROW 51000, 'Instructor has not submitted any tax forms.', 1;
		END

		RETURN (
			WITH instructorInfo (gender, phone, DOB, address,degrees, workplace, scientificBackground, vipState, totalRevenue) AS (
				SELECT gender, phone, DOB, address,degrees, workplace, scientificBackground, vipState, totalRevenue
				FROM [instructor]
				WHERE id = @instructorId;
			),
			SELECT * 
			FROM [taxForm]
			JOIN instructorInfo ON id = vipInstructorId
			WHERE vipInstructorId = @instructorId;
		)
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN


-- finished
CREATE OR ALTER PROC sp_AD_ReviewVIPInstructor (
	@instructorId NVARCHAR(128),
	@state VARCHAR(7)
)
BEGIN TRAN
	SET XACT_ABORT ON
	SET NOCOUNT ON
	BEGIN TRY
		IF (@instructorId IS NULL OR @state IS NULL)
		BEGIN
			THROW 52000, 'InstructorID and Review State is required.', 1
		END
		IF (@state NOT IN ('notVip', 'vip', 'pending'))
		BEGIN
			THROW 52000, 'Invalid Review State.', 1
		END
		IF NOT EXISTS(SELECT 1 FROM [instructor] WHERE id = @instructorId)
		BEGIN
			THROW 51000, 'Instructor does not exist.', 1;
		END
		UPDATE [instructor]
		SET state = @state
		WHERE id = @instructorId;
		RETURN (
			SELECT id, state
			FROM [instructor]
			WHERE id = @instructorId;
		)
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN
GO


-- finished
CREATE OR ALTER PROC sp_CM_CreateMessage (
	@senderId NVARCHAR(128),
	@receiverId NVARCHAR(128),
	@messageContent NVARCHAR(MAX)
)
BEGIN TRAN
	SET XACT_ABORT ON
	SET NOCOUNT ON
	BEGIN TRY
		IF @senderId IS NULL OR @receiverId IS NULL OR @messageContent IS NULL
		BEGIN
			THROW 52000, 'SenderID, ReceiverID and MessageContent is required', 1
		END

		IF NOT EXISTS(SELECT 1 FROM [user] WHERE id = @senderId)
		BEGIN
			THROW 51000, 'Sender does not exist', 1;
		END

		IF NOT EXISTS(SELECT 1 FROM [user] WHERE id = @receiverId)
		BEGIN
			THROW 51000, 'Receiver does not exist', 1;
		END
		
		INSERT INTO [message](senderId, receiverId, content)
		VALUES (@senderId, @receiverId, @messageContent)

		RETURN (
			SELECT *
			FROM inserted
		)
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN
GO


-- finished
CREATE OR ALTER PROC sp_CM_GetMessages (
	@senderId NVARCHAR(128),
	@receiverId NVARCHAR(128),
	@offset INT,
	@limit INT
)
BEGIN TRAN
	SET XACT_ABORT ON
	SET NOCOUNT ON
	BEGIN TRY
		IF @senderId IS NULL OR @receiverId IS NULL
		BEGIN
			THROW 52000, 'SenderID, ReceiverID are required', 1
		END
		IF NOT EXISTS(SELECT 1 FROM [user] WHERE id = @senderId)
		BEGIN
			THROW 51000, 'Sender does not exist', 1;
		END
		IF NOT EXISTS(SELECT 1 FROM [user] WHERE id = @receiverId)
		BEGIN
			THROW 51000, 'Receiver does not exist', 1;
		END

		RETURN (
			WITH sentMessage(id, senderId, receiverId, content, sentTime, isRead) AS (
				SELECT id, senderId, receiverId, content, sentTime, isRead
				FROM [message]
				WHERE senderId = @senderId AND receiverId = @receiverId
				ORDER BY sentTime
			),
			WITH receivedMessage(id, senderId, receiverId, content, sentTime, isRead) AS (
				SELECT id, senderId, receiverId, content, sentTime, isRead
				FROM [message]
				WHERE senderId = @receiverId AND receiverId = @senderId
				ORDER BY sentTime
			),
			SELECT *
			FROM (
				SELECT *
				FROM sentMessage
				UNION
				SELECT *
				FROM receivedMessage
			)
			ORDER BY sentTime
			OFFSET @offset ROWS
			FETCH NEXT @limit ROWS ONLY;
		)
		
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN
GO



-- finished
CREATE OR ALTER PROC sp_CM_MarkReadMessages (
	@senderId NVARCHAR(128),
	@receiverId NVARCHAR(128),
	@offset INT,
	@limit INT
)
BEGIN TRAN
	SET XACT_ABORT ON
	SET NOCOUNT ON
	BEGIN TRY
		IF @senderId IS NULL OR @receiverId IS NULL
		BEGIN
			THROW 52000, 'SenderID, ReceiverID are required', 1
		END
		IF NOT EXISTS(SELECT 1 FROM [user] WHERE id = @senderId)
		BEGIN
			THROW 51000, 'Sender does not exist', 1;
		END
		IF NOT EXISTS(SELECT 1 FROM [user] WHERE id = @receiverId)
		BEGIN
			THROW 51000, 'Receiver does not exist', 1;
		END

		UPDATE [message]
		SET isRead = 1
		WHERE receiverId = @receiverId AND senderId = @senderId AND isRead = 0
		
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN
GO


-- finished
CREATE OR ALTER PROC sp_CM_CreatePost (
	@postPublisher NVARCHAR(128),
	@courseId INT,
	@postContent NVARCHAR(MAX)
)
BEGIN TRAN
	SET XACT_ABORT ON
	SET NOCOUNT ON
	BEGIN TRY
		IF (@postPublisher IS NULL OR @courseId IS NULL OR @postContent IS NULL)
		BEGIN
			THROW 52000, 'Post publisher ID, Course ID, Post Content are required.', 1;
		END
		IF NOT EXISTS(SELECT 1 FROM [user] WHERE id = @postPublisher AND role = 'CM')
		BEGIN
			THROW 51000, 'Post publisher does not exist', 1;
		END
		IF NOT EXISTS(SELECT 1 FROM [course] WHERE id = @courseId)
		BEGIN
			THROW 51000, 'Course does not exist', 1;
		END
		
		INSERT INTO [post](date, courseId, publisher, content)
		VALUES (now(), @courseId, @postPublisher, @postContent);

		RETURN (
			SELECT *
			FROM inserted;
		)
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN
GO



-- un
CREATE OR ALTER PROC sp_CM_GetPostsInForum (
	@senderId NVARCHAR(128),
	@receiverId NVARCHAR(128),
	@messageContent NVARCHAR(MAX)
)
AS
BEGIN TRAN
	SET XACT_ABORT ON
	SET NOCOUNT ON
	BEGIN TRY
		IF NOT EXISTS()
		BEGIN
			THROW 51000, 'Receiver does not exist', 1;
		END
		
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN
GO



-- un
CREATE OR ALTER PROC sp_CM_CommentInPost (
	@senderId NVARCHAR(128),
	@receiverId NVARCHAR(128),
	@messageContent NVARCHAR(MAX)
)
AS
BEGIN TRAN
	SET XACT_ABORT ON
	SET NOCOUNT ON
	BEGIN TRY
		IF NOT EXISTS()
		BEGIN
			THROW 51000, 'Receiver does not exist', 1;
		END
		
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN
GO



-- un
CREATE OR ALTER PROC sp_CM_GetCommentsInPost (
	@senderId NVARCHAR(128),
	@receiverId NVARCHAR(128),
	@messageContent NVARCHAR(MAX)
)
AS
BEGIN TRAN
	SET XACT_ABORT ON
	SET NOCOUNT ON
	BEGIN TRY
		IF NOT EXISTS()
		BEGIN
			THROW 51000, 'Receiver does not exist', 1;
		END
		
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN
GO



-- un
CREATE OR ALTER PROC sp_CM_CreatePostNotification (
	@senderId NVARCHAR(128),
	@receiverId NVARCHAR(128),
	@messageContent NVARCHAR(MAX)
)
AS
BEGIN TRAN
	SET XACT_ABORT ON
	SET NOCOUNT ON
	BEGIN TRY
		IF NOT EXISTS()
		BEGIN
			THROW 51000, 'Receiver does not exist', 1;
		END
		
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN
GO



-- un
CREATE OR ALTER PROC sp_CM_CreateCommentNotification (
	@senderId NVARCHAR(128),
	@receiverId NVARCHAR(128),
	@messageContent NVARCHAR(MAX)
)
AS
BEGIN TRAN
	SET XACT_ABORT ON
	SET NOCOUNT ON
	BEGIN TRY
		IF NOT EXISTS()
		BEGIN
			THROW 51000, 'Receiver does not exist', 1;
		END
		
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN
GO




-- un
CREATE OR ALTER PROC sp_CM_GetAccountNotifications (
	@senderId NVARCHAR(128),
	@receiverId NVARCHAR(128),
	@messageContent NVARCHAR(MAX)
)
AS
BEGIN TRAN
	SET XACT_ABORT ON
	SET NOCOUNT ON
	BEGIN TRY
		IF NOT EXISTS()
		BEGIN
			THROW 51000, 'Receiver does not exist', 1;
		END
		
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN
GO




-- un
CREATE OR ALTER PROC sp_CM_ReadCommentNotification (
	@senderId NVARCHAR(128),
	@receiverId NVARCHAR(128),
	@messageContent NVARCHAR(MAX)
)
AS
BEGIN TRAN
	SET XACT_ABORT ON
	SET NOCOUNT ON
	BEGIN TRY
		IF NOT EXISTS()
		BEGIN
			THROW 51000, 'Receiver does not exist', 1;
		END
		
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN
GO




-- un
CREATE OR ALTER PROC sp_CM_ReadPostNotification (
	@senderId NVARCHAR(128),
	@receiverId NVARCHAR(128),
	@messageContent NVARCHAR(MAX)
)
AS
BEGIN TRAN
	SET XACT_ABORT ON
	SET NOCOUNT ON
	BEGIN TRY
		IF NOT EXISTS()
		BEGIN
			THROW 51000, 'Receiver does not exist', 1;
		END
		
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN
GO




-- un
CREATE OR ALTER PROC sp_CM_GetLearnerPaymentCard (
	@senderId NVARCHAR(128),
	@receiverId NVARCHAR(128),
	@messageContent NVARCHAR(MAX)
)
AS
BEGIN TRAN
	SET XACT_ABORT ON
	SET NOCOUNT ON
	BEGIN TRY
		IF NOT EXISTS()
		BEGIN
			THROW 51000, 'Receiver does not exist', 1;
		END
		
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN
GO





-- un
CREATE OR ALTER PROC sp_CM_GetInstructorPaymentCard (
	@senderId NVARCHAR(128),
	@receiverId NVARCHAR(128),
	@messageContent NVARCHAR(MAX)
)
AS
BEGIN TRAN
	SET XACT_ABORT ON
	SET NOCOUNT ON
	BEGIN TRY
		IF NOT EXISTS()
		BEGIN
			THROW 51000, 'Receiver does not exist', 1;
		END
		
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN
GO