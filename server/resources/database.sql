-- Create database
USE master
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'LMS')
    DROP DATABASE LMS
GO

CREATE DATABASE LMS
GO

USE LMS
GO

-- Create tables

CREATE FUNCTION isValidUser(@userId VARCHAR(128), @userRole VARCHAR(3))
RETURNS BIT
AS
BEGIN
    IF (EXISTS(SELECT id FROM [user] WHERE id = @userId AND role = @userRole))
        RETURN 1

    RETURN 0
END
GO

-- Table user
IF OBJECT_ID('user', 'U') IS NOT NULL
    DROP TABLE [user]
GO

CREATE TABLE [user]
(
    id NVARCHAR(128) NOT NULL,
    email VARCHAR(256) NOT NULL,
    name NVARCHAR(128) NOT NULL,
    password VARCHAR(128) NOT NULL,
    profilePhoto NVARCHAR(256) NOT NULL,
    role VARCHAR(3) NOT NULL,

	CONSTRAINT [User id is required.] CHECK(LEN(id) > 0),
	CONSTRAINT [User email format is invalid.] CHECK(email LIKE '_%@_%._%'),
	CONSTRAINT [A user with this email already exists.] UNIQUE(email),
	CONSTRAINT [User name is required.] CHECK(LEN(name) > 0),
	CONSTRAINT [User password must be at least 5 characters long.] CHECK(LEN(password) > 4),
	CONSTRAINT [User profile photo is required.] CHECK(LEN(profilePhoto) > 0),
	CONSTRAINT [User role is invalid.] CHECK (role IN ('AD', 'LN', 'INS')),
    
    CONSTRAINT [PK_user] PRIMARY KEY (id)
);
GO

-- Table admin
IF OBJECT_ID('admin', 'U') IS NOT NULL
    DROP TABLE [admin]
GO

CREATE TABLE [admin]
(
    id NVARCHAR(128) NOT NULL,
    
	CONSTRAINT [Admin id is required.] CHECK(LEN(id) > 0),
	CONSTRAINT [Admin id is invalid.] CHECK([dbo].isValidUser(id, 'AD') = 1),
    
    CONSTRAINT [PK_admin] PRIMARY KEY (id),

	CONSTRAINT [FK_admin_user] FOREIGN KEY (id) REFERENCES [user](id)
);
GO

CREATE FUNCTION isValidCourseMember(@courseMemberId VARCHAR(128), @courseMemberRole VARCHAR(3))
RETURNS BIT
AS
BEGIN
    IF (EXISTS(SELECT id FROM [courseMember] WHERE id = @courseMemberId AND role = @courseMemberRole))
        RETURN 1

    RETURN 0
END
GO
-- Table course member
IF OBJECT_ID('courseMember', 'U') IS NOT NULL
    DROP TABLE [courseMember]
GO

CREATE TABLE [courseMember]
(
    id NVARCHAR(128) NOT NULL,
	role VARCHAR(3) NOT NULL,
    
	CONSTRAINT [Course member id is required.] CHECK(LEN(id) > 0),
	CONSTRAINT [Course member id is invalid.] CHECK([dbo].isValidUser(id, 'LN') = 1 OR [dbo].isValidUser(id, 'INS') = 1),
    CONSTRAINT [Course member role is invalid.] CHECK (role IN ('LN', 'INS')),

    CONSTRAINT [PK_courseMember] PRIMARY KEY (id),

	CONSTRAINT [FK_courseMember_user] FOREIGN KEY (id) REFERENCES [user](id)
																	         
);
GO

-- Table learner
IF OBJECT_ID('learner', 'U') IS NOT NULL
    DROP TABLE [learner]
GO

CREATE TABLE [learner]
(
    id NVARCHAR(128) NOT NULL,
    
	CONSTRAINT [Learner id is required.] CHECK(LEN(id) > 0),
	CONSTRAINT [Learner id is invalid.] CHECK([dbo].isValidCourseMember(id, 'LN') = 1),

    CONSTRAINT [PK_learner] PRIMARY KEY (id),

	CONSTRAINT [FK_learner_courseMember] FOREIGN KEY (id) REFERENCES [courseMember](id)
																						
);
GO

-- Table instructor
IF OBJECT_ID('instructor', 'U') IS NOT NULL
    DROP TABLE [instructor]
GO

CREATE TABLE [instructor]
(
    id NVARCHAR(128) NOT NULL,
    gender CHAR(1) NOT NULL ,
    phone VARCHAR(11) NOT NULL ,
    DOB DATE NOT NULL,
    address NVARCHAR(256) NOT NULL,
    degrees NVARCHAR(512) NOT NULL,
    workplace NVARCHAR(256) NOT NULL,
    scientificBackground NVARCHAR(512) NOT NULL,
    vipState VARCHAR(7) NOT NULL DEFAULT 'notVip',
    totalRevenue DECIMAL(18, 2) NOT NULL DEFAULT 0,
    
	CONSTRAINT [Instructor id is required.] CHECK(LEN(id) > 0),
	CONSTRAINT [Instructor id is invalid.] CHECK([dbo].isValidCourseMember(id, 'INS') = 1),
	CONSTRAINT [Instructor gender is invalid.] CHECK(gender IN ('M', 'F')),
	CONSTRAINT [Instructor phone number must be 10 to 11 digits long.] CHECK(LEN(phone) BETWEEN 10 AND 11 AND ISNUMERIC(phone) = 1),
	CONSTRAINT [Instructor address is required.] CHECK(LEN(address) > 0),
	CONSTRAINT [Instructor degrees is required.] CHECK(LEN(degrees) > 0),
	CONSTRAINT [Instructor scientific background is required.] CHECK(LEN(scientificBackground) > 0),
	CONSTRAINT [Instructor vipState is invalid.] CHECK(vipState IN ('notVip', 'vip', 'pendingReview')),
	CONSTRAINT [Instructor total revenue must be non-negative.] CHECK(totalRevenue >= 0),

    CONSTRAINT [PK_instructor] PRIMARY KEY (id),

	CONSTRAINT [FK_instructor_courseMember] FOREIGN KEY (id) REFERENCES [courseMember](id)
																						   
);
GO

