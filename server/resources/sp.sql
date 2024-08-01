-- Write the SPs here
Use LMS 
GO
-- Doanh thu hàng ngày của 1 khóa học
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
        c.id AS courseId,
        c.title AS courseName,
        SUM(od.coursePrice) AS revenue
    FROM
        [orderDetail] od
        JOIN
        [course] c ON od.courseId = c.id
    WHERE
            od.courseId = @courseId
        AND o.dateCreated >= DATEADD(DAY, -@duration, GETDATE())
        AND o.dateCreated < GETDATE()
    GROUP BY
            c.id,
            c.title;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RAISERROR ('Cannot get course revenue by dates.', 16, 1);
    END CATCH
END;

-- Doanh thu hàng tháng của 1 khóa học
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
        c.id AS courseId,
        c.title AS courseName,
        SUM(od.coursePrice) AS revenue,
        CAST(o.dateCreated As DATE) As revenueDate
    FROM
        [orderDetail] od
        JOIN
        [course] c ON od.courseId = c.id
        JOIN
        [order] o ON od.orderId = o.id
    WHERE
            od.courseId = @courseId
        AND o.dateCreated >= DATEADD(DAY, -@duration, GETDATE())
        AND o.dateCreated < GETDATE()
    GROUP BY
            c.id,
            c.title,
            revenueDate;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RAISERROR ('Cannot get course revenue by date.', 16, 1);
    END CATCH
END;

-- Doanh thu hàng năm của 1 khóa học
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
        DECLARE @endDate DATE = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
        DECLARE @startDate DATE = DATEADD(MONTH, -@duration, @endDate);
        SELECT
        courseId, year, month, revenue
    FROM
        courseRevenueByMonth
    WHERE
            courseId = @courseId
        AND DATEFROMPARTS(year, month, 1) >= @startDate
        AND DATEFROMPARTS(year, month, 1) < @endDate
    ORDER BY
            year,
            month;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RAISERROR ('Cannot get course revenue by month.', 16, 1);
    END CATCH
END;

-- Top 50 khóa học có doanh thu cao nhất
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
            totalRevenue DESC;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RAISERROR ('Cannot get top 50 courses by revenue.', 16, 1);
    END CATCH
END;
GO

-- Tạo mã giảm giá
IF OBJECT_ID('sp_AD_InsertCoupon', 'P') IS NOT NULL
    DROP PROCEDURE [sp_AD_InsertCoupon]
GO
CREATE PROCEDURE sp_AD_InsertCoupon
    @code VARCHAR(20),
    @discountPercent DECIMAL(5, 2),
    @quantity INT,
    @startDate DATE,
    @adminCreatedCoupon NVARCHAR(128)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO [coupon]
        (code, discountPercent, quantity, startDate, adminCreatedCoupon)
    VALUES
        (@code, @discountPercent, @quantity, @startDate, @adminCreatedCoupon);
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
    DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR ('Cannot insert coupon. Error: %s', 16, 1, @errorMessage);    
    END CATCH
END;
GO

-- Tạo tài khoản học viên
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
        ROLLBACK TRANSACTION;
        DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR ('Cannot insert user, course member, or learner. Error: %s', 16, 1, @errorMessage);
    END CATCH
END;
GO

-- Cập nhật thông tin Thanh toán
IF OBJECT_ID('sp_LN_UpdateLearnerPaymentCard', 'P') IS NOT NULL
    DROP PROCEDURE [sp_LN_UpdateLearnerPaymentCard]
GO

CREATE PROCEDURE sp_LN_UpdateLearnerPaymentCard
    @learnerId NVARCHAR(128),
    @paymentCardNumber VARCHAR(16),
    @paymentCardType VARCHAR(6),
    @paymentCardName NVARCHAR(128),
    @paymentCardCVC CHAR(3),
    @paymentCardExpireDate DATE
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1
            FROM [paymentCard]
            WHERE number = @paymentCardNumber
        )
        BEGIN
            INSERT INTO [paymentCard] (number, type, name, CVC, expireDate)
            VALUES (@paymentCardNumber, @paymentCardType, @paymentCardName, @paymentCardCVC, @paymentCardExpireDate);
        END
        INSERT INTO [learnerPaymentCard] (learnerId, paymentCardNumber)
        VALUES (@learnerId, @paymentCardNumber);
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR ('Cannot update learner payment card. Error: %s', 16, 1, @errorMessage);
    END CATCH
END;
GO

