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
COMMIT TRAN

-- test
select * from taxform
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
EXEC sp_AD_GetTaxForm
	@instructorId = 'instructor1'
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
		IF (@state NOT IN ('notVip', 'vip', 'pending'))
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

EXEC sp_AD_ReviewVIPInstructor 
	@instructorId = 'instructor1',
	@state = 'Vip'
GO
SELECT * FROM INSTRUCTOR

-- finished and tested
CREATE OR ALTER PROC sp_CM_CreateMessage (
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
select * from [user];
insert into [user](id, email, name, password, profilePhoto, role) values ('learner1', 'learner1@email.com', 'some name', 'fuckingpassword', 'photo.png', 'LN');
insert into [coursemember] values ('learner1', 'LN');
insert into [learner] values ('learner1');
exec sp_CM_CreateMessage 
	'learner1',
	'instructor1',
	'hey man how its going'
go
exec sp_CM_CreateMessage 
	'instructor1',
	'learner1',
	'do i know you'
go
exec sp_CM_CreateMessage 
	'learner1',
	'instructor1',
	'its your old pal learner1 bro'
go

-- finished and tested
CREATE OR ALTER PROC sp_CM_GetMessages (
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

exec sp_CM_GetMessages 
	@senderId = 'instructor1',
	@receiverId = 'learner1',
	@offset = 0,
	@limit = 10
go

-- finished and tested
CREATE OR ALTER PROC sp_CM_MarkReadMessages (
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

exec sp_CM_MarkReadMessages 
	@senderId = 'instructor1',
	@receiverId = 'learner1'
go
select * from [message];

select 


-- finished and untested
CREATE OR ALTER PROC sp_CM_CreatePost (
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


--insert into [category] values ('category1');
--insert into [subcategory](parentCategoryId, name) values (1, 'subcategory1');

--INSERT INTO [course] (title, subTitle, description, image, video, state, numberOfStudents, numberOfLectures, totalTime, averageRating, subCategoryId, categoryId, totalRevenue, language, price, lastUpdateTime) VALUES (N'Introduction to Financial Modeling (Professional Level)', N'Sub Introduction to Financial Modeling (Professional Level)', N'Description for Introduction to Financial Modeling (Professional Level)', N'resources/image.png', N'resources/path.png', N'draft', 0, 0, 0.0, 0.0, 1, 1, 15431.93, N'English', 14.55, '2024-07-20 16:44:11');

--select * from course;
--select * from learnerEnrollCourse
--insert into learnerEnrollCourse (courseId, learnerId) values (9, 'learner1');

--exec sp_CM_CreatePost
--	@postPublisher = 'learner1',
--	@courseId = 9,
--	@postContent = 'some post content 1'
--go
--select * from post;


-- finished and untested
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
CREATE OR ALTER PROC sp_CM_GetCommentsInPost (
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
CREATE OR ALTER PROC sp_CM_GetAccountNotifications (
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
CREATE OR ALTER PROC sp_CM_ReadCommentNotification (
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
CREATE OR ALTER PROC sp_CM_ReadPostNotification (
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

select * from learnerPaymentCard;
select * from paymentCard;
insert into paymentCard (number, type, name, CVC, expireDate) values ('1234567890123456', 'debit', 'Some name', '214', GETDATE()+1);
insert into learnerPaymentCard (learnerId, paymentCardNumber) values ('learner1', '1234567890123456');

exec sp_LN_GetLearnerPaymentCard 
	@learnerId = 'learner1'
go


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

-- test
insert into vipInstructor(id, paymentCardNumber) values ('instructor1', '1234567890123456');
EXEC sp_CM_GetInstructorPaymentCard
	@instructorId = 'instructor1'
GO