-- TEST COURSE INTENDED LEARNER
use LMS
go

truncate table courseIntendedLearners;

insert into courseIntendedLearners (courseId, intendedLearner) values (25, 'Students who work in Finance'),
																	(25, 'Students who have finished University in Finance and want to expanse their expertise'),
																	(25, 'Students who are too bored');

insert into courseIntendedLearners (courseId, intendedLearner) values (25, 'Students who want to increase the number of 0 in their salary'),
																	(25, 'Everybody'),
																	(29, 'Students who are too exhausted'),
																	(29, 'University students');


insert into courseIntendedLearners (courseId, intendedLearner) values (29, 'Students who want to increase the number of 0 in their salary'),
																	(29, 'Nobody'),
																	(73, 'Adult'),
																	(73, 'Children');

select * from courseIntendedLearners;


INSERT INTO courseRequirements (courseId, Requirement) 
VALUES (25, 'Basic understanding of Finance concepts'),
       (25, 'Degree in Finance or equivalent experience'),
       (25, 'Interest in deepening Finance knowledge');

INSERT INTO courseRequirements (courseId, Requirement) 
VALUES (25, 'Desire to significantly increase income'),
       (25, 'Open to all, no specific prerequisites'),
       (29, 'Ability to manage workload under stress'),
       (29, 'Current enrollment in a university program');

INSERT INTO courseRequirements (courseId, Requirement) 
VALUES (29, 'Strong motivation to enhance financial earnings'),
       (29, 'No specific requirements'),
       (73, 'Must be an adult with some life experience'),
       (73, 'Suitable for children with basic understanding');

select * from courseRequirements;

INSERT INTO courseObjectives (courseId, Objective) 
VALUES (25, 'Develop a solid foundation in Finance principles'),
       (25, 'Expand expertise in advanced Finance topics'),
       (25, 'Engage with complex Finance concepts in an interesting way');

INSERT INTO courseObjectives (courseId, Objective) 
VALUES (25, 'Achieve significant salary growth through advanced Finance knowledge'),
       (25, 'Broaden understanding of Finance across various contexts'),
       (29, 'Improve stress management in academic and professional settings'),
       (29, 'Successfully apply Finance concepts within university-level coursework');

INSERT INTO courseObjectives (courseId, Objective) 
VALUES (29, 'Maximize financial earnings through strategic decision-making'),
       (29, 'Master fundamental Finance principles with no prior knowledge required'),
       (73, 'Gain practical knowledge applicable to adult life scenarios'),
       (73, 'Introduce children to basic financial concepts in an engaging manner');

select * from courseObjectives;