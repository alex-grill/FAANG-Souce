--- Set ITOM6265_FYY_Group25 as active database
USE ITOM6265_F22_Group25

--- Create a new user for Group 25 database called ITOM6265_G25_USER
CREATE USER ITOM6265_G25_USER WITH PASSWORD = 'str0ng!shPassw0rd';

--- To add a user to a database role, use an alter role statement:
ALTER ROLE db_owner ADD member ITOM6265_G25_USER;

-- MAKE BLANK TABLES
--- Making Company table where company_id is Identity PK
CREATE TABLE dbo.Company
(company_id int NOT NULL IDENTITY PRIMARY KEY,
company_name varchar(255) NOT NULL,
hq_location varchar(255) NOT NULL);

--- Making Job table where company_id is Identity PK and company_id is FK
CREATE TABLE dbo.Job
(job_id int NOT NULL IDENTITY PRIMARY KEY,
company_id int NOT NULL REFERENCES dbo.Company (company_id),
job_title varchar(255) NOT NULL);

--- Making UserInfo table where user_id is Identity PK
CREATE TABLE dbo.UserInfo
(user_id int NOT NULL IDENTITY PRIMARY KEY,
first_name varchar(255) NOT NULL,
last_name varchar(255) NOT NULL,
email_address varchar(255) NOT NULL,
gender varchar(255) NOT NULL,
age int NOT NULL);

--- Making UserInput table where entry_id is Identity PK, AND user_id, job_id are FK's
CREATE TABLE dbo.UserInput
(entry_id int NOT NULL IDENTITY PRIMARY KEY,
user_id int NOT NULL REFERENCES dbo.UserInfo (user_id),
job_id int NULL REFERENCES dbo.Job (job_id),
education_level varchar(255) NOT NULL,
years_of_exp varchar(255) NOT NULL,
salary int NOT NULL,
office_location varchar(255) NOT NULL);

-- INSERT DATA INTO TABLES
--- Bringing over data from CompanyData table
INSERT INTO dbo.Company
SELECT company_name, hq_location
FROM dbo.CompanyData;

--- Bringing over data from JobData table
INSERT INTO dbo.Job
SELECT company_id, job_title
FROM dbo.JobData;

--- Bringing over data from UserInfoData table
INSERT INTO dbo.UserInfo
SELECT first_name, last_name, email_address, gender, age
FROM dbo.UserInfoData;

--- Bringing over data from UserInputData table
INSERT INTO dbo.UserInput
SELECT user_id, job_id, education_level, years_of_exp, salary, office_location
FROM dbo.UserInputData;