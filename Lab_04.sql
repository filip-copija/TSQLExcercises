create database BANKACCOUNT
-- Skill 1.2 � u�ywaj�c sk�adni z��cze� napisz zapytania do bazy danych college.
-- 12.01
select m.module_id, m.module_name
from modules m left join students_modules sm on m.module_id = sm.module_id
where student_id is null
order by m.module_name desc

-- 12.02
select m.module_id, m.module_name, e.surname
from modules m
left join students_modules sm on m.module_id = sm.module_id
left join employees e on m.lecturer_id = e.employee_id
where student_id is null
order by m.module_name desc

-- 12.03
select employee_id lecturer_id, surname,  module_name
from employees e
join lecturers l on e.employee_id = l.lecturer_id
left join modules m on l.lecturer_id = m.lecturer_id
order by e.surname asc

-- 12.04
select l.lecturer_id, e.first_name, e.surname
from employees e
inner join lecturers l on l.lecturer_id = e.employee_id

-- 12.05
select l.lecturer_id, e.first_name, e.surname
from employees e
left join lecturers l on l.lecturer_id = e.employee_id 
where l.lecturer_id IS NULL

-- 12.06
select s.student_id, s.first_name, s.surname, s.group_no
from students s
left join students_modules sm on s.student_id = sm.student_id
where sm.student_id IS NULL
order by  s.surname, s.first_name asc

-- 12.07
select distinct s.surname, s.first_name, s.student_id, sg.exam_date
from students s
join student_grades sg on sg.student_id = s.student_id
order by sg.exam_date asc

-- 12.08
select m.module_name, m.no_of_hours, e.employee_id, e.surname, e.first_name
from modules m
left join employees e on m.lecturer_id = e.employee_id
order by m.module_name, e.surname, e.first_name

-- 12.09
select s.student_id, s.surname, s.first_name 
from students s
join students_modules sm on s.student_id = sm.student_id
join modules m on m.module_id = sm.module_id
where m.module_name = 'Statistics'

-- 12.10
select e.surname, e.first_name, l.acad_position
from lecturers l
join employees e on e.employee_id = l.lecturer_id
where l.department = 'Department of Informatics'
order by e.surname, e.first_name asc

-- 12.11
select surname, first_name, l.department
from employees e
left join lecturers l on l.lecturer_id = e.employee_id
order by surname, first_name desc

-- 12.12
select surname, first_name, l.department
from employees e
join lecturers l on l.lecturer_id = e.employee_id
order by surname, first_name desc

-- 12.13
select l.lecturer_id, surname, first_name, l.acad_position
from employees e
join lecturers l on l.lecturer_id = e.employee_id
left join modules m on l.lecturer_id = m.lecturer_id
where m.lecturer_id IS NULL
order by l.acad_position desc

-- 12.14
select s.first_name, s.surname, m.module_name,
e.surname as 'lecturer_surname', l.department
from students s
left join students_modules sm on s.student_id = sm.student_id
left join modules m on sm.module_id = m.module_id
left join lecturers l on m.lecturer_id = l.lecturer_id
left join employees e on e.employee_id = l.lecturer_id
order by m.module_name desc, lecturer_surname asc

-- 12.15
select sum(no_of_hours)
from modules m
left join lecturers l on l.lecturer_id = m.lecturer_id
where m.lecturer_id is null or l.acad_position is null

-- 12.16
select module_id, module_name, l.department
from modules m
left join lecturers l on l.lecturer_id = m.lecturer_id
where m.lecturer_id is null or l.acad_position is null

-- 12.17
select module_name, no_of_hours, e.surname, l.department
from modules m
left join lecturers l on l.lecturer_id = m.lecturer_id
join employees e on e.employee_id = l.lecturer_id
where m.module_name collate polish_CS_as like 'computer%'
order by e.surname

-- 12.18
select module_name, no_of_hours, e.surname, l.department
from modules m
left join lecturers l on l.lecturer_id = m.lecturer_id
left join employees e on e.employee_id = l.lecturer_id
where m.module_name collate polish_CS_as like 'Computer%'
order by e.surname

-- 12.19
select s.student_id, s.surname, m.module_name, sg.grade
from students s
join students_modules sm on s.student_id = sm.student_id
join modules m on sm.module_id = m.module_id
left join student_grades sg on sm.student_id = sg.student_id
and sm.module_id = sg.module_id
where sg.grade is null

-- 12.20
select s.student_id, s.surname, m.module_name, sg.grade
from students s
join student_grades sg on sg.student_id = s.student_id
join modules m on m.module_id = sg.module_id
order by sg.student_id, sg.module_id desc, sg.grade desc

-- 12.21
select module_name
from modules m
left join lecturers l on m.lecturer_id = l.lecturer_id
where m.department != l.department

-- 12.22
select e.surname, e.first_name, e.PESEL, m.module_name, 'wykładowca' as siema
from lecturers l
LEFT join employees e on l.lecturer_id = e.employee_id
INNER join modules m on l.lecturer_id = m.lecturer_id
union
select s.surname, s.first_name, s.group_no, m.module_name, 'student' as siema
from students s
LEFT join students_modules sm on s.student_id = sm.student_id
LEFT join modules m on sm.module_id = m.module_id
order by m.module_name asc, siema asc
