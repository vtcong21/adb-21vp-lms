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
	@postId INT,
	@commenter NVARCHAR(128),
	@commentContent NVARCHAR(MAX)
)
AS
BEGIN TRAN
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	BEGIN TRY
		IF (@postId IS NULL OR @commenter IS NULL OR @commentContent IS NULL)
		BEGIN;
			THROW 52000, 'Post ID, Course ID, Post Publisher ID, Commenter ID and Message Content are required.', 1;
		END
		IF NOT EXISTS(SELECT 1 FROM [post] WHERE id = @postId)
		BEGIN;
			THROW 51000, 'Post does not exist', 1;
		END

		DECLARE @inserted TABLE (
			commentId INT,
			dateCommented DATE,
			commenter NVARCHAR(128),
			commentContent NVARCHAR(MAX)
		)
		
		INSERT INTO [comment](postId, [date], commenter, content)
		OUTPUT inserted.id, inserted.[date], inserted.commenter, inserted.content
		INTO @inserted
		VALUES (@postId, GETDATE(), @commenter, @commentContent)

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
		BEGIN;
			THROW 52000, 'Course ID, Post ID, Post Publisher ID, Offset and Limit are required.', 1;
		END;
		IF NOT EXISTS(SELECT 1 FROM [post] WHERE id = @postId)
		BEGIN;
			THROW 51000, 'Post does not exist', 1;
		END;
		
		SELECT id as commentId, commenter, content
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
CREATE OR ALTER PROC sp_LN_GetLearnerPaymentCards(
	@learnerId NVARCHAR(128)
)
AS
BEGIN TRAN
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	BEGIN TRY
		SELECT
            pc.number,
            pc.type,
            pc.name,
            pc.CVC,
            pc.expireDate
        FROM
            [paymentCard] pc
            JOIN [learnerPaymentCard] lc ON pc.number = lc.paymentCardNumber
        WHERE
            lc.learnerId = @learnerId
        FOR JSON PATH, INCLUDE_NULL_VALUES;
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

-- Write the SPs here
Use LMS 
GO

-- AD - Get Daily Revenue Of A Course un
IF OBJECT_ID('sp_AD_INS_GetDailyRevenueOfACourse', 'P') IS NOT NULL
    DROP PROCEDURE [sp_AD_INS_GetDailyRevenueOfACourse]
GO
CREATE PROCEDURE sp_AD_INS_GetDailyRevenueOfACourse
    @courseId INT,
    @duration INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        SELECT
            o.dateCreated AS [date], 
            SUM(od.coursePrice * (100 - COALESCE(c.discountPercent, 0))/100) AS revenue
        FROM
            [orderDetail] od
            JOIN [order] o ON od.orderId = o.id
            LEFT JOIN [coupon] c ON o.couponCode = c.code
        WHERE
            od.courseId = @courseId
            AND o.dateCreated >= DATEADD(DAY, -@duration, GETDATE())
            AND o.dateCreated < GETDATE()
        GROUP BY
            o.dateCreated
        ORDER BY
            o.dateCreated DESC
        FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@trancount > 0 ROLLBACK TRANSACTION;
        RAISERROR ('Cannot get daily revenue of the course.', 16, 1);
    END CATCH
END;
GO

-- AD - Get Monthly Revenue Of A Course
IF OBJECT_ID('sp_AD_INS_GetMonthlyRevenueOfACourse', 'P') IS NOT NULL
    DROP PROCEDURE [sp_AD_INS_GetMonthlyRevenueOfACourse]
GO
CREATE PROCEDURE sp_AD_INS_GetMonthlyRevenueOfACourse
    @courseId INT,
    @duration INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
    
        DECLARE @startDate DATE = DATEADD(MONTH, -@duration, GETDATE());
        DECLARE @endDate DATE = GETDATE();
        SELECT
            year, month, revenue
        FROM
            courseRevenueByMonth
        WHERE
            courseId = @courseId
            AND DATEFROMPARTS(year, month, 1) >= @startDate
            AND DATEFROMPARTS(year, month, 1) < @endDate
        ORDER BY
            year,
            month
        FOR JSON AUTO, INCLUDE_NULL_VALUES;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@trancount > 0 ROLLBACK TRANSACTION;
        RAISERROR ('Cannot get course revenue by date.', 16, 1);
    END CATCH
END;
GO

-- AD - Get Yearly Revenue Of A Course
IF OBJECT_ID('sp_AD_INS_GetYearlyRevenueOfACourse', 'P') IS NOT NULL
    DROP PROCEDURE [sp_AD_INS_GetYearlyRevenueOfACourse]
GO

CREATE PROCEDURE sp_AD_INS_GetYearlyRevenueOfACourse
    @courseId INT,
    @duration INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @startYear INT = YEAR(DATEADD(YEAR, -@duration, GETDATE()));
        DECLARE @endYear INT = YEAR(GETDATE());
        SELECT
            year, SUM(revenue) AS totalRevenue
        FROM
            courseRevenueByMonth
        WHERE
            courseId = @courseId
            AND year >= @startYear
            AND year < @endYear
        GROUP BY
            year
        ORDER BY
            year
        FOR JSON AUTO, INCLUDE_NULL_VALUES;
		COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@trancount > 0 ROLLBACK TRANSACTION;
        RAISERROR ('Cannot get course revenue by year.', 16, 1);
    END CATCH
END;
GO

-- AD - Get Top 50 Courses By Revenue 
IF OBJECT_ID('sp_AD_GetTop50CoursesByRevenue', 'P') IS NOT NULL
    DROP PROCEDURE [sp_AD_GetTop50CoursesByRevenue]
GO
CREATE PROCEDURE sp_AD_GetTop50CoursesByRevenue
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        SELECT TOP 50
        id, title, totalRevenue
    FROM
        [course]
    ORDER BY
            totalRevenue DESC
    FOR JSON AUTO, INCLUDE_NULL_VALUES;
    COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@trancount > 0 ROLLBACK TRANSACTION;
        RAISERROR ('Cannot get top 50 courses by revenue.', 16, 1);
    END CATCH
END;
GO

-- AD - Insert Coupon
IF OBJECT_ID('sp_AD_InsertCoupon', 'P') IS NOT NULL
    DROP PROCEDURE [sp_AD_InsertCoupon]
GO
CREATE PROCEDURE sp_AD_InsertCoupon
    @code VARCHAR(20),
    @discountPercent DECIMAL(5, 2),
    @quantity INT,
    @startDate DATE,
    @adminId NVARCHAR(128)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF @discountPercent > 30 
        BEGIN
            RAISERROR ('Discount percent must be less than 30.', 16, 1);
            IF @@trancount > 0 ROLLBACK TRANSACTION;
            RETURN;
        END
        INSERT INTO [coupon]
        (code, discountPercent, quantity, startDate, adminCreatedCoupon)
        VALUES
        (@code, @discountPercent, @quantity, @startDate, @adminId);
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@trancount > 0 ROLLBACK TRANSACTION;
    DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR ('Cannot insert coupon. Error: %s', 16, 1, @errorMessage);    
    END CATCH
END;
GO

-- LN - Create Learner - 
IF OBJECT_ID('sp_LN_CreateLearner', 'P') IS NOT NULL
    DROP PROCEDURE [sp_LN_CreateLearner]
GO
CREATE PROCEDURE sp_LN_CreateLearner
    @userId NVARCHAR(128),
    @email VARCHAR(256),
    @name NVARCHAR(128),
    @password VARCHAR(128),
    @profilePhoto NVARCHAR(256)   
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO [user] (id, email, name, password, profilePhoto, role)
        VALUES (@userId, @email, @name, @password, @profilePhoto, 'LN');
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@trancount > 0 ROLLBACK TRANSACTION;
        DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR ('Cannot insert user, course member, or learner. Error: %s', 16, 1, @errorMessage);
    END CATCH
END;
GO

-- LN - Update Learner Payment Card
IF OBJECT_ID('sp_LN_AddLearnerPaymentCard', 'P') IS NOT NULL
    DROP PROCEDURE [sp_LN_AddLearnerPaymentCard]
GO

CREATE PROCEDURE sp_LN_AddLearnerPaymentCard
    @learnerId NVARCHAR(128),
    @number VARCHAR(16),
    @type VARCHAR(6),
    @name NVARCHAR(128),
    @CVC CHAR(3),
    @expireDate DATE
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1
            FROM [paymentCard]
            WHERE number = @number
        )
        BEGIN
            INSERT INTO [paymentCard] (number, type, name, CVC, expireDate)
            VALUES (@number, @type, @name, @CVC, @expireDate);
        END
        INSERT INTO [learnerPaymentCard] (learnerId, paymentCardNumber)
        VALUES (@learnerId, @number);
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@trancount > 0 ROLLBACK TRANSACTION;
        DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR ('Cannot update learner payment card. Error: %s', 16, 1, @errorMessage);
    END CATCH
END;
GO

-- Ln - Add A Course To Cart 
IF OBJECT_ID('sp_LN_AddCourseToCart', 'P') IS NOT NULL
    DROP PROCEDURE [sp_LN_AddCourseToCart]
GO

CREATE PROCEDURE sp_LN_AddCourseToCart
    @learnerId NVARCHAR(128),
    @courseId INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
		IF EXISTS (
            SELECT 1
            FROM [learnerEnrollCourse]
            WHERE learnerId = @learnerId AND courseId = @courseId
        )
        BEGIN
            RAISERROR ('The learner is already enrolled in the course.', 16, 1);
            IF @@trancount > 0 ROLLBACK TRANSACTION;
            RETURN;
        END

        IF EXISTS (
            SELECT 1
            FROM [cartDetail]
            WHERE learnerId = @learnerId AND courseId = @courseId
        )
        BEGIN
            RAISERROR ('The course is already in the learner''s cart.', 16, 1);
            IF @@trancount > 0 ROLLBACK TRANSACTION;
            RETURN;
        END

        INSERT INTO [cartDetail] (learnerId, courseId)
        VALUES (@learnerId, @courseId);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@trancount > 0 ROLLBACK TRANSACTION;
        
        DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR ('Cannot add course to cart. Error: %s', 16, 1, @errorMessage);
    END CATCH
END;
GO

-- LN - Remove A Course From Cart 
IF OBJECT_ID('sp_LN_RemoveCourseFromCart', 'P') IS NOT NULL
    DROP PROCEDURE [sp_LN_RemoveCourseFromCart]
GO

CREATE PROCEDURE sp_LN_RemoveCourseFromCart
    @learnerId NVARCHAR(128),
    @courseId INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1
            FROM [cartDetail]
            WHERE learnerId = @learnerId AND courseId = @courseId
        )
        BEGIN
            RAISERROR ('The course is not in the learner''s cart.', 16, 1);
            IF @@trancount > 0 ROLLBACK TRANSACTION;
            RETURN;
        END

        DELETE FROM [cartDetail]
        WHERE learnerId = @learnerId AND courseId = @courseId;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@trancount > 0 ROLLBACK TRANSACTION;

        DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR ('Cannot remove course from cart. Error: %s', 16, 1, @errorMessage);
    END CATCH
