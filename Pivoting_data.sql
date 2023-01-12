-- Skill 2.3/2. Pivoting and unpivoting data

-- 23/2.01a
/* Nazwy wszystkich katedr, w których pracuje co najmniej jeden wykładowca
(w pierwszej kolumnie), trzy tytuły naukowe: doctor, master, full professor 
(w pierwszym wierszu) oraz liczbę godzin zajęć prowadzonych w ramach każdej 
katedry przez każdą z tych trzech grup pracowników. Użyj składni CTE. */

-- CTE
WITH PivotData AS
(
	SELECT
		l.department, -- grouping_column
		acad_position, -- spreading_column
		no_of_hours -- aggregation_column
	FROM lecturers l
	LEFT JOIN modules m ON l.lecturer_id = m.lecturer_id
)
SELECT department, [doctor], [master], [full professor]
FROM PivotData 
PIVOT(SUM(no_of_hours) -- aggregation function, column
FOR acad_position -- spreading_column 
IN([doctor], [master], [full professor]) -- distinct_spreading_values
)
AS P

-- derived table
SELECT * FROM
	(SELECT l.department, acad_position, no_of_hours
	FROM lecturers l
	LEFT JOIN modules m ON l.lecturer_id = m.lecturer_id)
PivotData

PIVOT(SUM(no_of_hours)
FOR acad_position 
IN([doctor], [master], [full professor]) )
AS P

-- 23/2.01c
/* Zmodyfikuj zapytanie z punktu 2.01a, aby wynik został zapisany w tabeli o nazwie 
#hours (tabela, której nazwa jest poprzedzona znakiem # istnieje do zamknięcia sesji). */

WITH PivotData AS
(
	SELECT 
		l.department, -- grouping_column
		acad_position, -- spreading_column
		no_of_hours -- aggregation_column
	FROM lecturers l
	LEFT JOIN modules m ON l.lecturer_id = m.lecturer_id
)
SELECT department, [doctor], [master], [full professor] INTO #hours
FROM PivotData 
PIVOT(SUM(no_of_hours) -- aggregation function, column
FOR acad_position -- spreading_column 
IN([doctor], [master], [full professor]) -- distinct_spreading_values
)
AS P

-- dynamic table

DECLARE @cols AS NVARCHAR(MAX) = ''
DECLARE @query AS NVARCHAR(MAX) = ''


SELECT @cols = @cols + QUOTENAME(acad_position) + ',' -- adds delimiters [ ] to expression
	FROM (SELECT DISTINCT acad_position 
		  FROM lecturers
		  WHERE acad_position IS NOT NULL) AS tmp
SET @cols = substring(@cols, 1, len(@cols)-1) -- trim "," at the end
PRINT @cols

SET @query='
SELECT * FROM
	(SELECT l.department, acad_position, no_of_hours
	FROM lecturers l
	JOIN modules m ON l.lecturer_id = m.lecturer_id)
PivotData

PIVOT(SUM(no_of_hours)
FOR acad_position 
IN(' + @cols + ') )
AS P'

execute(@query) 

-- 23/2.01d
-- Wykonaj operację UNPIVOT na tabeli #hours.

SELECT department, acad_position, no_of_hours
FROM #hours
UNPIVOT (no_of_hours FOR acad_position
	IN ([doctor], [master], [full professor]))
AS UP

SELECT * FROM #hours

-- 23/2.02
/* Nazwy wszystkich stopni/tytułów naukowych przypisanych co najmniej jednemu wykładowcy
(w pierwszej kolumnie), trzy katedry: Department of History, Department of Informatics 
oraz Department of Statistics (w pierwszym wierszu) oraz liczbę wykładów prowadzonych
przez poszczególne grupy pracowników w ramach tych trzech katedr. */

WITH PivotData AS
(
	SELECT
		acad_position,
		l.department,
		module_id
	FROM lecturers l 
	LEFT JOIN modules m ON m.lecturer_id = l.lecturer_id
)
SELECT acad_position, [Department of History], 
	[Department of Informatics], [Department of Statistics]
FROM PivotData
PIVOT(COUNT(module_id)
FOR department
IN( [Department of History], 
	[Department of Informatics], [Department of Statistics]))
AS P

-- Zinterpretuj fakt, że w pierwszym rekordzie jako acad_position jest NULL.
-- Wykładowca ten nie ma przypisanego acad_position

-- 23/2.03
/* Identyfikatory studentów, którzy dokonywali wpłat za studia w ostatnim kwartale 
2018 roku (w pierwszej kolumnie), nazwy miesięcy ostatniego kwartału:
October, November, December (w pierwszym wierszu) oraz sumę wpłat dokonanych przez 
poszczególnych studentów w poszczególnych miesiącach. Aby otrzymać nazwy miesięcy użyj 
funkcji DATENAME. */

WITH PivotData AS
(
	SELECT 
		student_id,
		DATENAME(MONTH, date_of_payment) AS MONTH,
		fee_amount
	FROM tuition_fees
	WHERE date_of_payment BETWEEN '20181001' AND '20181231'
)
SELECT student_id, [October], [November], [December]
FROM PivotData
PIVOT(SUM(fee_amount)
FOR MONTH
IN([October], [November], [December]))
AS P

-- 23/2.04
/* Wszystkie oceny przyznane co najmniej raz (w pierwszej kolumnie), nazwy trzech 
wykładów: Management, Statistics i Economics (w pierwszym wierszu) oraz informację, 
ile razy każda z ocen została przyznana z poszczególnych wykładów. */

WITH PivotData AS
(
	SELECT
		grade,
		module_name,
		student_id
	FROM modules m
	JOIN student_grades sg ON sg.module_id = m.module_id
)
SELECT grade, [Managment], [Statistics], [Economics]
FROM PivotData
PIVOT(COUNT(student_id)
FOR module_name
IN([Managment], [Statistics], [Economics]))
AS P

