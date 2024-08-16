use LMS
go

-- finished and tested
CREATE OR ALTER PROC sp_AD_CreateAdmin (
	@id NVARCHAR(128),
	@email NVARCHAR(256),
	@name NVARCHAR(128),
	@password VARCHAR(128),
    @profilePhoto NVARCHAR(256)
)
AS
BEGIN TRAN;
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	BEGIN TRY
		IF (@id IS NULL OR @email IS NULL OR @name IS NULL OR @password IS NULL OR @profilePhoto IS NULL)
		BEGIN;
			THROW 52000, 'ID, Email, Name, Password and ProfilePhoto is required', 1;
		END
		
		INSERT INTO [user](id, email, name, password, profilePhoto, role)
		VALUES (@id, @email, @name, @password, @profilePhoto, 'AD');

		SELECT id, email, name, profilePhoto, role 
		FROM [user] 
		WHERE id = @id
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN
GO

-- finished and tested
CREATE OR ALTER PROC sp_AD_GetVIPInstructorQueue
AS
BEGIN TRAN;
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	BEGIN TRY		
		SELECT [instructor].* 
		FROM [instructor]
		WHERE vipState = 'pendingReview'
		FOR JSON PATH;
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN;
GO

-- finished and tested
CREATE OR ALTER PROC sp_AD_GetTaxForm (
	@instructorId NVARCHAR(128)
)
AS
BEGIN TRAN;
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	BEGIN TRY
		IF (@instructorId IS NULL)
		BEGIN
			THROW 52000, 'InstructorID is required.', 1;
		END;
		IF NOT EXISTS(SELECT 1 FROM [instructor] WHERE id = @instructorId)
		BEGIN
			THROW 51000, 'Instructor does not exist.', 1;
		END;
		IF NOT EXISTS(SELECT 1 FROM [taxForm] WHERE vipInstructorId = @instructorId)
		BEGIN
			THROW 51000, 'Instructor has not submitted any tax forms.', 1;
		END;

		SELECT * 
		FROM [taxForm]
		WHERE vipInstructorId = @instructorId
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
	END CATCH
COMMIT TRAN;
GO

-- finished and tested
CREATE OR ALTER PROC sp_AD_ReviewVIPInstructor (
	@instructorId NVARCHAR(128),
	@state VARCHAR(7)
)
AS
BEGIN TRAN
	SET XACT_ABORT ON
	SET NOCOUNT ON
	BEGIN TRY
		IF (@instructorId IS NULL OR @state IS NULL)
		BEGIN
			THROW 52000, 'InstructorID and Review State is required.', 1
		END
		IF (@state NOT IN ('notVip', 'vip', 'pendingReview'))
		BEGIN
			THROW 52000, 'Invalid Review State.', 1
		END
		IF NOT EXISTS(SELECT 1 FROM [instructor] WHERE id = @instructorId)
		BEGIN
			THROW 51000, 'Instructor does not exist.', 1;
		END
		UPDATE [instructor]
		SET [vipState] = @state
		WHERE id = @instructorId;
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN
GO

-- finished and tested
CREATE OR ALTER PROC sp_INS_LN_CreateMessage (
	@senderId NVARCHAR(128),
	@receiverId NVARCHAR(128),
	@messageContent NVARCHAR(MAX)
)
AS
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

		DECLARE @inserted TABLE (
            id INT,
            senderId NVARCHAR(128),
            receiverId NVARCHAR(128),
            content NVARCHAR(MAX)
        );
		
		INSERT INTO [message](senderId, receiverId, content)
		OUTPUT INSERTED.id, INSERTED.senderId, INSERTED.receiverId, INSERTED.content
		INTO @inserted
		VALUES (@senderId, @receiverId, @messageContent);

		SELECT id, senderId, receiverId, content
		FROM @inserted;
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN
GO

-- finished and tested
CREATE OR ALTER PROC sp_INS_LN_GetMessages (
	@senderId NVARCHAR(128),
	@receiverId NVARCHAR(128),
	@offset INT,
	@limit INT
)
AS
BEGIN TRAN
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	BEGIN TRY
		IF @senderId IS NULL OR @receiverId IS NULL
		BEGIN
			THROW 52000, 'SenderID, ReceiverID are required', 1
		END;
		IF NOT EXISTS(SELECT 1 FROM [user] WHERE id = @senderId)
		BEGIN
			THROW 51000, 'Sender does not exist', 1;
		END;
		IF NOT EXISTS(SELECT 1 FROM [user] WHERE id = @receiverId)
		BEGIN
			THROW 51000, 'Receiver does not exist', 1;
		END;

		WITH AllMessages AS (
            SELECT id, senderId, receiverId, content, sentTime, isRead
            FROM [message]
            WHERE (senderId = @senderId AND receiverId = @receiverId)
               OR (senderId = @receiverId AND receiverId = @senderId)
        )
        SELECT id, senderId, receiverId, content, sentTime, isRead
        FROM AllMessages
        ORDER BY sentTime
        OFFSET @offset ROWS
        FETCH NEXT @limit ROWS ONLY
        FOR JSON PATH;
		
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN
GO

