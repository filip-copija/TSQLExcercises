-- Skill 2.2. Query data by using table expressions

/* 22.01a – Widok (view) i funkcja (function)
Nazwiska i imiona studentów zapisanych na wykład z matematyki (Mathematics).
Dane posortowane według nazwisk. Użyj składni podzapytania. */

CREATE OR ALTER VIEW v_mathematics AS
	SELECT surname, first_name
	FROM students s
	WHERE student_id IN(
		SELECT student_id
		FROM students_modules sm
		JOIN modules m ON m.module_id = sm.module_id
		WHERE m.module_name = 'Mathematics')

SELECT * FROM v_mathematics
ORDER BY surname

----------

CREATE OR ALTER FUNCTION f_mathematics() RETURNS TABLE AS
RETURN
SELECT surname, first_name
	FROM students s
	WHERE student_id IN(
		SELECT student_id
		FROM students_modules sm
		JOIN modules m ON m.module_id = sm.module_id
		WHERE m.module_name = 'Mathematics')

SELECT * FROM f_mathematics()
ORDER BY surname

/* 22.01b – Widok (view) i funkcja (function)
Napisz funkcję o nazwie studmod_f, która zwróci nazwiska i imiona studentów zapisanych na 
wykład o nazwie przekazanej do funkcji przy pomocy parametru. 
Uruchom funkcję podając jako parametr nazwę wybranego wykładu. */

CREATE OR ALTER FUNCTION studmod_f(@D1 VARCHAR(50))RETURNS TABLE AS
RETURN
SELECT surname, first_name
	FROM students s
	WHERE student_id IN(
		SELECT student_id
		FROM students_modules sm
		JOIN modules m ON m.module_id = sm.module_id
		WHERE m.module_name = @D1)
GO

SELECT * FROM studmod_f('Mathematics')
SELECT * FROM studmod_f('Statistics') 
SELECT * FROM studmod_f('Databases') 

----------

CREATE OR ALTER VIEW studmod_v AS
	SELECT surname, first_name
	FROM students s
	WHERE student_id IN(
		SELECT student_id
		FROM students_modules sm
		JOIN modules m ON m.module_id = sm.module_id
		WHERE m.module_name = CONTEXT_INFO())
GO

DECLARE @D1 AS VARBINARY(128) = CAST('Statistics' AS VARBINARY(128));
SET CONTEXT_INFO @D1

SELECT * FROM studmod_v

/* 22.01c – Widok (view) i funkcja (function)
Jedną z różnic między funkcją a widokiem jest to, że do funkcji można przekazać parametr a do widoku nie.
Aby przekazać parametr do widoku, można jednak użyć context info lub session context.
Utwórz widok o nazwie studmod_v, który zwróci nazwiska i imiona studentów zapisanych na wykład o nazwie 
przekazanej do widoku przy pomocy session context. Wykorzystaj mechanizm session context do przekazania 
nazwy wykładu do widoku i uruchom widok. */

CREATE OR ALTER VIEW studmod2_v AS
	SELECT surname, first_name
	FROM students s
	WHERE student_id IN(
		SELECT student_id
		FROM students_modules sm
		JOIN modules m ON m.module_id = sm.module_id
		WHERE m.module_name = CAST(SESSION_CONTEXT(N'D2') AS VARCHAR(50)))
GO

EXEC sp_set_session_context @key = 'D2', @value = 'Statistics'

SELECT * FROM studmod2_v

/* 22.02 – Funkcja ROW_NUMBER()
Wszystkie dane z tabeli student_grades, w ramach każdego module_id (partition by) posortowane według daty 
egzaminu a następnie identyfikatora studenta oraz ponumerowane kolejnymi liczbami. Pole zawierające kolejny 
numer oceny w ramach każdego module_id ma mieć nazwę sequence_num. */

SELECT ROW_NUMBER() OVER
	(PARTITION BY module_id
	ORDER BY exam_date, student_id) AS squence_num, *
	FROM student_grades

/* 22.03 – Funkcja ROW_NUMBER()
Wszystkie dane z tabeli student_grades, w ramach każdego student_id posortowane według daty egzaminu oraz 
ponumerowane kolejnymi liczbami. Zapytanie ma zwrócić jedynie dane o ocenach pozytywnych (większych niż 2).
Pole zawierające kolejny numer oceny w ramach każdego student_id ma mieć nazwę sequence_num. */

SELECT * 
FROM
(SELECT ROW_NUMBER()
	OVER(PARTITION BY student_id
	ORDER BY grade) AS sequence_num, *
	FROM student_grades) AS D
WHERE grade > 2

