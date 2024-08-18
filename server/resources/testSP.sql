USE LMS;
GO

-- DATA

-- Insert into User
INSERT INTO [user] (id, email, name, password, profilePhoto, role)
VALUES
('user001', 'admin1@example.com', 'Admin One', 'password1', 'photo1.jpg', 'AD'),
('user002', 'admin2@example.com', 'Admin Two', 'password2', 'photo2.jpg', 'AD'),
('user003', 'learner1@example.com', 'Learner One', 'password3', 'photo3.jpg', 'LN'),
('user004', 'learner2@example.com', 'Learner Two', 'password4', 'photo4.jpg', 'LN'),
('user005', 'instructor1@example.com', 'Instructor One', 'password5', 'photo5.jpg', 'INS'),
('user006', 'instructor2@example.com', 'Instructor Two', 'password6', 'photo6.jpg', 'INS'),
('user007', 'learner3@example.com', 'Learner Three', 'password7', 'photo7.jpg', 'LN'),
('user008', 'learner4@example.com', 'Learner Four', 'password8', 'photo8.jpg', 'LN'),
('user009', 'instructor3@example.com', 'Instructor Three', 'password9', 'photo9.jpg', 'INS'),
('user010', 'instructor4@example.com', 'Instructor Four', 'password10', 'photo10.jpg', 'INS');
GO

-- Insert into Admin
INSERT INTO admin (id)
VALUES
('user001'),
('user002');
GO

-- Insert into courseMember
INSERT INTO courseMember (id, role)
VALUES
('user003', 'LN'),
('user004', 'LN'),
('user005', 'INS'),
('user006', 'INS'),
('user007', 'LN'),
('user008', 'LN'),
('user009', 'INS'),
('user010', 'INS');
GO

-- Insert into learner
INSERT INTO learner (id)
VALUES
('user003'),
('user004'),
('user007'),
('user008');
GO

-- Insert into instructor
INSERT INTO instructor (id, gender, phone, DOB, address, degrees, workplace, scientificBackground, vipState, totalRevenue)
VALUES
('user005', 'M', '1234567890', '1980-01-01', '123 Main St', 'PhD', 'University A', 'Physics', 'vip', 10000.00),
('user006', 'F', '0987654321', '1985-02-01', '456 Elm St', 'MSc', 'University B', 'Chemistry', 'notVip', 5000.00),
('user009', 'M', '1112223334', '1975-03-01', '789 Oak St', 'PhD', 'University C', 'Mathematics', 'vip', 15000.00),
('user010', 'F', '4445556667', '1990-04-01', '101 Pine St', 'MSc', 'University D', 'Biology', 'pending', 2000.00);
GO

-- Insert into instructorRevenueByMonth
INSERT INTO instructorRevenueByMonth (instructorId, year, month, revenue)
VALUES
('user005', 2024, 1, 800.00),
('user005', 2024, 2, 850.00),
('user005', 2023, 12, 10000.00),
('user005', 2023, 11, 6000.00),
('user005', 2023, 10, 4000.00),
('user005', 2022, 12, 300.00),
('user005', 2022, 11, 100.00),
('user005', 2022, 10, 7000.00),
('user006', 2023, 12, 800.00),
('user006', 2023, 11, 9000.00),
('user006', 2023, 10, 970.00),
('user006', 2022, 12, 14200.00),
('user006', 2022, 11, 1200.00),
('user006', 2022, 10, 1400.00),
('user006', 2024, 1, 400.00),
('user006', 2024, 2, 450.00),
('user009', 2024, 1, 1200.00),
('user009', 2024, 2, 1250.00),
('user010', 2024, 1, 150.00),
('user010', 2024, 2, 200.00);
GO

-- Insert into paymentCard
INSERT INTO paymentCard (number, type, name, CVC, expireDate)
VALUES
('1111222233334444', 'Debit', 'Instructor One', '123', '2025-12-01'),
('5555666677778888', 'Credit', 'Instructor Two', '456', '2026-01-01'),
('9999000011112222', 'Debit', 'Instructor Three', '789', '2025-11-01'),
('3333444455556666', 'Credit', 'Instructor Four', '012', '2026-02-01');
GO