CREATE FUNCTION isValidVipInstructor(@vipInstructorId VARCHAR(128))
RETURNS BIT
AS
BEGIN
    IF (EXISTS(SELECT id FROM [instructor] WHERE id = @vipInstructorId AND vipState = 'vip'))
        RETURN 1

    RETURN 0
END
GO

-- Table instructor revenue by month
IF OBJECT_ID('instructorRevenueByMonth', 'U') IS NOT NULL
    DROP TABLE [instructorRevenueByMonth]
GO	

CREATE TABLE [instructorRevenueByMonth]
(
    instructorId NVARCHAR(128) NOT NULL,
    year int NOT NULL,
	month int NOT NULL,
	revenue DECIMAL(18, 2) NOT NULL DEFAULT 0,

	CONSTRAINT [Year of instructor revenue by month must be greater than 1900.]  CHECK(year >= 1900),
	CONSTRAINT [Month of instructor revenue by month must be between 1 and 12.]  CHECK(month BETWEEN 1 AND 12),
	CONSTRAINT [Instructor revenue by month must be non-negative.]  CHECK(revenue >= 0),

    CONSTRAINT [PK_instructorRevenueByMonth] PRIMARY KEY(instructorId, year, month),

    CONSTRAINT [FK_instructorRevenueByMonth_instructor] FOREIGN KEY (instructorId) REFERENCES [instructor](id),
);
GO

-- Table payment card
IF OBJECT_ID('paymentCard', 'U') IS NOT NULL
    DROP TABLE [paymentCard]
GO

