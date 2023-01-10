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
	JOIN modules m ON l.lecturer_id = m.lecturer_id
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
	JOIN modules m ON l.lecturer_id = m.lecturer_id)
PivotData

PIVOT(SUM(no_of_hours)
FOR acad_position 
IN([doctor], [master], [full professor]) )
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