-- Insert into vipInstructor
INSERT INTO vipInstructor (id, paymentCardNumber)
VALUES
('user005', '1111222233334444'),
('user009', '9999000011112222');
GO

-- Insert into taxForm
INSERT INTO taxForm (submissionDate, fullName, address, phone, taxCode, identityNumber, postCode, vipInstructorId)
VALUES
('2024-07-15', 'Instructor One', '123 Main St', '1234567890', '123456789012', '123456789012', '12345', 'user005'),
('2024-07-16', 'Instructor Three', '789 Oak St', '1112223334', '987654321098', '987654321098', '67890', 'user009');
GO

-- Insert into category
INSERT INTO category (name)
VALUES
('Science'),
('Technology'),
('Engineering'),
('Mathematics');
GO

-- Insert into subCategory
INSERT INTO subCategory (id, parentCategoryId, numberOfLearners, averageRating, numberOfCourses, name)
VALUES
(1, 1, 200, 4.5, 10, 'Physics 2'),
(2, 1, 150, 4.2, 8, 'Chemistry 2'),
(1, 2, 300, 4.7, 12, 'Computer Science 2'),
(1, 3, 180, 4.4, 9, 'Civil Engineering 2');
GO

-- Insert into course
INSERT INTO course (title, subTitle, description, image, video, state, numberOfStudents, numberOfLectures, totalTime, averageRating, ratingCount, subCategoryId, categoryId, totalRevenue, revenueByMonth, language, price)
VALUES
('Physics 102', 'Introduction to Physics', 'Basic concepts of physics', 'physics.jpg', 'physics.mp4', 'public', 100, 15, 20.5, 4.5, 50, 1, 1, 5000.00, 1000.00, 'English', 29.99),
('Advanced Chemistry 2', 'Deep dive into Chemistry', 'Advanced topics in Chemistry', 'chemistry.jpg', 'chemistry.mp4', 'public', 80, 12, 18.0, 4.3, 40, 2, 1, 4000.00, 800.00, 'English', 39.99),
('Computer Science Basics 2', 'Intro to CS', 'Foundational computer science concepts', 'cs.jpg', 'cs.mp4', 'draft', 150, 20, 30.0, 4.6, 70, 1, 2, 6000.00, 1200.00, 'English', 49.99);
GO

-- Insert into courseRevenueByMonth
INSERT INTO courseRevenueByMonth (courseId, year, month, revenue)
VALUES
(4, 2024, 3, 2000.00),
(4, 2024, 5, 2000.00),
(4, 2024, 6, 2000.00),
(4, 2024, 7, 3000.00),
(4, 2024, 2, 3000.00),
(5, 2021, 9, 1500.00),
(5, 2022, 10, 1500.00),
(5, 2022, 11, 1500.00),
(5, 2022, 12, 1500.00),
(5, 2023, 9, 1500.00),
(5, 2023, 10, 1500.00),
(5, 2023, 11, 1500.00),
(5, 2023, 12, 1500.00),
(5, 2024, 1, 1500.00),
(5, 2024, 2, 2500.00);
GO

-- Insert into courseIntendedLearners
INSERT INTO courseIntendedLearners (courseId, intendedLearnerId, intendedLearner)
VALUES
(4, 1, 'High school students'),
(4, 2, 'Undergraduates'),
(5, 3, 'Chemistry majors'),
(5, 4, 'Science enthusiasts');
GO

-- Insert into courseRequirements
INSERT INTO courseRequirements (courseId, requirementId, requirement)
VALUES
(4, 1, 'Basic Math knowledge'),
(4, 2, 'Interest in Physics'),
(5, 3, 'Understanding of basic Chemistry concepts');
GO

-- Insert into courseObjectives
INSERT INTO courseObjectives (courseId, objectiveId, objective)
VALUES
(4, 1, 'Understand fundamental Physics concepts'),
(4, 2, 'Apply Physics in real-life scenarios'),
(5, 3, 'Master advanced Chemistry topics');
GO

-- Insert into instructorOwnCourse
INSERT INTO instructorOwnCourse (courseId, instructorId, percentageInCome)
VALUES
(4, 'user005', 80.00),
(5, 'user006', 70.00),
(6, 'user009', 90.00);
GO

