--Trigger LMS
USE master
GO

USE LMS
GO

-- Triggers to auto-increment the 'id' column

--1/ Trigger to auto-increment the 'id' column in 'subCategory' table
IF OBJECT_ID('trg_AutoIncrement_SubCategoryID', 'TR') IS NOT NULL
    DROP TRIGGER trg_AutoIncrement_SubCategoryID
GO

CREATE TRIGGER trg_AutoIncrement_SubCategoryID
ON subCategory
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @countSubCategoriesOfCategory TABLE(
        categoryId INT,
        countSubCategories INT DEFAULT 0
    )

    INSERT INTO @countSubCategoriesOfCategory(categoryId, countSubCategories)
    SELECT DISTINCT pc.categoryId, ISNULL(MAX(sc.id), 0) AS count
    FROM (SELECT DISTINCT parentCategoryId categoryId FROM inserted) pc
    LEFT JOIN [subCategory] sc ON sc.parentCategoryId = pc.categoryId
	GROUP BY pc.categoryId;

    INSERT INTO [subCategory] (id, parentCategoryId, name, numberOfLearners, averageRating, numberOfCourses)
    SELECT ROW_NUMBER() OVER (PARTITION BY parentCategoryId ORDER BY (SELECT NULL)) + ssc.countSubCategories, parentCategoryId, name, numberOfLearners, averageRating, numberOfCourses
    FROM inserted
    JOIN @countSubCategoriesOfCategory ssc ON inserted.parentCategoryId = ssc.categoryId;
END
GO

--2/ Trigger to auto-increment the 'id' column in 'courseIntendedLearners' table
IF OBJECT_ID('trg_AutoIncrement_CourseIntendedLearners', 'TR') IS NOT NULL
    DROP TRIGGER trg_AutoIncrement_CourseIntendedLearners
GO

CREATE TRIGGER trg_AutoIncrement_CourseIntendedLearners
ON courseIntendedLearners
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @countIntendedLearnerOfCourse TABLE(
        courseId INT,
        countIntendedLearner INT DEFAULT 0
    )

	INSERT INTO @countIntendedLearnerOfCourse(courseId, countIntendedLearner)
    SELECT DISTINCT c.courseId, ISNULL(MAX(intendedLearnerId), 0) AS count
    FROM (SELECT DISTINCT courseId FROM inserted) c
    LEFT JOIN [courseIntendedLearners] cil ON cil.courseId = c.courseId
	GROUP BY c.courseId;

    INSERT INTO courseIntendedLearners (intendedLearnerId, courseId, intendedLearner)
    SELECT ROW_NUMBER() OVER (PARTITION BY inserted.courseId ORDER BY (SELECT NULL)) + cil.countIntendedLearner, inserted.courseId, inserted.intendedLearner
    FROM inserted
	JOIN @countIntendedLearnerOfCourse cil ON cil.courseId = inserted.courseId;
END
GO

--3/ Trigger to auto-increment the 'id' column in 'courseRequirements' table
IF OBJECT_ID('trg_AutoIncrement_CourseRequirements', 'TR') IS NOT NULL
    DROP TRIGGER trg_AutoIncrement_CourseRequirements
GO

CREATE TRIGGER trg_AutoIncrement_CourseRequirements
ON courseRequirements
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @countRequirementOfCourse TABLE(
        courseId INT,
        countRequirement INT DEFAULT 0
    )

	INSERT INTO @countRequirementOfCourse(courseId, countRequirement)
    SELECT DISTINCT c.courseId, ISNULL(MAX(requirementId), 0) AS count
    FROM (SELECT DISTINCT courseId FROM inserted) c
    LEFT JOIN [courseRequirements] cr ON cr.courseId = c.courseId
	GROUP BY c.courseId;

    INSERT INTO courseRequirements (requirementId, courseId, requirement)
    SELECT ROW_NUMBER() OVER (PARTITION BY inserted.courseId ORDER BY (SELECT NULL)) + cr.countRequirement, inserted.courseId, inserted.requirement
    FROM inserted
	JOIN @countRequirementOfCourse cr ON cr.courseId = inserted.courseId;
END
GO

--4/ Trigger to auto-increment the 'id' column in 'courseObjectives' table
IF OBJECT_ID('trg_AutoIncrement_CourseObjectives', 'TR') IS NOT NULL
    DROP TRIGGER trg_AutoIncrement_CourseObjectives
GO