END;
GO

-- LN - Get Cart Details 
IF OBJECT_ID('sp_LN_GetCartDetails', 'P') IS NOT NULL
    DROP PROCEDURE [sp_LN_GetCartDetails]
GO

CREATE PROCEDURE sp_LN_GetCartDetails
    @learnerId NVARCHAR(128)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        SELECT
            cd.courseId, c.title, c.price
        FROM
            [cartDetail] cd
        JOIN
            [course] c ON cd.courseId = c.id
        WHERE
            cd.learnerId = @learnerId
        FOR JSON PATH, INCLUDE_NULL_VALUES;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@trancount > 0 ROLLBACK TRANSACTION;
        DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR ('Cannot retrieve cart details. Error: %s', 16, 1, @errorMessage);
    END CATCH
END;
GO

-- update the total revenue of a course and course revenue by month
IF OBJECT_ID('sp_UpdateCourseRevenueAndInstructorRevenue', 'P') IS NOT NULL
    DROP PROCEDURE [sp_UpdateCourseRevenueAndInstructorRevenue]
GO

CREATE PROCEDURE sp_UpdateCourseRevenueAndInstructorRevenue
    @courseId INT,
    @amount DECIMAL(18, 2),
    @date DATETIME
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY

        DECLARE @currentDate DATE;
        SET @currentDate =@date;

        -- update course total revenue
        UPDATE [course]
        SET totalRevenue = totalRevenue + @amount
        WHERE id = @courseId;

        -- update course revenue by month
        DECLARE @year INT = YEAR(@currentDate);
        DECLARE @month INT = MONTH(@currentDate);
        
        IF EXISTS (SELECT 1 FROM [courseRevenueByMonth] WHERE courseId = @courseId AND year = @year AND month = @month)
        BEGIN
            UPDATE [courseRevenueByMonth]
            SET revenue = revenue + @amount
            WHERE courseId = @courseId AND year = @year AND month = @month;
        END
        ELSE
        BEGIN
            INSERT INTO [courseRevenueByMonth] (courseId, year, month, revenue)
            VALUES (@courseId, @year, @month, @amount);
        END

        -- update instructor revenue by month
        DECLARE @instructorId NVARCHAR(128);
        DECLARE @percentageInCome DECIMAL(5, 2);
        DECLARE @instructorRevenue DECIMAL(18, 2);
        
        DECLARE instructor_cursor CURSOR LOCAL FOR
        SELECT instructorId, percentageInCome
        FROM [instructorOwnCourse]
        WHERE courseId = @courseId;

        OPEN instructor_cursor;
        FETCH NEXT FROM instructor_cursor INTO @instructorId, @percentageInCome;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @instructorRevenue = @amount * @percentageInCome / 100;

            IF EXISTS (SELECT 1 FROM [instructorRevenueByMonth] WHERE instructorId = @instructorId AND year = @year AND month = @month)
            BEGIN
                UPDATE [instructorRevenueByMonth]
                SET revenue = revenue + @instructorRevenue
                WHERE instructorId = @instructorId AND year = @year AND month = @month;
            END
            ELSE
            BEGIN
                INSERT INTO [instructorRevenueByMonth] (instructorId, year, month, revenue)
                VALUES (@instructorId, @year, @month, @instructorRevenue);
            END
            
            FETCH NEXT FROM instructor_cursor INTO @instructorId, @percentageInCome;
        END
        
        CLOSE instructor_cursor;
        DEALLOCATE instructor_cursor;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@trancount > 0 ROLLBACK TRANSACTION;
        DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR ('Error updating course and instructor revenue. Error: %s', 16, 1, @errorMessage);
    END CATCH
END;
GO

-- LN - Make Order 
IF OBJECT_ID('sp_LN_MakeOrder', 'P') IS NOT NULL
    DROP PROCEDURE [sp_LN_MakeOrder]
GO

CREATE PROCEDURE sp_LN_MakeOrder
    @learnerId NVARCHAR(128),
    @paymentCardNumber VARCHAR(16),
    @couponCode VARCHAR(20) = NULL,
    @dateCreated DATETIME = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY

        -- Declare variables
        DECLARE @discountPercent DECIMAL(5, 2) = 0;
        DECLARE @totalAmount DECIMAL(18, 2) = 0;
        DECLARE @totalAmountAfterDiscount DECIMAL(18, 2) = 0;
        DECLARE @newOrderId INT;
        DECLARE @courseId INT;
        DECLARE @coursePrice DECIMAL(18, 2);
        DECLARE @couponQuantity INT;
        DECLARE @startDate DATETIME;
		DECLARE @orderDetailId INT = 0;
        
        -- Compute total amount
        SELECT @totalAmount = SUM(c.price)
        FROM [cartDetail] cd
        JOIN [course] c ON cd.courseId = c.id
        WHERE cd.learnerId = @learnerId;

		IF @totalAmount IS NULL
        BEGIN
            RAISERROR ('Cart is empty. No items to process.', 16, 1);
            IF @@trancount > 0 ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Check discount percent
        IF @couponCode IS NOT NULL
        BEGIN
            SELECT @discountPercent = discountPercent, @couponQuantity = quantity,  @startDate = startDate
            FROM [coupon]
            WHERE code = @couponCode;   
            IF @startDate > GETDATE()
            BEGIN
                RAISERROR ('The coupon is not available yet.', 16, 1);
                IF @@trancount > 0 ROLLBACK TRANSACTION;
                RETURN;
            END
            IF @couponQuantity > 0
            BEGIN
                UPDATE [coupon] SET quantity = quantity - 1 WHERE code = @couponCode
            END
            ELSE 
            BEGIN
                RAISERROR ('The coupon is out of quantity.', 16, 1);
                IF @@trancount > 0 ROLLBACK TRANSACTION;
                RETURN;
            RETURN;
            END

        END
        
        SET @totalAmountAfterDiscount = @totalAmount / 100 * (100 - @discountPercent);
		
        SELECT @newOrderId =  ISNULL(MAX(id), 0) FROM [order];
		SET @newOrderId = @newOrderId + 1;
        IF @DateCreated IS NULL
			SET @DateCreated = GETDATE();

        INSERT INTO [order] (id, learnerId, total, paymentCardNumber, couponCode, dateCreated)
        VALUES (@newOrderId, @learnerId, @totalAmountAfterDiscount, @paymentCardNumber, @couponCode, @dateCreated);

        -- Insert into order details and delete from cart details
        DECLARE cart_cursor CURSOR LOCAL FOR
        SELECT courseId
        FROM [cartDetail]
        WHERE learnerId = @learnerId;

        OPEN cart_cursor;
        FETCH NEXT FROM cart_cursor INTO @courseId;
		
        WHILE @@FETCH_STATUS = 0
        BEGIN
			SET @orderDetailId = @orderDetailId + 1;
            -- Get the course price
            SELECT @coursePrice = price 
            FROM [course] 
            WHERE id = @courseId;

            -- Insert into orderDetails
            INSERT INTO [orderDetail] (id, orderId, learnerId, courseId, coursePrice)
            VALUES (@orderDetailId, @newOrderId, @learnerId, @courseId, @coursePrice);
            
            -- Enroll course
            INSERT INTO [learnerEnrollCourse] (courseId, learnerId, learnerScore, completionPercentInCourse)
            SELECT @courseId, @learnerId, 0, 0;

            -- Participate section
            INSERT INTO [learnerParticipateSection] (learnerId, courseId, sectionId, completionPercentSection)
            SELECT @learnerId, @courseId, s.id, 0
            FROM [section] s
            WHERE s.courseId = @courseId;
            
            -- Participate lesson
            INSERT INTO [learnerParticipateLesson] (learnerId, courseId, sectionId, lessonId, isCompletedLesson)
            SELECT @learnerId, @courseId, s.id, l.id, 0
            FROM [section] s
            JOIN [lesson] l ON s.id = l.sectionId AND s.courseId = l.courseId
            WHERE s.courseId = @courseId;
            
            -- Participate exercise
            INSERT INTO [learnerDoExercise] (learnerId, courseId, sectionId, lessonId, learnerScore)
            SELECT @learnerId, @courseId, s.id, e.id, NULL
            FROM [section] s
            JOIN [exercise] e ON s.id = e.sectionId AND s.courseId = e.courseId
            WHERE s.courseId = @courseId;

            -- Update course numberOf learner
			UPDATE [course] SET numberOfLearners = numberOfLearners + 1 WHERE course.id = @courseId
            
            -- Delete from cartDetails
            DELETE FROM [cartDetail]
            WHERE learnerId = @learnerId AND courseId = @courseId;

            -- Update course total revenue, course revenue by month, instructor revenue by month
            SET @coursePrice = @coursePrice / 100 * (100 - @discountPercent);
            EXEC [sp_UpdateCourseRevenueAndInstructorRevenue] @courseId = @courseId, @amount = @coursePrice, @date = @dateCreated;

            FETCH NEXT FROM cart_cursor INTO @courseId;
        END
        
        CLOSE cart_cursor;
        DEALLOCATE cart_cursor;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@trancount > 0 ROLLBACK TRANSACTION;
        DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR ('Cannot complete the order. Error: %s', 16, 1, @errorMessage);
    END CATCH
END;
GO

-- LN - View Orders
IF OBJECT_ID('sp_LN_ViewOrders', 'P') IS NOT NULL
    DROP PROCEDURE [sp_LN_ViewOrders]
GO

CREATE PROCEDURE sp_LN_ViewOrders
    @learnerId NVARCHAR(128)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        
         SELECT
            u.id AS learnerId,
            u.name,
            (
                SELECT
                    o.id,
                    o.dateCreated,
                    o.total,
                    o.paymentCardNumber AS paymentCardNumber,
                    o.couponCode AS couponCode,
                    c.discountPercent AS discountPercent
                FROM
                    [order] o
                LEFT JOIN
                    [coupon] c ON o.couponCode = c.code
                WHERE
                    o.learnerId = u.id
                ORDER BY
                    o.dateCreated DESC
                FOR JSON PATH
            ) AS orders
        FROM
            [user] u
        WHERE
            u.id = @learnerId
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@trancount > 0 ROLLBACK TRANSACTION;
        DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR ('Cannot retrieve orders. Error: %s', 16, 1, @errorMessage);
    END CATCH
END;
GO

-- LN - View An Order's Details 
IF OBJECT_ID('sp_LN_ViewOrderDetails', 'P') IS NOT NULL
    DROP PROCEDURE [sp_LN_ViewOrderDetails]
