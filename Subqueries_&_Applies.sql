-- Skill 2.1. Query data by using subqueries and APPLY.

-- 21.01
/* Identyfikatory i nazwy wykładów, na które nie został zapisany żaden student.
Dane posortowane malejąco według nazw wykładów. Użyj składni podzapytania. */

select module_id, module_name
from modules
where module_id not in
(select module_id
from students_modules)
order by module_name desc

-- 21.02
/* Identyfikatory studentów, którzy przystąpili do egzaminu zarówno 2018-03-22 jak i 2018 09 30.
Dane posortowane malejąco według identyfikatorów. Napisz dwie wersje tego zapytania: raz używając składni podzapytania, 
drugi raz operatora INTERSECT. */

select distinct student_id -- ?
from student_grades
where student_id in
(select student_id
from student_grades
where exam_date = '2018-03-22' and student_id in 
(select student_id
from student_grades 
where exam_date = '2018-09-30'))
order by student_id desc

select student_id
from student_grades
where exam_date = '2018-03-22'
intersect
select student_id
from student_grades
where exam_date = '2018-09-30'
order by student_id desc

-- 21.03
/* Identyfikatory, nazwiska, imiona i numery grup studentów, którzy zapisali się zarówno na wykład o identyfikatorze 2 jak i 4. 
Dane posortowane malejąco według nazwisk. Użyj składni podzapytania a w zapytaniu zewnętrznym także złączenia. */

select s.student_id, s.surname, s.first_name, s.group_no
from students s
where s.student_id in
(select sm.student_id
from students_modules sm
join modules m on sm.module_id = m.module_id
where m.module_id = 2 and sm.student_id in
(select sm.student_id
from students_modules sm
join modules m on sm.module_id = m.module_id
where m.module_id = 4))
order by surname desc

-- 21.04
/* Identyfikatory, nazwiska i imiona studentów, którzy zapisali się na wykład z matematyki (Mathematics) ale nie zapisali się na wykład ze statystyki (Statistics). 
Zapytanie napisz korzystając ze składni podzapytania, według następującego algorytmu:
•	najbardziej wewnętrznym zapytaniem wybierz identyfikatory studentów, którzy zapisali się na wykład ze statystyki 
	(tu potrzebne będzie złączenie),
•	kolejnym zapytaniem wybierz identyfikatory studentów, którzy zapisali się na wykład z matematyki (także potrzebne będzie złączenie)
	oraz nie zapisali sią na wykład ze statystyki (ich identyfikatory nie należą do zbioru zwróconego przez poprzednie zapytanie),
•	zewnętrznym zapytaniem wybierz dane o studentach, których identyfikatory należą do zbioru zwróconego przez zapytanie środkowe. */

select student_id, surname, first_name
from students 
where student_id in
(select student_id 
from students_modules sm
join modules m on m.module_id = sm.module_id
where module_name = 'Mathematics' and student_id not in
(select student_id
from students_modules sm
join modules m on m.module_id = sm.module_id
where module_name = 'Statistics'))

-- 21.05
/* Imiona, nazwiska i numery grup studentów z grup, których nazwa zaczyna się na DMIe i kończy cyfrą 1 i którzy nie są 
zapisani na wykład z „Ancient history”. Użyj składni zapytania negatywnego a w zapytaniu wewnętrznym także złączenia. */

select first_name, surname, group_no 
from students
where group_no like 'DMIe%1' and student_id not in
(select student_id
from students_modules sm
join modules m on m.module_id = sm.module_id
where module_name = 'Ancient history')

-- 21.06
/* Nazwy wykładów o najmniejszej liczbie godzin. Zapytanie, oprócz nazw wykładów, ma zwrócić także liczbę godzin.
Użyj operatora ALL. */

select module_name, no_of_hours
from modules
where no_of_hours <= all (select no_of_hours from modules)