CREATE TABLE [paymentCard]
(
    number VARCHAR(16) NOT NULL,
    type VARCHAR(6) NOT NULL,
    name NVARCHAR(128) NOT NULL,
    CVC CHAR(3) NOT NULL,
    expireDate DATE NOT NULL,
    
	CONSTRAINT [Card number is required.] CHECK(LEN(number) > 0),
    CONSTRAINT [Card number must be 16 digits long.] CHECK(number LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    CONSTRAINT [Card CVC must be 3 digits long.] CHECK(CVC LIKE '[0-9][0-9][0-9]'),
	CONSTRAINT [Card type is invalid.] CHECK(type IN ('Debit', 'Credit')),
	CONSTRAINT [Card name is required.] CHECK(LEN(name) > 0),
    CONSTRAINT [Expiration date must be on or after today.] CHECK(expireDate >= GETDATE()),
    
    CONSTRAINT [PK_paymentCard] PRIMARY KEY(number)
);
GO

-- Table vip instructor
IF OBJECT_ID('vipInstructor', 'U') IS NOT NULL
    DROP TABLE [vipInstructor]
GO

CREATE TABLE [vipInstructor]
(
    id NVARCHAR(128) NOT NULL,
    paymentCardNumber VARCHAR(16) NOT NULL,
    
	CONSTRAINT [VIP instructor id is required.] CHECK(LEN(id) > 0),
	CONSTRAINT [VIP instructor id is invalid.] CHECK([dbo].isValidVipInstructor(id) = 1),

    CONSTRAINT [PK_vipInstructor] PRIMARY KEY (id),

	CONSTRAINT [FK_vipInstructor_instructor] FOREIGN KEY (id) REFERENCES [instructor](id)
																						  ,
	CONSTRAINT [FK_vipInstructor_paymentCard] FOREIGN KEY (paymentCardNumber) REFERENCES [paymentCard](number)
);
GO

-- Table tax form
IF OBJECT_ID('taxForm', 'U') IS NOT NULL
    DROP TABLE [taxForm]
GO

CREATE TABLE [taxForm]
(
    submissionDate DATE NOT NULL DEFAULT GETDATE(),
    fullName NVARCHAR(128) NOT NULL,
    address NVARCHAR(256) NOT NULL,
    phone VARCHAR(11) NOT NULL,
    taxCode VARCHAR(50) NOT NULL,
    identityNumber CHAR(12) NOT NULL,
    postCode CHAR(5) NOT NULL,
    vipInstructorId NVARCHAR(128) NOT NULL,
    
	CONSTRAINT [Submission date must be before today.] CHECK(submissionDate <= GETDATE()),
    CONSTRAINT [Full name is required.] CHECK(LEN(fullName) > 0),
    CONSTRAINT [Address is required.] CHECK(LEN(address) > 0),
	CONSTRAINT [Phone number must be 10 to 11 digits long.] CHECK(LEN(phone) BETWEEN 10 AND 11 AND ISNUMERIC(phone) = 1),
    CONSTRAINT [Tax code must be 10 to 13 digits long.] CHECK(LEN(taxCode) BETWEEN 10 AND 13 AND ISNUMERIC(taxCode) = 1),
    CONSTRAINT [ID number must be 12 digits long.] CHECK(LEN(identityNumber) = 12 AND ISNUMERIC(identityNumber) = 1),
    CONSTRAINT [Postal code must be 5 digits long.] CHECK(LEN(postCode) = 5 AND ISNUMERIC(identityNumber) = 1),

    CONSTRAINT [PK_taxForm] PRIMARY KEY(vipInstructorId),

    CONSTRAINT [FK_taxForm_instructor] FOREIGN KEY (vipInstructorId) REFERENCES [instructor](id) 																								   
);
GO

-- Table category
IF OBJECT_ID('category', 'U') IS NOT NULL
    DROP TABLE [category]
GO

CREATE TABLE [category]
(
    id INT IDENTITY(1,1) NOT NULL,
	name NVARCHAR(128) NOT NULL,
    
    CONSTRAINT [Category name is required.] CHECK(LEN(name) > 0),
	CONSTRAINT [A category with this name already exists.] UNIQUE(name),

    CONSTRAINT [PK_category] PRIMARY KEY(id)
);
GO

-- Table sub category
IF OBJECT_ID('subCategory', 'U') IS NOT NULL
    DROP TABLE [subCategory]
GO

CREATE TABLE [subCategory]
(
    id INT NOT NULL,
	parentCategoryId INT NOT NULL,
    numberOfLearners INT NOT NULL DEFAULT 0,
    averageRating DECIMAL(3, 2) NOT NULL DEFAULT 0,
    numberOfCourses INT NOT NULL DEFAULT 0,
    name NVARCHAR(128) NOT NULL CHECK(LEN(name) > 0),
    
	CONSTRAINT [Number of learners must be non-negative.] CHECK(numberOfLearners >= 0),
	CONSTRAINT [Sub Category average rating must be from 0 to 5.] CHECK(averageRating BETWEEN 0 AND 5),
	CONSTRAINT [Number of courses must be non-negative.] CHECK(numberOfCourses >= 0),
    CONSTRAINT [Sub category name is required.] CHECK(LEN(name) > 0),
	CONSTRAINT [A Sub category with this name already exists.] UNIQUE(name),

    CONSTRAINT [PK_subCategory] PRIMARY KEY(id, parentCategoryId),

	CONSTRAINT [FK_subCategory_category] FOREIGN KEY (parentCategoryId) REFERENCES [category](id)
);
GO

-- Table course
IF OBJECT_ID('course', 'U') IS NOT NULL
    DROP TABLE [course]
GO

CREATE TABLE [course]
(
    id INT NOT NULL IDENTITY(1,1),
    title NVARCHAR(256) NOT NULL,
    subTitle NVARCHAR(256) NOT NULL,
    description NVARCHAR(MAX) NOT NULL,
    image NVARCHAR(256) NOT NULL,
    video NVARCHAR(256) NOT NULL,
    state NVARCHAR(15) NOT NULL DEFAULT 'draft',
    numberOfStudents INT NOT NULL DEFAULT 0,
    numberOfLectures INT NOT NULL DEFAULT 0,
    totalTime DECIMAL(10, 2) NOT NULL DEFAULT 0,
    averageRating DECIMAL(3, 2) NOT NULL DEFAULT 0,
    ratingCount INT NOT NULL DEFAULT 0,
    subCategoryId INT NOT NULL,
    categoryId INT NOT NULL,
    totalRevenue DECIMAL(18, 2) NOT NULL DEFAULT 0,
    
    language NVARCHAR(50) NOT NULL,
    price DECIMAL(18, 2) NOT NULL,
    lastUpdateTime DATETIME NOT NULL DEFAULT GETDATE(),
    
	CONSTRAINT [Course title is required.] CHECK(LEN(title) > 0),
	CONSTRAINT [A course with this title already exists.] UNIQUE(title),
	CONSTRAINT [Course sub title is required.] CHECK(LEN(subTitle) > 0),
	CONSTRAINT [Course description is required.] CHECK(LEN(description) > 0),
	CONSTRAINT [Course image is required.] CHECK(LEN(image) > 0),
	CONSTRAINT [Course video is required.] CHECK(LEN(video) > 0),
	CONSTRAINT [Course state is invalid.] CHECK(state IN ('draft', 'pendingReview', 'public')),
	CONSTRAINT [Number of students must be non-negative.] CHECK(numberOfStudents >= 0),
	CONSTRAINT [Number of lectures must be non-negative.] CHECK(numberOfLectures >= 0),
	CONSTRAINT [Course total time must be non-negative.]  CHECK(totalTime >= 0),
	CONSTRAINT [Course average rating must be from 0 to 5.] CHECK(averageRating BETWEEN 0 AND 5),
	CONSTRAINT [Course total revenue must be non-negative.]  CHECK(totalRevenue >= 0),
	CONSTRAINT [Course language is required.] CHECK(LEN(language) > 0),
	CONSTRAINT [Course price must be non-negative.]  CHECK(price >= 0),
	CONSTRAINT [Course last update time must be before today.]  CHECK(lastUpdateTime <= GETDATE()),

    CONSTRAINT [PK_course] PRIMARY KEY(id),

    CONSTRAINT [FK_course_subCategory] FOREIGN KEY (subCategoryId, categoryId) REFERENCES [subCategory](id, parentcategoryID),
);
GO

-- Table course revenue by month
IF OBJECT_ID('courseRevenueByMonth', 'U') IS NOT NULL
    DROP TABLE [courseRevenueByMonth]
GO	

CREATE TABLE [courseRevenueByMonth]
(
    courseId INT NOT NULL,
    year int NOT NULL,
	month int NOT NULL,
	revenue DECIMAL(18, 2) NOT NULL DEFAULT 0,

	CONSTRAINT [Year of course revenue by month must be greater than 1900.]  CHECK(year >= 1900),
	CONSTRAINT [Month of course revenue by month must be between 1 and 12.]  CHECK(month BETWEEN 1 AND 12),
	CONSTRAINT [Course revenue by month must be non-negative.]  CHECK(revenue >= 0),

    CONSTRAINT [PK_courseRevenueByMonth] PRIMARY KEY(courseId, year, month),

    CONSTRAINT [FK_courseRevenueByMonth_course] FOREIGN KEY (courseId) REFERENCES [course](id),
);
GO

-- Table course intended learners
IF OBJECT_ID('courseIntendedLearners', 'U') IS NOT NULL
    DROP TABLE [courseIntendedLearners]
GO	

CREATE TABLE [courseIntendedLearners]
(
    courseId INT NOT NULL,
	intendedLearnerId INT NOT NULL,
    intendedLearner NVARCHAR(256) NOT NULL,
 
	CONSTRAINT [Course intended leaner is required.] CHECK(LEN(intendedLearner) > 0),

    CONSTRAINT [PK_courseIntendedLearners] PRIMARY KEY(courseId, intendedLearnerId),

    CONSTRAINT [FK_courseIntendedLearners_course] FOREIGN KEY (courseId) REFERENCES [course](id),
);
GO

-- Table course requirements
IF OBJECT_ID('courseRequirements', 'U') IS NOT NULL
    DROP TABLE [courseRequirements]
GO	

CREATE TABLE [courseRequirements]
(
    courseId INT NOT NULL,
	requirementId INT NOT NULL,
    requirement NVARCHAR(256) NOT NULL,
 
	CONSTRAINT [Course requirement is required.] CHECK(LEN(requirement) > 0),

    CONSTRAINT [PK_courseRequirements] PRIMARY KEY(courseId, requirementId),

    CONSTRAINT [FK_courseRequirements_course] FOREIGN KEY (courseId) REFERENCES [course](id),
);
GO

-- Table course objectives
IF OBJECT_ID('courseObjectives', 'U') IS NOT NULL
    DROP TABLE [courseObjectives]
GO	

CREATE TABLE [courseObjectives]
(
    courseId INT NOT NULL,
	objectiveId INT NOT NULL,
    objective NVARCHAR(256) NOT NULL,
 
	CONSTRAINT [Course objective is required.] CHECK(LEN(objective) > 0),

    CONSTRAINT [PK_courseObjectives] PRIMARY KEY(courseId, objectiveId),

    CONSTRAINT [FK_courseObjectives_course] FOREIGN KEY (courseId) REFERENCES [course](id),
);
GO

-- Table instructor own course
IF OBJECT_ID('instructorOwnCourse', 'U') IS NOT NULL
    DROP TABLE [instructorOwnCourse]
GO	

CREATE TABLE [instructorOwnCourse]
(
    courseId INT NOT NULL,
	instructorId NVARCHAR(128) NOT NULL,
	percentageInCome DECIMAL(5, 2) NOT NULL,
 
	CONSTRAINT [Instructor percentage in come must be between 0 and 100.] CHECK(percentageInCome > 0 AND percentageInCome <= 100),
    
	CONSTRAINT [PK_instructorOwnCourse] PRIMARY KEY(courseId, instructorId),

    CONSTRAINT [FK_instructorOwnCourse_course] FOREIGN KEY (courseId) REFERENCES [course](id),
	CONSTRAINT [FK_instructorOwnCourse_instructor] FOREIGN KEY (instructorId) REFERENCES [instructor](id),
);
GO

-- Table coupon
IF OBJECT_ID('coupon', 'U') IS NOT NULL
    DROP TABLE [coupon]
GO	

CREATE TABLE [coupon]	
(
    code VARCHAR(20) NOT NULL,
    discountPercent DECIMAL(5, 2) NOT NULL,
    quantity INT NOT NULL,
    startDate DATE NOT NULL,
    adminCreatedCoupon NVARCHAR(128) NOT NULL,
    
    CONSTRAINT [Coupon code is required.] CHECK(LEN(code) > 0),
	CONSTRAINT [Coupon discount percent must be between 0% and 100%.] CHECK(discountPercent >= 0 AND discountPercent <= 100),
	CONSTRAINT [Coupon quantity must be non-negative.] CHECK(quantity >= 0),
    CONSTRAINT [Admin created coupon is required.] CHECK(LEN(adminCreatedCoupon) > 0),

    CONSTRAINT [PK_coupon] PRIMARY KEY(code),

    CONSTRAINT [FK_coupon_admin] FOREIGN KEY (adminCreatedCoupon) REFERENCES [admin](id) 
);
GO

-- Table section
IF OBJECT_ID('section', 'U') IS NOT NULL
    DROP TABLE [section]
GO	

CREATE TABLE [section]
(
    id INT NOT NULL,
    courseId INT NOT NULL,
    title NVARCHAR(256) NOT NULL,
    learnTime DECIMAL(5, 2) NOT NULL DEFAULT 0,

	CONSTRAINT [Secion title is required.] CHECK(LEN(title) > 0),
	CONSTRAINT [Secion learn time must be non-negative.] CHECK(learnTime >= 0),
    
    CONSTRAINT [PK_section] PRIMARY KEY(id, courseId),

    CONSTRAINT [FK_section_course] FOREIGN KEY (courseId) REFERENCES [course](id) 
);
GO

-- Table lesson
IF OBJECT_ID('lesson', 'U') IS NOT NULL
    DROP TABLE [lesson]
GO	

CREATE TABLE [lesson]
(
    id INT NOT NULL,
	sectionId INT NOT NULL,
    courseId INT NOT NULL,
    title NVARCHAR(256) NOT NULL,
    learnTime DECIMAL(5, 2) NOT NULL DEFAULT 0,
	type VARCHAR(10),

	CONSTRAINT [Lesson title is required.] CHECK(LEN(title) > 0),
	CONSTRAINT [Lesson learn time must be non-negative.] CHECK(learnTime >= 0),
	CONSTRAINT [Lesson type must be 'exercise' or 'lecture'.] CHECK (type IN ('lecture', 'exercise')),
    
    CONSTRAINT [PK_lesson] PRIMARY KEY(id, sectionId, courseId),

    CONSTRAINT [FK_lesson_section] FOREIGN KEY (sectionId, courseId) REFERENCES [section](id, courseId) 
);
GO

CREATE FUNCTION isValidLesson(@lessonId VARCHAR(128), @lessonType VARCHAR(10))
RETURNS BIT
AS
BEGIN
    IF (EXISTS(SELECT id FROM [lesson] WHERE id = @lessonId AND type = @lessonType))
        RETURN 1

    RETURN 0
END
GO

-- Table lecture
IF OBJECT_ID('lecture', 'U') IS NOT NULL
    DROP TABLE [lecture]
GO	

CREATE TABLE [lecture]
(
	id INT NOT NULL,
	sectionId INT  NOT NULL,
    courseId INT NOT NULL,
    resource NVARCHAR(256) NOT NULL,

	CONSTRAINT [Lecture resource is required.] CHECK(LEN(resource) > 0),
	CONSTRAINT [Invalid lecture, Lesson ID not found or Lesson Type invalid.] CHECK([dbo].isValidLesson(id, 'lecture') = 1),
    
    CONSTRAINT [PK_lecture] PRIMARY KEY(id, sectionId, courseId),

    CONSTRAINT [FK_lecture_lesson] FOREIGN KEY (id, sectionId, courseId) REFERENCES [lesson](id, sectionId, courseId)
);
GO

-- Table exercise
IF OBJECT_ID('exercise', 'U') IS NOT NULL
    DROP TABLE [exercise]
GO	

CREATE TABLE [exercise]
(
    id INT NOT NULL,
	sectionId INT NOT NULL,
    courseId INT NOT NULL,

	CONSTRAINT [Excercise id is invalid.] CHECK([dbo].isValidLesson(id, 'exercise') = 1),
    
    CONSTRAINT [PK_exercise] PRIMARY KEY(id, sectionId, courseId),

    CONSTRAINT [FK_exercise_lesson] FOREIGN KEY (id, sectionId, courseId) REFERENCES [lesson](id, sectionId, courseId)
);
GO

-- Table question
IF OBJECT_ID('question', 'U') IS NOT NULL
    DROP TABLE [question]
GO	

CREATE TABLE [question]
(
	id INT NOT NULL,
    exerciseId INT NOT NULL,
	sectionId INT NOT NULL,
    courseId INT NOT NULL,
	question NVARCHAR(2000) NOT NULL,

	CONSTRAINT [Question is required.] CHECK(LEN(question) > 0),
    
    CONSTRAINT [PK_question] PRIMARY KEY(id, exerciseId, sectionId, courseId),

    CONSTRAINT [FK_question_exercise] FOREIGN KEY (exerciseId, sectionId, courseId) REFERENCES [exercise](id, sectionId, courseId)
);
GO

-- Table question answer
IF OBJECT_ID('questionAnswer', 'U') IS NOT NULL
    DROP TABLE [questionAnswer]
GO	

CREATE TABLE [questionAnswer]
(
	id INT NOT NULL,
	questionId INT NOT NULL,
    exerciseId INT NOT NULL,
	sectionId INT NOT NULL,
    courseId INT NOT NULL,
	questionAnswers NVARCHAR(2000) NOT NULL,
	isCorrect BIT NOT NULL,

	CONSTRAINT [Question answers are required.] CHECK(LEN(questionAnswers) > 0),
    
    CONSTRAINT [PK_questionAnswer] PRIMARY KEY(id, questionId, exerciseId, sectionId, courseId),

    CONSTRAINT [FK_questionAnswer_question] FOREIGN KEY (questionId, exerciseId, sectionId, courseId) REFERENCES [question](id, exerciseId, sectionId, courseId)
);
GO

-- Table learner answer question
IF OBJECT_ID('learnerAnswerQuestion', 'U') IS NOT NULL
    DROP TABLE [learnerAnswerQuestion]
GO	

CREATE TABLE [learnerAnswerQuestion]
(
	learnerId NVARCHAR(128) NOT NULL,
	questionId INT NOT NULL,
    exerciseId INT NOT NULL,
	sectionId INT NOT NULL,
    courseId INT NOT NULL,
	learnerAnswer INT NOT NULL,

    CONSTRAINT [PK_learnerAnswerQuestion] PRIMARY KEY(learnerId, questionId, exerciseId, sectionId, courseId),

    CONSTRAINT [FK_learnerAnswerQuestion_question] FOREIGN KEY (questionId, exerciseId, sectionId, courseId) REFERENCES [question](id, exerciseId, sectionId, courseId),
	CONSTRAINT [FK_learnerAnswerQuestion_learner] FOREIGN KEY (learnerId) REFERENCES [learner](id)
);
GO

-- Table learner participate lesson	
IF OBJECT_ID('learnerParticipateLesson', 'U') IS NOT NULL
    DROP TABLE [learnerParticipateLesson]
GO	

CREATE TABLE [learnerParticipateLesson]
(
	learnerId NVARCHAR(128) NOT NULL,
    courseId INT NOT NULL,
	sectionId INT NOT NULL,
    lessonId INT NOT NULL,
	isCompletedLesson BIT NOT NULL DEFAULT 0,

    CONSTRAINT [PK_learnerParticipateLesson] PRIMARY KEY(learnerId, lessonId, sectionId, courseId),

    CONSTRAINT [FK_learnerParticipateLesson_lesson] FOREIGN KEY (lessonId, sectionId, courseId) REFERENCES [lesson](id, sectionId, courseId),
	CONSTRAINT [FK_learnerParticipateLesson_learner] FOREIGN KEY (learnerId) REFERENCES [learner](id)
);
GO

-- Table learner do exercise	
IF OBJECT_ID('learnerDoExercise', 'U') IS NOT NULL
    DROP TABLE [learnerDoExercise]
GO	

CREATE TABLE [learnerDoExercise]
(
	learnerId NVARCHAR(128) NOT NULL,
    courseId INT NOT NULL,
	sectionId INT NOT NULL,
    lessonId INT NOT NULL,
	learnerScore DECIMAL(3, 1)

	CONSTRAINT [Learner score must be from 1 to 10.] CHECK (LearnerScore BETWEEN 0.0 AND 10.0),

	CONSTRAINT [PK_learnerDoExercise] PRIMARY KEY(learnerId, lessonId, sectionId, courseId),

    CONSTRAINT [FK_learnerDoExercise_exercise] FOREIGN KEY (lessonId, sectionId, courseId) REFERENCES [exercise](id, sectionId, courseId),
	CONSTRAINT [FK_learnerDoExercise_learner] FOREIGN KEY (learnerId) REFERENCES [learner](id)
);
GO

-- Table learner participate section	
IF OBJECT_ID('learnerParticipateSection', 'U') IS NOT NULL
    DROP TABLE [learnerParticipateSection]
GO	

CREATE TABLE [learnerParticipateSection]
(
	learnerId NVARCHAR(128) NOT NULL,
    courseId INT NOT NULL,
	sectionId INT NOT NULL,
	completionPercentSection DECIMAL(5, 2) NOT NULL DEFAULT 0,

	CONSTRAINT [Completion percentage section must be between 0 and 100.] CHECK(completionPercentSection BETWEEN 0 AND 100),

    CONSTRAINT [PK_learnerParticipateSection] PRIMARY KEY(learnerId, sectionId, courseId),

    CONSTRAINT [FK_learnerParticipateSection_section] FOREIGN KEY (sectionId, courseId) REFERENCES [section](id, courseId),
	CONSTRAINT [FK_learnerParticipateSection_learner] FOREIGN KEY (learnerId) REFERENCES [learner](id)
);
GO

-- Table admin response
IF OBJECT_ID('adminResponse', 'U') IS NOT NULL
    DROP TABLE [adminResponse]
GO	

CREATE TABLE [adminResponse]
(
	id INT NOT NULL,
	adminId NVARCHAR(128) NOT NULL,
    courseId INT NOT NULL,
	dateResponse DATE NOT NULL DEFAULT GETDATE(),
	responseText NVARCHAR(MAX) NOT NULL,

	CONSTRAINT [Admin response text is required.] CHECK(LEN(responseText) > 0),
	CONSTRAINT [Admin date response must be before today.] CHECK(dateResponse <= GETDATE()),

    CONSTRAINT [PK_adminResponse] PRIMARY KEY(courseId, adminId, id),

    CONSTRAINT [FK_adminResponse_admin] FOREIGN KEY (adminId) REFERENCES [admin](id),
	CONSTRAINT [FK_adminResponse_course] FOREIGN KEY (courseId) REFERENCES [course](id)
);
GO

-- Table cart detail
IF OBJECT_ID('cartDetail', 'U') IS NOT NULL
    DROP TABLE [cartDetail]
GO	

CREATE TABLE [cartDetail]
(
	learnerId NVARCHAR(128) NOT NULL,
    courseId INT NOT NULL,

    CONSTRAINT [PK_cartDetail] PRIMARY KEY(learnerId, courseId),

    CONSTRAINT [FK_cartDetail_learner] FOREIGN KEY (learnerId) REFERENCES [learner](id),
	CONSTRAINT [FK_cartDetail_course] FOREIGN KEY (courseId) REFERENCES [course](id)
);
GO

-- Table message
IF OBJECT_ID('message', 'U') IS NOT NULL
    DROP TABLE [message]
GO	

CREATE TABLE [message]	
(
	id INT NOT NULL,
    content NVARCHAR(MAX) NOT NULL,
    isRead BIT NOT NULL DEFAULT 0,
    senderId NVARCHAR(128) NOT NULL,
    receiverId NVARCHAR(128) NOT NULL,
    sentTime DATETIME NOT NULL DEFAULT GETDATE(),

	CONSTRAINT [Message sent time must be before today.] CHECK(sentTime <= GETDATE()),
    
    CONSTRAINT [PK_message] PRIMARY KEY(senderId, receiverId, id),

	CONSTRAINT [FK_messageSender_courseMember] FOREIGN KEY (senderId) REFERENCES [courseMember](id),
	CONSTRAINT [FK_messageReceiver_courseMember] FOREIGN KEY (receiverId) REFERENCES [courseMember](id)
);
GO

-- Table order
IF OBJECT_ID('order', 'U') IS NOT NULL
    DROP TABLE [order]
GO

CREATE TABLE [order]
(
    id INT NOT NULL,
    learnerId NVARCHAR(128) NOT NULL,
    dateCreated DATETIME NOT NULL DEFAULT GETDATE(),
    total DECIMAL(18, 2) NOT NULL,
    paymentCardNumber VARCHAR(16) NOT NULL,
    couponCode VARCHAR(20),

	CONSTRAINT [Date created order must be before today.] CHECK(dateCreated <= GETDATE()),

    CONSTRAINT [PK_order] PRIMARY KEY(learnerId, id),
    
    CONSTRAINT [FK_order_learner] FOREIGN KEY (learnerId) REFERENCES [learner](id),
    CONSTRAINT [FK_order_paymentCard] FOREIGN KEY (paymentCardNumber) REFERENCES [paymentCard](number),
    CONSTRAINT [FK_order_coupon] FOREIGN KEY (couponCode) REFERENCES [coupon](code)
);
GO

-- Table order detail
IF OBJECT_ID('orderDetail', 'U') IS NOT NULL
	DROP TABLE [orderDetail]
GO

CREATE TABLE [orderDetail]
(
	id INT NOT NULL,
	orderId INT NOT NULL,
	learnerId NVARCHAR(128) NOT NULL,
	courseId INT NOT NULL,
	coursePrice DECIMAL(18, 2) NOT NULL,

	CONSTRAINT [PK_ORDER_DETAIL] PRIMARY KEY(id, orderId),
    
	CONSTRAINT [FK_orderDetail_learner] FOREIGN KEY (learnerId) REFERENCES [learner](id),
	CONSTRAINT [FK_orderDetail_course] FOREIGN KEY (courseId) REFERENCES [course](id),
);
GO

-- Table learner payment card
IF OBJECT_ID('learnerPaymentCard', 'U') IS NOT NULL
    DROP TABLE [learnerPaymentCard]
GO

CREATE TABLE [learnerPaymentCard]
(
    learnerId NVARCHAR(128) NOT NULL,
    paymentCardNumber VARCHAR(16) NOT NULL,
    
    CONSTRAINT [PK_learnerPaymentCard] PRIMARY KEY(learnerId, paymentCardNumber),
    
    CONSTRAINT [FK_learnerPaymentCard_learner] FOREIGN KEY (learnerId) REFERENCES [learner](id),
    CONSTRAINT [FK_learnerPaymentCard_paymentCard] FOREIGN KEY (paymentCardNumber) REFERENCES [paymentCard](number),
);
GO

-- Table learner enroll course
IF OBJECT_ID('learnerEnrollCourse', 'U') IS NOT NULL
    DROP TABLE [learnerEnrollCourse]
GO

CREATE TABLE [learnerEnrollCourse]
(
    courseId INT NOT NULL,
    learnerId NVARCHAR(128) NOT NULL,
    learnerScore DECIMAL(3, 1),
    completionPercentInCourse DECIMAL(5, 2) DEFAULT 0,

	CONSTRAINT [Learner score  must be from 1 to 10.] CHECK (LearnerScore BETWEEN 0.0 AND 10.0),
	CONSTRAINT [Conpletion percent in course must be between 0 and 100.] CHECK(completionPercentInCourse BETWEEN 0 AND 100),

    CONSTRAINT [PK_learnerEnrollCourse] PRIMARY KEY(CourseId, LearnerId),
    
    CONSTRAINT [FK_learnerEnrollCourse_course] FOREIGN KEY (courseId) REFERENCES [course](id),
    CONSTRAINT [FK_learnerEnrollCourse_learner] FOREIGN KEY (learnerId) REFERENCES [learner](id)
);
GO

-- Table learner review course
IF OBJECT_ID('learnerReviewCourse', 'U') IS NOT NULL
    DROP TABLE [learnerReviewCourse]
GO

CREATE TABLE [learnerReviewCourse]
(
    courseId INT NOT NULL,
    learnerId NVARCHAR(128) NOT NULL,
    review NVARCHAR(MAX) NOT NULL,
    rating DECIMAL(3, 2) NOT NULL,
    date DATE NOT NULL DEFAULT GETDATE(),

	CONSTRAINT [Learner reivew course is required.] CHECK(LEN(review) > 0),
	CONSTRAINT [Learner rating course must be between 0 and  5.] CHECK(rating BETWEEN 0 AND 5),
	CONSTRAINT [Review date must be before today.] CHECK(date <= GETDATE()),


    CONSTRAINT [PK_learnerReviewCourse] PRIMARY KEY(CourseId, LearnerId),
    
    CONSTRAINT [FK_learnerReviewCourse_course] FOREIGN KEY (courseId) REFERENCES [course](id),
    CONSTRAINT [FK_learnerReviewCourse_learner] FOREIGN KEY (learnerId) REFERENCES [learner](id)
);
GO

-- Table post
IF OBJECT_ID('post', 'U') IS NOT NULL
    DROP TABLE [post]
GO

CREATE TABLE [post]
(
    id INT NOT NULL,
    date DATETIME NOT NULL DEFAULT GETDATE(),
    courseId INT NOT NULL,
    publisher NVARCHAR(128) NOT NULL,
    content NVARCHAR(MAX) NOT NULL,

	CONSTRAINT [Post date must be before today.] CHECK(date <= GETDATE()),
	CONSTRAINT [Post content is required.] CHECK(LEN(content) > 0),

    CONSTRAINT [PK_post] PRIMARY KEY(id, courseId, publisher),

    CONSTRAINT [FK_post_course] FOREIGN KEY (CourseId) REFERENCES [course](id),
	CONSTRAINT [FK_post_courseMember] FOREIGN KEY (publisher) REFERENCES [courseMember](id)
);
GO

-- Table post notification
IF OBJECT_ID('postNotification', 'U') IS NOT NULL
    DROP TABLE [postNotification]
GO

CREATE TABLE [postNotification]
(
    postId INT NOT NULL,
    courseId INT NOT NULL,
    postPublisher NVARCHAR(128) NOT NULL,
    memberNotification NVARCHAR(128) NOT NULL,
	isRead BIT NOT NULL DEFAULT 0,

    CONSTRAINT [PK_postNotification] PRIMARY KEY(postId, courseId, postPublisher, memberNotification),

    CONSTRAINT [FK_postNotification_courseMember] FOREIGN KEY (memberNotification) REFERENCES [courseMember](id),
	CONSTRAINT [FK_postNotification_post] FOREIGN KEY (postId, courseId, postPublisher) REFERENCES [post](id, courseId, publisher),
);
GO

-- Table comment
IF OBJECT_ID('comment', 'U') IS NOT NULL
    DROP TABLE [comment]
GO

CREATE TABLE [comment]	
(
    id INT NOT NULL,
	postId INT NOT NULL,
    date DATETIME NOT NULL DEFAULT GETDATE(),
    courseId INT NOT NULL,
    postPublisher NVARCHAR(128) NOT NULL,
	commenter NVARCHAR(128) NOT NULL,	
    content NVARCHAR(MAX) NOT NULL,

	CONSTRAINT [Comment date must be before today.] CHECK(date <= GETDATE()),
	CONSTRAINT [Comment content is required.] CHECK(LEN(content) > 0),

    CONSTRAINT [PK_comment] PRIMARY KEY(id, postId, courseId, postPublisher, commenter),

    CONSTRAINT [FK_comment_post] FOREIGN KEY (postId, courseId, postPublisher) REFERENCES [post](id, courseId, publisher),
	CONSTRAINT [FK_comment_courseMember] FOREIGN KEY (commenter) REFERENCES [courseMember](id)
);
GO

-- Table comment notfication
IF OBJECT_ID('commentNotification', 'U') IS NOT NULL
    DROP TABLE [commentNotification]
GO

CREATE TABLE [commentNotification]	
(
    commentId INT NOT NULL,
	postId INT NOT NULL,
    date DATETIME NOT NULL DEFAULT GETDATE(),
    courseId INT NOT NULL,
    postPublisher NVARCHAR(128) NOT NULL,
	commenter NVARCHAR(128) NOT NULL,	
	memberNotification NVARCHAR(128) NOT NULL,
    isRead BIT NOT NULL DEFAULT 0,

    CONSTRAINT [PK_commentNotification] PRIMARY KEY(commentId, postId, courseId, postPublisher, commenter, memberNotification),

    CONSTRAINT [FK_commentNotification_comment] FOREIGN KEY (commentId, postId, courseId, postPublisher, commenter) REFERENCES [comment](id, postId, courseId, postPublisher, commenter),
	CONSTRAINT [FK_commentNotification__courseMember] FOREIGN KEY (memberNotification) REFERENCES [courseMember](id)
);
GO