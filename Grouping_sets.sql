-- SELECT 4b. Grouping Sets

-- 4b.1a
/* Nazwy katedr, w których pracuje co najmniej jeden wykładowca, tytuły naukowe występujące 
w ramach każdej katedry oraz informację o liczbie prowadzonych wykładów w ramach katedr 
i w katedrach przez każdą z grup wykładowców (według tytułu naukowego). W zapytaniu należy 
pominąć wykładowców, którzy nie prowadzą żadnego wykładu.
Użyj grupowania ROLLUP. */

SELECT l.department, acad_position, COUNT(module_id) AS number_of_modules
FROM lecturers l
JOIN modules m ON l.lecturer_id = m.lecturer_id
GROUP BY ROLLUP(l.department, acad_position)

-- 4b.1b
/* Używając funkcji GROUPING zmodyfikuj zapytanie tak, aby zwróciło informację, 
względem których pól jest wykonywane grupowanie. */

SELECT l.department, GROUPING(l.department) AS grp_department, acad_position,
	GROUPING(acad_position) AS grp_acad_position, COUNT(module_id) AS number_of_modules
FROM lecturers l
JOIN modules m ON l.lecturer_id = m.lecturer_id
GROUP BY ROLLUP(l.department, acad_position)

/* W niektórych polach będących wynikiem działania funkcji GROUPING pojawiły
się liczby 1,w niektórych 0 – zinterpretuj te wyniki.
W ostatnim rekordzie, w polach będących wynikiem działania funkcji GROUPING 
są dwie jedynki – zinterpretuj informację znajdującą się w tym rekordzie. */


-- 4b.1c
/* Zmodyfikuj zapytanie wyświetlając informację o sposobie grupowania
przy pomocy funkcji GROUPING_ID. */

SELECT GROUPING_ID(l.department, acad_position) AS grp, 
	l.department, acad_position, COUNT(module_id) AS number_of_modules
FROM lecturers l
JOIN modules m ON l.lecturer_id = m.lecturer_id
GROUP BY ROLLUP(l.department, acad_position)

/* W ostatnim rekordzie, w polu będącym wynikiem działania funkcji GROUPING_ID 
znajduje się liczba 3. Zinterpretuj tę informację.

Napisz zapytanie zwracające liczbę rekordów znajdujących się w tabeli modules.
Odpowiedz na pytanie, dlaczego liczba rekordów w tabeli modules (26) jest różna 
od liczby wykładów zwróconych w ostatnim rekordzie poprzedniego zapytania (20). */

SELECT COUNT(*) modules -- niektóre wykłady przypisane mają te same katedry

-- 4b.2a
/* Numery grup, do których zapisany jest co najmniej jeden student, nazwy wszystkich 
wykładów, na które studenci są zapisani oraz informację o liczbie studentów w ramach
każdej grupy oddzielnie zapisanych na poszczególne wykłady. */

SELECT group_no, module_name, COUNT(sm.student_id) AS no_of_students
FROM students s
LEFT JOIN students_modules sm ON s.student_id = sm.student_id
LEFT JOIN modules m ON sm.module_id = m.module_id
GROUP BY ROLLUP(group_no, module_name)

/* W pierwszych 16 rekordach w polu group_no znajduje się wartość NULL.
Zinterpretuj tę informację. */

-- są to studenci bez grup

--4b.2b
/* Zmodyfikuj poprzednie zapytanie, aby zwracało wynik działania funkcji
GROUPING_ID (kolumnę nazwij grp_id). Zinterpretuj znaczenie liczb 0, 1 i 3
znajdujących się w kolumnie zawierającej wynik działania tej funkcji. */

SELECT GROUPING_ID(group_no, module_name) as grp_id,
group_no, module_name, COUNT(sm.student_id) AS no_of_students
FROM students s
LEFT JOIN students_modules sm ON s.student_id = sm.student_id
LEFT JOIN modules m ON sm.module_id = m.module_id
GROUP BY ROLLUP(group_no, module_name)

-- 0 grupowanie po group_no, module_name
-- 1 grupowanie po group_no
-- 3 (011)

-- 4b.2c
/* Zmodyfikuj poprzednie zapytanie, aby zwracało jedynie rekordy, które 
w polu grp_id mają liczbę 1. */

SELECT GROUPING_ID(group_no, module_name) as grp_id,
group_no, module_name, COUNT(sm.student_id) AS no_of_students
FROM students s
LEFT JOIN students_modules sm ON s.student_id = sm.student_id
LEFT JOIN modules m ON sm.module_id = m.module_id
GROUP BY ROLLUP(group_no, module_name)
HAVING GROUPING_ID(group_no, module_name) = 1

-- Napisz zapytanie zwracające informację o liczbie RÓŻNYCH grup w tabeli students. 
SELECT COUNT(DISTINCT group_no) FROM students
-- NULL oznacza, że studenci nie sa przypisani do grupy i jest ich 24

-- 4b.3
/* Nazwy stopni/tytułów naukowych, nazwy katedr oraz informację, ile godzin mają 
poszczególne grupy wykładowców (posiadających taki sam stopień/tytuł) w ramach każdej 
katedry. Użyj funkcji GROUPING_ID lub GROUPING. */

SELECT GROUPING_ID(acad_position, l.department) AS grp, 
	acad_position, l.department, SUM(no_of_hours) AS number_of_hours
FROM lecturers l
JOIN modules m ON l.lecturer_id = m.lecturer_id
GROUP BY ROLLUP(acad_position, l.department)
