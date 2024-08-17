-- FILEGROUP 1
alter database lms
add filegroup fg1;
go

alter database lms
add file
(name = lms1,
filename = 'C:\Database\LMS\lms1.ndf',
size=2, maxsize=100, filegrowth=1)
to filegroup fg1;
go

-- FILEGROUP 2
alter database lms
add filegroup fg2;
go

alter database lms
add file
(name = lms2,
filename = 'C:\Database\LMS\lms2.ndf',
size=2, maxsize=100, filegrowth=1)
to filegroup fg2;
go

-- CHECK FILEGROUPS AND FILENAMES
select name as [file group name]
from sys.filegroups
where type = 'FG'
go

select name as [db filename], physical_name as [db filepath]
from sys.database_files
where type_desc = 'ROWS'
go

-- PARTITION FUNCTION
create partition function pf_yearlyPartition (int)
as range right for values (2023, 2024);
go

-- PARTITION SCHEME
create partition scheme yearlyPartitionScheme
as partition pf_yearlyPartition
to ([primary], fg1, fg2)
go

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
) ON yearlyPartitionScheme (year);
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
) ON yearlyPartitionScheme (year);
GO