GO

CREATE PROCEDURE sp_LN_ViewOrderDetails
    @learnerId NVARCHAR(128),
    @orderId INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        
        SELECT
            o.id AS orderId,
            o.learnerId,
            u.name AS learnerName,
            o.dateCreated,
            o.total,
            o.paymentCardNumber,
            o.couponCode,
            c.discountPercent,
            (
                SELECT
                    od.courseId,
                    co.title AS courseTitle,
                    od.coursePrice
                FROM
                    [orderDetail] od
                JOIN
                    [course] co ON od.courseId = co.id
                WHERE
                    od.orderId = o.id 
					AND o.learnerId = @learnerId
                FOR JSON PATH
            ) AS orderDetails
        FROM
            [order] o
        JOIN
            [user] u ON o.learnerId = u.id
        LEFT JOIN
            [coupon] c ON o.couponCode = c.code
        WHERE
            o.learnerId = @learnerId
            AND o.id = @orderId
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@trancount > 0 ROLLBACK TRANSACTION;
        DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR ('Cannot retrieve order details. Error: %s', 16, 1, @errorMessage);
    END CATCH
END;
GO

-- LN - Unenroll 
IF OBJECT_ID('sp_LN_UnenrollLearnerFromCourse', 'P') IS NOT NULL
    DROP PROCEDURE [sp_LN_UnenrollLearnerFromCourse]
GO

CREATE PROCEDURE sp_LN_UnenrollLearnerFromCourse
    @learnerId NVARCHAR(128),
    @courseId INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        -- del from learnerEnrollCourse
        DELETE FROM [learnerEnrollCourse]
        WHERE courseId = @courseId
          AND learnerId = @learnerId;

        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR ('No enrollment record found for the given course and learner.', 16, 1);
            IF @@trancount > 0 ROLLBACK TRANSACTION;
            RETURN;
        END
        -- del from learnerAnswerQuestion
        DELETE FROM [learnerAnswerQuestion]
        WHERE courseId = @courseId
          AND learnerId = @learnerId;

        -- del from learnerDoExercise
        DELETE FROM [learnerDoExercise]
        WHERE courseId = @courseId
          AND learnerId = @learnerId;

        -- del from learnerParticipateLesson
        DELETE FROM [learnerParticipateLesson]
        WHERE courseId = @courseId
          AND learnerId = @learnerId;

        -- del from learnerParticipateSection
        DELETE FROM [learnerParticipateSection]
        WHERE courseId = @courseId
          AND learnerId = @learnerId;
          
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@trancount > 0 ROLLBACK TRANSACTION;
        DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR ('Cannot unenroll the learner from the course. Error: %s', 16, 1, @errorMessage);
    END CATCH
END;
GO


-- LN - Complete A Lesson 
IF OBJECT_ID('sp_LN_CompleteLesson', 'P') IS NOT NULL
    DROP PROCEDURE [sp_LN_CompleteLesson]
GO

CREATE PROCEDURE sp_LN_CompleteLesson
    @learnerId NVARCHAR(128),
    @courseId INT,
    @sectionId INT,
    @lessonId INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        -- update learnerParticipateLesson
        UPDATE learnerParticipateLesson
        SET isCompletedLesson = 1
        WHERE learnerId = @learnerId AND courseId = @courseId AND sectionId = @sectionId AND lessonId = @lessonId;

        -- update learnerParticipateSection
        DECLARE @totalLessonsInSection INT;
        DECLARE @completedLessonsInSection INT;
        DECLARE @completedExercisesInSection INT;
        DECLARE @newSectionCompletionPercent DECIMAL(5, 2);

        SELECT @totalLessonsInSection = COUNT(*)
        FROM lesson
        WHERE sectionId = @sectionId AND courseId = @courseId;

        SELECT @completedLessonsInSection = COUNT(*)
        FROM learnerParticipateLesson
        WHERE learnerId = @learnerId AND sectionId = @sectionId AND courseId = @courseId AND isCompletedLesson = 1;

        SELECT @completedExercisesInSection = COUNT(*)
        FROM learnerDoExercise
        WHERE learnerId = @learnerId AND courseId = @courseId AND sectionId = @sectionId AND learnerScore IS NOT NULL;

        SET @newSectionCompletionPercent = CAST((@completedLessonsInSection + @completedExercisesInSection) AS DECIMAL(5, 2)) / @totalLessonsInSection * 100;

        UPDATE learnerParticipateSection
        SET completionPercentSection = @newSectionCompletionPercent
        WHERE learnerId = @learnerId AND courseId = @courseId AND sectionId = @sectionId;

        -- update learnerEnrollCourse
        DECLARE @totalSectionsInCourse INT;
        DECLARE @totalCompletionPercentSections DECIMAL(5, 2);
        DECLARE @newCourseCompletionPercent DECIMAL(5, 2);

        SELECT @totalSectionsInCourse = COUNT(*)
        FROM section
        WHERE courseId = @courseId;

        SELECT @totalCompletionPercentSections = SUM(completionPercentSection)
        FROM learnerParticipateSection
        WHERE learnerId = @learnerId AND courseId = @courseId;

        SET @newCourseCompletionPercent = @totalCompletionPercentSections / @totalSectionsInCourse;

        UPDATE learnerEnrollCourse
        SET completionPercentInCourse = @newCourseCompletionPercent
        WHERE learnerId = @learnerId AND courseId = @courseId;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        
        IF @@trancount > 0 ROLLBACK TRANSACTION;
        DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR ('Error occurred while completing the lesson: %s', 16, 1, @errorMessage);
    END CATCH
END;
GO

-- LN - View Test 
IF OBJECT_ID('sp_LN_ViewTest', 'P') IS NOT NULL
    DROP PROCEDURE [sp_LN_ViewTest]
GO
CREATE PROCEDURE sp_LN_ViewTest
    @courseId INT,
    @sectionId INT,
    @exerciseId INT
AS
BEGIN
    
    IF NOT EXISTS (
        SELECT 1
        FROM exercise
        WHERE id = @exerciseId AND sectionId = @sectionId AND courseId = @courseId
    )
    BEGIN
        RAISERROR ('Exercise not found.', 16, 1);
        RETURN;
    END

    DECLARE @lessonTitle NVARCHAR(256);
    DECLARE @lessonLearnTime DECIMAL(5, 2);

    SELECT @lessonTitle = l.title,
           @lessonLearnTime = l.learnTime
    FROM lesson l
    WHERE l.id = @exerciseId AND l.sectionId = @sectionId AND l.courseId = @courseId;

    SELECT q.id AS QuestionId, 
           q.question AS QuestionText,
           qa.id AS AnswerId,
           qa.questionAnswers AS AnswerText
    INTO #QuestionsAndAnswers
    FROM question q
    LEFT JOIN questionAnswer qa
      ON q.id = qa.questionId AND q.exerciseId = qa.exerciseId AND q.sectionId = qa.sectionId AND q.courseId = qa.courseId
    WHERE q.exerciseId = @exerciseId 
      AND q.sectionId = @sectionId 
      AND q.courseId = @courseId;

    -- construct the JSON result
    SELECT 
        @lessonTitle AS title,
        @lessonLearnTime AS learnTime,
        (
           SELECT 
                QuestionId,
                QuestionText,
                (
                    SELECT 
                        AnswerId,
                        AnswerText
                    FROM #QuestionsAndAnswers AS qa
                    WHERE qa.QuestionId = q.QuestionId
                    FOR JSON PATH
                ) AS Answers
            FROM #QuestionsAndAnswers AS q
            GROUP BY QuestionId, QuestionText
            FOR JSON PATH
        ) AS Questions
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

    DROP TABLE #QuestionsAndAnswers;
END;
GO

-- LN -Take The Test 
IF OBJECT_ID('sp_LN_AddLearnerAnswersOfExercise', 'P') IS NOT NULL
    DROP PROCEDURE [sp_LN_AddLearnerAnswersOfExercise]
GO

CREATE PROCEDURE sp_LN_AddLearnerAnswersOfExercise
    @learnerId NVARCHAR(128),
    @courseId INT,
    @sectionId INT,
    @exerciseId INT,
    @learnerAnswers NVARCHAR(MAX) -- Format: "questionId,learnerAnswer|questionId,learnerAnswer|..."
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
       
        DECLARE @AnswerTable TABLE
        (
            questionId INT,
            learnerAnswer INT
        );

        INSERT INTO @AnswerTable (questionId, learnerAnswer)
        SELECT 
            CAST(SUBSTRING(value, 1, CHARINDEX(',', value) - 1) AS INT) AS questionId,
            CAST(SUBSTRING(value, CHARINDEX(',', value) + 1, LEN(value)) AS INT) AS learnerAnswer
        FROM STRING_SPLIT(@learnerAnswers, '|')
        WHERE value LIKE '%,%';

        -- insert or update answers
        MERGE learnerAnswerQuestion AS laq
		USING (SELECT @learnerId, questionId, @exerciseId, @sectionId, @courseId, learnerAnswer FROM @AnswerTable) AS ant(learnerId, questionId, exerciseId, sectionId, courseId, learnerAnswer)
		ON laq.learnerId = ant.learnerId AND laq.questionId = ant.questionId AND laq.exerciseId = ant.exerciseId AND laq.sectionId = ant.sectionId AND laq.courseId = ant.courseId
		WHEN MATCHED THEN
			UPDATE SET learnerAnswer = ant.learnerAnswer
		WHEN NOT MATCHED THEN
			INSERT (learnerId, questionId, exerciseId, sectionId, courseId, learnerAnswer)
			VALUES (ant.learnerId, ant.questionId, ant.exerciseId, ant.sectionId, ant.courseId, ant.learnerAnswer);

        -- calculate score
        DECLARE @totalQuestions INT;
        DECLARE @correctAnswers INT;
        DECLARE @learnerScore DECIMAL(5, 2);

        SELECT @totalQuestions = COUNT(*)
        FROM question
        WHERE courseId = @courseId AND sectionId = @sectionId AND exerciseId = @exerciseId;

        SELECT @correctAnswers = COUNT(*)
        FROM @AnswerTable a
        JOIN questionAnswer qa
            ON a.questionId = qa.questionId 
            AND a.learnerAnswer = qa.id
        WHERE qa.isCorrect = 1
        AND qa.exerciseId = @exerciseId
        AND qa.sectionId = @sectionId
        AND qa.courseId = @courseId;

        IF @totalQuestions > 0
        BEGIN
            SET @learnerScore = (@correctAnswers * 10.0) / @totalQuestions;
        END
        ELSE
        BEGIN
            SET @learnerScore = 0;
        END

        -- update score to learnerDoExercise
        UPDATE learnerDoExercise
        SET learnerScore = @learnerScore
        WHERE learnerId = @learnerId AND lessonId = @exerciseId AND sectionId = @sectionId AND courseId = @courseId;

        -- update lesson, section, and course completion
        EXEC sp_LN_CompleteLesson
			@courseId = @courseId,
			@learnerId = @learnerId, 
			@sectionId = @sectionId, 
			@lessonId = @exerciseId;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@trancount > 0 ROLLBACK TRANSACTION;
        DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR ('Cannot complete the operation. Error: %s', 16, 1, @errorMessage);
    END CATCH