CREATE TRIGGER trg_AutoIncrement_CourseObjectives
ON courseObjectives
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @countObjectiveOfCourse TABLE(
        courseId INT,
        countObjective INT DEFAULT 0
    )

	INSERT INTO @countObjectiveOfCourse(courseId, countObjective)
    SELECT DISTINCT c.courseId, ISNULL(MAX(objectiveId), 0) AS count
    FROM (SELECT DISTINCT courseId FROM inserted) c
    LEFT JOIN [courseObjectives] co ON co.courseId = c.courseId
	GROUP BY c.courseId;

    INSERT INTO courseObjectives (objectiveId, courseId, objective)
    SELECT ROW_NUMBER() OVER (PARTITION BY inserted.courseId ORDER BY (SELECT NULL)) + co.countObjective, inserted.courseId, inserted.objective
    FROM inserted
	JOIN @countObjectiveOfCourse co ON co.courseId = inserted.courseId;
END
GO


--5/ Trigger to auto-increment the 'id' column in 'questionAnswer' table CHECK
IF OBJECT_ID('trg_AutoIncrement_QuestionAnswerID', 'TR') IS NOT NULL
    DROP TRIGGER trg_AutoIncrement_QuestionAnswerID
GO

CREATE TRIGGER trg_AutoIncrement_QuestionAnswerID
ON questionAnswer
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @countQuestionAnswer TABLE(
        courseId INT,
        sectionId INT,
        exerciseId INT,
        questionId INT,
        countQuestionAnswer INT DEFAULT 0
    )

    INSERT INTO @countQuestionAnswer(courseId, sectionId, exerciseId, questionId, countQuestionAnswer)
    SELECT DISTINCT c.courseId, c.sectionId, c.exerciseId, c.questionId, ISNULL(MAX(id), 0) AS countQuestionAnswer
    FROM (SELECT DISTINCT courseId, sectionId, exerciseId, questionId FROM inserted) c
    LEFT JOIN [questionAnswer] qa ON qa.courseId = c.courseId AND qa.sectionId = c.sectionId AND qa.exerciseId = c.exerciseId AND qa.questionId = c.questionId
	GROUP BY c.courseId, c.sectionId, c.exerciseId, c.questionId;

    INSERT INTO questionAnswer (id, questionId, exerciseId, sectionId, courseId, questionAnswers, isCorrect)
    SELECT ROW_NUMBER() OVER (PARTITION BY inserted.courseId, inserted.sectionId, inserted.exerciseId, inserted.questionId ORDER BY (SELECT NULL)) + qa.countQuestionAnswer, inserted.questionId, inserted.exerciseId, inserted.sectionId, inserted.courseId, inserted.questionAnswers, inserted.isCorrect
    FROM inserted
    JOIN @countQuestionAnswer qa ON qa.courseId = inserted.courseId AND qa.sectionId = inserted.sectionId AND qa.exerciseId = inserted.exerciseId AND qa.questionId = inserted.questionId;
END
GO

--ID1/ Trigger to auto-increment the 'id' column in 'adminResponse' table

--ID2/ Trigger to auto-increment the 'id' column in 'message' table

--ID3/ Trigger to auto-increment the 'id' column in 'post' table

--ID4/ Trigger to auto-increment the 'id' column in 'comment' table

--15/ Trigger insert learner
IF OBJECT_ID('trg_Insert_InsertUserAsLearner', 'TR') IS NOT NULL
    DROP TRIGGER trg_Insert_InsertUserAsLearner
GO

CREATE TRIGGER trg_Insert_InsertUserAsLearner
ON [user]
AFTER INSERT
AS
BEGIN
    INSERT INTO courseMember (id, role)
    SELECT id, 'LN'
    FROM inserted
    WHERE role = 'LN';

    INSERT INTO learner (id)
    SELECT id
    FROM inserted
    WHERE role = 'LN';
END
GO

--16/ Trigger insert admin
IF OBJECT_ID('trg_Insert_InsertUserAsAdmin', 'TR') IS NOT NULL
    DROP TRIGGER trg_Insert_InsertUserAsAdmin
GO

CREATE TRIGGER trg_Insert_InsertUserAsAdmin
ON [user]
AFTER INSERT
AS
BEGIN
    INSERT INTO [admin](id)
    SELECT id
    FROM inserted
    WHERE role = 'AD';
END
GO

-- 17/ Trigger để chèn người dùng có vai trò Instructor vào bảng courseMember
IF OBJECT_ID('trg_AfterInsertUser_InsertInstructorToCourseMember', 'TR') IS NOT NULL
    DROP TRIGGER trg_AfterInsertUser_InsertInstructorToCourseMember
GO

CREATE TRIGGER trg_AfterInsertUser_InsertInstructorToCourseMember
ON [user]
AFTER INSERT
AS
BEGIN
    -- Chèn người dùng có vai trò 'INS' vào bảng courseMember
    INSERT INTO courseMember (id, role)
    SELECT id, 'INS'
    FROM inserted
    WHERE role = 'INS';
