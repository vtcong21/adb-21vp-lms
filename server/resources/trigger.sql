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


CREATE TRIGGER trg_AfterInsertComment_InsertCommentNotification
ON [comment]
AFTER INSERT
AS
BEGIN
    -- Chèn thông báo vào bảng CommentNotification ngay sau khi có một comment mới nào đó vào một post
    -- Thông báo đến 1. người đăng post 2. người comment vào post
    WITH insertedComment(commentId, postId, date, courseId, postPublisher, commenter) AS (
        SELECT commentId, postId, date, courseId, postPublisher, commenter
        FROM inserted
    ),
    WITH membersNoticed(memberId) AS (
        SELECT publisher
        FROM post
        WHERE EXISTS (
            SELECT 1
            FROM inserted
            WHERE inserted.postId = post.id
        )
        UNION
        SELECT commenter
        FROM comment
        WHERE EXISTS (
            SELECT 1
            FROM inserted
            WHERE inserted.postId = comment.postId
        )
    ),
    INSERT INTO [commentNotification](commendId, date, memberNotification)
    SELECT commentId, date, memberId
    FROM insertedComment
    CROSS JOIN memberNoticed nc
END
GO

CREATE TRIGGER trg_AfterInsertPost_InsertPostNotification
ON [post]
AFTER INSERT
AS
BEGIN
    -- Chèn thông báo vào bảng CommentNotification ngay sau khi có một comment mới nào đó vào một post
    -- Thông báo đến 1. người đăng post 2. người comment vào post
    WITH insertedPost(postId, courseId, date) AS (
        SELECT id, date
        FROM inserted
    ),
    WITH membersNoticed(memberId) AS (
        SELECT learnerId
        FROM learnerEnrollCourse
        WHERE EXISTS (
            SELECT 1
            FROM inserted
            WHERE inserted.courseId = learnerEnrollCourse.courseId
        )
    )
    INSERT INTO [postNotification](postId, date, memberNotification)
    SELECT ip.postId, ip.date, nc.memberId
    FROM insertedPost ip
    CROSS JOIN memberNoticed nc;
END
GO