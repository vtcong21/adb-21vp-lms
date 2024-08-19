DECLARE @i INT = 1;
DECLARE @max INT = 6000;

WHILE @i <= @max
BEGIN
    DECLARE @vipInstructorId NVARCHAR(128) = FORMAT(@i, 'instructor000000');
    DECLARE @fullName NVARCHAR(128);
    DECLARE @address NVARCHAR(256);
    DECLARE @phone VARCHAR(11);

    SELECT 
        @fullName = [user].[name],
        @address = [address],
        @phone = [phone]
    FROM 
        [instructor]
	JOIN [user] ON [user].id = [instructor].id
    WHERE 
        [instructor].[id] = @vipInstructorId;
	DECLARE @identityNumber CHAR(12) = RIGHT('000000000000' + CAST(@i AS VARCHAR(12)), 12);
    DECLARE @taxCode VARCHAR(50) = RIGHT('000000000000' + CAST(1234567890 + @i AS VARCHAR(50)), 10);


    -- Insert into taxForm with the retrieved values
    INSERT INTO [taxForm] 
        (fullName, address, phone, taxCode, identityNumber, postCode, vipInstructorId)
    VALUES 
        (
        @fullName,
        @address,
        @phone,
        @taxCode,
        @identityNumber,
        '12345',
        @vipInstructorId
    );

    SET @i = @i + 1;
END;