-- 21.07
/* Identyfikatory i nazwiska studentów, którzy otrzymali ocenę wyższą od najniższej. Dane każdego studenta mają się pojawić tyle razy, ile takich ocen otrzymał.
Użyj operatora ANY. W zapytaniu nie wolno posługiwać się liczbami oznaczającymi oceny 2, 3, itd.) ani funkcjami agregującymi (MIN, MAX). */

select s.student_id, s.surname
from student_grades sg
join students s on sg.student_id = s.student_id
where grade > any (select grade from student_grades)

select * from student_grades where grade > 2

-- 21.08
/* Napisz jedno zapytanie, które zwróci dane o najmłodszym i najstarszym studencie (do połączenia tych danych użyj jednego z operatorów typu SET). 
W zapytaniu nie wolno używać funkcji agregujących (MIN, MAX).
Uwaga: należy uwzględnić fakt, że data urodzenia w tabeli students może być NULL, do porównania należy więc wybrać rekordy, które w polu date_of_birth mają wpisane daty.
Użyj operatora ALL. */

select top(1) * from students
where date_of_birth is not null and date_of_birth = all(select date_of_birth from student_grades)
union
select top(2) * from students
where date_of_birth is not null and date_of_birth = all(select date_of_birth from student_grades)
order by date_of_birth asc

-- 21.09a
/* Identyfikatory, imiona i nazwiska studentów z grupy DMIe1011, którzy otrzymali oceny z egzaminu wcześniej, niż wszyscy pozostali studenci z innych grup (nie uwzględniamy studentów, którzy nie są zapisani do żadnej grupy). Dane każdego studenta mają się pojawić tylko raz.
Użyj złączenia i operatora ALL. */

select distinct s.student_id, s.first_name, s.surname -- ?
from students s
left join student_grades sg on  s.student_id = sg.student_id 
where s.group_no = 'DMIe1011' and sg.exam_date <= all
(select sg.exam_date
from student_grades sg
where s.group_no is not null )

-- 21.09b
/* Jak wyżej, ale tym razem należy uwzględnić studentów, którzy nie są zapisani do żadnej grupy. */

select distinct s.student_id, s.first_name, s.surname -- ?
from students s
left join student_grades sg on sg.student_id = s.student_id 
where s.group_no = 'DMIe1011' and sg.exam_date <= all
(select sg.exam_date
from student_grades sg)

-- 21.10
/* Nazwy wykładów, którym przypisano największą liczbę godzin (wraz z liczbą godzin).
Wyko¬rzystaj składnię podzapytania z operatorem =. W zapytaniu wewnętrznym użyj funkcji MAX. */

select module_name, no_of_hours
from modules
where no_of_hours =
(select max(no_of_hours)
from modules)

-- 21.11
/* Nazwy wykładów, którym przypisano liczbę godzin większą od najmniejszej. 
Użyj funkcji MIN i składni podzapytania z operatorem >. */

select module_name, no_of_hours
from modules
where no_of_hours >
(select min(no_of_hours)
from modules)
order by no_of_hours desc

-- 21.12a
/* Wszystkie dane o najstarszym studencie z każdej grupy. 
Użyj fujnkcji MIN i składni podzapytania skorelowanego z operatorem =. */

select *
from students as s1
where date_of_birth =
	(select min(date_of_birth)
	from students s2
	where s1.group_no = s2.group_no)

-- 21.12b
/* Wszystkie numery grup z tabeli students posortowane według numerów grup. Każda grupa ma się pojawić jeden raz.
Zapytanie zwróciło 13 rekordów. Ponieważ jedną z wartości jest NULL, więc studenci są przypisani do 12 różnych grup.
Poprzednie zapytanie, zwracające dane o najmłodszym studencie z każdej grupy, zwróciło 11 rekordów. Znajdź przyczynę tej różnicy. */

select distinct group_no
from students
-- dwa null null

-- 21.13
/* Identyfikatory, nazwiska i imiona studentów, którzy otrzymali ocenę 5.0. 
Nazwisko każdego studenta ma się pojawić jeden raz. 
Użyj operatora EXISTS. */

