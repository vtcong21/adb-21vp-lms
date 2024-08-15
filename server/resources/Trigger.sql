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
    DECLARE @MaxID INT;

    SELECT @MaxID = ISNULL(MAX(id), 0) FROM subCategory;

    INSERT INTO subCategory (id, parentCategoryId, name, numberOfLearners, averageRating, numberOfCourses)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + @MaxID, parentCategoryId, name, numberOfLearners, averageRating, numberOfCourses
    FROM inserted;
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
    DECLARE @MaxID INT;

    SELECT @MaxID = ISNULL(MAX(intendedLearnerId), 0) FROM courseIntendedLearners;

    INSERT INTO courseIntendedLearners (intendedLearnerId, courseId, intendedLearner)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + @MaxID, courseId, intendedLearner
    FROM inserted;
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
    DECLARE @MaxID INT;

    SELECT @MaxID = ISNULL(MAX(requirementId), 0) FROM courseRequirements;

    INSERT INTO courseRequirements (requirementId, courseId, requirement)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + @MaxID, courseId, requirement
    FROM inserted;
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
    DECLARE @MaxID INT;

    SELECT @MaxID = ISNULL(MAX(objectiveId), 0) FROM courseObjectives;

    INSERT INTO courseObjectives (objectiveId, courseId, objective)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + @MaxID, courseId, objective
    FROM inserted;
END
GO

--5/ Trigger to auto-increment the 'id' column in 'section' table
IF OBJECT_ID('trg_AutoIncrement_SectionID', 'TR') IS NOT NULL
    DROP TRIGGER trg_AutoIncrement_SectionID
GO

CREATE TRIGGER trg_AutoIncrement_SectionID
ON section
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @MaxID INT;

    SELECT @MaxID = ISNULL(MAX(id), 0) FROM section;

    INSERT INTO section (id, courseId, title, learnTime)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + @MaxID, courseId, title, learnTime
    FROM inserted;
END
GO

--6/ Trigger to auto-increment the 'id' column in 'lesson' table
IF OBJECT_ID('trg_AutoIncrement_LessonID', 'TR') IS NOT NULL
    DROP TRIGGER trg_AutoIncrement_LessonID
GO

CREATE TRIGGER trg_AutoIncrement_LessonID
ON lesson
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @MaxID INT;

    SELECT @MaxID = ISNULL(MAX(id), 0) FROM lesson;

    INSERT INTO lesson (id, sectionId, courseId, title, learnTime, type)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + @MaxID, sectionId, courseId, title, learnTime, type
    FROM inserted;
END
GO

--7/ Trigger to auto-increment the 'id' column in 'question' table
IF OBJECT_ID('trg_AutoIncrement_QuestionID', 'TR') IS NOT NULL
    DROP TRIGGER trg_AutoIncrement_QuestionID
GO

CREATE TRIGGER trg_AutoIncrement_QuestionID
ON question
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @MaxID INT;

    SELECT @MaxID = ISNULL(MAX(id), 0) FROM question;

    INSERT INTO question (id, exerciseId, sectionId, courseId, question, correctAnswer)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + @MaxID, exerciseId, sectionId, courseId, question, correctAnswer
    FROM inserted;
END
GO

--8/ Trigger to auto-increment the 'id' column in 'questionAnswer' table
IF OBJECT_ID('trg_AutoIncrement_QuestionAnswerID', 'TR') IS NOT NULL
    DROP TRIGGER trg_AutoIncrement_QuestionAnswerID
GO

CREATE TRIGGER trg_AutoIncrement_QuestionAnswerID
ON questionAnswer
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @MaxID INT;

    SELECT @MaxID = ISNULL(MAX(id), 0) FROM questionAnswer;

    INSERT INTO questionAnswer (id, questionId, exerciseId, sectionId, courseId, questionAnswers)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + @MaxID, questionId, exerciseId, sectionId, courseId, questionAnswers
    FROM inserted;
