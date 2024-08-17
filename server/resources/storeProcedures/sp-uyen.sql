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
		-- từ chối phê duyệt khóa học (pendingReview --> pendingReview)
		-- ẩn khóa học (public --> pendingReview)
		ELSE IF (@vipState = 'pendingReview' 
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
		ELSE IF (@responseText IS NULL AND @adminId IS NULL)
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
IF OBJECT_ID('sp_AD_INS_GetAnnualRevenueOfAInnstructor', 'P') IS NOT NULL
    DROP PROCEDURE [sp_AD_INS_GetAnnualRevenueOfAInnstructor]
GO
CREATE PROCEDURE sp_AD_INS_GetAnnualRevenueOfAInnstructor
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
		SELECT C.id, C.title, C.subTitle, C.image, C.state, C.numberOfStudents, 
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
		FROM subCategory SC JOIN category C ON (SC.parentCategoryId = C.id)
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

