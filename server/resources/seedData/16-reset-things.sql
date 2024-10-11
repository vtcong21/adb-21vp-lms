
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

-- Update learnerTime in section
UPDATE sec
SET sec.learnTime = ISNULL(lectureSum.totalLearnTime, 0)
FROM section sec
INNER JOIN (
    SELECT 
		l.courseId,
        l.sectionId,
        SUM(l.learnTime) AS totalLearnTime
    FROM lesson l
    GROUP BY l.courseId, l.sectionId
) AS lectureSum ON sec.id = lectureSum.sectionId AND sec.courseId =lectureSum.courseId;

-- Update totalTime in course
UPDATE c
SET c.totalTime = ISNULL(sectionSum.totalSectionTime, 0)
FROM course c
INNER JOIN (
    SELECT 
        s.courseId,
        SUM(s.learnTime) AS totalSectionTime
    FROM section s
    GROUP BY s.courseId
) AS sectionSum ON c.id = sectionSum.courseId;

EXEC sp_columns @table_name = 'section';


UPDATE [user] SET password = (select password from [user] where id = 'learner000001') where [user].role = 'LN'

UPDATE [user] SET password = (select password from [user] where id = 'admin000001') where [user].role = 'AD'

UPDATE [user] SET password = (select password from [user] where id = 'instructor000001') where [user].role = 'INS'
