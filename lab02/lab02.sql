CREATE TABLE MAJOROWSKIP.countries AS SELECT * FROM HR.countries;
CREATE TABLE MAJOROWSKIP.departments AS SELECT * FROM HR.departments;
CREATE TABLE MAJOROWSKIP.employees AS SELECT * FROM HR.employees;
CREATE TABLE MAJOROWSKIP.job_grades AS SELECT * FROM HR.job_grades;
CREATE TABLE MAJOROWSKIP.job_history AS SELECT * FROM HR.job_history;
CREATE TABLE MAJOROWSKIP.jobs AS SELECT * FROM HR.jobs;
CREATE TABLE MAJOROWSKIP.locations AS SELECT * FROM HR.locations;
CREATE TABLE MAJOROWSKIP.regions AS SELECT * FROM HR.regions;

ALTER TABLE Job_Grades ADD PRIMARY KEY (Grade);
ALTER TABLE Regions ADD PRIMARY KEY (Region_ID);
ALTER TABLE Countries ADD PRIMARY KEY (Country_ID);
ALTER TABLE Locations ADD PRIMARY KEY (Location_ID);
ALTER TABLE Jobs ADD PRIMARY KEY (Job_ID);
ALTER TABLE Departments ADD PRIMARY KEY (Department_ID);
ALTER TABLE Employees ADD PRIMARY KEY (Employee_ID);
ALTER TABLE job_history
ADD (
    CONSTRAINT PK_job_history PRIMARY KEY (employee_id, start_date)
);

ALTER TABLE jobs
ADD (
    CONSTRAINT check_min_salary CHECK (max_salary - 2000 > min_salary)
);

ALTER TABLE countries
ADD (
    CONSTRAINT FK_countries_region_id FOREIGN KEY (region_id) REFERENCES regions(region_id)
);

ALTER TABLE locations
ADD (
    CONSTRAINT FK_locations_country_id FOREIGN KEY (country_id) REFERENCES countries(country_id)
);

