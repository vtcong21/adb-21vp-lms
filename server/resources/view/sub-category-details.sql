USE LMS 
GO


CREATE VIEW vw_SubCategoryDetails AS
SELECT 
    sc.id,
    sc.parentCategoryId,
    sc.name,
    
    -- Tổng số học viên
    SUM(c.numberOfStudents) AS numberOfStudents,
    
    -- Điểm đánh giá trung bình
    ISNULL(AVG(c.averageRating), 0) AS averageRating,
    
    -- Số lượng khóa học
    COUNT(c.id) AS numberOfCourse

FROM 
    subCategory sc
LEFT JOIN 
    course c ON c.subCategoryId = sc.id AND c.categoryId = sc.parentCategoryId

GROUP BY 
    sc.id, sc.parentCategoryId, sc.name;
GO