END;
GO

-- LN - View Test With Results 
IF OBJECT_ID('sp_LN_GetLearnerAnswersOfExercise', 'P') IS NOT NULL
    DROP PROCEDURE [sp_LN_GetLearnerAnswersOfExercise]
GO

CREATE PROCEDURE sp_LN_GetLearnerAnswersOfExercise
    @learnerId NVARCHAR(128),
    @courseId INT,
    @sectionId INT,
    @exerciseId INT
AS
BEGIN
    BEGIN TRY
        -- get score
        DECLARE @learnerScore DECIMAL(5, 2);

        SELECT @learnerScore = learnerScore
        FROM learnerDoExercise
        WHERE learnerId = @learnerId AND lessonId = @exerciseId AND sectionId = @sectionId AND courseId = @courseId;

        -- get test title 
        DECLARE @testTitle NVARCHAR(256);

        SELECT @testTitle = l.title
        FROM lesson l
        WHERE l.id = @exerciseId AND l.sectionId = @sectionId AND l.courseId = @courseId;

        -- get question with correct answer and learner's answer 
        SELECT 
            q.id AS questionId,
            q.question,
            qa.questionAnswers AS correctAnswer,
            laq.learnerAnswer
        FROM 
            question q
        JOIN 
            questionAnswer qa 
            ON q.id = qa.questionId 
            AND q.exerciseId = qa.exerciseId AND q.exerciseId = @exerciseId
            AND q.sectionId = qa.sectionId AND q.sectionId = @sectionId
            AND q.courseId = qa.courseId AND q.courseId = @courseId
            AND qa.isCorrect = 1 -- Get the correct answer
        LEFT JOIN 
            learnerAnswerQuestion laq 
            ON laq.questionId = q.id
            AND laq.exerciseId = q.exerciseId
			AND laq.sectionId = q.sectionId
			AND laq.courseId = q.courseId
            AND laq.learnerId = @learnerId
        WHERE 
            q.exerciseId = @exerciseId
        FOR JSON PATH, INCLUDE_NULL_VALUES, ROOT('results');

        SELECT 
            @testTitle AS title,
            @learnerScore AS score
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

    END TRY
    BEGIN CATCH
        IF @@trancount > 0 ROLLBACK TRANSACTION;
        DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR ('Cannot retrieve the results. Error: %s', 16, 1, @errorMessage);
    END CATCH
END;
GO

-- LN - Add Review 
IF OBJECT_ID('sp_LN_AddLearnerReview', 'P') IS NOT NULL
    DROP PROCEDURE sp_LN_AddLearnerReview;
GO

CREATE PROCEDURE sp_LN_AddLearnerReview
    @learnerId NVARCHAR(128),
    @courseId INT,
    @review NVARCHAR(MAX),
    @rating DECIMAL(3, 2)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        
        IF NOT EXISTS (
            SELECT 1 
            FROM learnerEnrollCourse 
            WHERE learnerId = @learnerId AND courseId = @courseId
        )
        BEGIN
            RAISERROR('Learner is not enrolled in this course.', 16, 1);
            IF @@trancount > 0 ROLLBACK TRANSACTION;
            RETURN;
        END

        -- learner complete percentage must be over 25% to leave a review 
        DECLARE @completionPercent DECIMAL(5, 2);
        SELECT @completionPercent = completionPercentInCourse
        FROM learnerEnrollCourse 
        WHERE learnerId = @learnerId AND courseId = @courseId;

        IF @completionPercent <= 25.00
        BEGIN
            RAISERROR('Learner has not completed enough of the course to leave a review. Must complete at least 25%%.', 16, 1);
            IF @@trancount > 0 ROLLBACK TRANSACTION;
            RETURN;
        END

        INSERT INTO learnerReviewCourse (courseId, learnerId, review, rating)
        VALUES (@courseId, @learnerId, @review, @rating);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@trancount > 0 ROLLBACK TRANSACTION;
        DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR('An error occurred while adding the review: %s', 16, 1, @errorMessage);
    END CATCH
END;
GO

-- LN - GetEnrolledCourse
IF OBJECT_ID('sp_LN_GetEnrolledCourse', 'P') IS NOT NULL
    DROP PROCEDURE sp_LN_GetEnrolledCourse;
GO

CREATE PROCEDURE sp_LN_GetEnrolledCourse
    @learnerId NVARCHAR(128)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        SELECT
            c.id,
            c.title,
            c.image
        FROM
            course c
        JOIN
            learnerEnrollCourse lec ON c.id = lec.courseId
        WHERE
            lec.learnerId = @learnerId
        FOR JSON PATH, INCLUDE_NULL_VALUES;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@trancount > 0 ROLLBACK TRANSACTION;
        DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR('An error occurred while get the enrolled courses: %s', 16, 1, @errorMessage);
    END CATCH
END;
GO

Use LMS 
GO

-- ADMIN
-- Thay đổi state khóa học 
IF OBJECT_ID('sp_AD_INS_ChangeStateOfCourse', 'P') IS NOT NULL
    DROP PROCEDURE [sp_AD_INS_ChangeStateOfCourse]
GO
CREATE PROCEDURE sp_AD_INS_ChangeStateOfCourse
	@adminId NVARCHAR(128) = NULL,
	@courseId INT,
	@vipState VARCHAR(15),
	@responseText NVARCHAR(MAX) = NULL
AS
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY
		-- phê duyệt khóa học (pendingReview --> public)
		IF (@vipState = 'public')
		BEGIN
            UPDATE course
            SET state = @vipState
            WHERE id = @courseId;
        END

		-- có 2 trường hợp
		-- từ chối phê duyệt khóa học (pendingReview --> draft) + responseText
		-- ẩn khóa học (public --> draft) + responseText
		ELSE IF (@vipState = 'draft' 
				AND @responseText IS NOT NULL AND @adminId IS NOT NULL)
		BEGIN
			
			UPDATE course
			SET state = @vipState
			WHERE id = @courseId;

			INSERT INTO adminResponse(adminId, courseId, responseText, dateResponse)
			VALUES (@adminId, @courseId, @responseText, GETDATE());

        END

		-- giảng viên gửi yêu cầu đc đăng khóa học
		-- draft --> pendingReview
		ELSE IF (@vipState = 'pendingReview'  
				AND @responseText IS NULL AND @adminId IS NULL)
        BEGIN
            UPDATE course
            SET state = @vipState
            WHERE id = @courseId;
        END


		-- trả về lỗi nếu không thuộc 1 trong 2 trường hợp trên
		ELSE
		BEGIN
			RAISERROR('Invalid vipState or missing responseText for pendingReview state.', 16, 1);
			IF @@trancount > 0 ROLLBACK TRANSACTION;
			RETURN;
		END

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@trancount > 0 ROLLBACK TRANSACTION;
		DECLARE @errorMessage NVARCHAR(4000);
		SET @errorMessage = ERROR_MESSAGE();
		RAISERROR ('Error changing state of course. Details: %s', 16, 1, @errorMessage);
	END CATCH
END
GO


-- Xem danh sách tất cả learner / admin / instructor 
IF OBJECT_ID('sp_AD_GetAllUsers', 'P') IS NOT NULL
    DROP PROCEDURE [sp_AD_GetAllUsers]
GO
CREATE PROCEDURE sp_AD_GetAllUsers
	@type CHAR(3) = NULL
AS
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY
		IF (@type = 'LN' OR @type = 'AD')
		BEGIN
			SELECT id, email, name, profilePhoto, role
			FROM [user] WHERE role = @type
			FOR JSON PATH;
		END

		ELSE IF (@type = 'INS')
		BEGIN
			SELECT U.id, U.email, U.name, U.profilePhoto, U.role, 
					INS.gender, INS.phone, INS.DOB, INS.address, INS.degrees,
					INS.scientificBackground, INS.vipState
			FROM [user] U JOIN instructor INS ON (U.id = INS.id)
			WHERE role = 'INS'
			FOR JSON PATH;
		END

		ELSE 
		BEGIN
			SELECT U.id, U.email, U.name, U.profilePhoto, U.role, 
					INS.gender, INS.phone, INS.DOB, INS.address, INS.degrees,
					INS.scientificBackground, INS.vipState
			FROM [user] U LEFT JOIN instructor INS ON (U.id = INS.id)
			FOR JSON PATH;
		END

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@trancount > 0 ROLLBACK TRANSACTION;
		DECLARE @errorMessage NVARCHAR(4000);
		SET @errorMessage = ERROR_MESSAGE();
		RAISERROR ('Error retrieving user information. Details: %s', 16, 1, @errorMessage);
	END CATCH
END
GO

-- Doanh thu hàng tháng của 1 giảng viên 
IF OBJECT_ID('sp_AD_INS_GetMonthlyRevenueOfAnInstructor', 'P') IS NOT NULL
    DROP PROCEDURE [sp_AD_INS_GetMonthlyRevenueOfAnInstructor]
GO
CREATE PROCEDURE sp_AD_INS_GetMonthlyRevenueOfAnInstructor
	@instructorId NVARCHAR(128),
    @duration INT
AS
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY

        DECLARE @currentDate DATE = GETDATE();

        DECLARE @currentYear INT = YEAR(@currentDate);
        DECLARE @currentMonth INT = MONTH(@currentDate);

        DECLARE @startYear INT = YEAR(DATEADD(MONTH, -@duration, @currentDate));
        DECLARE @startMonth INT = MONTH(DATEADD(MONTH, -@duration, @currentDate));
		
		SELECT year, month, revenue
        FROM instructorRevenueByMonth
        WHERE instructorId = @instructorId AND
				((year = @startYear AND month >= @startMonth) OR
				(year = @currentYear AND month <= @currentMonth) OR
				(year > @startYear AND year < @currentYear))
        ORDER BY year, month
		FOR JSON PATH;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@trancount > 0 ROLLBACK TRANSACTION;
		DECLARE @errorMessage NVARCHAR(4000);
		SET @errorMessage = ERROR_MESSAGE();
		RAISERROR ('Error retrieving monthly revenue for instructor. Details: %s', 16, 1, @errorMessage);
	END CATCH
END
GO

-- Doanh thu hàng năm của một giảng viên 
IF OBJECT_ID('sp_AD_INS_GetAnnualRevenueOfAnInstructor', 'P') IS NOT NULL
    DROP PROCEDURE [sp_AD_INS_GetAnnualRevenueOfAnInstructor]
