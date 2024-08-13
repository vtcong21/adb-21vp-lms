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

-- test
EXEC sp_AD_CreateAdmin 
    @id = 'user3', 
    @email = 'user3@example.com', 
    @name = 'User Three', 
    @password = 'Password123', 
    @profilePhoto = 'photo1.jpg';
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
		WHERE vipState = 'pending'
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

-- test
INSERT INTO [user] (id, email, name, password, profilePhoto, role)
VALUES (
    'instructor1', 
    'instructor1@springfield.edu', 
    'John Doe', 
    'Password123', 
    'john_doe_photo.jpg', 
    'INS'
);
INSERT INTO [courseMember] (id, role)
VALUES (
	'instructor1',
	'INS'
)
INSERT INTO [instructor] (id, gender, phone, DOB, address, degrees, workplace, scientificBackground, vipState, totalRevenue)
VALUES (
    'instructor1', 
    'M', 
    '12345678901', 
    '1980-05-15', 
    '123 Elm Street, Springfield, IL', 
    'Ph.D. in Computer Science', 
    'Springfield University', 
    'Expert in Artificial Intelligence and Machine Learning', 
    'pending', 
    50000.00
);
INSERT INTO [user] (id, email, name, password, profilePhoto, role)
VALUES (
    'instructor2', 
    'instructor2@greenfield.edu', 
    'Jane Smith', 
    'SecurePass456', 
    'jane_smith_photo.jpg', 
    'INS'
);
INSERT INTO [courseMember] (id, role)
VALUES (
	'instructor2',
	'INS'
)
INSERT INTO [instructor] (id, gender, phone, DOB, address, degrees, workplace, scientificBackground, vipState, totalRevenue)
VALUES (
    'instructor2', 
    'F', 
    '09876543210', 
    '1975-10-22', 
    '456 Oak Avenue, Greenfield, CA', 
    'Master of Education', 
    'Greenfield High School', 
    'Specialist in Educational Psychology', 
    'Vip', 
    75000.00
);
INSERT INTO [user] (id, email, name, password, profilePhoto, role)
VALUES (
    'instructor3', 
    'instructor3@rivercity.edu', 
    'Michael Brown', 
    'MathGuru789', 
    'michael_brown_photo.jpg', 
    'INS'
);
INSERT INTO [courseMember] (id, role)
VALUES (
	'instructor3',
	'INS'
)
INSERT INTO [instructor] (id, gender, phone, DOB, address, degrees, workplace, scientificBackground, vipState, totalRevenue)
VALUES (
    'instructor3', 
    'M', 
    '11223344556', 
    '1990-01-10', 
    '789 Maple Lane, River City, NY', 
    'Bachelor of Science in Mathematics', 
    'River City College', 
    'Researcher in Theoretical Mathematics and Algebra', 
    'notVip', 
    40000.00
);

EXEC sp_AD_GetVIPInstructorQueue
GO

-- finished
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

		WITH instructorInfo (id, gender, phone, DOB, address,degrees, workplace, scientificBackground, vipState, totalRevenue) AS (
			SELECT id, gender, phone, DOB, address,degrees, workplace, scientificBackground, vipState, totalRevenue
			FROM [instructor]
			WHERE id = @instructorId
		)
		SELECT * 
		FROM [taxForm]
		JOIN instructorInfo ON id = vipInstructorId
		WHERE vipInstructorId = @instructorId
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
	END CATCH
COMMIT TRAN

-- test

INSERT INTO [vipInstructor] VALUES ('instructor1', '12421412412');
INSERT INTO [taxForm] (
    submissionDate, 
    fullName, 
    address, 
    phone, 
    taxCode, 
    identityNumber, 
    postCode, 
    vipInstructorId
)
VALUES (
    GETDATE(),                  -- submissionDate (defaults to today's date)
    'John Doe',                 -- fullName
    '123 Elm Street, Springfield, IL',  -- address
    '12345678901',              -- phone
    '123456789012',             -- taxCode
    '987654321012',             -- identityNumber
    '62704',                    -- postCode
    'instructor1'               -- vipInstructorId (foreign key)
);


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
	@receiverId NVARCHAR(128)
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



-- finished
CREATE OR ALTER PROC sp_CM_GetPostsInForum (
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
		RETURN (
			SELECT id as postId, date, publisher, content
			FROM [post]
			WHERE courseId = @courseId
			ORDER BY date
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
CREATE OR ALTER PROC sp_CM_CommentInPost (
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
		IF (@postId IS NULL OR @courseId IS NULL OR @postPublisher IS NULL OR @commenter IS NULL OR @messageContent IS NULL)
		BEGIN
			THROW 52000, 'Post ID, Course ID, Post Publisher ID, Commenter ID and Message Content are required.', 1;
		END
		IF NOT EXISTS(SELECT 1 FROM [post] WHERE id = @postId AND courseId = @courseId AND publisher = @postPublisher)
		BEGIN
			THROW 51000, 'Post does not exist', 1;
		END
		
		INSERT INTO [comment](postId, date, courseId, postPublisher, commenter, content)
		VALUES (@postId, now(), @courseId, @postPublisher, @commenter, @commentContent)

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
CREATE OR ALTER PROC sp_CM_GetCommentsInPost (
	@courseId INT,
	@postId INT,
	@postPublisher NVARCHAR(128),
	@offset INT,
	@limit INT
)
AS
BEGIN TRAN
	SET XACT_ABORT ON
	SET NOCOUNT ON
	BEGIN TRY
		IF (@postId IS NULL OR @courseId IS NULL OR @postPublisher IS NULL OR @commenter IS NULL OR @messageContent IS NULL)
		BEGIN
			THROW 52000, 'Course ID, Post ID, Post Publisher ID, Offset and Limit are required.', 1;
		END
		IF NOT EXISTS(SELECT 1 FROM [post] WHERE id = @postId AND courseId = @courseId AND publisher = @postPublisher)
		BEGIN
			THROW 51000, 'Post does not exist', 1;
		END
		RETURN (
			SELECT id as commentId, commenter, postId, postPublisher, content
			FROM [comment]
			WHERE postId = @postId AND courseId = @courseId AND postPublisher = @postPublisher
			ORDER BY date asc -- check
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




-- finished
CREATE OR ALTER PROC sp_CM_GetLearnerPaymentCard (
	@learnerId NVARCHAR(128)
)
AS
BEGIN TRAN
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	BEGIN TRY
		IF (@learnerId IS NULL)
		BEGIN
			THROW 51000, 'Learner Id is required.', 1;
		END;
		IF (SELECT * FROM [learner] WHERE id = @learnerId)
		BEGIN
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
CREATE OR ALTER PROC sp_CM_GetInstructorPaymentCard (
	@instructorId NVARCHAR(128)
)
AS
BEGIN TRAN;
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	BEGIN TRY
		IF (@instructorId IS NULL)
		BEGIN
			THROW 51000, 'Instructor Id is required.', 1;
		END

		SELECT paymentCardNumber
		FROM [vipInstructor]
		WHERE id = @instructorId
		FOR JSON PATH
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN
GO

-- test

EXEC sp_CM_GetInstructorPaymentCard
	@instructorId = 'instructor1'
GO