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
    CONCAT(1, '.mp4') AS resource
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

-- Delete existing sections, lessons (including exercises), questions, and question answers for Course 1
DELETE FROM [questionAnswer] WHERE questionId IN (SELECT id FROM [question] WHERE exerciseId IN (SELECT id FROM [exercise] WHERE courseId = 1));
DELETE FROM [question] WHERE exerciseId IN (SELECT id FROM [exercise] WHERE courseId = 1);
DELETE FROM [exercise] WHERE courseId = 1;
DELETE FROM [lesson] WHERE courseId = 1;
DELETE FROM [section] WHERE courseId = 1;

-- Insert 3 new sections for Course 1
INSERT INTO [section] (id, courseId, title, learnTime)
VALUES
    (1, 1, 'Mastering the Foundations of Positive Psychology', ROUND(ABS(CHECKSUM(NEWID())) % 1000 / 100.0, 2)),
    (2, 1, 'Advanced Strategies for Enhancing Well-being', ROUND(ABS(CHECKSUM(NEWID())) % 1000 / 100.0, 2)),
    (3, 1, 'Implementing Expert Techniques in Everyday Life', ROUND(ABS(CHECKSUM(NEWID())) % 1000 / 100.0, 2));

-- Insert 9 new lectures (3 for each section) for Course 1
INSERT INTO [lesson] (id, sectionId, courseId, title, learnTime, type)
VALUES
    -- Section 1 Lectures
    (1, 1, 1, 'The Science Behind Positive Psychology', ROUND(ABS(CHECKSUM(NEWID())) % 1000 / 100.0, 2), 'lecture'),
    (2, 1, 1, 'Core Theories and Models of Positive Psychology', ROUND(ABS(CHECKSUM(NEWID())) % 1000 / 100.0, 2), 'lecture'),
    (3, 1, 1, 'Evaluating the Impact of Positive Psychology Interventions', ROUND(ABS(CHECKSUM(NEWID())) % 1000 / 100.0, 2), 'lecture'),

    -- Section 2 Lectures
    (4, 2, 1, 'Techniques for Building Resilience and Grit', ROUND(ABS(CHECKSUM(NEWID())) % 1000 / 100.0, 2), 'lecture'),
    (5, 2, 1, 'Advanced Methods for Cultivating Gratitude and Compassion', ROUND(ABS(CHECKSUM(NEWID())) % 1000 / 100.0, 2), 'lecture'),
    (6, 2, 1, 'Optimizing Personal Strengths for Professional Success', ROUND(ABS(CHECKSUM(NEWID())) % 1000 / 100.0, 2), 'lecture'),

    -- Section 3 Lectures
    (7, 3, 1, 'Designing and Conducting Positive Psychology Workshops', ROUND(ABS(CHECKSUM(NEWID())) % 1000 / 100.0, 2), 'lecture'),
    (8, 3, 1, 'Integrating Positive Psychology Practices into Coaching and Therapy', ROUND(ABS(CHECKSUM(NEWID())) % 1000 / 100.0, 2), 'lecture'),
    (9, 3, 1, 'Measuring and Sustaining Long-term Well-being Gains', ROUND(ABS(CHECKSUM(NEWID())) % 1000 / 100.0, 2), 'lecture');

-- Insert new lectures with specific video resources
INSERT INTO [lecture] (id, sectionId, courseId, resource)
VALUES
    (1, 1, 1, '1.mp4'),
    (2, 1, 1, '2.mp4'),
    (3, 1, 1, '3.mp4'),
    (4, 2, 1, '4.mp4'),
    (5, 2, 1, '5.mp4'),
    (6, 2, 1, '6.mp4'),
    (7, 3, 1, '7.mp4'),
    (8, 3, 1, '8.mp4'),
    (9, 3, 1, '9.mp4');