ALTER TABLE departments
ADD (
    CONSTRAINT FK_departments_location_id FOREIGN KEY (location_id) REFERENCES locations(location_id),
    CONSTRAINT FK_departments_manager_id FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

ALTER TABLE employees
ADD (
    CONSTRAINT FK_employees_department_id FOREIGN KEY (department_id) REFERENCES departments(department_id),
    CONSTRAINT FK_employees_job_id FOREIGN KEY (job_id) REFERENCES jobs(job_id),
    CONSTRAINT FK_employees_manager_id FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

ALTER TABLE job_history
ADD (
    CONSTRAINT FK_job_history_job_id FOREIGN KEY (job_id) REFERENCES jobs(job_id),
    CONSTRAINT FK_job_history_employee_id FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    CONSTRAINT FK_job_history_department_id FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

/* 1.	Z tabeli employees wypisz w jednej kolumnie nazwisko i zarobki – 
nazwij kolumnê wynagrodzenie, dla osób z departamentów 20 i 50 z zarobkami pomiêdzy 2000 a 7000,
uporz¹dkuj kolumny wed³ug nazwiska */
CREATE VIEW zadanie_1 AS
SELECT last_name || ' ' || salary AS "wynagrodzenie" FROM employees
WHERE department_id IN (20, 50) AND (salary BETWEEN 2000 AND 7000)
ORDER BY last_name;

/* 2.	Z tabeli employees wyci¹gn¹æ informacjê data zatrudnienia, nazwisko oraz kolumnê podan¹ przez u¿ytkownika
dla osób maj¹cych menad¿era zatrudnionych w roku 2005. Uporz¹dkowaæ wed³ug kolumny podanej przez u¿ytkownika */
CREATE VIEW zadanie_2 AS
SELECT last_name, hire_date, &podaj_kolumne AS podaj_kolumne FROM employees
WHERE manager_id IN (SELECT employee_id FROM employees WHERE EXTRACT(YEAR FROM hire_date) = 2005)
ORDER BY podaj_kolumne;

/* 3.	Wypisaæ imiona i nazwiska  razem, zarobki oraz numer telefonu
porz¹dkuj¹c dane wed³ug pierwszej kolumny malej¹co
a nastêpnie drugiej rosn¹co (u¿yæ numerów do porz¹dkowania) dla osób z trzeci¹ liter¹ nazwiska ‘e’
oraz czêœci¹ imienia podan¹ przez u¿ytkownika*/
CREATE VIEW zadanie_3 AS
SELECT first_name || ' ' || last_name as "imie i nazwisko", salary, phone_number FROM employees
WHERE SUBSTR(last_name, 3, 1) = 'e' AND first_name LIKE '%&podaj_imie%'
ORDER BY 1 DESC, 2 ASC;

/*
4.	Wypisaæ imiê i nazwisko, liczbê miesiêcy przepracowanych – 
funkcje months_between oraz round oraz kolumnê wysokoœæ_dodatku jako (u¿yæ CASE lub DECODE):
    10% wynagrodzenia dla liczby miesiêcy do 150
    20% wynagrodzenia dla liczby miesiêcy od 150 do 200
    30% wynagrodzenia dla liczby miesiêcy od 200
    uporz¹dkowaæ wed³ug liczby miesiêcy
*/
CREATE VIEW zadanie_4 AS
SELECT first_name, last_name, round(months_between(CURRENT_DATE, hire_date), 2) AS liczba_miesiecy_przepracowanych,
CASE
WHEN round(months_between(CURRENT_DATE, hire_date)) < 150 THEN 0.1*Salary
WHEN round(months_between(CURRENT_DATE, hire_date)) < 200 THEN 0.2*Salary
ELSE 0.3*Salary END
AS "wysokoœæ_dodatku"
FROM employees
ORDER BY liczba_miesiecy_przepracowanych;

/*
5.	Dla ka¿dego dzia³ów w których minimalna p³aca jest wy¿sza ni¿ 5000
wypisz sumê oraz œredni¹ zarobków zaokr¹glon¹ do ca³oœci nazwij odpowiednio kolumny   
*/
CREATE VIEW zadanie_5 AS
SELECT Departments.Department_name, SUM(Employees.salary) AS "suma zarobków", ROUND(AVG(Employees.salary)) AS "œrednia zarobków"
FROM Departments, Employees
WHERE Departments.department_id = Employees.department_id
AND Employees.job_id NOT IN (SELECT Jobs.job_id FROM Jobs WHERE min_salary <= 5000)
GROUP BY Departments.Department_name;

/*
6. Wypisaæ nazwisko, numer departamentu, nazwê departamentu, id pracy, dla osób z pracuj¹cych Toronto
*/
CREATE VIEW zadanie_6 AS
SELECT Employees.last_name, Employees.department_id, Departments.department_name, Employees.job_id
FROM Departments, Employees, Locations 
WHERE Departments.location_id = Locations.location_id AND Departments.department_id = Employees.department_id
AND Locations.city = 'Toronto';

/*
7.	Dla pracowników o imieniu „Jennifer” wypisz imiê i nazwisko tego pracownika oraz osoby które z nim wspó³pracuj¹
*/
CREATE VIEW zadanie_7 AS
SELECT Employees.First_name, Employees.Last_name
FROM Employees
WHERE Employees.department_id IN 
    (SELECT Departments.department_id 
     FROM Departments, Employees
     WHERE Departments.department_id = Employees.department_id
     AND Employees.employee_id IN (
        SELECT Employees.employee_id
        FROM Employees
        WHERE Employees.first_name = 'Jennifer'));
/*
8.  Wypisaæ wszystkie departamenty w których nie ma pracowników
*/
CREATE VIEW zadanie_8 AS
SELECT department_name
FROM Departments
WHERE department_id NOT IN (
    SELECT UNIQUE Departments.department_id
    FROM Departments, Employees
    WHERE Departments.department_id = Employees.department_id);
/*
9.  Skopiuj tabelê Job_grades od u¿ytkownika HR
    ZOSTA£O ZROBIONE NA POCZ¥TKU
*/

/*
10.	Wypisz imiê i nazwisko, id pracy, nazwê departamentu, zarobki, oraz odpowiedni grade dla ka¿dego pracownika
*/
CREATE VIEW zadanie_10 AS
SELECT Employees.First_Name, Employees.Last_Name, Departments.Department_name, Employees.salary,
       (SELECT Job_grades.Grade FROM Job_grades WHERE Employees.salary between Job_grades.min_salary AND Job_grades.max_salary) AS "Grade"
FROM Departments, Employees
WHERE Departments.department_id = Employees.department_id;
/*
11.	Wypisz imiê nazwisko oraz zarobki dla osób które zarabiaj¹ wiêcej ni¿ œrednia wszystkich, uporz¹dkuj malej¹co wed³ug zarobków
*/
CREATE VIEW zadanie_11 AS
SELECT First_Name, Last_Name, salary
FROM Employees
WHERE Employees.salary > (SELECT AVG(salary) FROM Employees)
ORDER BY salary DESC;
/*
12.	Wypisz id imie i nazwisko osób, które pracuj¹ w departamencie z osobami maj¹cymi w nazwisku „u”
*/
CREATE VIEW zadanie_12 AS
SELECT Employees.employee_id, Employees.First_Name, Employees.Last_Name
FROM Employees
WHERE Employees.department_id IN (
      SELECT UNIQUE Departments.department_id
      FROM Departments, Employees
      WHERE Departments.department_id = Employees.department_id
      AND Employees.employee_id IN (
        SELECT employee_id FROM Employees WHERE last_name LIKE '%u%'));