select student_id, surname, first_name
from students s
where exists 
	(select *
	from student_grades sg
	where s.student_id = sg.student_id
	and sg.grade = 5)

select * from student_grades where grade = 5

-- 21.14a
/* Wszystkie dane o wykładach, w których uczestnictwo wymaga wcześniejszego uczestnictwa
w wykładzie o identyfikatorze 3. 
Użyj operatora EXISTS. */

select *
from modules m1
where exists
	(select module_id
	from modules m2
	where m1.module_id = m2.module_id and preceding_module = 3)

-- 21.14b
/* Nazwy wykładów, w których uczestnictwo wymaga wcześniejszego uczestnictwa w wykładzie z matematyki (Mathematics). 
Użyj operatora EXISTS.
Wskazówka: id. wykładu z matematyki znajdź przy pomocy odpowiedniego zapytania. */

select *
from modules m1
where exists
	(select module_id
	from modules m2
	where m1.module_id = m2.module_id and preceding_module = 4)

-- 21.15a
/* Dane studentów z grupy DMIe1011 wraz z najwcześniejszą datą planowanego dla nich egzaminu 
(pole planned_exam_date w tabeli students_modules). Zapytanie nie zwraca danych o studentach, którzy nie mają wyznaczonej takiej daty. 
Sortowanie rosnące według planned_exam_date a następnie student_id.
Użyj operatora APPLY.
Uwaga: należy uwzględnić fakt, że data planowanego egzaminu może być NULL. */

select s.*, planned_exam_date
from students s
cross apply
	(select top(1) *
	from students_modules sm
	where s.student_id = sm.student_id and
	planned_exam_date is not null and
	group_no = 'DMIe1011'
	order by planned_exam_date, student_id) xD
	order by planned_exam_date

-- 21.15b
/* Jak wyżej, tylko zapytanie ma zwrócić najpóźniejszą datę planowanego egzaminu. 
Ponadto zapytanie ma także zwrócić dane o studentach, którzy nie mają wyznaczonej takiej daty. Sortowanie rosnące według planned_exam_date.
Użyj operatora APPLY. */

select s.*, planned_exam_date -- ?
from students s
cross apply
	(select top(1) *
	from students_modules sm
	where sm.student_id = s.student_id and
	group_no = 'DMIe1011'
	order by planned_exam_date, student_id desc) xD
	order by planned_exam_date desc

-- 21.16a
/* Identyfikatory i nazwiska studentów oraz dwie najlepsze oceny dla każdego studenta wraz z datami ich przyznania.
Zapytanie uwzględnia tylko studentów, którym została przyznana co najmniej jedna ocena.
Użyj operatora APPLY. */

select s.student_id, s.surname, grade, exam_date
from students s
cross apply
(select top(2) *
from student_grades sg
where s.student_id = sg.student_id
order by grade desc) XD

-- 21.16b
/* Identyfikatory i nazwiska studentów oraz dwie najgorsze oceny dla każdego studenta wraz z datami ich przyznania. 
Zapytanie uwzględnia także studentów, którym nie została przyznana żadna ocena.
Użyj operatora APPLY. */

select s.student_id, s.surname, grade, exam_date
from students s
outer apply
(select top(2) *
from student_grades sg
where s.student_id = sg.student_id
order by grade desc) XD

-- 21.17
/* Identyfikatory i nazwiska studentów oraz kwoty dwóch ostatnich wpłat za studia wraz z datami tych wpłat. 
Zapytanie uwzględnia także studentów, którzy nie dokonali żadnej wpłaty.
Użyj operatora APPLY. */

select s.student_id, s.surname, fee_amount, date_of_payment
from students s
outer apply
(select top(2) *
from tuition_fees tf
where s.student_id = tf.student_id
order by fee_amount desc) XD

-- 21.18
/* Nazwę modułu poprzedzającego dla modułu Databases. */

select module_name
from modules
where module_id in
	(select preceding_module
	from modules
	where module_name = 'Databases')
