use master
create database University
go

use University
go

create table students(
student_id int primary key,
surname varchar(50) not null,
first_name varchar(50),
date_of_birth date default getdate(),
group_no char(20)
)
	
create table groups(
group_no char(20) primary key
)

alter table students add
constraint rgs foreign key(group_no) references groups(group_no)
on delete no action on update cascade

create table tuition_fees(
payment_id int identity primary key,
student_id int not null,
fee_amount decimal(8,2) not null,
date_of_payment date default getdate(),
constraint rstf foreign key(student_id) references students
)

create table departments(
department varchar(50) primary key
)

create table acad_positions(
acad_position varchar(50) primary key,
overtime_rate decimal(8,2) not null
)

create table employees(
employee_id int primary key,
surname varchar(50) not null,
first_name varchar(50) not null,
employment_date date,
PESEL char(11)
)

create table lecturers(
lecturer_id int primary key,
acad_position varchar(50) null,
department varchar(50) not null
constraint rl1 foreign key(lecturer_id) references employees(employee_id)
on delete cascade,
constraint rl2 foreign key(acad_position) references acad_positions(acad_position)
on delete no action on update cascade,
constraint rl3 foreign key(department) references departments(department)
on delete no action on update cascade
)

create table modules(
module_id int identity primary key,
module_name varchar(50) unique not null,
no_of_hours int not null,
lecturer_id int,
preceding_module int,
department varchar(50)not null
constraint rm1 foreign key(preceding_module) references modules(module_id),
constraint rm2 foreign key(lecturer_id) references lecturers(lecturer_id),
constraint rm3 foreign key(department) references departments(department)
on delete no action on update cascade
)

create table grades(
grade decimal (2,1) primary key
)

create table students_modules(
student_id int,
module_id int,
planned_exam_date date,
constraint pk1 primary key(student_id, module_id),
constraint rsm1 foreign key(student_id) references students(student_id)
on delete cascade,
constraint rsm2 foreign key(module_id) references modules(module_id)
)

create table student_grades(
student_id int,
module_id int,
exam_date date,
grade decimal(2,1),
constraint pk_sg1 primary key(student_id, module_id, exam_date),
constraint rsg1 foreign key(student_id, module_id) references students_modules(student_id, module_id)
on delete cascade,
constraint rsg2 foreign key(grade) references grades(grade)
on delete no action on update cascade
)
