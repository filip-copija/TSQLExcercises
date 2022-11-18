-- Skill 1.2 – u¿ywaj¹c sk³adni z³¹czeñ napisz zapytania do bazy danych college.
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



 