GO
CREATE PROCEDURE sp_AD_INS_GetAnnualRevenueOfAnInstructor
    @instructorId NVARCHAR(128),
	@duration INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @currentYear INT = YEAR(GETDATE());
        DECLARE @startYear INT = @currentYear - @duration + 1;

        SELECT year, SUM(revenue) AS annualRevenue
        FROM instructorRevenueByMonth
        WHERE instructorId = @instructorId AND year >= @startYear
        GROUP BY year
        ORDER BY year
		FOR JSON PATH;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@trancount > 0 ROLLBACK TRANSACTION;
        DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR ('Error retrieving annual revenue for instructor. Details: %s', 16, 1, @errorMessage);
    END CATCH
END
GO

-------------------------------------------------------------------
-- INSTRUCTOR
-- Tạo tài khoản giảng viên

IF OBJECT_ID('sp_INS_CreateInstructorAccount', 'P') IS NOT NULL
    DROP PROCEDURE [sp_INS_CreateInstructorAccount]
GO
CREATE PROCEDURE sp_INS_CreateInstructorAccount
	@userId NVARCHAR(128),
	@email VARCHAR(256),
	@name NVARCHAR(128),
	@password NVARCHAR(128),
	@profilePhoto NVARCHAR(256),
	------
	@gender CHAR(1),
	@phone VARCHAR(11),
	@dob DATE,
	@address NVARCHAR(256),
	@degrees NVARCHAR(512),
	@workplace NVARCHAR(256),
	@scientificBackground NVARCHAR(512)
AS
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY
		INSERT INTO [user] (id, email, name, password, profilePhoto, role)
		VALUES (@userId, @email, @name, @password, @profilePhoto, 'INS');

		INSERT INTO instructor(id, gender, phone, DOB, address, degrees, workplace, scientificBackground)
		VALUES (@userId, @gender, @phone, @dob, @address, @degrees, @workplace, @scientificBackground);

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@trancount > 0 ROLLBACK TRANSACTION;
		DECLARE @errorMessage NVARCHAR(4000);
		SET @errorMessage = ERROR_MESSAGE();
		RAISERROR ('Cannot insert user, course member, or instructor. Error: %s', 16, 1, @errorMessage);
	END CATCH
END
GO

-- Xem danh sách tất cả khóa học của mình
IF OBJECT_ID('sp_INS_GetOwnCourses', 'P') IS NOT NULL
    DROP PROCEDURE [sp_INS_GetOwnCourses]
GO
CREATE PROCEDURE sp_INS_GetOwnCourses
	@userId NVARCHAR(128)
AS
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY
		SELECT C.id, C.title, C.subTitle, C.image, C.state, C.numberOfLearners, 
			C.numberOfLectures, C.totalTime, C.averageRating, C.price, C.lastUpdateTime,
			(SELECT SC.name FROM subCategory SC WHERE SC.parentCategoryId = C.categoryId AND SC.id = C.subCategoryId) as subCategory, 
			(SELECT PC.name FROM category PC WHERE PC.id = C.categoryId) as category,
			T.instructors, T.instructorsId
		FROM course C 
		JOIN (SELECT IOC.courseId, STRING_AGG(U.name, ', ') AS instructors, 
					STRING_AGG(U.id, ', ') AS instructorsId
			FROM instructorOwnCourse IOC JOIN [user] U ON IOC.instructorId = U.id
			WHERE IOC.courseId IN 
				(SELECT courseId
				FROM instructorOwnCourse
				WHERE instructorId = @userId)
			GROUP BY IOC.courseId) AS T 
		ON C.id = T.courseId
		FOR JSON PATH;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@trancount > 0 ROLLBACK TRANSACTION;
		DECLARE @errorMessage NVARCHAR(4000);
		SET @errorMessage = ERROR_MESSAGE();
		RAISERROR ('Error retrieving courses for instructor. Details: %s', 16, 1, @errorMessage);
	END CATCH
END
GO

-- Xem các response của QTV thuộc 1 khóa học
IF OBJECT_ID('sp_INS_GetAdminResponseInCourse', 'P') IS NOT NULL
    DROP PROCEDURE [sp_INS_GetAdminResponseInCourse]
GO
CREATE PROCEDURE sp_INS_GetAdminResponseInCourse
	@courseId INT
AS
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY
		SELECT AR.adminId, U.name, AR.responseText, AR.dateResponse
		FROM adminResponse AR JOIN [user] U ON (AR.adminId = U.id)
		WHERE courseId = @courseId
		ORDER BY AR.dateResponse DESC
		FOR JSON PATH;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@trancount > 0 ROLLBACK TRANSACTION;
		DECLARE @errorMessage NVARCHAR(4000);
		SET @errorMessage = ERROR_MESSAGE();
		RAISERROR ('Error retrieving admin responses for course ID %d. Details: %s', 16, 1, @errorMessage);
	END CATCH
END
GO

-- Xem danh sách các học viên tham gia vào 1 khóa học của mình
IF OBJECT_ID('sp_INS_GetLearnersInCourse', 'P') IS NOT NULL
    DROP PROCEDURE [sp_INS_GetLearnersInCourse]
GO
CREATE PROCEDURE sp_INS_GetLearnersInCourse
	@courseId INT
AS
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY
		SELECT LER.learnerId, U.name
		FROM learnerEnrollCourse LER JOIN [user] U ON (LER.learnerId = U.id)
		WHERE LER.courseId = @courseId
		FOR JSON PATH;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@trancount > 0 ROLLBACK TRANSACTION;
		DECLARE @errorMessage NVARCHAR(4000);
		SET @errorMessage = ERROR_MESSAGE();
		RAISERROR ('Error retrieving admin responses for course ID %d. Details: %s', 16, 1, @errorMessage);
	END CATCH
END
GO

-- Xem top các thể loại hot nhất (số học viên cao và đánh giá cao)
IF OBJECT_ID('sp_INS_GetTopHotCategories', 'P') IS NOT NULL
    DROP PROCEDURE [sp_INS_GetTopHotCategories]
GO
CREATE PROCEDURE sp_INS_GetTopHotCategories
AS
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY
		SELECT TOP 25
				SC.id as subCategoryId, SC.name as subCategoryName, 
				C.id as categoryId, C.name as categoryName, 
				SC.numberOfLearners, SC.averageRating
		FROM vw_SubCategoryDetails SC JOIN category C ON (SC.parentCategoryId = C.id)
		ORDER BY SC.numberOfLearners DESC, SC.averageRating DESC
		FOR JSON PATH;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@trancount > 0 ROLLBACK TRANSACTION;
		DECLARE @errorMessage NVARCHAR(4000);
		SET @errorMessage = ERROR_MESSAGE();
		RAISERROR ('Error retrieving top hot categories. Details: %s', 16, 1, @errorMessage);
	END CATCH
END
GO

-- Gửi biểu mẫu thuế 
IF OBJECT_ID('sp_INS_SendTaxForm', 'P') IS NOT NULL
    DROP PROCEDURE [sp_INS_SendTaxForm]
GO
CREATE PROCEDURE sp_INS_SendTaxForm
    @submissionDate DATE,
    @fullName NVARCHAR(128),
    @address NVARCHAR(256),
    @phone VARCHAR(11),
    @taxCode VARCHAR(50),
    @identityNumber CHAR(12),
    @postCode CHAR(5),
    @vipInstructorId NVARCHAR(128)
AS
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY
		IF EXISTS (SELECT 1 FROM taxForm WHERE vipInstructorId = @vipInstructorId)
		BEGIN
			DELETE FROM taxForm WHERE vipInstructorId = @vipInstructorId;
		END

		INSERT INTO taxForm(submissionDate, fullName, address, phone, taxCode, identityNumber, postCode, vipInstructorId)
		VALUES (@submissionDate, @fullName, @address, @phone, @taxCode, @identityNumber, @postCode, @vipInstructorId);

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@trancount > 0 ROLLBACK TRANSACTION;
		DECLARE @errorMessage NVARCHAR(4000);
		SET @errorMessage = ERROR_MESSAGE();
		RAISERROR ('Error sending tax form. Details: %s', 16, 1, @errorMessage);
	END CATCH
END
GO


-- Đăng ký thông tin thẻ
IF OBJECT_ID('sp_INS_UpdateInstructorPaymentCard', 'P') IS NOT NULL
    DROP PROCEDURE [sp_INS_UpdateInstructorPaymentCard]
GO
CREATE PROCEDURE sp_INS_UpdateInstructorPaymentCard
    @instructorId NVARCHAR(128),
    @number VARCHAR(16),
    @type VARCHAR(6),
    @name NVARCHAR(128),
    @CVC CHAR(3),
    @expireDate DATE
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Kiểm tra trạng thái VIP của giảng viên
        IF (SELECT vipState FROM instructor WHERE id = @instructorId) <> 'vip'
        BEGIN
            RAISERROR('Instructor is not a VIP and cannot register a payment card.', 16, 1);
            IF @@trancount > 0 ROLLBACK TRANSACTION;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM paymentCard WHERE number = @number)
        BEGIN
            INSERT INTO paymentCard(number, type, name, CVC, expireDate)
            VALUES (@number, @type, @name, @CVC, @expireDate);
        END

        IF NOT EXISTS (SELECT 1 FROM vipInstructor WHERE id = @instructorId)
        BEGIN
            INSERT INTO vipInstructor(id, paymentCardNumber)
            VALUES (@instructorId, @number);
        END
        ELSE
        BEGIN
            UPDATE vipInstructor
            SET paymentCardNumber = @number
            WHERE id = @instructorId;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@trancount > 0 ROLLBACK TRANSACTION;
        DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR('Error updating instructor payment card. Details: %s', 16, 1, @errorMessage);
    END CATCH
END
GO


-------------------------------------------------------------------
-- TẠO KHÓA HỌC
-- Tạo course
IF OBJECT_ID('sp_INS_CreateCourse', 'P') IS NOT NULL
    DROP PROCEDURE [sp_INS_CreateCourse]
GO
CREATE PROCEDURE sp_INS_CreateCourse
	@instructorId1 NVARCHAR(128),
	@instructorId2 NVARCHAR(128) = NULL,
    @title NVARCHAR(256),
    @subTitle NVARCHAR(256),
    @description NVARCHAR(MAX),
    @image NVARCHAR(256),
    @video NVARCHAR(256),
    @subCategoryId INT,
    @categoryId INT,
	@language NVARCHAR(50),
    @price DECIMAL(18, 2) = NULL
