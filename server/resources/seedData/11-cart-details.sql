INSERT INTO cartDetail (learnerId, courseId)
SELECT 
    l.id AS learnerId,
    c.id AS courseId
FROM 
    (SELECT TOP 20 id FROM learner ORDER BY id) l
CROSS JOIN 
    (SELECT TOP 20 id FROM course ORDER BY id) c;

