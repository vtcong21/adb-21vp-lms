INSERT INTO [section] (id, courseId, title, learnTime)
SELECT 
    ROW_NUMBER() OVER (ORDER BY c.id, s.id) AS id,
    c.id AS courseId,
    CONCAT('Section ', s.id, ' for Course ', c.id) AS title,
    ROUND(ABS(CHECKSUM(NEWID())) % 1000 / 100.0, 2) AS learnTime
FROM 
    (SELECT id FROM course WHERE id BETWEEN 1 AND 50000) c
CROSS JOIN 
    (SELECT 1 AS id UNION ALL SELECT 2) s;

INSERT INTO [lesson] (id, sectionId, courseId, title, learnTime, type)
SELECT 
    ROW_NUMBER() OVER (ORDER BY sec.courseId, sec.id, l.type) AS id,
    sec.id AS sectionId,
    sec.courseId AS courseId,
    CASE 
        WHEN l.type = 'lecture' THEN CONCAT('Lecture for Section ', sec.id)
        WHEN l.type = 'exercise' THEN CONCAT('Exercise for Section ', sec.id)
    END AS title,
    ROUND(ABS(CHECKSUM(NEWID())) % 1000 / 100.0, 2) AS learnTime,
    l.type
FROM 
    [section] sec
CROSS JOIN 
    (SELECT 'lecture' AS type UNION ALL SELECT 'exercise') l
WHERE 
    (sec.id % 2 = 1 AND l.type = 'lecture') 
    OR (sec.id % 2 = 0 AND l.type = 'exercise');

INSERT INTO [lecture] (id, sectionId, courseId, resource)
SELECT 
    l.id,
    l.sectionId,
    l.courseId,
    CONCAT('/resources/upload/lecture/', l.id, '.mp4') AS resource
FROM 
    lesson l
WHERE 
    l.type = 'lecture';

INSERT INTO [question] (id, exerciseId, sectionId, courseId, question)
SELECT 
    ROW_NUMBER() OVER (ORDER BY e.courseId, e.sectionId, e.id) AS id,
    e.id AS exerciseId,
    e.sectionId,
    e.courseId,
    CONCAT('What is the answer to question ', ROW_NUMBER() OVER (ORDER BY e.id)) AS question
FROM 
    exercise e;

INSERT INTO [questionAnswer] (id, questionId, exerciseId, sectionId, courseId, questionAnswers, isCorrect)
SELECT 
    ROW_NUMBER() OVER (ORDER BY q.courseId, q.sectionId, q.exerciseId, q.id, a.id) AS id,
    q.id AS questionId,
    q.exerciseId,
    q.sectionId,
    q.courseId,
    CONCAT('Answer ', a.id, ' for question ', q.id) AS questionAnswers,
    CASE 
        WHEN a.id = 1 THEN 1
        ELSE 0
    END AS isCorrect
FROM 
    question q
CROSS JOIN 
    (SELECT 1 AS id UNION ALL SELECT 2) a;
