-- Define variables
DECLARE @counter INT = 1;
DECLARE @learnerId NVARCHAR(20);
DECLARE @courseId INT;
DECLARE @paymentCardNumber NVARCHAR(20);
DECLARE @dateCreated DATE;

-- Insert 10,000 courses into cartDetail for each learner from learner000021 to learner000025
WHILE @counter <= 5
BEGIN
    -- Calculate learnerId
    SET @learnerId = 'learner' + RIGHT('000000' + CAST(20 + @counter AS NVARCHAR(6)), 6);
    
    -- Insert into cartDetail
    INSERT INTO cartDetail (learnerId, courseId)
    SELECT 
        @learnerId AS learnerId,
        c.id AS courseId
    FROM 
        (SELECT id FROM course) c;
    
    -- Increment counter
    SET @counter = @counter + 1;
END

-- Reset counter
SET @counter = 1;

-- Loop through each learner and call stored procedure sp_LN_MakeOrder
WHILE @counter <= 5
BEGIN
    -- Calculate learnerId
    SET @learnerId = 'learner' + RIGHT('000000' + CAST(20 + @counter AS NVARCHAR(6)), 6);
    
    -- Get paymentCardNumber from learnerPaymentCard table
    SELECT TOP 1 @paymentCardNumber = paymentCardNumber 
    FROM learnerPaymentCard 
    WHERE learnerId = @learnerId;
    
    -- Set dateCreated
    IF @counter <= 3
        SET @dateCreated = '2023-01-01';
    ELSE
        SET @dateCreated = '2024-01-01';

    -- Call stored procedure sp_LN_MakeOrder
    EXEC [dbo].[sp_LN_MakeOrder]
        @learnerId = @learnerId,
        @paymentCardNumber = @paymentCardNumber,
        @couponCode = NULL,
        @dateCreated = @dateCreated;
    
    -- Increment counter
    SET @counter = @counter + 1;
END

-- Update learnerEnrollCourse: set completionPercentInCourse to 30%, learnerScore to 10
UPDATE [learnerEnrollCourse]
SET completionPercentInCourse = 30.0, learnerScore = 10.0
WHERE learnerId BETWEEN 'learner000021' AND 'learner000025';

-- Insert into learnerReviewCourse with random rating between 1 and 5
DECLARE @rating DECIMAL(3, 2);

-- Declare cursor for learnerEnrollCourse
DECLARE enroll_cursor CURSOR FOR
SELECT learnerId, courseId
FROM [learnerEnrollCourse]
WHERE learnerId BETWEEN 'learner000021' AND 'learner000025';

OPEN enroll_cursor;
FETCH NEXT FROM enroll_cursor INTO @learnerId, @courseId;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Generate a random rating between 1 and 5
    SET @rating = CAST(FLOOR(RAND(CHECKSUM(NEWID())) * 5) + 1 AS DECIMAL(3, 2));
    
    -- Insert into learnerReviewCourse
    INSERT INTO [learnerReviewCourse] (courseId, learnerId, review, rating)
    VALUES (@courseId, @learnerId, 'This is an auto-generated review.', @rating);

    FETCH NEXT FROM enroll_cursor INTO @learnerId, @courseId;
END

CLOSE enroll_cursor;
DEALLOCATE enroll_cursor;