AS
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY

		-- kiểm tra nếu instructorId1 tồn tại trong vipInstructor
		-- và nếu instructorId2 không NULL thì cũng phải tồn tại
		IF EXISTS (SELECT 1 FROM vipInstructor WHERE id = @instructorId1)
			AND (@instructorId2 IS NULL OR EXISTS (SELECT 1 FROM vipInstructor WHERE id = @instructorId2))
		BEGIN
			
			DECLARE @NewCourseId INT;
			
			INSERT INTO course (title, subTitle, description, image, video, subCategoryId, categoryId, language, price)
			VALUES (@title, @subTitle, @description, @image, @video, @subCategoryId, @categoryId, @language, @price);

			SET @NewCourseId = SCOPE_IDENTITY();
			SELECT @NewCourseId AS courseId
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

		END
		ELSE
		BEGIN
			RAISERROR('Both instructors must be VIP instructors.', 16, 1);
			IF @@trancount > 0 ROLLBACK TRANSACTION;
			RETURN;
		END

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@trancount > 0 ROLLBACK TRANSACTION;
		DECLARE @errorMessage NVARCHAR(4000);
		SET @errorMessage = ERROR_MESSAGE();
		RAISERROR ('Error creating course. Details: %s', 16, 1, @errorMessage);
	END CATCH
END
GO

-- Tạo Instructor Own Course
IF OBJECT_ID('sp_INS_CreateInstructorOwnCourse', 'P') IS NOT NULL
    DROP PROCEDURE [sp_INS_CreateInstructorOwnCourse]
GO
CREATE PROCEDURE sp_INS_CreateInstructorOwnCourse
    @courseId INT,
    @instructorId NVARCHAR(128),
    @percentageInCome DECIMAL(5, 2) = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @count INT;
        SELECT @count = COUNT(instructorId)
        FROM instructorOwnCourse
        WHERE courseId = @courseId;

        -- Nếu đã có 2 giảng viên thì báo lỗi
        IF @count = 2
        BEGIN
            RAISERROR('No more than 2 instructors can own the same course.', 16, 1);
            IF @@trancount > 0 ROLLBACK TRANSACTION;
            RETURN;
        END

        DECLARE @isPriced BIT;
        SET @isPriced = CASE WHEN (SELECT price FROM course WHERE id = @courseId) IS NOT NULL 
                             THEN 1 
                             ELSE 0 
                        END;

        -- Nếu khóa học thu tiền mà giảng viên sắp insert KHÔNG tồn tại trong vipInstructor
        IF (@isPriced = 1 AND 
            NOT EXISTS (SELECT 1 FROM vipInstructor WHERE id = @instructorId))
        BEGIN
            RAISERROR('The instructor must be a VIP instructor to own a paid course.', 16, 1);
            IF @@trancount > 0 ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Nếu khóa học KHÔNG thu tiền mà giảng viên sắp insert có percentage KHÁC 0
        IF (@isPriced = 0 AND @percentageInCome != 0)
        BEGIN
            RAISERROR('Non-paid courses must have 0% income for instructors.', 16, 1);
            IF @@trancount > 0 ROLLBACK TRANSACTION;
            RETURN;
        END

        DECLARE @totalPercent DECIMAL(5, 2);
        SET @totalPercent = (SELECT COALESCE(SUM(percentageInCome), 0) 
                             FROM instructorOwnCourse 
                             WHERE courseId = @courseId);

        -- Tổng percentage <= 100
        IF (@totalPercent + ISNULL(@percentageInCome, 0)) > 100
        BEGIN
            RAISERROR('Total income percentage cannot exceed 100%.', 16, 1);
            IF @@trancount > 0 ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Thỏa hết thì thêm giảng viên vào
        IF (@isPriced = 0)
        BEGIN
            SET @percentageInCome = 0;
        END

        INSERT INTO instructorOwnCourse(courseId, instructorId, percentageInCome)
        VALUES (@courseId, @instructorId, @percentageInCome);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@trancount > 0 ROLLBACK TRANSACTION;
        DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR ('Error creating instructor-own-course record. Details: %s', 16, 1, @errorMessage);
    END CATCH
END
GO

-- Tạo Course Requirement
IF OBJECT_ID('sp_INS_CreateCourseRequirement', 'P') IS NOT NULL
    DROP PROCEDURE [sp_INS_CreateCourseRequirement]
GO
CREATE PROCEDURE sp_INS_CreateCourseRequirement
    @courseId INT,
    @requirement NVARCHAR(256)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO courseRequirements (courseId, requirement)
        VALUES (@courseId, @requirement);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@trancount > 0 ROLLBACK TRANSACTION;
        DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR ('Error adding course requirement. Details: %s', 16, 1, @errorMessage);
    END CATCH
END
GO

-- Tạo Course Objective
IF OBJECT_ID('sp_INS_CreateCourseObjective', 'P') IS NOT NULL
    DROP PROCEDURE [sp_INS_CreateCourseObjective]
GO
CREATE PROCEDURE sp_INS_CreateCourseObjective
    @courseId INT,
    @objective NVARCHAR(256)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO courseObjectives(courseId, objective)
        VALUES (@courseId, @objective);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@trancount > 0 ROLLBACK TRANSACTION;
        DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR ('Error adding course objective. Details: %s', 16, 1, @errorMessage);
    END CATCH
END
GO

-- Tạo section
IF OBJECT_ID('sp_INS_CreateSection', 'P') IS NOT NULL
    DROP PROCEDURE [sp_INS_CreateSection]
GO
CREATE PROCEDURE sp_INS_CreateSection
	@courseId INT,
    @title NVARCHAR(256)
AS
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY
		DECLARE @NewSectionId INT;

        SELECT @NewSectionId = ISNULL(MAX(id), 0) + 1
        FROM section
        WHERE courseId = @courseId;

		INSERT INTO section(id, courseId, title)
		VALUES (@NewSectionId, @courseId, @title);

		SELECT @NewSectionId as sectionId
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@trancount > 0 ROLLBACK TRANSACTION;
		DECLARE @errorMessage NVARCHAR(4000);
		SET @errorMessage = ERROR_MESSAGE();
		RAISERROR ('Error adding section. Details: %s', 16, 1, @errorMessage);
	END CATCH
END
GO

-- Tạo lesson
IF OBJECT_ID('sp_INS_CreateLesson', 'P') IS NOT NULL
    DROP PROCEDURE [sp_INS_CreateLesson]
GO
CREATE PROCEDURE sp_INS_CreateLesson
	@courseId INT,
	@sectionId INT,
    @title NVARCHAR(256),
	@learnTime DECIMAL(5, 2),
	@type VARCHAR(10)
AS
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY
		DECLARE @NewLessonId INT;

        SELECT @NewLessonId = ISNULL(MAX(id), 0) + 1
        FROM lesson
        WHERE courseId = @courseId AND sectionId = @sectionId;

		INSERT INTO lesson(id, courseId, sectionId, title, learnTime, type)
		VALUES (@NewLessonId, @courseId, @sectionId, @title, @learnTime, @type);

		SELECT @NewLessonId as lessonId
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@trancount > 0 ROLLBACK TRANSACTION;
		DECLARE @errorMessage NVARCHAR(4000);
		SET @errorMessage = ERROR_MESSAGE();
		RAISERROR ('Error adding lesson. Details: %s', 16, 1, @errorMessage);
	END CATCH
END
GO

-- Tạo lecture
IF OBJECT_ID('sp_INS_CreateLecture', 'P') IS NOT NULL
    DROP PROCEDURE [sp_INS_CreateLecture]
GO
CREATE PROCEDURE sp_INS_CreateLecture
	@courseId INT,
	@sectionId INT,
	@lessonId INT,
    @resource NVARCHAR(256)
AS
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY

		INSERT INTO lecture(courseId, sectionId, id, resource)
		VALUES (@courseId, @sectionId, @lessonId, @resource);

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@trancount > 0 ROLLBACK TRANSACTION;
		DECLARE @errorMessage NVARCHAR(4000);
		SET @errorMessage = ERROR_MESSAGE();
		RAISERROR ('Error adding lecture. Details: %s', 16, 1, @errorMessage);
	END CATCH
END
GO


-- Tạo question
IF OBJECT_ID('sp_INS_CreateQuestion', 'P') IS NOT NULL
    DROP PROCEDURE [sp_INS_CreateQuestion]
GO
CREATE PROCEDURE sp_INS_CreateQuestion
    @courseId INT,
	@sectionId INT,
    @exerciseId INT,
	@question NVARCHAR(2000)
AS
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY
		DECLARE @NewQuestionId INT;

        SELECT @NewQuestionId = ISNULL(MAX(id), 0) + 1
        FROM question
        WHERE courseId = @courseId AND sectionId = @sectionId AND exerciseId = @exerciseId;

		INSERT INTO question(id, courseId, sectionId, exerciseId, question)
		VALUES (@NewQuestionId, @courseId, @sectionId, @exerciseId, @question);

		SELECT @NewQuestionId as questionId
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@trancount > 0 ROLLBACK TRANSACTION;
		DECLARE @errorMessage NVARCHAR(4000);
		SET @errorMessage = ERROR_MESSAGE();
		RAISERROR ('Error adding question. Details: %s', 16, 1, @errorMessage);
	END CATCH
END
GO


-- Tạo question answer
IF OBJECT_ID('sp_INS_CreateQuestionAnswer', 'P') IS NOT NULL
    DROP PROCEDURE [sp_INS_CreateQuestionAnswer]
GO
CREATE PROCEDURE sp_INS_CreateQuestionAnswer
    @courseId INT,
	@sectionId INT,
    @exerciseId INT,
	@questionId INT,
	@questionAnswers NVARCHAR(2000),
	@isCorrect BIT
AS
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY
		
		INSERT INTO questionAnswer(courseId, sectionId, exerciseId, questionId, questionAnswers, isCorrect)
		VALUES (@courseId, @sectionId, @exerciseId, @questionId, @questionAnswers, @isCorrect);

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@trancount > 0 ROLLBACK TRANSACTION;
		DECLARE @errorMessage NVARCHAR(4000);
		SET @errorMessage = ERROR_MESSAGE();
		RAISERROR ('Error adding question answer. Details: %s', 16, 1, @errorMessage);
	END CATCH
END
GO


-- CẬP NHẬT KHÓA HỌC
-- Cập nhật Course
IF OBJECT_ID('sp_INS_UpdateCourse', 'P') IS NOT NULL
    DROP PROCEDURE [sp_INS_UpdateCourse]
