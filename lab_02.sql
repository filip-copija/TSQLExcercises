CREATE TABLE groups(
	group_no char(20),
	CONSTRAINT cons_grupy PRIMARY KEY(group_no)
	)

ALTER TABLE students ADD
	CONSTRAINT rgs FOREIGN KEY(group_no) REFERENCES groups(group_no)
	ON DELETE NO ACTION ON UPDATE CASCADE
	
CREATE TABLE tution_fees(
	payment_id int IDENTITY PRIMARY KEY,
	student_id int NOT NULL,
	fee_amount decimal(8,2) NOT NULL,
	date_of_payment date DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT rstf FOREIGN KEY(student_id) REFERENCES students(student_id)
	)

CREATE TABLE departments(
	department varchar(50)
	CONSTRAINT rdm PRIMARY KEY(department)
	)

CREATE TABLE modules(
	module_id int IDENTITY PRIMARY KEY,
	module_name varchar(50) UNIQUE,
	no_of_hours int NOT NULL,
	lecturer_id int,
	preceding_module varchar(50),
	depratment varchar(50) NOT NULL
	)

CREATE TABLE students_modules(
	student_id int,
	module_id int,
	planned_exam_date date
	)

CREATE TABLE student_grades(
	student_id int,
	module_id int,
	exam_date int,
	grade decimal(3,2)
	)

CREATE TABLE grades(
	grade int
	CONSTRAINT rgrs PRIMARY KEY(grade)
	)

CREATE TABLE lecturers(
	lecturer_id int PRIMARY KEY IDENTITY,
	acad_position varchar(50),
	department varchar(50)
	CONSTRAINT rla FOREIGN KEY(acad_position) REFERENCES acad_positions(acad_position)
	)

ALTER TABLE lecturers ADD 
	CONSTRAINT rld FOREIGN KEY(department) REFERENCES departments(department)
	ON DELETE NO ACTION ON UPDATE CASCADE

CREATE TABLE employees(
	employee_id int PRIMARY KEY IDENTITY,
	surname varchar(50) NOT NULL,
	first_name varchar(50) NOT NULL,
	employe_date date DEFAULT CURRENT_TIMESTAMP,
	PESEL char(11) UNIQUE
	)

CREATE TABLE acad_positions(
	acad_position varchar(50) PRIMARY KEY,
	overtime_rate int
	)



