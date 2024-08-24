USE LMS
GO

-- INDEX 1
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Course_LastUpdate' AND object_id = OBJECT_ID('course'))
BEGIN
    DROP INDEX IX_Course_LastUpdate ON [course]

END;

CREATE NONCLUSTERED INDEX IX_Course_LastUpdate
ON [course] (lastUpdateTime);
GO


-- INDEX 2
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Course_Category_SubCategory' AND object_id = OBJECT_ID('course'))
BEGIN
    DROP INDEX IX_Course_Category_SubCategory ON [course];
END;

CREATE NONCLUSTERED INDEX IX_Course_Category_SubCategory
ON [course] (categoryId, subCategoryId);
GO


-- INDEX 3
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Order_DateCreated' AND object_id = OBJECT_ID('order'))
BEGIN
    DROP INDEX IX_Order_DateCreated ON [order];
END;

CREATE NONCLUSTERED INDEX IX_Order_DateCreated
ON [order] (dateCreated);
GO


-- INDEX 4
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Coupon_StartDate_Quantity' AND object_id = OBJECT_ID('coupon'))
BEGIN
    DROP INDEX IX_Coupon_StartDate_Quantity ON [coupon];
END;

CREATE NONCLUSTERED INDEX IX_Coupon_StartDate_Quantity
ON [coupon] (startDate DESC, quantity DESC)
INCLUDE (code, discountPercent);
GO