-- Insert into coupon
INSERT INTO coupon (code, discountPercent, quantity, startDate, adminCreatedCoupon)
VALUES
('DISC20', 20.00, 100, '2024-08-01', 'user001'),
('CHEM30', 30.00, 50, '2024-08-01', 'user002');
GO

-- Insert into section
INSERT INTO section (id, courseId, title, learnTime)
VALUES
(1, 4, 'Introduction', 2.5),
(2, 4, 'Basic Concepts', 3.0),
(3, 4, 'Advanced Topics 1', 4.0),
(1, 5, 'Advanced Topics 1', 4.0),
(2, 5, 'Advanced Topics 2', 4.0),
(3, 5, 'Advanced Topics 3', 4.0);

GO

INSERT INTO lesson (id, sectionId, courseId, title, learnTime, type)
VALUES
(1, 1, 4, 'Introduction to Physics', 100, 'lecture'),
(2, 1, 4, 'Prerequisite Test', 100, 'exercise'),
(1, 2, 4, 'Motions and Velocity', 40, 'lecture'),
(2, 2, 4, 'Motions and Velocity Test', 40, 'exercise'),
(1, 3, 5, 'Bonds of atoms', 70, 'lecture');
GO

-- Insert into lecture
INSERT INTO lecture (id, sectionId, courseId, resource)
VALUES
(1, 1, 4, 'intro.mp4'),
(1, 2, 4, 'motion.mp4'),
(1, 3, 5, 'bonds.mp4');
GO

-- Insert into exam
INSERT INTO exercise (id, sectionId, courseId)
VALUES
(2, 1, 4),
(2, 2, 4);
GO

-- Insert into question
INSERT INTO question (id, exerciseId, sectionId, courseId, question)
VALUES
(1, 2, 1, 4, 'What is Newton''s First Law?'),
(2, 2, 1, 4, 'Explain the concept of inertia.'),
(3, 2, 1, 4, 'Some physics question 1.'),
(4, 2, 1, 4, 'Some physics question 2.'),
(1, 2, 2, 4, 'Describe the different types of chemical bonds.'),
(2, 2, 2, 4, 'What is bond?'),
(3, 2, 2, 4, 'Some physics question 1.'),
(4, 2, 2, 4, 'Some physics question 2.'),
(5, 2, 2, 4, 'Some physics question 3.');
GO

insert into questionAnswer (id, questionId, exerciseId, sectionId, courseId, questionAnswers, isCorrect) values
(1, 1, 2, 1, 4, 'Newton''s First Law is something incorrect', 0),
(2, 1, 2, 1, 4, 'Newton''s First Law is something incorrect', 0),
(3, 1, 2, 1, 4, 'Newton''s First Law is something correct', 1),
(1, 2, 2, 1, 4, 'Inertia is a phenomenon when you incorrect.', 0),
(2, 2, 2, 1, 4, 'Inertia is a phenomenon when you correct.', 1),
(1, 3, 2, 1, 4, 'Some physics answer 1 incorrect.', 0),
(2, 3, 2, 1, 4, 'Some physics answer 1 incorrect.', 0),
(3, 3, 2, 1, 4, 'Some physics answer 1 correct.', 1),
(1, 4, 2, 1, 4, 'Some physics answer 2 incorrect.', 0),
(2, 4, 2, 1, 4, 'Some physics answer 2 correct.', 1),
(1, 1, 2, 2, 4, 'Describe the different types of chemical bonds.', 0),
(2, 1, 2, 2, 4, 'Hexagonal bond appears in metal material like Fe, Cu, etc.', 1),
(3, 1, 2, 2, 4, 'Something something incorrect.', 0),
(4, 1, 2, 2, 4, 'Something something incorrect.', 0),
(1, 2, 2, 2, 4, 'Bond is how atoms are bound to each others to create a structure that ...', 1),
(2, 2, 2, 2, 4, 'Incorrect ...', 0),
(3, 2, 2, 2, 4, 'Incorrect ...', 0),
(1, 3, 2, 2, 4, 'Incorrect.', 0),
(2, 3, 2, 2, 4, 'Incorrect.', 0),
(3, 3, 2, 2, 4, 'Incorrect.', 0),
(4, 3, 2, 2, 4, 'All are incorrect.', 1),
(1, 4, 2, 2, 4, 'Correct.', 0),
(2, 4, 2, 2, 4, 'Correct.', 0),
(3, 4, 2, 2, 4, 'Correct.', 0),
(4, 4, 2, 2, 4, 'All are correct.', 1),
(1, 5, 2, 2, 4, 'Correct.', 0),
(2, 5, 2, 2, 4, 'Correct.', 0),
(3, 5, 2, 2, 4, 'Incorrect.', 0),
(4, 5, 2, 2, 4, '1 and 2 are correct.', 1);
GO


