/*
Zadanie 1

Stworzyæ blok anonimowy wypisuj¹cy zmienn¹ numer_max równ¹ maksymalnemu numerowi Departamentu
i dodaj do tabeli departamenty – departament z numerem o 10 wiekszym,
typ pola dla zmiennej z nazw¹ nowego departamentu (zainicjowaæ na EDUCATION)
ustawiæ taki jak dla pola department_name w tabeli (%TYPE)
*/
SELECT * FROM departments;

SET SERVEROUTPUT ON;
DECLARE
    numer_max departments.department_id%TYPE;
BEGIN
   SELECT max(department_id) INTO numer_max FROM DEPARTMENTS;
   DBMS_OUTPUT.PUT_LINE('numer_max: ' || numer_max);
   INSERT INTO departments(department_id, department_name) VALUES ((numer_max+10), 'EDUCATION');
END;

/*
Zadanie 2

Do poprzedniego skryptu dodaj instrukcje zmieniaj¹c¹ location_id (3000) dla dodanego departamentu 
*/

SET SERVEROUTPUT ON;
DECLARE
    numer_max departments.department_id%TYPE;
BEGIN
   SELECT max(department_id) INTO numer_max FROM DEPARTMENTS;
   DBMS_OUTPUT.PUT_LINE('numer_max: ' || numer_max);
   INSERT INTO departments(department_id, department_name) VALUES ((numer_max+10), 'EDUCATION');
   UPDATE departments SET departments.location_id = 3000 WHERE departments.department_id = (numer_max+10);
END;

/*
Zadanie 3

Stwórz tabelê nowa z jednym polem typu varchar a nastêpnie wpisz do niej za pomoc¹ pêtli liczby od 1 do 10 bez liczb 4 i 6 
*/

CREATE TABLE nowa (
    pole VARCHAR(10)
);

DECLARE
    i INT := 1;
BEGIN
    WHILE i <= 10 LOOP
        IF i != 4 AND i != 6 THEN
            INSERT INTO nowa(pole) VALUES (TO_CHAR(i));
        END IF;
        i := i + 1;
    END LOOP;
END;

/*
Zadanie 4

Wyci¹gn¹æ informacje z tabeli countries do jednej zmiennej (%ROWTYPE) dla kraju o identyfikatorze ‘CA’. Wypisaæ nazwê i region_id na ekran 
*/
SET SERVEROUTPUT ON;

DECLARE
  zmienna countries%ROWTYPE;
BEGIN
  SELECT * INTO zmienna FROM countries WHERE country_id = 'CA';
  DBMS_OUTPUT.PUT_LINE('Nazwa kraju: ' || zmienna.country_name);
  DBMS_OUTPUT.PUT_LINE('ID regionu: ' || zmienna.region_id);
END;

/*
Zadanie 5

Za pomoc¹ tabeli INDEX BY wyci¹gn¹æ informacje o nazwach departamentów i wypisaæ na ekran 10 (numery 10,20,…,100)
*/
SET SERVEROUTPUT ON;

DECLARE
    TYPE department_names_index_by_table IS TABLE OF departments.department_name%TYPE INDEX BY PLS_INTEGER;
    nazwy_departamentow department_names_index_by_table;
BEGIN
    FOR i IN 1..10 LOOP
        SELECT department_name
        INTO nazwy_departamentow(i)
        FROM departments
        WHERE department_id = i * 10;
    END LOOP;
    FOR i IN 1..10 LOOP
    DBMS_OUTPUT.PUT_LINE(nazwy_departamentow(i));
    END LOOP;
END;
/*
Zadanie 6

Zmieniæ skrypt z 5 tak aby pojawia³y siê wszystkie informacje na ekranie (wstawiæ %ROWTYPE do tabeli)
*/
SET SERVEROUTPUT ON;

DECLARE
    TYPE typ_departamenty IS TABLE OF departments%ROWTYPE INDEX BY PLS_INTEGER;
    departamenty typ_departamenty;
BEGIN
    FOR i IN 1..10 LOOP
        SELECT *
        INTO departamenty(i)
        FROM departments
        WHERE department_id = i * 10;
    END LOOP;
    FOR i IN 1..10 LOOP
        DBMS_OUTPUT.PUT_LINE(departamenty(i).department_id || ' ' ||
            departamenty(i).department_name || ' ' ||
            departamenty(i).manager_id || ' ' ||
            departamenty(i).location_id);
    END LOOP;
END;
/*
Zadanie 7

Zadeklaruj kursor jako wynagrodzenie, nazwisko dla departamentu o numerze 50. Dla elementów kursora wypisaæ na ekran,
jeœli wynagrodzenie jest wy¿sze ni¿ 3100: nazwisko osoby i tekst ‘nie dawaæ podwy¿ki’ w przeciwnym przypadku: nazwisko + ‘daæ podwy¿kê’
*/
SET SERVEROUTPUT ON;