END
GO

--9/ Trigger to auto-increment the 'id' column in 'adminResponse' table
IF OBJECT_ID('trg_AutoIncrement_AdminResponseID', 'TR') IS NOT NULL
    DROP TRIGGER trg_AutoIncrement_AdminResponseID
GO

CREATE TRIGGER trg_AutoIncrement_AdminResponseID
ON adminResponse
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @MaxID INT;

    SELECT @MaxID = ISNULL(MAX(id), 0) FROM adminResponse;

    INSERT INTO adminResponse (id, adminId, courseId, dateResponse, responseText)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + @MaxID, adminId, courseId, dateResponse, responseText
    FROM inserted;
END
GO

--10/ Trigger to auto-increment the 'id' column in 'message' table
IF OBJECT_ID('trg_AutoIncrement_MessageID', 'TR') IS NOT NULL
    DROP TRIGGER trg_AutoIncrement_MessageID
GO

CREATE TRIGGER trg_AutoIncrement_MessageID
ON [message]
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @MaxID INT;

    SELECT @MaxID = ISNULL(MAX(id), 0) FROM [message];

    INSERT INTO [message] (id, content, isRead, senderId, receiverId, sentTime)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + @MaxID, content, isRead, senderId, receiverId, sentTime
    FROM inserted;
END
GO

--11/ Trigger to auto-increment the 'id' column in 'order' table
IF OBJECT_ID('trg_AutoIncrement_OrderID', 'TR') IS NOT NULL
    DROP TRIGGER trg_AutoIncrement_OrderID
GO

CREATE TRIGGER trg_AutoIncrement_OrderID
ON [order]
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @MaxID INT;

    SELECT @MaxID = ISNULL(MAX(id), 0) FROM [order];

    INSERT INTO [order] (id, learnerId, dateCreated, total, paymentCardNumber, couponCode)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + @MaxID, learnerId, dateCreated, total, paymentCardNumber, couponCode
    FROM inserted;
END
GO

--12/ Trigger to auto-increment the 'id' column in 'orderDetail' table
IF OBJECT_ID('trg_AutoIncrement_OrderDetailID', 'TR') IS NOT NULL
    DROP TRIGGER trg_AutoIncrement_OrderDetailID
GO

CREATE TRIGGER trg_AutoIncrement_OrderDetailID
ON orderDetail
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @MaxID INT;

    SELECT @MaxID = ISNULL(MAX(id), 0) FROM orderDetail;

    INSERT INTO orderDetail (id, orderId, learnerId, courseId, coursePrice)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + @MaxID, orderId, learnerId, courseId, coursePrice
	FROM inserted;
END
GO

--13/ Trigger to auto-increment the 'id' column in 'post' table
IF OBJECT_ID('trg_AutoIncrement_PostID', 'TR') IS NOT NULL
    DROP TRIGGER trg_AutoIncrement_PostID
GO

CREATE TRIGGER trg_AutoIncrement_PostID
ON post
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @MaxID INT;

    SELECT @MaxID = ISNULL(MAX(id), 0) FROM post;

    INSERT INTO post (id, date, courseId, publisher, content)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + @MaxID, date, courseId, publisher, content
	FROM inserted;
END
GO

--14/ Trigger to auto-increment the 'id' column in 'comment' table
IF OBJECT_ID('trg_AutoIncrement_CommentID', 'TR') IS NOT NULL
    DROP TRIGGER trg_AutoIncrement_CommentID
GO

CREATE TRIGGER trg_AutoIncrement_CommentID
ON comment
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @MaxID INT;

    SELECT @MaxID = ISNULL(MAX(id), 0) FROM comment;

    INSERT INTO comment (id, postId, date, courseId, postPublisher, commenter, content)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + @MaxID, postId, date, courseId, postPublisher, commenter, content
	FROM inserted;
END
GO

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
	SET vipState = 'pending'
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
AFTER INSERT
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