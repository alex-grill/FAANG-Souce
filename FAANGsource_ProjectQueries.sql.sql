USE ITOM6265_F22_Group25

--- CREATE NEW USER TAB QUERY
INSERT INTO UserInfo (first_name, last_name, email_address, gender, age) 
VALUES ('Tim', 'Smith' ,'tim.smith96@outlook.com', 'Male', '26' );


--- DATA ENTRY TAB QUERIES
INSERT INTO UserInput (user_id, education_level, years_of_exp, salary, office_location)
VALUES ('501', 'Undergraduate Degree', '2', '200100', 'Austin, TX');

UPDATE UserInput
SET job_id = (SELECT j.job_id
			  FROM Job as j
			  JOIN Company as c
			  ON j.company_id = c.company_id
			  WHERE c.company_name = 'Google' AND j.job_title = 'Data Analyst 2')
WHERE user_id = 501 AND salary = 200100;


--- SEARCH DATABASE TAB QUERY
SELECT c.company_name AS 'FAANG Company', j.job_title AS Position,  
       uinp.education_level AS 'Education Level',
	   uinp.years_of_exp AS 'Years of Experience',
	   uinp.office_location AS 'Office Location', uinp.salary as 'Salary ($)'
FROM UserInput as uinp
JOIN Job as j
ON uinp.job_id = j.job_id
JOIN Company as c
ON j.company_id = c.company_id
WHERE c.company_name LIKE '%%' AND j.job_title LIKE '%%'
AND uinp.education_level LIKE '%%' AND uinp.years_of_exp LIKE '%%'
AND uinp.office_location LIKE '%%'
ORDER BY uinp.salary DESC;


--- ANALYSIS TAB QUERIES
---- AVG Salary (Company)
SELECT c.company_name AS 'FAANG Company', AVG(uinp.salary) AS 'Average Salary'
FROM UserInfo as uinf
JOIN UserInput as uinp
ON uinf.user_id = uinp.user_id
JOIN Job as j
ON uinp.job_id = j.job_id
JOIN Company as c
ON j.company_id = c.company_id
GROUP BY c.company_name
ORDER BY AVG(uinp.salary) DESC;

---- AVG Salary (Job Title)
SELECT j.job_title AS 'Position', AVG(uinp.salary) AS 'Average Salary'
FROM UserInfo as uinf
JOIN UserInput as uinp
ON uinf.user_id = uinp.user_id
JOIN Job as j
ON uinp.job_id = j.job_id
JOIN Company as c
ON j.company_id = c.company_id
GROUP BY j.job_title
ORDER BY AVG(uinp.salary) DESC;

--- AVG Salary (Gender)
SELECT uinf.gender AS 'Gender', 
        AVG(uinp.salary) AS 'Average Salary'
FROM UserInfo as uinf
JOIN UserInput as uinp
ON uinf.user_id = uinp.user_id
JOIN Job as j
ON uinp.job_id = j.job_id
JOIN Company as c
ON j.company_id = c.company_id
GROUP BY uinf.gender
ORDER BY AVG(uinp.salary) DESC;

--- AVG Salary (Age Range)
SELECT CASE
   WHEN uinf.age < 27 THEN '20-26'
   WHEN uinf.age BETWEEN 27 AND 33 THEN '27-33'
   WHEN uinf.age BETWEEN 34 AND 40 THEN '34-40'
   END AS 'Age Range', AVG(uinp.salary) as 'Average Salary'
FROM UserInfo as uinf
JOIN UserInput as uinp
ON uinf.user_id = uinp.user_id
JOIN Job as j
ON uinp.job_id = j.job_id
JOIN Company as c
ON j.company_id = c.company_id
GROUP BY CASE
   WHEN uinf.age < 27 THEN '20-26'
   WHEN uinf.age BETWEEN 27 AND 33 THEN '27-33'
   WHEN uinf.age BETWEEN 34 AND 40 THEN '34-40'
   END
ORDER BY AVG(uinp.salary) DESC;

---- AVG Salary (Level of Education)
SELECT uinp.education_level AS 'Education Level', AVG(uinp.salary) AS 'Average Salary'
FROM UserInfo as uinf
JOIN UserInput as uinp
ON uinf.user_id = uinp.user_id
JOIN Job as j
ON uinp.job_id = j.job_id
JOIN Company as c
ON j.company_id = c.company_id
GROUP BY uinp.education_level
ORDER BY AVG(uinp.salary) DESC;

---- AVG Salary (Years of Experience)
SELECT uinp.years_of_exp AS 'Years of Experience', AVG(uinp.salary) AS 'Average Salary'
FROM UserInfo as uinf
JOIN UserInput as uinp
ON uinf.user_id = uinp.user_id
JOIN Job as j
ON uinp.job_id = j.job_id
JOIN Company as c
ON j.company_id = c.company_id
GROUP BY uinp.years_of_exp
ORDER BY AVG(uinp.salary) DESC;

---- AVG Salary (Office Location)
SELECT uinp.office_location AS 'Office Location', AVG(uinp.salary) AS 'Average Salary'
FROM UserInfo as uinf
JOIN UserInput as uinp
ON uinf.user_id = uinp.user_id
JOIN Job as j
ON uinp.job_id = j.job_id
JOIN Company as c
ON j.company_id = c.company_id
GROUP BY uinp.office_location
ORDER BY AVG(uinp.salary) DESC;


--- USER SETTINGS TAB QUERIES
--- User Settings Tab: My Entries Query
SELECT uinp.entry_id AS 'Entry Number',
       uinf.first_name + ' ' + uinf.last_name AS 'Name',
	   c.company_name as 'FAANG Company', j.job_title AS Position,
	   uinp.education_level AS 'Education Level',
	   uinp.years_of_exp AS 'Years of Experience',
	   uinp.salary AS 'Salary ($)', uinp.office_location AS 'Office Location'
FROM UserInput AS uinp
JOIN UserInfo AS uinf ON uinp.user_id = uinf.user_id
JOIN Job as j ON uinp.job_id = j.job_id
JOIN Company as c ON j.company_id = c.company_id
WHERE uinp.user_id = 502;

--- User Settings Tab: Edit Entry Queries
UPDATE UserInput
SET education_level = 'Postgraduate Degree'
WHERE user_id = 502 AND entry_id = 505;

UPDATE UserInput
SET salary = 195800
WHERE user_id = 502 AND entry_id = 505;

--- User Settings Tab: Delete Entry Query
DELETE
FROM UserInput
WHERE user_id = 502 AND entry_id = 504;

--- User Settings Tab: Edit User Info Queries
UPDATE UserInfo
SET first_name = 'Jeffrey'
WHERE user_id = 502;

UPDATE UserInfo
SET gender = 'Male'
WHERE user_id = 502;

UPDATE UserInfo
SET age = 26
WHERE user_id = 502;

SELECT first_name + ' ' + last_name AS 'Name',
			email_address AS 'Email Address',
			gender AS 'Gender', age AS 'Age'
FROM UserInfo
WHERE user_id = 502;

--- User Settings Tab: Forgot User ID Query
SELECT uinf.user_id
FROM UserInfo as uinf
WHERE uinf.first_name = 'Paxton' AND uinf.last_name = 'Greene';