DECLARE
    CURSOR kursor IS SELECT last_name, salary FROM employees WHERE department_id = 50;
    nazwisko employees.last_name%TYPE;
    zarobki employees.salary%TYPE;
BEGIN
    FOR wiersz IN kursor LOOP
        nazwisko := wiersz.last_name;
        zarobki := wiersz.salary;
        IF zarobki > 3100 THEN
            DBMS_OUTPUT.PUT_LINE(nazwisko || ' nie dawaæ podwy¿ki');
        ELSE
            DBMS_OUTPUT.PUT_LINE(nazwisko || ' daæ podwy¿kê');
        END IF;
    END LOOP;
END;
/*
Zadanie 8

Zadeklarowaæ kursor zwracaj¹cy zarobki imiê i nazwisko pracownika z parametrami,
gdzie pierwsze dwa parametry okreœlaj¹ wide³ki zarobków a trzeci czêœæ imienia pracownika.
Wypisaæ na ekran pracowników:
    a.   	z wide³kami 1000- 5000 z czêœci¹ imienia a (mo¿e byæ równie¿ A)
    b.   	z wide³kami 5000-20000 z czêœci¹ imienia u (mo¿e byæ równie¿ U)
*/
SET SERVEROUTPUT ON;

DECLARE
    CURSOR kursor(min_zarobki NUMBER, max_zarobki NUMBER, imiona VARCHAR2)
    IS SELECT first_name, last_name, salary FROM employees WHERE salary BETWEEN
    min_zarobki AND max_zarobki AND UPPER(first_name) LIKE '%' || UPPER(imiona) || '%';

    imie employees.first_name%TYPE;
    nazwisko employees.last_name%TYPE;
    zarobki employees.salary%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('a.   	z wide³kami 1000- 5000 z czêœci¹ imienia a (mo¿e byæ równie¿ A)');
    FOR wiersz IN kursor(1000, 5000, 'a') LOOP
        imie := wiersz.first_name;
        nazwisko := wiersz.last_name;
        zarobki := wiersz.salary;
        DBMS_OUTPUT.PUT_LINE(imie || ' ' || nazwisko || ', Zarobki: ' || zarobki);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('b.   	z wide³kami 5000-20000 z czêœci¹ imienia u (mo¿e byæ równie¿ U)');
    FOR wiersz IN kursor(5000, 20000, 'u') LOOP
        imie := wiersz.first_name;
        nazwisko := wiersz.last_name;
        zarobki := wiersz.salary;
    DBMS_OUTPUT.PUT_LINE(imie || ' ' || nazwisko || ', Zarobki: ' || zarobki);
    END LOOP;
END;
/*
Zadanie 9

Stwórz procedury:
    a.   dodaj¹c¹ wiersz do tabeli Jobs – z dwoma parametrami wejœciowymi okreœlaj¹cymi
         Job_id, Job_title, przetestuj dzia³anie wrzuæ wyj¹tki – co najmniej when others
    b.   modyfikuj¹c¹ title w  tabeli Jobs – z dwoma parametrami id dla którego ma byæ modyfikacja oraz
         now¹ wartoœæ dla Job_title – przetestowaæ dzia³anie, dodaæ swój wyj¹tek dla no Jobs updated – najpierw sprawdziæ numer b³êdu
    c.   usuwaj¹c¹ wiersz z tabeli Jobs  o podanym Job_id– przetestowaæ dzia³anie,
         dodaj wyj¹tek dla no Jobs deleted
    d.   Wyci¹gaj¹c¹ zarobki i nazwisko (parametry zwracane przez procedurê)
         z tabeli employees dla pracownika o przekazanym jako parametr id
    e.   dodaj¹c¹ do tabeli employees wiersz – wiêkszoœæ parametrów ustawiæ na domyœlne (id poprzez sekwencjê),
         stworzyæ wyj¹tek jeœli wynagrodzenie dodawanego pracownika jest wy¿sze ni¿ 20000
*/

/* podpunkt a */
SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE zad_9_a_dodaj_job (
    p_job_id IN jobs.job_id%TYPE,
    p_job_title IN jobs.job_title%TYPE
) AS
BEGIN
    INSERT INTO Jobs (job_id, job_title)
    VALUES (p_job_id, p_job_title);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Dodano nowy wiersz do tabeli jobs');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wyst¹pi³ B£¥D nowy wiersz do tabeli jobs:' || SQLERRM);
END zad_9_a_dodaj_job;

CALL zad_9_a_dodaj_job ('FI_MGR', 'Finance Manager');
CALL zad_9_a_dodaj_job ('IT_TEST', 'Tester');

/* podpunkt b */
SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE zad_9_b_edytuj_job_title (
    p_job_id IN jobs.job_id%TYPE,
    p_job_title IN jobs.job_title%TYPE
) AS
    no_jobs_updated EXCEPTION;
    PRAGMA EXCEPTION_INIT(no_jobs_updated, -20000);
