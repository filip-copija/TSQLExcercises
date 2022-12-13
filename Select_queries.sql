-- 11.01 (NULL w wyra¿eniach i funkcjach agreguj¹cych)
-- a)
SELECT 34+NULL
-- zwraca NULL dla ka¿dego dzia³ania zawieraj¹cego NULL

-- b)
SELECT * FROM employees WHERE PESEL IS NULL OR employment_date IS NULL

-- c)
SELECT * FROM students_modules

-- d)
SELECT *, DATEDIFF(DAY, planned_exam_date, GETDATE()) number_of_days
FROM students_modules
ORDER BY planned_exam_date DESC

-- e)
SELECT COUNT(planned_exam_date)
FROM students_modules

-- f)
SELECT COUNT(*)
FROM students_modules

-- 11.02 (DISTINCT)
-- a)
SELECT DISTINCT student_id, exam_date
FROM student_grades
ORDER BY exam_date
DESC

-- b)
SELECT DISTINCT student_id 
FROM student_grades
WHERE YEAR(exam_date) = 2018 AND MONTH(exam_date) = 03
ORDER BY student_id
DESC

-- 11.03
-- a) 
SELECT student_id, surname AS family_name
FROM students
WHERE surname ='Fisher' 

-- 11.04 (SARG)
-- a) COALESCE
SELECT module_name, lecturer_id
FROM modules
WHERE lecturer_id = 8 OR COALESCE(lecturer_id, 0) = 0

-- b) IS NULL => to rozwi¹zanie jest SARG, poniewa¿ nie jest argumentem funkcji
SELECT module_name, lecturer_id
FROM modules
WHERE lecturer_id = 8 OR lecturer_id IS NULL

-- 11.05
-- a) CAST
SELECT CAST('ABC' AS INT)

-- b) TRY_CAST 
SELECT TRY_CAST('ABC' AS INT)

-- 11.06
-- a) 11/04/2022
SELECT CONVERT(VARCHAR(20), GETDATE(), 101)

-- b) 2022.11.04
SELECT CONVERT(VARCHAR(20), GETDATE(), 102)

-- c) 04/11/2022
SELECT CONVERT(VARCHAR(20), GETDATE(), 103)

-- 11.07 (LIKE)
-- a)
SELECT *
FROM groups
WHERE group_no LIKE 'DM%'

-- b) 
SELECT * 
FROM groups 
WHERE group_no NOT LIKE '%10%'

-- c)
SELECT * 
FROM groups 
WHERE group_no LIKE '_M%'

-- d)
SELECT * 
FROM groups 
WHERE group_no LIKE '%0_'

-- e)
SELECT * 
FROM groups 
WHERE group_no LIKE '%1' OR group_no LIKE '%2'

-- f)
SELECT * 
FROM groups 
WHERE group_no NOT LIKE 'D%'

-- g)
SELECT * 
FROM groups 
WHERE group_no LIKE '_[A-P]%'

-- 11.08 (LIKE i COLLATE)
-- a)
SELECT module_name
FROM modules
WHERE module_name LIKE '%o%'

-- b)
SELECT module_name
FROM modules
WHERE module_name COLLATE polish_CS_as LIKE '%O%'

-- c)
SELECT *
FROM groups
WHERE group_no LIKE '__i%'

-- d)
SELECT *
FROM groups
WHERE group_no COLLATE polish_CS_as LIKE '__i%'

-- 11.09 (COLLATE)
CREATE TABLE #tmp(
id INT PRIMARY KEY,
nazwisko VARCHAR(30) COLLATE POLISH_CS_AS
)
INSERT INTO #tmp VALUES
(1,'Kowalski'),
(2,'kowalski'),
(3,'KoWaLsKi'),
(4,'KOWALSKI')

-- a)
SELECT * FROM #tmp
WHERE nazwisko COLLATE polish_CS_as LIKE 'K%'

SELECT * FROM #tmp
WHERE nazwisko COLLATE polish_CS_as LIKE 'Kowalski'

SELECT * FROM #tmp
WHERE nazwisko COLLATE polish_CS_as LIKE '%K_'

-- b)
SELECT * FROM #tmp
WHERE nazwisko ='kowalski'

SELECT * FROM #tmp
WHERE nazwisko LIKE '_o%'

-- użycie COLLATE nie było konieczne w żadnym przypadku, ponieważ zastosowaliśmy je przy tworzeniu tabeli co wpłyneło na ostateczny wynik wyszukiwania w przykładzie b)

-- 11.10 
-- a) !!!
SELECT surname, group_no
FROM students
ORDER BY group_no

-- 11.11 (TOP)
-- a) 
SELECT TOP 5 *
FROM student_grades
ORDER BY exam_date ASC

-- b)
SELECT TOP 5 WITH TIES * 
FROM student_grades
ORDER BY exam_date ASC

-- otrzymujemy o 1 rekord więcej, z racji że dla warunku exam_date jest on identyczny jak pozostałe 2

-- 11.12 (TOP, OFFEST)
-- a) (58)
SELECT * FROM student_grades

-- b) 20% z 58 = 11,6, a wynik zostaje zaokrąglony do 12
SELECT TOP(20) PERCENT *
FROM student_grades
ORDER BY exam_date DESC

-- c) 
SELECT * 
FROM student_grades
ORDER BY exam_date ASC
OFFSET 6 ROWS  FETCH NEXT 10 ROWS ONLY

-- d)
SELECT * 
FROM student_grades
ORDER BY exam_date ASC
OFFSET 20 ROWS 

-- 11.13 (INTERSECT, UNION, EXCEPT)
-- a) 
SELECT surname FROM students
UNION 
SELECT surname FROM employees
ORDER BY surname 

-- b)
SELECT surname FROM students
UNION ALL
SELECT surname FROM employees
ORDER BY surname 

-- c)
SELECT surname FROM students
EXCEPT
SELECT surname FROM employees

-- d)
SELECT surname FROM students
INTERSECT
SELECT surname FROM employees

-- e)
SELECT department FROM departments
EXCEPT 
SELECT department FROM lecturers

-- f)
SELECT module_id FROM modules
EXCEPT 
SELECT preceding_module FROM modules

-- g)
SELECT student_id, module_id
FROM students_modules
EXCEPT
SELECT student_id, module_id
FROM student_grades

-- h)
SELECT student_id FROM students_modules
WHERE module_id = 3
INTERSECT
SELECT student_id FROM students_modules
WHERE module_id = 12

-- i) 
SELECT surname, first_name, group_no AS group_departmet
FROM students
WHERE group_no LIKE 'DMIe%' 
UNION
SELECT employees.first_name, employees.surname, lecturers.department
FROM employees, lecturers
WHERE lecturers.lecturer_id = employees.employee_id
ORDER BY students.group_no