-- Thêm 1 khóa học vào giỏ hàng
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
            FROM [cartDetail]
            WHERE learnerId = @learnerId AND courseId = @courseId
        )
        BEGIN
            RAISERROR ('The course is already in the learner''s cart.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        INSERT INTO [cartDetail] (learnerId, courseId)
        VALUES (@learnerId, @courseId);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR ('Cannot add course to cart. Error: %s', 16, 1, @errorMessage);
    END CATCH
END;
GO

-- Xóa 1 khóa học khỏi giỏ hàng
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
            ROLLBACK TRANSACTION;
            RETURN;
        END

        DELETE FROM [cartDetail]
        WHERE learnerId = @learnerId AND courseId = @courseId;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR ('Cannot remove course from cart. Error: %s', 16, 1, @errorMessage);
    END CATCH
END;
GO

-- Xem danh sách các khóa học trong giỏ hàng
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
            cd.learnerId, cd.courseId, c.title AS courseTitle, c.price AS coursePrice
        FROM
            [cartDetail] cd
        JOIN
            [course] c ON cd.courseId = c.id
        WHERE
            cd.learnerId = @learnerId;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR ('Cannot retrieve cart details. Error: %s', 16, 1, @errorMessage);
    END CATCH
END;
GO

-- Thanh toán giỏ hàng 
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

        -- check discount percent
        DECLARE @discountPercent DECIMAL(5, 2) = 0;
        IF @couponCode IS NOT NULL
        BEGIN
            SELECT @discountPercent = discountPercent
            FROM [coupon]
            WHERE code = @couponCode;
        END

        -- compute total amount
        DECLARE @totalAmount DECIMAL(18, 2);
        SELECT @totalAmount = SUM(c.price)
        FROM [cartDetail] cd
        JOIN [course] c ON cd.courseId = c.id
        WHERE cd.learnerId = @learnerId;

        SET @totalAmount = @totalAmount * (1 - @discountPercent / 100);

        -- insert to order
        DECLARE @newOrderId INT;
        SET @newOrderId = (SELECT ISNULL(MAX(id), 0) + 1 FROM [order]);

        INSERT INTO [order] (id, learnerId, total, paymentCardNumber, couponCode)
        VALUES (@newOrderId, @learnerId, @totalAmount, @paymentCardNumber, @couponCode);

        DECLARE @nextOrderDetailId INT;
        
        -- insert to order details and delete from cart details
        DECLARE cart_cursor CURSOR FOR
        SELECT courseId
        FROM [cartDetail]
        WHERE learnerId = @learnerId;

        OPEN cart_cursor;
        FETCH NEXT FROM cart_cursor INTO @courseId;
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @nextOrderDetailId = (SELECT ISNULL(MAX(id), 0) + 1 FROM [orderDetail]);
            -- insert order details
            INSERT INTO [orderDetail] (id, orderId, learnerId, courseId, coursePrice)
            VALUES (@nextOrderDetailId, @newOrderId, @learnerId, @courseId, 
                    (SELECT price FROM [course] WHERE id = @courseId));
            -- del cart details
            DELETE FROM [cartDetail]
            WHERE learnerId = @learnerId AND courseId = @courseId;
            -- insert learner enroll course
            INSERT INTO [learnerEnrollCourse] (courseId, learnerId)
            VALUES (@courseId, @learnerId);
            FETCH NEXT FROM cart_cursor INTO @courseId;
        END
        
        CLOSE cart_cursor;
        DEALLOCATE cart_cursor;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR ('Cannot complete the order. Error: %s', 16, 1, @errorMessage);
    END CATCH
END;
GO

-- Xem danh sách các hóa đơn
IF OBJECT_ID('sp_LN_ViewOrders', 'P') IS NOT NULL
    DROP PROCEDURE [sp_LN_ViewOrders]
GO

CREATE PROCEDURE sp_LN_ViewOrders
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        
        SELECT
            o.id,
            o.learnerId,
            l.name,
            o.dateCreated,
            o.total,
            o.paymentCardNumber,
            o.couponCode AS CouponCode,
            c.discountPercent
        FROM
            [order] o
        JOIN
            [learner] l ON o.learnerId = l.id
        JOIN
            [paymentCard] p ON o.paymentCardNumber = p.number
        LEFT JOIN
            [coupon] c ON o.couponCode = c.code;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR ('Cannot retrieve orders. Error: %s', 16, 1, @errorMessage);
    END CATCH
END;
GO

-- Xem chi tiết 1 hóa đơn
IF OBJECT_ID('sp_LN_ViewOrderDetails', 'P') IS NOT NULL
    DROP PROCEDURE [sp_LN_ViewOrderDetails]
GO

CREATE PROCEDURE sp_LN_ViewOrderDetails
    @orderId INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        
        SELECT
            o.id,
            o.learnerId,
            l.name,
            o.dateCreated,
            o.total,
            o.paymentCardNumber,
            o.couponCode,
            c.discountPercent,
            od.courseId,
            co.title,
            od.coursePrice
        FROM
            [order] o
        JOIN
            [learner] l ON o.learnerId = l.id
        JOIN
            [paymentCard] p ON o.paymentCardNumber = p.number
        LEFT JOIN
            [coupon] c ON o.couponCode = c.code
        JOIN
            [orderDetail] od ON o.id = od.orderId
        JOIN
            [course] co ON od.courseId = co.id
        WHERE
            o.id = @orderId;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR ('Cannot retrieve order details. Error: %s', 16, 1, @errorMessage);
    END CATCH
END;
GO

-- Hủy tham gia 1 khóa học
IF OBJECT_ID('sp_LN_UnenrollLearnerFromCourse', 'P') IS NOT NULL
    DROP PROCEDURE [sp_LN_UnenrollLearnerFromCourse]
GO

CREATE PROCEDURE sp_LN_UnenrollLearnerFromCourse
    @courseId INT,
    @learnerId NVARCHAR(128)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        DELETE FROM [learnerEnrollCourse]
        WHERE courseId = @courseId
          AND learnerId = @learnerId;

        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR ('No enrollment record found for the given course and learner.', 16, 1);
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @errorMessage NVARCHAR(4000);
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR ('Cannot unenroll the learner from the course. Error: %s', 16, 1, @errorMessage);
    END CATCH
END;
GO

-- Học 1 bài học

-- Làm bài test

-- Đánh giá khóa học