BEGIN
    UPDATE jobs SET job_title = p_JOB_title WHERE job_id = p_job_id;
    IF SQL%ROWCOUNT = 0 THEN
        RAISE no_jobs_updated;
    ELSE
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Zaktualizowano wiersz w tabeli jobs');
    END IF; 
EXCEPTION
    WHEN no_jobs_updated THEN
        DBMS_OUTPUT.PUT_LINE('no_jobs_updated - Nie zaktualizowano ¿adnych wierszy w tabeli jobs');
END zad_9_b_edytuj_job_title;

CALL zad_9_b_edytuj_job_title ('IT_TEST', 'Tester oprogramowania');
CALL zad_9_b_edytuj_job_title ('NIE_ISTNIEJACE_ID', 'Tester oprogramowania');

/* podpunkt c */
SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE zad_9_c_usun_job (
    p_job_id IN jobs.job_id%TYPE
) AS
    no_jobs_deleted EXCEPTION;
    PRAGMA EXCEPTION_INIT(no_jobs_deleted, -20001);
BEGIN
    DELETE FROM jobs WHERE job_id = p_job_id;
    IF SQL%ROWCOUNT = 0 THEN
        RAISE no_jobs_deleted;
    ELSE
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Usuniêto wiersz w tabeli jobs');
    END IF; 
EXCEPTION
    WHEN no_jobs_deleted THEN
        DBMS_OUTPUT.PUT_LINE('no_jobs_deleted - Nie usuniêto ¿adnych wierszy w tabeli jobs');
END zad_9_c_usun_job;

CALL zad_9_c_usun_job ('IT_TEST');
CALL zad_9_c_usun_job ('NIE_ISTNIEJACE_ID');

/* podpunkt d */
SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE zad_9_d_zarobki_pracownika(
    p_employee_id Employees.employee_id%TYPE,
    o_zarobki OUT employees.salary%TYPE,
    o_nazwisko OUT employees.last_name%TYPE
) AS
BEGIN
    SELECT salary, last_name INTO o_zarobki, o_nazwisko FROM employees
    WHERE employees.employee_id = p_employee_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono pracownika o podanym id');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wyst¹pi³ b³¹d: ' || SQLERRM);
END zad_9_d_zarobki_pracownika;

DECLARE
  zarobki NUMBER;
  nazwisko VARCHAR2(50);
BEGIN
    zad_9_d_zarobki_pracownika(103, zarobki, nazwisko);
    IF zarobki IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Zarobki: ' || zarobki);
        DBMS_OUTPUT.PUT_LINE('Nazwisko: ' || nazwisko);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono pracownika o podanym id');
    END IF;
END;

/* podpunkt e */
CREATE OR REPLACE PROCEDURE zad_9_e_dodaj_pracownika(
    p_first_name employees.first_name%TYPE,
    p_last_name employees.last_name%TYPE,
    p_salary employees.salary%TYPE DEFAULT 1000,
    p_email employees.email%TYPE DEFAULT 'example@mail.com',
    p_phone_number employees.phone_number%TYPE DEFAULT NULL,
    p_hire_date employees.hire_date%TYPE DEFAULT SYSDATE,
    p_job_id employees.job_id%TYPE DEFAULT 'IT_PROG',
    p_commission_pct employees.commission_pct%TYPE DEFAULT NULL,
    p_manager_id employees.manager_id%TYPE DEFAULT NULL,
    p_department_id employees.department_id%TYPE DEFAULT 60
) AS
    salary_too_high EXCEPTION;
    PRAGMA EXCEPTION_INIT(salary_too_high, -20002);
    id_nowego_pracownika NUMBER;
BEGIN
    IF p_salary > 20000 THEN
        RAISE salary_too_high;
    END IF;
    SELECT (MAX(employee_id)+1) INTO id_nowego_pracownika FROM employees;
    INSERT INTO employees
        VALUES (id_nowego_pracownika, p_first_name, p_last_name, p_email, p_phone_number,
        p_hire_date, p_job_id, p_salary, p_commission_pct, p_manager_id, p_department_id);
    COMMIT;
EXCEPTION
    WHEN salary_too_high THEN
        DBMS_OUTPUT.PUT_LINE('Nie mo¿na dodaæ pracownika, poniewa¿ jego wynagrodzenie przekracza 20 000');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wyst¹pi³ b³¹d: ' || SQLERRM);
END zad_9_e_dodaj_pracownika;

CALL zad_9_e_dodaj_pracownika ('Jan', 'Kowalski', 5000);
CALL zad_9_e_dodaj_pracownika ('Piotr', 'Nowak', 15000, 'nowak.piotr@gmail.com');
CALL zad_9_e_dodaj_pracownika ('Andrzej', 'Klakson', 25000);