/* 22.04 – Funkcja ROW_NUMBER()
Identyfikatory i nazwiska studentów oraz daty egzaminów, w ramach każdego student_id posortowane według daty 
egzaminu oraz ponumerowane kolejnymi liczbami. Zapytanie ma zwrócić jedynie dane o ocenach negatywnych (równych 2).
Pole zawierające kolejny numer oceny w ramach każdego student_id ma mieć nazwę sequence_num. */

SELECT student_id, exam_date -- surname?
FROM
(SELECT ROW_NUMBER() OVER(PARTITION BY student_id 
	ORDER BY exam_date) AS sequence_num, *
	FROM student_grades) AS D -- join?
WHERE grade = 2

----------

WITH C AS
(
	SELECT
	ROW_NUMBER() OVER(PARTITION BY s.student_id 
	ORDER BY sg.exam_date) AS sequence_num,
	s.student_id, s.surname, sg.exam_date
	FROM students s
	INNER JOIN student_grades sg ON s.student_id = sg.student_id
	WHERE sg.grade = 2
)
SELECT *
FROM C

/* 22.05 – Funkcja ROW_NUMBER()
Wszystkie dane z tabeli students, grupami. W ramach każdej grupy dane posortowane według daty urodzenia studenta.
W ramach każdej grupy rekordy mają być ponumerowane. */

WITH C AS
(
	SELECT ROW_NUMBER() OVER(PARTITION BY group_no
	ORDER BY date_of_birth) AS sequence_num, *
	FROM students
)
SELECT *
FROM C

/* 22.06a
Identyfikator, nazwisko i datę ostatniego egzaminu dla każdego studenta. 
Zapytanie ma zwrócić jedynie dane o studentach, którzy przystąpili co najmniej do jednego egzaminu.
Napisz zapytanie w dwóch wersjach: raz używając składni derived tables, raz CTE. */

SELECT *
FROM
	(SELECT
	ROW_NUMBER() OVER(PARTITION BY s.student_id 
	ORDER BY exam_date) AS sequence_num,
	s.student_id, s.surname, sg.exam_date
	FROM students s
	INNER JOIN student_grades sg ON s.student_id = sg.student_id) D
WHERE sequence_num = 1

----------

WITH C AS
(
	SELECT ROW_NUMBER()
	OVER(PARTITION BY s.student_id
	ORDER BY exam_date) AS seuqence_num,
	s.student_id, s.surname, sg.exam_date
	FROM students s
	INNER JOIN student_grades sg ON s.student_id = sg.student_id
)
SELECT * 
FROM C
WHERE seuqence_num = 1

/* 22.06b
Korzystając z poprzedniego zapytania utwórz widok (VIEW) o nazwie last_exam zwracający identyfikator, 
nazwisko i datę ostatniego egzaminu dla każdego studenta.
Uruchom widok i sprawdź poprawność jego działania.
Wskazówka: Aby utworzyć widok, należy zapytanie poprzedzić instrukcją CREATE VIEW.
Uwaga: Widok nie może mieć takiej samej nazwy jak inny obiekt w bazie danych (tabela, funkcja). */

CREATE OR ALTER VIEW v_last_exam AS
	WITH C AS
	(
		SELECT ROW_NUMBER()
		OVER(PARTITION BY s.student_id
		ORDER BY exam_date) AS seuqence_num,
		s.student_id, s.surname, sg.exam_date
		FROM students s
		INNER JOIN student_grades sg ON s.student_id = sg.student_id
	)
	SELECT * 
	FROM C
	WHERE seuqence_num = 1
GO

SELECT * FROM v_last_exam

/* 22.06c
Zmodyfikuj utworzony widok o nazwie last_exam, aby wywołując go instrukcją SELECT można było podać liczbę 
oznaczającą, ile rekordów z danymi o ostatnich egzaminach ma zostać zwróconych dla każdego studenta.
Wskazówka: widok powinien zwracać dane o wszystkich egzaminach dla każdego studenta, dzięki czemu zapytanie 
uruchamiające widok może zawierać klauzulę WHERE zawierającą warunek wskazujący, ile ostatnich egzaminów dla 
każdego studenta ma zostać zwróconych. */

CREATE OR ALTER VIEW v_last_exam AS
	WITH C AS
	(
		SELECT ROW_NUMBER()
		OVER(PARTITION BY s.student_id
		ORDER BY exam_date) AS seuqence_num,
		s.student_id, s.surname, sg.exam_date
		FROM students s
		INNER JOIN student_grades sg ON s.student_id = sg.student_id
	)
	SELECT * 
	FROM C
GO

SELECT * FROM v_last_exam
WHERE seuqence_num = 1
SELECT * FROM v_last_exam
WHERE seuqence_num <= 3

