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

-- 4a.13a
/* Nazwy wykładów oraz kwotę, jaką uczelnia musi przygotować na wypłaty pracownikom prowadzącym wykłady 
ze Statistics i Economics (osobno). Jeśli jest wiele wykładów o nazwie Statistics lub Economics, suma 
dla nich ma być obliczona łącznie. Zapytanie ma więc zwrócić dwa rekordy (jeden dla wykładów ze 
Statistics, drugi dla Economics).

Kwotę za jeden wykład należy obliczyć jako iloczyn stawki godzinowej prowadzącego wykładowcy oraz 
liczby godzin przeznaczonych na wykład. */

SELECT m.module_name, (m.no_of_hours * ap.overtime_rate) as result
FROM modules m 
JOIN lecturers l ON l.lecturer_id = m.lecturer_id
JOIN acad_positions ap ON ap.acad_position = l.acad_position 
GROUP BY m.module_name, (m.no_of_hours * ap.overtime_rate)
HAVING module_name = 'Economics' OR module_name = 'Statistics'

-- dla wykładu statistics lecturer o id = 30 nie ma przypisanego acad_position

-- 4a.13b
/* Sumaryczną kwotę, jaką uczelnia musi wypłacić wykładowcom łącznie z tytułu prowadzenia 
przez nich wykładów. */

SELECT SUM(m.no_of_hours * ap.overtime_rate) as result
FROM modules m 
JOIN lecturers l ON l.lecturer_id = m.lecturer_id
JOIN acad_positions ap ON ap.acad_position = l.acad_position 

-- 4a.13c
/* Kwotę, jaką uczelnia musi przygotować na wypłaty z tytułu prowadzenia wykładów, 
którym nie jest przypisany żaden wykładowca, przy założeniu, że za godzinę takiego 
wykładu należy zapłacić średnią z pola overtime_rate w tabeli acad_positions. */

SELECT 
(
	SELECT SUM(m.no_of_hours)
	FROM modules m
	LEFT JOIN lecturers l ON m.lecturer_id = l.lecturer_id
	WHERE m.lecturer_id IS NULL 
)
*
(
	SELECT AVG(overtime_rate)
	FROM acad_positions
)

-- 4a.13d
/* Kwotę, jaką uczelnia musi przygotować na wypłaty z tytułu prowadzenia wszystkich 
wykładów, za które nie można ustalić stawki godzinowej. Przyjmij założenie, że za 
godzinę takiego wykładu należy zapłacić maksymalną wartość z pola overtime_rate w 
tabeli acad_positions. */

SELECT 
(
	SELECT SUM(m.no_of_hours)
	FROM modules m
	LEFT JOIN lecturers l ON m.lecturer_id = l.lecturer_id
	WHERE m.lecturer_id IS NULL 
		OR l.acad_position IS NULL
)
*
(
	SELECT MAX(overtime_rate)
	FROM acad_positions
)

-- 4a.14 (?)
/* Nazwiska i imiona wykładowców wraz z sumaryczną liczbą godzin wykładów prowadzonych 
przez każdego z nich z osobna ale tylko w przypadku, gdy suma godzin prowadzonych wykładów
jest większa od 30. Kolumna zwracająca liczbę godzin ma mieć nazwę no_of_hours. Dane 
posortowane malejąco według liczby godzin. */

SELECT e.surname, e.first_name, SUM(m.no_of_hours) AS no_of_hours
FROM modules m
JOIN lecturers l ON l.lecturer_id = m.lecturer_id
JOIN employees e ON e.employee_id = l.lecturer_id
GROUP BY e.surname, e.first_name
HAVING SUM(m.no_of_hours) > 30
ORDER BY no_of_hours DESC

-- 4a.15
/* Nazwy wszystkich grup oraz liczbę studentów zapisanych do każdej grupy
(kolumna ma mieć nazwę no_of_students). Dane posortowane rosnąco według 
liczby studentów a następnie numeru grupy. */

SELECT g.group_no, COUNT(student_id) AS no_of_students
FROM groups g
LEFT JOIN students s ON g.group_no = s.group_no
GROUP BY g.group_no
ORDER BY COUNT(student_id), g.group_no

-- 4a.16
/* Nazwy wszystkich wykładów, których nazwa zaczyna się literą A oraz średnią ocen ze 
wszystkich tych wykładów osobno (jeśli jest wiele takich wykładów, to średnia ma być 
obliczona dla każdego z nich oddzielnie). Jeśli z danego wykładu nie ma żadnej oceny, 
także powinien on pojawić się na liście. Kolumna ma mieć nazwę average. */

SELECT m.module_name, AVG(sg.grade) AS average
FROM modules m
LEFT JOIN student_grades sg ON m.module_id = sg.module_id
GROUP BY m.module_name
HAVING m.module_name LIKE 'A%'

-- 4a.17
/* Nazwy grup, do których jest zapisanych co najmniej dwóch studentów, liczba studentów 
zapisanych do tych grup (kolumna ma mieć nazwę no_of_students) oraz średnie ocen dla 
każdej grupy (kolumna ma mieć nazwę average_grade). Dane posortowane malejąco według średniej. */

SELECT group_no, COUNT(s.student_id) AS no_of_students, AVG(sg.grade) AS average_grade
FROM students s
JOIN student_grades sg ON sg.student_id = s.student_id
GROUP BY group_no
HAVING COUNT(s.student_id) >= 2
ORDER BY  average_grade DESC

-- 4a.18
/* Nazwy tych katedr (department), w których pracuje co najmniej 2 doktorów (doctor) 
wraz z liczbą doktorów pracujących w tych katedrach (ta ostatnia kolumna ma mieć 
nazwę no_of_doctors). Dane posortowane malejąco według liczby doktorów i rosnąco
według nazw katedr. */

SELECT department, COUNT(acad_position) AS no_of_doctors
FROM lecturers
WHERE acad_position = 'doctor'
GROUP BY department, acad_position
HAVING COUNT(acad_position) >= 2
ORDER BY no_of_doctors DESC, department ASC

-- 4a.19 (?)
/* Identyfikatory, nazwy wykładów oraz nazwy katedr odpowiedzialnych za prowadzenie wykładów, 
dla których nie można ustalić kwoty, jaką trzeba zapłacić za ich przeprowadzenie wraz z nazwiskiem
i imieniem dowolnego spośród pracowników tych katedr. Dane posortowane według module_id. */

SELECT module_id, module_name, m.department, CONCAT(e.surname,' ',e.first_name) employee
FROM modules m
LEFT JOIN lecturers l ON m.lecturer_id = l.lecturer_id
LEFT JOIN employees e ON l.lecturer_id = e.employee_id
WHERE m.lecturer_id IS NULL
ORDER BY module_id
