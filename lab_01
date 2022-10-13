CREATE TABLE employees1 (
employee_id INT IDENTITY PRIMARY KEY,
employee_name VARCHAR(50) NOT NULL,
salary DECIMAL(8,2) CHECK(salary>0),
employment_date DATE DEFAULT CURRENT_TIMESTAMP,
PESEL CHAR(11) NOT NULL UNIQUE,
date_of_birth DATE CHECK(date_of_birth <= GETDATE())
)

CREATE INDEX employee_name_index ON employees1(employee_name)

CREATE TABLE sprzedaz1 (
id_operacji SMALLINT IDENTITY PRIMARY KEY,
id_faktury VARCHAR(30) NOT NULL UNIQUE,
kategoria VARCHAR(20) DEFAULT 'obuwie' NOT NULL,
data_sprzedazy DATE DEFAULT CURRENT_TIMESTAMP CHECK(data_sprzedazy <= CURRENT_TIMESTAMP),
kwota_sprzedazy DECIMAL(8,2) NOT NULL CHECK(kwota_sprzedazy > 0),
rabat TINYINT DEFAULT 0 NOT NULL CHECK(rabat >= 0 AND rabat <= 15),
liczba_pozycji TINYINT DEFAULT 1 NOT NULL CHECK(liczba_pozycji > 0 AND liczba_pozycji <= 100)
)

CREATE INDEX id_faktury_index ON sprzedaz1(id_faktury)
CREATE INDEX kategoria_index ON sprzedaz1(kategoria)