GO
CREATE PROCEDURE sp_INS_UpdateCourse
    @courseId INT,
    @title NVARCHAR(256),
    @subTitle NVARCHAR(256),
    @description NVARCHAR(MAX),
    @image NVARCHAR(256),
    @video NVARCHAR(256),
    @subCategoryId INT,
    @categoryId INT,
    @language NVARCHAR(50),
    @price DECIMAL(18, 2) = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
		IF (@price IS NOT NULL)
        BEGIN
            DECLARE @countNonVIP INT;

            -- Đếm số giảng viên không phải VIP
            SELECT @countNonVIP = COUNT(*)
            FROM instructorOwnCourse ioc
            LEFT JOIN vipInstructor vi ON ioc.instructorId = vi.id
            WHERE ioc.courseId = @courseId AND vi.id IS NULL;

            -- Nếu có ít nhất 1 giảng viên không phải VIP, báo lỗi
            IF (@countNonVIP > 0)
            BEGIN
                RAISERROR ('All instructors for the course must be VIP if the course is priced.', 16, 1);
                IF @@trancount > 0 ROLLBACK TRANSACTION;
                RETURN;
            END
        END

        UPDATE course
        SET title = @title,
            subTitle = @subTitle,
            description = @description,
            image = @image,
            video = @video,
            subCategoryId = @subCategoryId,
            categoryId = @categoryId,
            language = @language,
            price = @price
        WHERE id = @courseId;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@trancount > 0 ROLLBACK TRANSACTION;
        DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR ('Error updating course. Details: %s', 16, 1, @errorMessage);
    END CATCH
END
GO


-- Cập nhật Course Requirement
IF OBJECT_ID('sp_INS_UpdateCourseRequirement', 'P') IS NOT NULL
    DROP PROCEDURE [sp_INS_UpdateCourseRequirement]
GO
CREATE PROCEDURE sp_INS_UpdateCourseRequirement
    @courseId INT,
	@requirementId INT,
    @requirement NVARCHAR(256)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        UPDATE courseRequirements
        SET requirement = @requirement
        WHERE courseId = @courseId AND requirementId = @requirementId;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@trancount > 0 ROLLBACK TRANSACTION;
        DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR ('Error updating course requirement. Details: %s', 16, 1, @errorMessage);
    END CATCH
END
GO


-- Cập nhật Course Objective
IF OBJECT_ID('sp_INS_UpdateCourseObjective', 'P') IS NOT NULL
    DROP PROCEDURE [sp_INS_UpdateCourseObjective]
GO
CREATE PROCEDURE sp_INS_UpdateCourseObjective
    @courseId INT,
	@objectiveId INT,
    @objective NVARCHAR(256)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
		UPDATE courseObjectives
        SET objective = @objective
        WHERE courseId = @courseId AND objectiveId = @objectiveId;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@trancount > 0 ROLLBACK TRANSACTION;
        DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR ('Error updating course objective. Details: %s', 16, 1, @errorMessage);
    END CATCH
END
GO


-- Cập nhật section
IF OBJECT_ID('sp_INS_UpdateSection', 'P') IS NOT NULL
    DROP PROCEDURE [sp_INS_UpdateSection]
GO
CREATE PROCEDURE sp_INS_UpdateSection
	@courseId INT,
	@sectionId INT,
    @title NVARCHAR(256)
AS
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY
		UPDATE section
        SET title = @title
        WHERE courseId = @courseId AND id = @sectionId;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@trancount > 0 ROLLBACK TRANSACTION;
		DECLARE @errorMessage NVARCHAR(4000);
		SET @errorMessage = ERROR_MESSAGE();
		RAISERROR ('Error updating section. Details: %s', 16, 1, @errorMessage);
	END CATCH
END
GO


-- Cập nhật lesson
IF OBJECT_ID('sp_INS_UpdateLesson', 'P') IS NOT NULL
    DROP PROCEDURE [sp_INS_UpdateLesson]
GO
CREATE PROCEDURE sp_INS_UpdateLesson
	@courseId INT,
	@sectionId INT,
	@lessonId INT,
    @title NVARCHAR(256),
	@learnTime DECIMAL(5, 2),
	@type VARCHAR(10)
AS
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY
		UPDATE lesson
        SET title = @title,
			learnTime = @learnTime
        WHERE courseId = @courseId AND sectionId = @sectionId AND id = @lessonId;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@trancount > 0 ROLLBACK TRANSACTION;
		DECLARE @errorMessage NVARCHAR(4000);
		SET @errorMessage = ERROR_MESSAGE();
		RAISERROR ('Error updating lesson. Details: %s', 16, 1, @errorMessage);
	END CATCH
END
GO


-- Cập nhật lecture
IF OBJECT_ID('sp_INS_UpdateLecture', 'P') IS NOT NULL
    DROP PROCEDURE [sp_INS_UpdateLecture]
GO
CREATE PROCEDURE sp_INS_UpdateLecture
	@courseId INT,
	@sectionId INT,
	@lessonId INT,
    @resource NVARCHAR(256)
AS
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY
		UPDATE lecture
        SET resource = @resource
        WHERE courseId = @courseId AND sectionId = @sectionId AND id = @lessonId;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@trancount > 0 ROLLBACK TRANSACTION;
		DECLARE @errorMessage NVARCHAR(4000);
		SET @errorMessage = ERROR_MESSAGE();
		RAISERROR ('Error updating lecture. Details: %s', 16, 1, @errorMessage);
	END CATCH
END
GO


-- Cập nhật question
IF OBJECT_ID('sp_INS_UpdateQuestion', 'P') IS NOT NULL
    DROP PROCEDURE [sp_INS_UpdateQuestion]
GO
CREATE PROCEDURE sp_INS_UpdateQuestion
    @courseId INT,
	@sectionId INT,
    @exerciseId INT,
	@questionId INT,
	@question NVARCHAR(2000)
AS
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY
		UPDATE question
        SET question = @question
        WHERE courseId = @courseId 
				AND sectionId = @sectionId
				AND exerciseId = @exerciseId 
				AND id = @questionId;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@trancount > 0 ROLLBACK TRANSACTION;
		DECLARE @errorMessage NVARCHAR(4000);
		SET @errorMessage = ERROR_MESSAGE();
		RAISERROR ('Error updating question. Details: %s', 16, 1, @errorMessage);
	END CATCH
END
GO


-- Cập nhật question answer
IF OBJECT_ID('sp_INS_UpdateQuestionAnswer', 'P') IS NOT NULL
    DROP PROCEDURE [sp_INS_UpdateQuestionAnswer]
GO
CREATE PROCEDURE sp_INS_UpdateQuestionAnswer
    @courseId INT,
	@sectionId INT,
    @exerciseId INT,
	@questionId INT,
	@questionAnswerId INT,
	@questionAnswers NVARCHAR(2000),
	@isCorrect BIT
AS
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY
		UPDATE questionAnswer 
        SET questionAnswers = @questionAnswers, isCorrect = @isCorrect
        WHERE courseId = @courseId 
				AND sectionId = @sectionId
				AND exerciseId = @exerciseId 
				AND questionId = @questionId
				AND id = @questionAnswerId;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@trancount > 0 ROLLBACK TRANSACTION;
		DECLARE @errorMessage NVARCHAR(4000);
		SET @errorMessage = ERROR_MESSAGE();
		RAISERROR ('Error updating question answer. Details: %s', 16, 1, @errorMessage);
	END CATCH
END
GO


-- XÓA CHI TIẾT TRONG KHÓA HỌC
-- Xóa Course Requirement
IF OBJECT_ID('sp_INS_DeleteCourseRequirement', 'P') IS NOT NULL
    DROP PROCEDURE [sp_INS_DeleteCourseRequirement]
GO
CREATE PROCEDURE sp_INS_DeleteCourseRequirement
    @courseId INT,
    @requirementId INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        DELETE FROM courseRequirements
        WHERE courseId = @courseId AND requirementId = @requirementId;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@trancount > 0 ROLLBACK TRANSACTION;
        DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR ('Error deleting course requirement. Details: %s', 16, 1, @errorMessage);
    END CATCH
END
GO


-- Xóa Course Objective
IF OBJECT_ID('sp_INS_DeleteCourseObjective', 'P') IS NOT NULL
    DROP PROCEDURE [sp_INS_DeleteCourseObjective]
GO
CREATE PROCEDURE sp_INS_DeleteCourseObjective
    @courseId INT,
	@objectiveId INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
		DELETE FROM courseObjectives
        WHERE courseId = @courseId AND objectiveId = @objectiveId;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@trancount > 0 ROLLBACK TRANSACTION;
        DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR ('Error deleting course objective. Details: %s', 16, 1, @errorMessage);
    END CATCH
END
GO


USE master
GO

USE LMS
GO

--1/ All Đăng nhập
IF OBJECT_ID('sp_All_UserLogin', 'P') IS NOT NULL
    DROP PROCEDURE sp_All_UserLogin
GO

CREATE PROCEDURE sp_All_UserLogin
    @id NVARCHAR(128),
    @password VARCHAR(128)
AS
BEGIN TRAN
    BEGIN TRY
        SET NOCOUNT ON;

        IF(NOT EXISTS(SELECT 1 FROM [user] WHERE id = @id and password = @password))
		BEGIN
			RAISERROR('Invalid user name or password', 16, 1);
			ROLLBACK TRAN
			RETURN
		END

		SELECT name, user, profilePhoto, role, password
		FROM [user]
		WHERE id = @id
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;


    END TRY
    BEGIN CATCH
        DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
        THROW 51000, @errorMessage, 1;
        RETURN
    END CATCH
COMMIT TRAN
GO

--2/ All Xem thông tin cá nhân
IF OBJECT_ID('sp_All_GetUserProfile', 'P') IS NOT NULL
    DROP PROCEDURE sp_All_GetUserProfile
GO

CREATE PROCEDURE sp_All_GetUserProfile
    @id NVARCHAR(128)
AS
BEGIN TRAN
	BEGIN TRY
		SET NOCOUNT ON;
		
		IF(NOT EXISTS(SELECT 1 FROM [user] WHERE id = @id))
		BEGIN
			RAISERROR('User does not exist', 16, 1);
			ROLLBACK TRAN
			RETURN
		END

		SELECT *
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

--3 All Xem thông tin, lý lịch một giảng viên
IF OBJECT_ID('sp_All_GetInstructorProfile', 'P') IS NOT NULL
    DROP PROCEDURE sp_All_GetInstructorProfile
GO

CREATE PROCEDURE sp_All_GetInstructorProfile
    @id NVARCHAR(128)
AS
BEGIN TRAN
	BEGIN TRY
		SET NOCOUNT ON;

		IF(NOT EXISTS(SELECT 1 FROM [instructor] WHERE id = @id))
		BEGIN
			RAISERROR('This instructor does not exist', 16, 1);
			ROLLBACK TRAN
			RETURN
		END

		SELECT u.id, email, name, profilePhoto, role, gender, phone, DOB, address, degrees, workplace, scientificBackground, vipState, totalRevenue
		FROM [user] u
		JOIN [instructor] i ON u.id = i.id
		WHERE i.id = @id
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

