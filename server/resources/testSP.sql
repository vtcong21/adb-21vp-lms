USE LMS;
GO

-- Insert into user
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

-- Insert into admin
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

select * from course

-- Insert into courseRevenueByMonth
INSERT INTO courseRevenueByMonth (courseId, year, month, revenue)
VALUES
(4, 2022, 11, 2000.00),
(4, 2022, 12, 3000.00),
(4, 2023, 9, 2000.00),
(4, 2023, 10, 3000.00),
(4, 2023, 11, 2000.00),
(4, 2023, 12, 3000.00),
(4, 2024, 1, 2000.00),
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

select * from lecture
select * from exercise

-- Insert into lecture
INSERT INTO lecture (id, sectionId, courseId, resource)
VALUES
(1, 1, 4, 'Welcome to Physics', 'An overview of the course', 1.0, 'intro.mp4'),
(1, 2, 4, 'Laws of Motion', 'Understanding Newton''s Laws', 2.5, 'motion.mp4'),
(1, 3, 5, 'Chemical Bonds', 'Exploring the types of bonds', 3.5, 'bonds.mp4');
GO

-- Insert into exam
INSERT INTO exercise (sectionId, courseId)
VALUES
(1, 1),
(2, 1);
GO

-- Insert into question
INSERT INTO question (exerciseId, sectionId, courseId, question)
VALUES
(1, 1, 'What is Newton''s First Law?'),
(2, 1, 'Explain the concept of inertia.'),
(3, 2, 'Describe the different types of chemical bonds.');
GO

-- Insert into result
INSERT INTO result (learnerId, examId, grade, dateTaken)
VALUES
('user003', 1, 85, '2024-08-21'),
('user004', 1, 90, '2024-08-21'),
('user007', 2, 75, '2024-08-23'),
('user008', 2, 80, '2024-08-23');
GO