/* 22.06d
Korzystając z poprzedniego zapytania utwórz funkcję o nazwie last_exams zwracającą identyfikator,
nazwisko i datę tylu ostatnich egzaminów każdego studenta, ile wynosi wartość parametru funkcji 
(np. jeśli jako parametr funkcji podana zostanie liczba 4, to funkcja ma zwrócić daty ostatnich 4 egzaminów
każdego studenta). Uruchom funkcję i sprawdź poprawność jej działania. */

CREATE OR ALTER FUNCTION f_last_exam(@D1 INT) RETURNS TABLE AS
RETURN
WITH C AS
	(
		SELECT ROW_NUMBER()
		OVER(PARTITION BY s.student_id
		ORDER BY exam_date) AS seuqence_num,
		s.student_id, s.surname, sg.exam_date
		FROM students s
		INNER JOIN student_grades sg ON s.student_id = sg.student_id	
	)
	SELECT * 
	FROM C
	WHERE seuqence_num <= @D1
GO

SELECT * FROM f_last_exam(1)
SELECT * FROM f_last_exam(2)
SELECT * FROM f_last_exam(4)

/* 22.07a
Wszystkie dane o dwóch najmłodszych studentach w każdej grupie. W zapytaniu pomiń dane o studentach, 
którzy nie są przypisani do żadnej grupy oraz o tych, którzy nie mają przypisanej daty urodzenia.
Napisz zapytanie w dwóch wersjach: raz używając składni derived tables, raz CTE. */

SELECT *
FROM
	(SELECT *,
	ROW_NUMBER() OVER(PARTITION BY group_no 
	ORDER BY date_of_birth DESC) row_num
	FROM students) D
WHERE date_of_birth IS NOT NULL
AND group_no IS NOT NULL
AND row_num < 3

----------

WITH C AS
(
	SELECT *,
	ROW_NUMBER() OVER(PARTITION BY group_no 
	ORDER BY date_of_birth DESC) row_num
	FROM students	
)
SELECT *
FROM C
WHERE date_of_birth IS NOT NULL
AND group_no IS NOT NULL	
AND row_num < 3

/* 22.07b
Korzystając z poprzedniego zapytania napisz funkcję o nazwie youngest_students, która zwróci dane o tylu 
najmłodszych studentach, ile wskazuje pierwszy parametr funkcji, z grupy, której nazwa zostanie podana jako 
drugi parametr. Uruchom funkcję (wykorzystaj instrukcję SELECT) i sprawdź poprawność jej działania. */

CREATE OR ALTER FUNCTION f_youngest_students(@D1 INT, @D2 VARCHAR(50)) RETURNS TABLE AS
RETURN
WITH C AS
(
	SELECT *,
	ROW_NUMBER() OVER(PARTITION BY group_no 
	ORDER BY date_of_birth DESC) row_num
	FROM students	
)
SELECT *
FROM C
WHERE date_of_birth IS NOT NULL
AND group_no IS NOT NULL	
AND row_num <= @D1 
AND group_no = @D2

SELECT * FROM f_youngest_students(4, 'DMIe1011')
SELECT * FROM f_youngest_students(3, 'ZMIe2012')
SELECT * FROM f_youngest_students(5, 'DZZa3001')

-- 22.08a – recursive CTE
/* Module_id, module_name and no_of_hours wykładu o identyfikatorze 9 wraz z łańcuchem poprzedzających wykładów.
Kolumnę zawierającą kolejny poziom nazwij distance. */

WITH C AS
(
	SELECT *, 0 AS distance
	FROM modules
	WHERE module_id = 9
		UNION ALL
	SELECT D.*, S.distance + 1
	FROM C S 
	JOIN modules D on s.preceding_module = D.module_id
)
SELECT module_id, module_name, no_of_hours, distance
FROM C

-- 22.08b
/* Na podstawie powyższego zapytania napisz funkcję o nazwie preceding_modules zwracającą module_id, module_no oraz 
no_of_hours wykładu o identyfikatorze podanym jako parametr funkcji wraz z łańcuchem poprzedzających wykładów. */

CREATE OR ALTER FUNCTION f_preceding_modules(@ID INT)
RETURNS TABLE AS RETURN
(
	WITH C AS
(
	SELECT *, 0 AS distance
	FROM modules
	WHERE module_id = @ID
		UNION ALL
	SELECT D.*, S.distance + 1
	FROM C S 
	JOIN modules D on s.preceding_module = D.module_id
)
SELECT module_id, module_name, no_of_hours, distance
FROM C
)
SELECT *
FROM f_preceding_modules(9)
SELECT *
FROM f_preceding_modules(5)
SELECT *
FROM f_preceding_modules(8)