--4 Tìm kiếm và lọc danh sách khóa học
IF OBJECT_ID('sp_All_GetCourseByName', 'P') IS NOT NULL
    DROP PROCEDURE sp_All_GetCourseByName
GO

CREATE PROCEDURE sp_All_GetCourseByName
    @courseName NVARCHAR(256),
	@CourseState NVARCHAR(15)
AS
BEGIN TRAN
	BEGIN TRY
		SET NOCOUNT ON;

		SELECT c.id courseId, title, subTitle, image, numberOfLectures, totalTime, c.averageRating courseAverageRating,
			   subCategoryId, categoryId, s.name subCatgoryName, ca.name catgoryName, language, price, lastUpdateTime,
			   (	
					SELECT i.id instructorId,u.name instructorName 
					FROM [instructorOwnCourse] ioc
					JOIN [instructor] i ON ioc.instructorId = i.id
					JOIN [user] u ON u.id = i.id
					WHERE courseId = c.id
					FOR JSON PATH, INCLUDE_NULL_VALUES
				) AS instructorsOwnCourse
		FROM [course] c 
		JOIN [subCategory] s ON c.subCategoryId = s.id AND c.categoryId = s.parentCategoryId
		JOIN [category] ca ON ca.id = s.parentCategoryId
		WHERE (c.title LIKE '% ' + @courseName + ' %' 
               OR c.title LIKE @courseName + ' %'
               OR c.title LIKE '% ' + @courseName
               OR c.title = @courseName)
		AND (@CourseState IS NULL OR c.state = @CourseState) 
		ORDER  BY c.lastUpdateTime ASC
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

--5 Xem thông tin chi tiết của một khóa học
IF OBJECT_ID('sp_All_GetCourseById', 'P') IS NOT NULL
    DROP PROCEDURE sp_All_GetCourseById
GO

CREATE PROCEDURE sp_All_GetCourseById
    @courseId NVARCHAR(128)
AS
BEGIN TRAN
	BEGIN TRY
		SET NOCOUNT ON;

		IF(NOT EXISTS(SELECT 1 FROM [course] WHERE id = @courseId))
		BEGIN
			RAISERROR('This course does not exist', 16, 1);
			ROLLBACK TRAN
			RETURN
		END

		SELECT c.id courseId, c.title courseTitle, subTitle, description, image, video, state, numberOfLearners, numberOfLectures, totalTime, 
			c.averageRating courseAverageRating, subCategoryId, categoryId, c.totalRevenue courseTotalRevenue, language, price, lastUpdateTime, 
			s.name subCategoryName, ca.name categoryName,
			(	
				SELECT requirementId, requirement
				FROM [courseRequirements]
				WHERE courseId = c.id
				FOR JSON PATH, INCLUDE_NULL_VALUES
			) AS courseRequirements,
			(	
				SELECT objectiveId, objective
				FROM [courseObjectives]
				WHERE courseId = c.id
				FOR JSON PATH, INCLUDE_NULL_VALUES
			) AS courseObjectives, 
			(	
				SELECT intendedLearnerId, intendedLearner
				FROM [courseIntendedLearners]
				WHERE courseId = c.id
				FOR JSON PATH, INCLUDE_NULL_VALUES
			) AS courseIntendedLearners, 
			(	
				SELECT learnerId, u.name, u.profilePhoto, rating, review
				FROM [learnerReviewCourse]  lrc
				JOIN [learner] l ON lrc.learnerId = l.id
				JOIN [user] u ON u.id = l.id
				WHERE courseId = c.id
				FOR JSON PATH, INCLUDE_NULL_VALUES
			) AS learnerReviews,
			(	
				SELECT i.id instructorId,u.name instructorName 
				FROM [instructorOwnCourse] ioc
				JOIN [instructor] i ON ioc.instructorId = i.id
				JOIN [user] u ON u.id = i.id
				WHERE courseId = c.id
				FOR JSON PATH, INCLUDE_NULL_VALUES
			) AS instructorsOwnCourse, 
			(	
				SELECT id sectionId, title sectionTitle, learnTime sectionLearnTime,
					   (
							SELECT lec.id lectureId, less.title lectureTitle, less.learnTime lectureLearnTime, resource lectureResource
							FROM [lesson] less 
							JOIN [lecture] lec ON lec.id = less.id AND lec.sectionId = less.sectionId AND lec.courseId = less.courseId
							WHERE less.sectionId = se.id AND less.courseId = se.courseId
							FOR JSON PATH, INCLUDE_NULL_VALUES
					   ) AS lectures,
					   (
							SELECT ex.id exerciseId, less.title exerciseTitle, less.learnTime exerciseLearnTime,
								(
									SELECT id questionId, question,
										(
											SELECT id questionAnswerId, questionAnswers, isCorrect
											FROM [questionAnswer]
											WHERE questionId = que.id AND exerciseId = que.exerciseId AND sectionId = que.sectionId AND courseId = que.courseId
											FOR JSON PATH, INCLUDE_NULL_VALUES
										) AS questionAnswers
									FROM [question] que
									WHERE courseId = ex.courseId AND sectionId = ex.sectionId AND exerciseId = ex.id
									FOR JSON PATH, INCLUDE_NULL_VALUES
								) AS questions
							FROM [lesson] less 
							JOIN [exercise] ex ON ex.id = less.id AND ex.sectionId = less.sectionId AND ex.courseId = less.courseId
							WHERE less.sectionId = se.id AND less.courseId = se.courseId
							FOR JSON PATH, INCLUDE_NULL_VALUES
					   ) AS exercises
				FROM [section] se
				WHERE courseId = c.id
				FOR JSON PATH, INCLUDE_NULL_VALUES
			) AS sections
		FROM [course] c 
		LEFT JOIN [subCategory] s ON c.subCategoryId = s.id AND c.categoryId = s.parentCategoryId
		LEFT JOIN [category] ca ON ca.id = s.parentCategoryId
		WHERE c.id = @courseId
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

--6 Tìm kiếm khóa học theo danh mục
IF OBJECT_ID('sp_All_GetCourseByCategoryId', 'P') IS NOT NULL
    DROP PROCEDURE sp_All_GetCourseByCategoryId
GO

CREATE PROCEDURE sp_All_GetCourseByCategoryId
    @categoryId INT,
	@subcategoryId INT
AS
BEGIN TRAN
	BEGIN TRY
		SET NOCOUNT ON;

		SELECT c.id courseId, title, subTitle, image, video, numberOfLectures, totalTime, c.averageRating courseAverageRating,
			   subCategoryId, categoryId, c.totalRevenue courseTotalRevenue, language, price, lastUpdateTime, s.name subCategoryName, 
			   ca.name categoryName,
			   (	
					SELECT i.id instructorId,u.name instructorName 
					FROM [instructorOwnCourse] ioc
					JOIN [instructor] i ON ioc.instructorId = i.id
					JOIN [user] u ON u.id = i.id
					WHERE courseId = c.id
					FOR JSON PATH, INCLUDE_NULL_VALUES
				) AS instructorsOwnCourse
		FROM [course] c 
		JOIN [subCategory] s ON c.subCategoryId = s.id AND c.categoryId = s.parentCategoryId
		JOIN [category] ca ON ca.id = s.parentCategoryId
		WHERE s.id = @subcategoryId AND s.parentCategoryId = @categoryId
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

--7 Xem danh sách các mã giảm còn số lượng
IF OBJECT_ID('sp_All_GetCoupons', 'P') IS NOT NULL
    DROP PROCEDURE sp_All_GetCoupons
GO

CREATE PROCEDURE sp_All_GetCoupons
	@isAvailable BIT
AS
BEGIN TRAN
	BEGIN TRY
		SET NOCOUNT ON;
		IF @isAvailable IS NULL
		BEGIN
			SELECT *
			FROM [coupon]
			ORDER BY quantity DESC, startDate DESC
			FOR JSON PATH;
		END

		ELSE IF @isAvailable = 1
		BEGIN
			SELECT *
			FROM [coupon]
			WHERE quantity > 0
			ORDER BY quantity DESC, startDate DESC
			FOR JSON PATH;
		END

		ELSE
		BEGIN
			SELECT *
			FROM [coupon]
			WHERE quantity = 0
			ORDER BY startDate DESC
			FOR JSON PATH;
		END

	END TRY
	BEGIN CATCH
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN
GO

--8 Cập nhật tài khoản Admin / Student
IF OBJECT_ID('sp_All_UpdateUserInfo', 'P') IS NOT NULL
    DROP PROCEDURE sp_All_UpdateUserInfo
GO
	
CREATE PROCEDURE sp_All_UpdateUserInfo
	@userId NVARCHAR(128),
	@email VARCHAR(256),
    @name NVARCHAR(128),
    @password VARCHAR(128),
    @profilePhoto NVARCHAR(256)
AS
BEGIN TRAN
	BEGIN TRY
		SET NOCOUNT ON;
		IF(NOT EXISTS(SELECT 1 FROM [user] WHERE id = @userId and password = @password))
		BEGIN
			RAISERROR('Invalid user name or password', 16, 1);
			ROLLBACK TRAN
			RETURN
		END

		UPDATE [user]
		SET name = COALESCE(@name, name),
			email = COALESCE(@email, email),
			password = COALESCE(@password, password),
			profilePhoto = COALESCE(@profilePhoto, profilePhoto)
		WHERE id = @userId

	END TRY
	BEGIN CATCH
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN
GO

--9 Cập nhật tài khoản Instructor
IF OBJECT_ID('sp_All_UpdateInstructorInfo', 'P') IS NOT NULL
    DROP PROCEDURE sp_All_UpdateInstructorInfo
GO
	
CREATE PROCEDURE sp_All_UpdateInstructorInfo
	@instructorId NVARCHAR(128),
	@password VARCHAR(128),
	@gender CHAR(1),
    @phone VARCHAR(11),
    @DOB DATE,
    @address NVARCHAR(256),
    @degrees NVARCHAR(512),
    @workplace NVARCHAR(256),
    @scientificBackground NVARCHAR(512)
AS
BEGIN TRAN
	BEGIN TRY
		SET NOCOUNT ON;
		IF(NOT EXISTS(SELECT 1 FROM [user] WHERE id = @instructorId and password = @password))
		BEGIN
			RAISERROR('Invalid user name or password', 16, 1);
			ROLLBACK TRAN
			RETURN
		END

		UPDATE [instructor]
		SET gender = COALESCE(@gender, gender),
			phone = COALESCE(@phone, phone),
			DOB = COALESCE(@DOB, DOB),
			address = COALESCE(@address, address),
			degrees = COALESCE(@degrees, degrees),
			workplace = COALESCE(@workplace, workplace),
			scientificBackground = COALESCE(@scientificBackground, scientificBackground)
		WHERE id = @instructorId
	END TRY
	BEGIN CATCH
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN
GO