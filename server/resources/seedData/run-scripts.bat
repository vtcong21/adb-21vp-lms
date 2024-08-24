
REM Run each SQL file in the desired order
sqlcmd /S KONG /d LMS -U LoginLMS -P 123 -i"1-categories.sql"
sqlcmd /S KONG /d LMS -U LoginLMS -P 123 -i"2.1-public-courses.sql"
sqlcmd /S KONG /d LMS -U LoginLMS -P 123 -i"3.1-objectives-intened-leanrers-requirements.sql"
sqlcmd /S KONG /d LMS -U LoginLMS -P 123 -i"3.2-sections-lessons-lecutres-exercise-questions-questionAnswers.sql"
sqlcmd /S KONG /d LMS -U LoginLMS -P 123 -i"4-admins.sql"
sqlcmd /S KONG /d LMS -U LoginLMS -P 123 -i"5-coupons.sql"
sqlcmd /S KONG /d LMS -U LoginLMS -P 123 -i"6-learners.sql"
sqlcmd /S KONG /d LMS -U LoginLMS -P 123 -i"7-instructors.sql"
sqlcmd /S KONG /d LMS -U LoginLMS -P 123 -i"8-tax-forms.sql"
sqlcmd /S KONG /d LMS -U LoginLMS -P 123 -i"9-payment-cards.sql"
sqlcmd /S KONG /d LMS -U LoginLMS -P 123 -i"10-instructor-own-course.sql"
sqlcmd /S KONG /d LMS -U LoginLMS -P 123 -i"11-cart-details.sql"
sqlcmd /S KONG /d LMS -U LoginLMS -P 123 -i"12-orders-learner-reviews.sql"
sqlcmd /S KONG /d LMS -U LoginLMS -P 123 -i"13-pending-review-courses.sql"
sqlcmd /S KONG /d LMS -U LoginLMS -P 123 -i"14-draft-courses.sql"
sqlcmd /S KONG /d LMS -U LoginLMS -P 123 -i"15-course-instructor-revenue.sql"
sqlcmd /S KONG /d LMS -U LoginLMS -P 123 -i"16-reset-make-order-proc.sql"


REM Pause to keep the Command Prompt window open
pause