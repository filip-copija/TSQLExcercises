-- SELECT 4a. Grupowanie i funkcje agregujące

-- 4a.01
-- Liczba studentów zarejestrowanych w bazie danych.

SELECT COUNT(*) 
FROM students

-- 4a.02
-- Liczba studentów, którzy są przypisani do jakiejś grupy.

SELECT COUNT(*) 
FROM students
WHERE group_no IS NOT NULL

-- 4a.03
-- Liczba studentów, którzy nie są przypisani do żadnej grupy.

SELECT COUNT(*) 
FROM students
WHERE group_no IS NULL

-- 4a.04
-- Liczba grup, do których jest przypisany co najmniej jeden student.

SELECT COUNT(DISTINCT group_no)
FROM students
WHERE group_no IS NOT NULL

-- 4a.05
/* Nazwy grup, do których zapisany jest przynajmniej jeden student wraz z liczbą studentów 
zapisanych do każdej grupy. Kolumna zwracająca liczbę studentów ma mieć nazwę no_of_students. 
Dane posortowane rosnąco według liczby studentów. */

SELECT group_no, COUNT(*) AS no_of_students
FROM students
WHERE group_no IS NOT NULL
GROUP BY group_no
HAVING COUNT(*) >= 1 
ORDER BY no_of_students ASC

-- 4a.06
/* Nazwy grup, do których zapisanych jest przynajmniej trzech studentów wraz z liczbą tych studentów. 
Kolumna zwracająca liczbę studentów ma mieć nazwę no_of_students. Dane posortowane rosnąco według liczby studentów. */

SELECT group_no, COUNT(*) AS no_of_students
FROM students
WHERE group_no IS NOT NULL
GROUP BY group_no
HAVING COUNT(*) >= 3
ORDER BY no_of_students ASC

-- 4a.07
/* Wszystkie możliwe oceny oraz ile razy każda z ocen została przyznana 
(kolumna ma mieć nazwę no_of_grades). Dane posortowane według ocen. */

SELECT g.grade, COUNT(sg.grade) AS no_of_grades
FROM grades g
LEFT JOIN student_grades sg ON g.grade = sg.grade
GROUP BY g.grade

-- 4a.08
/* Nazwy wszystkich katedr oraz ile godzin wykładów w sumie mają pracownicy zatrudnieni 
w  tych katedrach. Kolumna zwracająca liczbę godzin ma mieć nazwę total_hours. 
Dane posortowane rosnąco według kolumny total_hours. */

SELECT d.department, SUM(no_of_hours) no_of_hours
FROM departments d
LEFT JOIN lecturers l ON d.department = l.department
LEFT JOIN modules m ON l.lecturer_id = m.lecturer_id
GROUP BY d.department
ORDER BY no_of_hours

-- 4a.09
/* Nazwisko każdego wykładowcy wraz z liczbą prowadzonych przez niego wykładów. 
Kolumna zawierająca liczbę wykładów ma mieć nazwę no_of_modules. Dane posortowane 
malejąco według nazwiska. */

SELECT e.surname, COUNT(m.module_id) AS no_of_modules
FROM lecturers l
LEFT JOIN modules m ON m.lecturer_id = l.lecturer_id
JOIN employees e ON e.employee_id = l.lecturer_id
GROUP BY e.surname, l.lecturer_id
ORDER BY e.surname DESC

-- 4a.10
/* Nazwiska i imiona wykładowców prowadzących co najmniej dwa wykłady wraz z liczbą 
prowadzonych przez nich wykładów. Dane posortowane malejąco według liczby wykładów 
a następnie rosnąco według nazwiska. */

SELECT e.surname, e.first_name, COUNT(m.module_id) AS no_of_modules
FROM lecturers l
LEFT JOIN modules m ON m.lecturer_id = l.lecturer_id
JOIN employees e ON e.employee_id = l.lecturer_id
GROUP BY e.surname, l.lecturer_id, e.first_name
HAVING COUNT(*) >= 2
ORDER BY no_of_modules DESC, e.surname ASC

-- 4a.11
/* Nazwiska i imiona wszystkich studentów o nazwisku Bowen, którzy otrzymali przynajmniej 
jedną ocenę wraz ze średnią ocen (każdego Bowena z osobna). Kolumna zwracająca średnią ma 
mieć nazwę avg_grade. Dane posortowane malejąco według nazwisk i malejąco według imion. */

SELECT s.surname, s.first_name, CAST(AVG(sg.grade) AS DECIMAL (3,2)) AS avg_grade
FROM student_grades sg
LEFT JOIN students s ON s.student_id = sg.student_id
GROUP BY s.surname, s.first_name
HAVING s.surname = 'Bowen'
ORDER BY s.surname ASC, s.first_name DESC

-- 4a.12
/* Nazwiska i imiona wykładowców, którzy prowadzą co najmniej jeden wykład wraz ze średnią ocen 
jakie dali studentom (jeśli wykładowca nie dał do tej pory żadnej oceny, także ma się pojawić
na liście). Kolumna zwracająca średnią ma mieć nazwę avg_grade. Dane posortowane malejąco według 
średniej. */

SELECT e.surname, e.first_name, CAST(AVG(sg.grade) AS DECIMAL (3,2)) AS avg_grade
FROM employees e
JOIN modules m ON e.employee_id = m.lecturer_id
LEFT JOIN student_grades sg ON sg.module_id = m.module_id
GROUP BY e.surname, e.first_name, e.employee_id
ORDER BY avg_grade DESC