-- finished and tested
CREATE OR ALTER PROC sp_INS_LN_MarkReadMessages (
	@senderId NVARCHAR(128),
	@receiverId NVARCHAR(128)
)
AS
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

-- finished and untested
CREATE OR ALTER PROC sp_INS_LN_CreatePost (
	@postPublisher NVARCHAR(128),
	@courseId INT,
	@postContent NVARCHAR(MAX)
)
AS
BEGIN TRAN
	SET XACT_ABORT ON
	SET NOCOUNT ON
	BEGIN TRY
		IF (@postPublisher IS NULL OR @courseId IS NULL OR @postContent IS NULL)
		BEGIN
			THROW 52000, 'Post publisher ID, Course ID, Post Content are required.', 1;
		END
		IF NOT EXISTS(SELECT 1 FROM [user] WHERE id = @postPublisher AND role = 'LN' OR role = 'INS')
		BEGIN
			THROW 51000, 'Post publisher does not exist', 1;
		END
		IF NOT EXISTS(SELECT 1 FROM [course] WHERE id = @courseId)
		BEGIN
			THROW 51000, 'Course does not exist', 1;
		END
		DECLARE @inserted TABLE(
			id INT,
			datePosted date,
			postPublisher NVARCHAR(128),
			courseId INT,
			postContent NVARCHAR(MAX)
		);
		
		INSERT INTO [post]([date], courseId, publisher, content)
		OUTPUT INSERTED.id, INSERTED.[date], INSERTED.courseId, INSERTED.publisher, INSERTED.content 
		INTO @inserted
		VALUES (GETDATE(), @courseId, @postPublisher, @postContent);

		SELECT id, datePosted, courseId, postPublisher, postContent
		FROM @inserted
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN
GO

-- finished and untested
CREATE OR ALTER PROC sp_INS_LN_GetPostsInForum (
	@courseId INT,
	@offset INT,
	@limit INT
)
AS
BEGIN TRAN
	SET XACT_ABORT ON
	SET NOCOUNT ON
	BEGIN TRY
		IF (@courseId IS NULL OR @offset IS NULL OR @limit IS NULL)
		BEGIN
			THROW 52000, 'Course ID, Offset and Limit are required.', 1;
		END
		IF NOT EXISTS(SELECT 1 FROM [course] WHERE id = @courseId)
		BEGIN
			THROW 51000, 'Course does not exist', 1;
		END
		
		SELECT id as postId, date, publisher, content
		FROM [post]
		WHERE courseId = @courseId
		ORDER BY date
		OFFSET @offset ROWS
		FETCH NEXT @limit ROWS ONLY
		FOR JSON PATH;
		
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN
GO


-- finished and untested
CREATE OR ALTER PROC sp_INS_LN_CommentInPost (
	@courseId INT,
	@postId INT,
	@postPublisher NVARCHAR(128),
	@commenter NVARCHAR(128),
	@commentContent NVARCHAR(MAX)
)
AS
BEGIN TRAN
	SET XACT_ABORT ON
	SET NOCOUNT ON
	BEGIN TRY
		IF (@postId IS NULL OR @courseId IS NULL OR @postPublisher IS NULL OR @commenter IS NULL OR @commentContent IS NULL)
		BEGIN
			THROW 52000, 'Post ID, Course ID, Post Publisher ID, Commenter ID and Message Content are required.', 1;
		END
		IF NOT EXISTS(SELECT 1 FROM [post] WHERE id = @postId AND courseId = @courseId AND publisher = @postPublisher)
		BEGIN
			THROW 51000, 'Post does not exist', 1;
		END

		DECLARE @inserted TABLE (
			commentId INT,
			postId INT,
			courseId INT,
			postPublisher NVARCHAR(128),
			dateCommented DATE,
			commenter NVARCHAR(128),
			commentContent NVARCHAR(MAX)
		)
		
		INSERT INTO [comment](postId, [date], courseId, postPublisher, commenter, content)
		OUTPUT inserted.id, inserted.postId, inserted.courseId, inserted.postPublisher, inserted.[date], inserted.commenter, inserted.content
		INTO @inserted
		VALUES (@postId, GETDATE(), @courseId, @postPublisher, @commenter, @commentContent)

		SELECT *
		FROM @inserted
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN
GO


