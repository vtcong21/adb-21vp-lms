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
    @amount DECIMAL(18, 2)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY

        DECLARE @currentDate DATE;
        SET @currentDate = CONVERT(DATE, GETDATE());

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
    @couponCode VARCHAR(20) = NULL
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
		
        SELECT @newOrderId =  ISNULL(MAX(id), 0) FROM [order] WHERE learnerId = @learnerId;
		SET @newOrderId = @newOrderId + 1;
        INSERT INTO [order] (id, learnerId, total, paymentCardNumber, couponCode)
        VALUES (@newOrderId, @learnerId, @totalAmountAfterDiscount, @paymentCardNumber, @couponCode);

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
            
            -- Delete from cartDetails
            DELETE FROM [cartDetail]
            WHERE learnerId = @learnerId AND courseId = @courseId;

            -- Update course total revenue, course revenue by month, instructor revenue by month
            SET @coursePrice = @coursePrice / 100 * (100 - @discountPercent);
            EXEC [sp_UpdateCourseRevenueAndInstructorRevenue] @courseId = @courseId, @amount = @coursePrice;

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
        FOR JSON PATH;

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