/* Zapytanie miało zwrócić oceny przyznane co najmniej raz. Tymczasem w trzech ostatnich
rekordach (oceny 4.5, 5, 5.5) jest informacja, że oceny te nie zostały przyznane.
Zinterpretuj tę informację. */

-- oceny nie zostały przyznane tylko dla [Managment], [Statistics], [Economics]

DECLARE @cols AS NVARCHAR(MAX) = ''
DECLARE @query AS NVARCHAR(MAX) = ''


SELECT @cols = @cols + QUOTENAME(module_name) + ',' -- adds delimiters [ ] to expression
	FROM (SELECT DISTINCT module_name 
		  FROM modules
		  WHERE module_name IS NOT NULL) AS tmp
SET @cols = substring(@cols, 1, len(@cols)-1) -- trim "," at the end
PRINT @cols

SET @query='
SELECT * FROM
	(SELECT grade, module_name, student_id
	FROM modules m
	JOIN student_grades sg ON sg.module_id = m.module_id)
PivotData

PIVOT(COUNT(student_id)
FOR module_name
IN(' + @cols + '))
AS P'

execute(@query) 

-- 23/2.05a
/* Wszystkie oceny przyznane co najmniej raz (w pierwszej kolumnie), nazwy wszystkich wykładów 
(w pierwszym wierszu) oraz informację, ile razy każda z ocen została przyznana z każdego z wykładów. 
Wykorzystaj operator PIVOT i składnię Derived tables. */

-- powyżej

-- 23/2.05b
-- Wyeliminuj z wyniku powyższego zapytania nazwy wykładów, z których nie została przyznana żadna ocena.

DECLARE @cols AS NVARCHAR(MAX) = ''
DECLARE @query AS NVARCHAR(MAX) = ''


SELECT @cols = @cols + QUOTENAME(module_name) + ',' -- adds delimiters [ ] to expression
	FROM (SELECT DISTINCT module_name 
		  FROM modules m
		  JOIN student_grades sg ON sg.module_id = m.module_id
		  WHERE module_name IS NOT NULL) AS tmp
SET @cols = substring(@cols, 1, len(@cols)-1) -- trim "," at the end
PRINT @cols

SET @query='
SELECT * FROM
	(SELECT grade, module_name, student_id
	FROM modules m
	JOIN student_grades sg ON sg.module_id = m.module_id)
PivotData

PIVOT(COUNT(student_id)
FOR module_name
IN(' + @cols + '))
AS P'

execute(@query) 

-- 23/2.05c
-- Zmodyfikuj kod z punktu b) – zamiast Derived tables wykorzystaj składnię CTE.

DECLARE @cols AS NVARCHAR(MAX) = ''
DECLARE @query AS NVARCHAR(MAX) = ''


SELECT @cols = @cols + QUOTENAME(module_name) + ',' -- adds delimiters [ ] to expression
	FROM (SELECT DISTINCT module_name 
		  FROM modules m
		  JOIN student_grades sg ON sg.module_id = m.module_id
		  WHERE module_name IS NOT NULL) AS tmp
SET @cols = substring(@cols, 1, len(@cols)-1) -- trim "," at the end
PRINT @cols

SET @query='
WITH PivotData AS
(
	SELECT 
		grade,
		module_name,
		student_id
	FROM modules m
	JOIN student_grades sg ON sg.module_id = m.module_id
)
SELECT grade, ' + @cols + '
FROM PivotData
PIVOT(COUNT(student_id)
FOR module_name
IN(' + @cols + '))
AS P'

execute(@query) 

-- 23/2.06
/* Informację o liczbie pracowników zatrudnionych w poszczególnych miesiącach (niezależnie od roku).
W pierwszym wierszu mają się pojawić nazwy miesięcy, w drugim liczba zatrudnionych w każdym z nich.
Należy wykluczyć miesiące, w których żaden pracownik nie był zatrudniony. Zapytanie ma wyświetlić 
informację o liczbie pracowników, dla których data zatrudnienia jest nieznana (pod nazwą Unknown). */

DECLARE @cols  AS NVARCHAR(MAX)='';
DECLARE @query AS NVARCHAR(MAX)='';

SELECT @cols = @cols + QUOTENAME(month_name) + ','
FROM (select distinct
isnull(datename(month,employment_date),'Unknown') AS month_name FROM employees) AS tmp
SET @cols = substring(@cols, 1, len(@cols)-1);

SET @query = 
'SELECT * FROM 
(
 SELECT ''number_of_employed'' as number_of_employed, 
   ISNULL(datename(month,employment_date),''Unknown'') as month_name,
   employee_id 
 FROM employees
) PivotData
PIVOT
(
  COUNT(employee_id) 
  FOR month_name 
  IN (' + @cols + ')
) PivotData'

execute(@query)


-- 23/2.07
-- Kwotę wpłat studentów w poszczególnych miesiącach 2019 roku.

DECLARE @cols  AS NVARCHAR(MAX)='';
DECLARE @query AS NVARCHAR(MAX)='';

SELECT @cols = @cols + QUOTENAME(month_name) + ','
FROM (select distinct datename(month,date_of_payment) as month_name
from tuition_fees) as tmp
SET @cols = substring(@cols, 1, len(@cols)-1);

SET @query = 
'SELECT * FROM 
(
 SELECT datename(month,date_of_payment) as month_name,
		fee_amount 
 FROM tuition_fees
 WHERE date_of_payment between ''20190101'' and ''20191231''
) PivotData
PIVOT
(
  SUM(fee_amount)
  FOR month_name
  IN (' + @cols + ')
) P'

execute(@query)

SELECT * FROM tuition_fees