-- TEST

-- SELECT ĐỂ TEST, CỨ CHẠY HẾT MỘT NHÓM SELECT

-- BASIC
SELECT * FROM course
SELECT * FROM [user]
SELECT * FROM paymentCard
SELECT * FROM learnerpaymentCard
SELECT * FROM [instructor]
select * from vipInstructor
select * from category;
select * from subcategory;
UPDATE instructor
set vipState = 'pendingReview'
where vipState = 'pending'

-- NHỮNG CÁI LIÊN QUAN COURSE, BÀI HỌC
select * from section order by courseId;
select * from lesson;
select * from exercise; 
select * from lecture;

ALTER TABLE instructor
DROP CONSTRAINT [Instructor vipState is invalid.];

ALTER TABLE instructor
ADD CONSTRAINT [Instructor vipState must be valid.]
CHECK(vipState IN ('notVip', 'vip', 'pendingReview'));


-- NHỮNG BẢNG LIÊN QUAN VIỆC NGƯỜI DÙNG THAM GIA KHÓA HỌC
select * from learnerAnswerQuestion; 
select * from learnerDoExercise;
select * from learnerEnrollCourse
select * from learnerParticipateLesson;
select * from learnerParticipateSection;
select * from learnerReviewCourse;

-- CÂU HỎI VÀ CÂU TRẢ LỜI
select qa.questionId, q.question, questionAnswers
from question q
join questionAnswer qa on q.courseId = qa.courseId and q.sectionId = qa.sectionId and q.exerciseId = qa.exerciseId and q.id = qa.questionId
order by qa.questionId, qa.id;

-- CÂU HỎI VÀ CÂU TRẢ LỜI ĐÚNG
select qa.questionId, q.question, qa.id as questionAnswerId, questionAnswers
from question q
join questionAnswer qa on q.courseId = qa.courseId and q.sectionId = qa.sectionId and q.exerciseId = qa.exerciseId and q.id = qa.questionId
where isCorrect = 1
order by q.courseId, q.sectionId, q.exerciseId, qa.questionId;

-- PAYMENT CARD
insert into learnerPaymentCard values ('user003', '1111222233334444')

--

-- sp-cong
-- 1. sp_AD_INS_GetMonthlyRevenueOfACourse
--EXEC sp_AD_INS_GetMonthlyRevenueOfACourse
--    @courseId = 4,
--    @duration = 7
--GO
-- hiện giờ là tháng 8, chạy cái này thì chỉ cho kết quả
-- [{"year":2024,"month":2,"revenue":3000.00}]
-- trong test data có hai tháng của 2024 là 1 với 2, 
-- vậy nên 
-- 1. Sửa @duration lại thành cái gì đó dễ hiểu hơn thành @numberOfMonth hay @monthAgo
-- 2. Sửa lại để nó hợp lí hơn, nếu @numberOfMonth thì giữ cái code cũ, 
-- @monthAgo thì sửa lại code

-- 2. sp_AD_INS_GetYearlyRevenueOfACourse
-- Này thì ngược lại với cái Monthly
-- @duration là 1 thì kết quả
-- [{"year":2023,"totalRevenue":10000.00},{"year":2024,"totalRevenue":5000.00}]
-- nên bên trên làm sao thì dưới đây ngược lại

-- 3. sp_LN_UpdateLearnerPaymentCard
-- Tại sao này lại đặt là Update vậy? Không phải nó là Insert hả
-- Mà nếu chỉnh sửa paymentCard của học viên thì phải xóa learnerPaymentCard cũ?
-- Tại order thì fk với paymentCard rồi nên không có thằng nào fk với learnerPaymentCard hết

