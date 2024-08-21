DECLARE @courseId INT;
DECLARE @price DECIMAL(18, 2);
DECLARE @year INT;
DECLARE @month INT;
DECLARE @revenue DECIMAL(18, 2);
DECLARE @percentageIncome DECIMAL(5, 2);
DECLARE @instructorId NVARCHAR(128);
DECLARE @totalRevenue DECIMAL(18, 2);

-- Loop through the first 20 courses
DECLARE course_cursor CURSOR FOR
SELECT id, price FROM [course]
WHERE id BETWEEN 1 AND 20;

OPEN course_cursor;
FETCH NEXT FROM course_cursor INTO @courseId, @price;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Loop through each month excluding January 2023 and January 2024
    SET @year = 2023;
    SET @month = 2;

    WHILE @year < 2025
    BEGIN
        IF NOT (@year = 2023 AND @month = 1) AND NOT (@year = 2024 AND @month = 1)
        BEGIN
            -- Calculate base revenue (10 times the course price)
            SET @revenue = 10 * @price;
            
            -- Introduce a random variation in revenue (e.g., ±20%)
            SET @revenue = @revenue * (0.8 + (RAND(CHECKSUM(NEWID())) * 0.4));
            
            -- Insert into courseRevenueByMonth
            INSERT INTO [courseRevenueByMonth] (courseId, year, month, revenue)
            VALUES (@courseId, @year, @month, @revenue);

            -- Calculate and insert instructor revenue
            DECLARE instructor_cursor CURSOR FOR
            SELECT instructorId, percentageIncome FROM [instructorOwnCourse]
            WHERE courseId = @courseId;

            OPEN instructor_cursor;
            FETCH NEXT FROM instructor_cursor INTO @instructorId, @percentageIncome;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Calculate instructor's share of the revenue
                SET @revenue = @revenue * @percentageIncome / 100;
                
                -- Insert into instructorRevenueByMonth
                INSERT INTO [instructorRevenueByMonth] (instructorId, year, month, revenue)
                VALUES (@instructorId, @year, @month, @revenue);

                FETCH NEXT FROM instructor_cursor INTO @instructorId, @percentageIncome;
            END;

            CLOSE instructor_cursor;
            DEALLOCATE instructor_cursor;
        END;

        -- Increment the month
        IF @month < 12
            SET @month = @month + 1;
        ELSE
        BEGIN
            SET @month = 1;
            SET @year = @year + 1;
        END;
    END;

    -- Calculate the total revenue for the course
    SELECT @totalRevenue = SUM(revenue)
    FROM [courseRevenueByMonth]
    WHERE courseId = @courseId;

    -- Update the totalRevenue in the course table
    UPDATE [course]
    SET totalRevenue = @totalRevenue
    WHERE id = @courseId;

    FETCH NEXT FROM course_cursor INTO @courseId, @price;
END;

CLOSE course_cursor;
DEALLOCATE course_cursor;
