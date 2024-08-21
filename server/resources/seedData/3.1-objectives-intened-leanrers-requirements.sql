-- requirements
INSERT INTO [courseRequirements] (courseId, requirement)
SELECT c.id, r.requirement
FROM [course] c
CROSS JOIN (VALUES 
    (N'Basic understanding of programming'),
    (N'Access to a computer with an internet connection'),
    (N'Willingness to learn and explore'),
    (N'No prior experience needed')
) AS r(requirement);

-- objectives
INSERT INTO [courseObjectives] (courseId, objective)
SELECT c.id, o.objective
FROM [course] c
CROSS JOIN (VALUES 
    (N'Learn the basics of Python programming'),
    (N'Understand key programming concepts'),
    (N'Build real-world projects'),
    (N'Prepare for more advanced courses')
) AS o(objective);

-- intended learners
INSERT INTO [courseIntendedLearners] (courseId, intendedLearner)
SELECT c.id, l.intendedLearner
FROM [course] c
CROSS JOIN (VALUES 
    (N'Beginner programmers'),
    (N'Students interested in coding'),
    (N'Professionals looking to learn Python'),
    (N'Anyone interested in technology')
) AS l(intendedLearner);
