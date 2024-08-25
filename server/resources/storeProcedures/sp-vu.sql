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

--10 Xem tiến độ 1 khóa học
IF OBJECT_ID('sp_LN_GetLearnerProgressInCourse', 'P') IS NOT NULL
    DROP PROCEDURE sp_LN_GetLearnerProgressInCourse
GO
	
CREATE PROCEDURE sp_LN_GetLearnerProgressInCourse
	@learnerId NVARCHAR(128),
	@courseId VARCHAR(128)
AS
BEGIN TRAN
	BEGIN TRY
		SET NOCOUNT ON;
		SELECT (	
					SELECT lps.sectionId, lps.completionPercentSection,
							(	
							SELECT lpl.lessonId, lpl.isCompletedLesson,
									(	
									SELECT laq.questionId, laq.learnerAnswer
									FROM [learnerAnswerQuestion] laq
									WHERE laq.courseId = lpl.courseId AND laq.sectionId = lpl.sectionId
										AND laq.exerciseId = lpl.lessonId AND laq.learnerId = @learnerId
									FOR JSON PATH, INCLUDE_NULL_VALUES
									) AS LearnerAnswer
							FROM [learnerParticipateLesson] lpl
							WHERE lpl.courseId = lps.courseId AND lpl.sectionId = lps.sectionId
								AND lpl.learnerId = @learnerId
							FOR JSON PATH, INCLUDE_NULL_VALUES
							) AS LessonProgress
					FROM [learnerParticipateSection] lps
					WHERE lps.courseId = c.id AND lps.learnerId = @learnerId
					FOR JSON PATH, INCLUDE_NULL_VALUES
				) AS SectionProgress
		FROM [course] c
		WHERE c.id = @courseId
	END TRY
	BEGIN CATCH
		DECLARE @errorMessage NVARCHAR(200) = ERROR_MESSAGE();
		THROW 51000, @errorMessage, 1;
		RETURN
	END CATCH
COMMIT TRAN
GO