-- finished and untested
CREATE OR ALTER PROC sp_INS_LN_GetCommentsInPost (
	@postId INT,
	@offset INT,
	@limit INT
)
AS
BEGIN TRAN
	SET XACT_ABORT ON
	SET NOCOUNT ON
	BEGIN TRY
		IF (@postId IS NULL OR @offset IS NULL OR @limit IS NULL)
		BEGIN
			THROW 52000, 'Course ID, Post ID, Post Publisher ID, Offset and Limit are required.', 1;
		END;
		IF NOT EXISTS(SELECT 1 FROM [post] WHERE id = @postId)
		BEGIN
			THROW 51000, 'Post does not exist', 1;
		END;
		
		SELECT id as commentId, commenter, postId, postPublisher, content
		FROM [comment]
		WHERE postId = @postId
		ORDER BY date asc
		OFFSET @offset ROWS
		FETCH NEXT @limit ROWS ONLY
		FOR JSON PATH;
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN
GO


-- finished and untested
CREATE OR ALTER PROC sp_INS_LN_GetAccountNotifications (
	@memberId NVARCHAR(128)
)
AS
BEGIN TRAN
	SET XACT_ABORT ON
	SET NOCOUNT ON
	BEGIN TRY
		IF (@memberId IS NULL)
		BEGIN
			THROW 52000, 'Member ID is required.', 1;
		END
		IF NOT EXISTS(SELECT 1 FROM courseMember WHERE id = @memberId)
		BEGIN
			THROW 51000, 'Member not found.', 1;
		END

		SELECT commentId, 'post'
		FROM commentNotification
		WHERE memberNotification = @memberId
		UNION
		SELECT postId, 'comment'
		FROM postNotification
		WHERE memberNotification = @memberId
		FOR JSON PATH;
		
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN
GO


-- finished and untested
CREATE OR ALTER PROC sp_INS_LN_ReadCommentNotification (
	@commentId INT,
	@memberNotification NVARCHAR(128)
)
AS
BEGIN TRAN
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	BEGIN TRY;
		IF (@memberNotification IS NULL OR @commentId IS NULL)
		BEGIN
			THROW 52000, 'Member ID and Comment ID are required.', 1;
		END;
		IF NOT EXISTS(SELECT 1 FROM courseMember WHERE id = @memberNotification)
		BEGIN
			THROW 51000, 'Member not found.', 1;
		END;
		IF NOT EXISTS(SELECT 1 FROM commentNotification WHERE memberNotification = @memberNotification AND commentId = @commentId)
		BEGIN
			THROW 51000, 'Notification not found.', 1;
		END;

		UPDATE commentNotification
		SET isRead = 1
		WHERE memberNotification = @memberNotification AND commentId = @commentId

		SELECT commentId, memberNotification, isRead
		FROM commentNotification
		WHERE commentId = @commentId AND memberNotification = @memberNotification
		FOR JSON PATH;

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN
GO


-- finished and untested
CREATE OR ALTER PROC sp_INS_LN_ReadPostNotification (
	@postId INT,
	@memberNotification NVARCHAR(128)
)
AS
BEGIN TRAN;
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	BEGIN TRY
		IF (@memberNotification IS NULL OR @postId IS NULL)
		BEGIN;
			THROW 52000, 'Member ID and Post ID are required.', 1;
		END;
		IF NOT EXISTS(SELECT 1 FROM [courseMember] WHERE id = @memberNotification)
		BEGIN;
			THROW 51000, 'Member not found', 1;
		END;
		IF NOT EXISTS(SELECT 1 FROM [postNotification] WHERE postId = @postId AND memberNotification = @memberNotification)
		BEGIN;
			THROW 51000, 'Notification not found', 1;
		END;

		UPDATE postNotification
		SET isRead = 1
		WHERE postId = @postId AND memberNotification = @memberNotification;

		SELECT postId, memberNotification, isRead
		FROM postNotification
		WHERE postId = @postId AND memberNotification = @memberNotification
		FOR JSON PATH;

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN
GO


-- finished and tested
CREATE OR ALTER PROC sp_LN_GetLearnerPaymentCard (
	@learnerId NVARCHAR(128)
)
AS
BEGIN TRAN
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	BEGIN TRY
		IF (@learnerId IS NULL)
		BEGIN;
			THROW 51000, 'Learner Id is required.', 1;
		END;
		IF NOT EXISTS (SELECT 1 FROM [learner] WHERE id = @learnerId)
		BEGIN;
			THROW 51000, 'Learner not found.', 1;
		END;
		
		SELECT paymentCardNumber
		FROM [learnerPaymentCard]
		FOR JSON PATH;
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN
GO


-- finished and tested
CREATE OR ALTER PROC sp_INS_GetInstructorPaymentCard (
	@instructorId NVARCHAR(128)
)
AS
BEGIN TRAN;
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	BEGIN TRY
		IF (@instructorId IS NULL)
		BEGIN;
			THROW 51000, 'Instructor Id is required.', 1;
		END;

		SELECT paymentCardNumber
		FROM [vipInstructor]
		WHERE id = @instructorId
		FOR JSON PATH;

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN
GO