-- 4. sp_LN_ViewOrders
-- 5.1. Do này trả về nhiều nên không cần WITHOUT_ARRAY_WRAPPER
-- Trả về như thế này
-- [{"learnerId":"user003","name":"Learner One","orders":[
--{"id":3,"dateCreated":"2024-08-16T10:24:47.893","total":21.29},
--{"id":2,"dateCreated":"2024-08-16T10:22:25.437","total":28.39},
--{"id":1,"dateCreated":"2024-08-16T10:08:24.917","total":56.79}],
--"paymentCardNumber":"1111222233334444","couponCode":"LMFAO123",
--"discountPercent":29.00}]
-- Cái paymentCardNumber, couponCode, discountPercent tự nhiên gắn MAX chi vậy, sao không
-- lấy thông tin mỗi cái luôn???

-- 5. sp_UpdateCourseRevenueAndInstructorRevenue
-- Lỗi logic
-- Mình quy ước là, giá ban đầu giảng viên đưa là 70%, udemy sẽ lấy 30%, vậy nên cho dù như thế nào đi nữa
-- cho dù có coupon thì instructorrevenue vẫn là 70%, nhưng courserevenue là 85%
-- ví dụ, giờ có coupon 15%, giá là 100, thì 
-- 1) giảng viên nhận 70, instructorRevenue += 70
-- 2) udemy nhận 15
-- 3) courseRevenue += 85, chỉ trừ tiền giảm giá 15%
-- vậy thì chỉnh lại
-- @amount thay vì là @amount giá sau giảm giá, thì đổi thành @discount đi
-- vậy thì courseRevenue += @price * (100 - @discount) / 100
-- và instructorRevenue = @price * 70%

-- 6. sp_LN_GetLearnerAnswersOfExercise
-- t sửa thành trả id correct answer

-- sp-uyen
-- 1. sp_AD_INS_GetAnnualRevenueOfAInnstructor
-- đổi tên @duration thành @numberOfYear 
-- đổi tên sp thành sp_AD_INS_GetAnnualRevenueOfInnstructor nha, thường đặt tên
-- thì không nên có A, The, mấy cái đó. Có số nhiều thì có s thôi

-- 2. sp_AD_INS_GetMonthlyRevenueOfAnInstructor
-- đổi tên @duration thành @numberOfMonth nha, cho dễ hiểu
-- đổi tên sp bỏ An nha, thành sp_AD_INS_GetMonthlyRevenueOfInstructor

select * from instructorRevenueByMonth
where instructorId = 'user005'
order by year, month







-- sp-chau
-- chỉnh vipState pending thành pendingReview


-- CHECK TRIGGER ORDERID

-- CRITERIA
-- SELECT
-- 1. CORRECT AND UNDERSTANDABLE NAME
-- 2. ORDER BY
-- 3. ARRAY WRAPPER IF MANY

-- INSERT
-- 1. INSERT CORRECTLY?

select * from adminresponse;
select * from course;
insert into adminResponse (adminid, courseid, dateresponse, responseText) values
('user001', 7, '2024-08-12 18:54:46.227', 'Need fixing'),
('user001', 7, '2024-08-13 18:54:46.227', 'Something needs fixing'),
('user001', 7, '2024-08-14 18:54:46.227', 'LGTM'),
('user001', 8, '2024-08-12 18:54:46.227', 'Need fixing'),
('user001', 8, '2024-08-13 18:54:46.227', 'Something needs fixing'),
('user001', 8, '2024-08-14 18:54:46.227', 'LGTM');

select getdate()

-- check partitions

SELECT DISTINCT o.name as table_name, rv.value as partition_range, fg.name as file_groupName, p.partition_number, p.rows as number_of_rows
FROM sys.partitions p
INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
INNER JOIN sys.objects o ON p.object_id = o.object_id
INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id
INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id
INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id
INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number
INNER JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id 
LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id;

set statistics time on
SELECT *
FROM courseRevenueByMonth
WHERE year = 2024;