END
GO

-- 18. Tự động thay đổi trạng thái vipState sau khi tạo tax form
IF OBJECT_ID('trg_AfterInsertTaxForm_UpdateInstructor', 'TR') IS NOT NULL
    DROP TRIGGER trg_AfterInsertTaxForm_UpdateInstructor
GO
CREATE TRIGGER trg_AfterInsertTaxForm_UpdateInstructor
ON taxForm
AFTER INSERT
AS
BEGIN
	UPDATE instructor
	SET vipState = 'pendingReview'
	WHERE id IN (SELECT vipInstructorId FROM inserted);
END
GO


-- 19. Tự động cập nhật totalTime và numOfLesson trong course khi thêm hoặc xóa lesson
IF OBJECT_ID('trg_AfterChangeLesson_UpdateCourseAndSection', 'TR') IS NOT NULL
    DROP TRIGGER trg_AfterChangeLesson_UpdateCourseAndSection
GO
CREATE TRIGGER trg_AfterChangeLesson_UpdateCourseAndSection
ON lesson
AFTER INSERT, DELETE
AS
BEGIN
    -- Cập nhật learnTime cho section khi chèn hoặc xóa lesson
    UPDATE s
    SET s.learnTime = s.learnTime + COALESCE(i.TotalLearnTime, 0) - COALESCE(d.TotalLearnTime, 0)
    FROM section s
    LEFT JOIN (
        SELECT sectionId, courseId, SUM(learnTime) AS TotalLearnTime
        FROM inserted
        GROUP BY sectionId, courseId
    ) i ON s.id = i.sectionId AND s.courseId = i.courseId
    LEFT JOIN (
        SELECT sectionId, courseId, SUM(learnTime) AS TotalLearnTime
        FROM deleted
        GROUP BY sectionId, courseId
    ) d ON s.id = d.sectionId AND s.courseId = d.courseId;

    -- Cập nhật tổng thời gian và tổng số bài học cho mỗi khóa học khi thêm hoặc xóa lesson
    UPDATE c
    SET c.totalTime = c.totalTime + COALESCE(i.TotalLearnTime, 0) - COALESCE(d.TotalLearnTime, 0),
        c.numberOfLectures = c.numberOfLectures + COALESCE(i.LessonCount, 0) - COALESCE(d.LessonCount, 0)
    FROM course c
    LEFT JOIN (
        SELECT courseId, 
               SUM(learnTime) AS TotalLearnTime,
               COUNT(*) AS LessonCount
        FROM inserted
        GROUP BY courseId
    ) i ON c.id = i.courseId
    LEFT JOIN (
        SELECT courseId, 
               SUM(learnTime) AS TotalLearnTime,
               COUNT(*) AS LessonCount
        FROM deleted
        GROUP BY courseId
    ) d ON c.id = d.courseId;
END
GO


-- 20. Kiểm tra paymentCard nếu dư thừa thì xóa
IF OBJECT_ID('trg_AfterUpdateVipInstructor_DeletePaymentCard', 'TR') IS NOT NULL
    DROP TRIGGER trg_AfterUpdateVipInstructor_DeletePaymentCard
GO
CREATE TRIGGER trg_AfterUpdateVipInstructor_DeletePaymentCard
ON vipInstructor
AFTER UPDATE
AS
BEGIN
	-- Xóa các thẻ tín dụng không còn được tham chiếu
    DELETE FROM paymentCard
    WHERE number NOT IN (
        SELECT paymentCardNumber FROM vipInstructor
        UNION
        SELECT paymentCardNumber FROM learnerPaymentCard
    );
END
GO


-- 21. Tạo exercise
IF OBJECT_ID('trg_Insert_InsertLessenAsExercise', 'TR') IS NOT NULL
    DROP TRIGGER trg_Insert_InsertLessenAsExercise
GO
CREATE TRIGGER trg_Insert_InsertLessenAsExercise
ON lesson
AFTER INSERT
AS
BEGIN
    INSERT INTO exercise(id, courseId, sectionId)
    SELECT id, courseId, sectionId
    FROM inserted
    WHERE type = 'exercise';
END
GO


-- 22. Cập nhật điểm đánh giá một khóa học 
IF OBJECT_ID('trg_AfterInsertLRC_UpdateAverageRating', 'TR') IS NOT NULL
    DROP TRIGGER trg_AfterInsertLRC_UpdateAverageRating
GO

