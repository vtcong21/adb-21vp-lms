-- Create a temporary table to hold payment card data
CREATE TABLE #tempPaymentCard
(
    number VARCHAR(16) NOT NULL,
    type VARCHAR(6) NOT NULL,
    name NVARCHAR(128) NOT NULL,
    CVC CHAR(3) NOT NULL,
    expireDate DATE NOT NULL
);

-- Declare all variables
DECLARE @i INT;
DECLARE @j INT;
DECLARE @k INT;
DECLARE @l INT;
DECLARE @totalLearners INT;
DECLARE @totalInstructors INT;
DECLARE @learnerId NVARCHAR(128);
DECLARE @instructorId NVARCHAR(128);
DECLARE @cardNumber VARCHAR(16);
DECLARE @name NVARCHAR(128);

-- Initialize variables
SET @totalLearners = 10000;
SET @totalInstructors = 3000;

-- Insert payment card data for learners
SET @i = 1;
WHILE @i <= @totalLearners
BEGIN
    SET @learnerId = 'learner' + RIGHT('000000' + CAST(@i AS NVARCHAR(6)), 6);
    SET @cardNumber = RIGHT(REPLICATE('0', 16) + CAST(ABS(CHECKSUM(NEWID())) % 10000000000000000 AS VARCHAR(16)), 16);
    
    SET @name = (SELECT name FROM [user] WHERE id = @learnerId);
    
    INSERT INTO #tempPaymentCard (number, type, name, CVC, expireDate)
    VALUES (
        @cardNumber,
        CASE WHEN RAND() < 0.5 THEN 'Debit' ELSE 'Credit' END,
        @name,
        RIGHT('000' + CAST(ABS(CHECKSUM(NEWID())) % 1000 AS VARCHAR(3)), 3),
        DATEADD(YEAR, ABS(CHECKSUM(NEWID())) % 5 + 1, GETDATE())
    );

    SET @i = @i + 1;
END

-- Insert payment card data for instructors
SET @j = 1;
WHILE @j <= @totalInstructors
BEGIN
    SET @instructorId = 'instructor' + RIGHT('000000' + CAST(@j AS NVARCHAR(6)), 6);
    SET @cardNumber = RIGHT(REPLICATE('0', 16) + CAST(ABS(CHECKSUM(NEWID())) % 10000000000000000 AS VARCHAR(16)), 16);
    
    SET @name = (SELECT name FROM [user] WHERE id = @instructorId);
    
    INSERT INTO #tempPaymentCard (number, type, name, CVC, expireDate)
    VALUES (
        @cardNumber,
        CASE WHEN RAND() < 0.5 THEN 'Debit' ELSE 'Credit' END,
        @name,
        RIGHT('000' + CAST(ABS(CHECKSUM(NEWID())) % 1000 AS VARCHAR(3)), 3),
        DATEADD(YEAR, ABS(CHECKSUM(NEWID())) % 5 + 1, GETDATE())
    );

    SET @j = @j + 1;
END

-- Insert data from the temporary table into the paymentCard table
INSERT INTO [paymentCard] (number, type, name, CVC, expireDate)
SELECT number, type, name, CVC, expireDate
FROM #tempPaymentCard;

-- Insert into learnerPaymentCard table
SET @k = 1;
WHILE @k <= @totalLearners
BEGIN
    SET @learnerId = 'learner' + RIGHT('000000' + CAST(@k AS NVARCHAR(6)), 6);
    SET @cardNumber = (SELECT TOP 1 number FROM #tempPaymentCard WHERE name = (SELECT name FROM [user] WHERE id = @learnerId));
    
    INSERT INTO [learnerPaymentCard] (learnerId, paymentCardNumber)
    VALUES (@learnerId, @cardNumber);

    SET @k = @k + 1;
END

-- Insert into vipInstructor table
SET @l = 1;
WHILE @l <= @totalInstructors
BEGIN
    SET @instructorId = 'instructor' + RIGHT('000000' + CAST(@l AS NVARCHAR(6)), 6);
    SET @cardNumber = (SELECT TOP 1 number FROM #tempPaymentCard WHERE name = (SELECT name FROM [user] WHERE id = @instructorId));
    
    UPDATE [instructor]
    SET vipState = 'vip'
    WHERE id = @instructorId;

    INSERT INTO [vipInstructor] (id, paymentCardNumber)
    VALUES (@instructorId, @cardNumber);

    SET @l = @l + 1;
END

-- Drop the temporary table
DROP TABLE #tempPaymentCard;