CREATE TRIGGER trg_AfterInsertLRC_UpdateAverageRating
ON learnerReviewCourse
AFTER INSERT
AS
BEGIN
    UPDATE c
    SET 
        c.averageRating = ((c.averageRating * c.ratingCount) + newRatingInfo.totalNewRating) / (c.ratingCount + newRatingInfo.newRatingCount),
        c.ratingCount = c.ratingCount + newRatingInfo.newRatingCount
    FROM course c
    JOIN (
        SELECT i.courseId, COUNT(i.rating) AS newRatingCount, SUM(i.rating) AS totalNewRating
        FROM inserted i
        GROUP BY i.courseId
    ) AS newRatingInfo
    ON c.id = newRatingInfo.courseId;
END
GO


-- 23. Cập nhật điểm trung bình của một học sinh trên toàn khóa học
IF OBJECT_ID('trg_AfterInsertLDE_UpdateAverageScore', 'TR') IS NOT NULL
    DROP TRIGGER trg_AfterInsertLDE_UpdateAverageScore
GO

CREATE TRIGGER trg_AfterInsertLDE_UpdateAverageScore
ON learnerDoExercise
AFTER UPDATE
AS
BEGIN
    UPDATE lec
    SET lec.learnerScore = avgScores.newAvgScore
    FROM learnerEnrollCourse lec
    JOIN (
        SELECT lde.learnerId, lde.courseId, AVG(lde.learnerScore) AS newAvgScore
        FROM learnerDoExercise lde
        WHERE EXISTS (
            SELECT 1
            FROM inserted i
            WHERE i.learnerId = lde.learnerId AND i.courseId = lde.courseId
        )
        GROUP BY lde.learnerId, lde.courseId
    ) AS avgScores
    ON lec.learnerId = avgScores.learnerId AND lec.courseId = avgScores.courseId;

END
GO

IF OBJECT_ID('trg_AfterInsertComment_InsertCommentNotification', 'TR') IS NOT NULL
    DROP TRIGGER trg_AfterInsertComment_InsertCommentNotification
GO

CREATE TRIGGER trg_AfterInsertComment_InsertCommentNotification
ON [comment]
AFTER INSERT
AS
BEGIN
	DECLARE @inserted TABLE (
		commentId INT,
		dateCommented DATE,
		memberNotification NVARCHAR(128),
		isRead BIT
	);

    -- Chèn thông báo vào bảng CommentNotification ngay sau khi có một comment mới nào đó vào một post
    -- Thông báo đến 1. người đăng post 2. người comment vào post
    WITH insertedComment(commentId) AS (
        SELECT id
        FROM inserted
    ),
    membersNoticed(memberId) AS (
        SELECT publisher
        FROM post
        WHERE EXISTS (
            SELECT 1
            FROM inserted
            JOIN comment ON inserted.id = comment.id
			WHERE comment.postId = post.id
        )
        UNION
        SELECT commenter
        FROM comment c2
        WHERE EXISTS (
            SELECT 1
            FROM inserted
			JOIN comment c1 ON inserted.id = c1.id
            WHERE c2.postId = c1.postId
        )
    )
    INSERT INTO [commentNotification](commentId, date, memberNotification)
	OUTPUT inserted.commentId, inserted.date, inserted.memberNotification, inserted.isRead
	INTO @inserted
    SELECT commentId, GETDATE(), memberId
    FROM insertedComment
    CROSS JOIN membersNoticed mn;

END
GO

IF OBJECT_ID('trg_AfterInsertPost_InsertPostNotification', 'TR') IS NOT NULL
    DROP TRIGGER trg_AfterInsertPost_InsertPostNotification
GO

CREATE TRIGGER trg_AfterInsertPost_InsertPostNotification
ON [post]
AFTER INSERT
AS
BEGIN
    -- Chèn thông báo vào bảng CommentNotification ngay sau khi có một comment mới nào đó vào một post
    -- Thông báo đến 1. người đăng post 2. người comment vào post
	DECLARE @inserted TABLE (
		postId INT,
		datePosted DATE,
		memberNotification NVARCHAR(128),
		isRead BIT
	);

    WITH insertedPost(postId) AS (
        SELECT id
        FROM inserted
    ),
    membersNoticed(memberId) AS (
        SELECT learnerId
        FROM learnerEnrollCourse
        WHERE EXISTS (
            SELECT 1
            FROM inserted
			JOIN post ON inserted.id = post.id
            WHERE post.courseId = learnerEnrollCourse.courseId
        )
    )
    INSERT INTO [postNotification](postId, [date], memberNotification)
	OUTPUT inserted.postId, inserted.[date], inserted.memberNotification, inserted.isRead
	INTO @inserted
    SELECT ip.postId, GETDATE(), mn.memberId
    FROM insertedPost ip
    CROSS JOIN membersNoticed mn;
END
GO