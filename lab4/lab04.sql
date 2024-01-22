/*
Stwórz funkcje:
1.	Zwracaj¹c¹ nazwê pracy dla podanego parametru id, dodaj wyj¹tek, jeœli taka praca nie istnieje
*/
CREATE OR REPLACE FUNCTION funkcja_zad_1(p_id jobs.job_id%TYPE) RETURN jobs.job_title%TYPE
IS
    v_job_title jobs.job_title%TYPE;
BEGIN
    SELECT job_title INTO v_job_title
    FROM jobs
    WHERE job_id = p_id;
    RETURN v_job_title;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'NIE znaleziono pracy o podanym ID');
END;

SET SERVEROUTPUT ON;
DECLARE
    v_job_title jobs.job_title%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Zadanie 1');
    v_job_title := funkcja_zad_1('IT_PROG');
    DBMS_OUTPUT.PUT_LINE('Nazwa pracy dla IT_PROG: ' || v_job_title);
    v_job_title := funkcja_zad_1('JAKIES_NIE_ISTNIEJACE_ID');
    DBMS_OUTPUT.PUT_LINE('Nazwa pracy: ' || v_job_title);
END;

/*
Stwórz funkcje:
2.	zwracaj¹c¹ roczne zarobki (wynagrodzenie 12-to miesiêczne plus premia jako wynagrodzenie * commission_pct) dla pracownika o podanym id
*/
CREATE OR REPLACE FUNCTION funkcja_zad_2(p_employee_id employees.employee_id%TYPE) RETURN NUMBER
IS
    v_salary NUMBER;
    v_commission_pct NUMBER;
BEGIN
    SELECT salary
    INTO v_salary
    FROM employees
    WHERE employee_id = p_employee_id;
    
    SELECT commission_pct
    INTO v_commission_pct
    FROM employees
    WHERE employee_id = p_employee_id;
    
    IF v_commission_pct IS NOT NULL THEN
        RETURN (12 * (v_salary + v_salary * v_commission_pct));
    END IF;
    RETURN (12 * v_salary);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'NIE znaleziono pracownika o podanym ID');
END;

SET SERVEROUTPUT ON;
DECLARE
    roczne_zarobki NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Zadanie 2');
    roczne_zarobki := funkcja_zad_2(102);
    DBMS_OUTPUT.PUT_LINE('Roczne zarobki: ' || roczne_zarobki);
END;

/*
Stwórz funkcje:
3.	bior¹c¹ w nawias numer kierunkowy z numeru telefonu podanego jako varchar
*/
CREATE OR REPLACE FUNCTION funkcja_zad_3(p_numer_telefonu IN VARCHAR2) RETURN VARCHAR2
IS
    v_numer_telefonu VARCHAR2(15);
BEGIN
    v_numer_telefonu := '(' || SUBSTR(p_numer_telefonu, 2, 2) || ')' || SUBSTR(p_numer_telefonu, 4);
    RETURN v_numer_telefonu;
END;

SET SERVEROUTPUT ON;
DECLARE
    v_numer_telefonu VARCHAR2(20);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Zadanie 3');
    v_numer_telefonu := funkcja_zad_3('+48895234913');
    DBMS_OUTPUT.PUT_LINE('Numer telefonu: ' || v_numer_telefonu);
END;

/*
Stwórz funkcje:
4.	Dla podanego w parametrze ci¹gu znaków zmieniaj¹c¹ pierwsz¹ i ostatni¹ literê na wielk¹ – pozosta³e na ma³e
*/
CREATE OR REPLACE FUNCTION funkcja_zad_4(p_napis IN VARCHAR2) RETURN VARCHAR2
IS
    v_napis VARCHAR2(100);
BEGIN
    v_napis := UPPER(SUBSTR(p_napis, 1, 1)) || LOWER(SUBSTR(p_napis, 2, LENGTH(p_napis)-2)) || UPPER(SUBSTR(p_napis, LENGTH(p_napis)));
    RETURN v_napis;
END;

SET SERVEROUTPUT ON;
DECLARE
    v_napis VARCHAR2(100);
BEGIN
    DBMS_OUTPUT.PUT_LINE('zadanie 4:');
    v_napis := funkcja_zad_4('jAkiSDziwnyNaPPis');
    DBMS_OUTPUT.PUT_LINE('Napis: ' || v_napis);
END;
/*
Stwórz funkcje:
5.	Dla podanego peselu - przerabiaj¹c¹ pesel na datê urodzenia w formacie ‘yyyy-mm-dd’
*/
CREATE OR REPLACE FUNCTION funkcja_zad_5(p_pesel IN VARCHAR2) RETURN VARCHAR2
IS
    v_rok VARCHAR2(4);
    v_miesiac VARCHAR2(2);
    v_dzien VARCHAR2(2);
    v_data VARCHAR2(10);
BEGIN
    v_miesiac := SUBSTR(p_pesel, 3, 2);
    IF TO_NUMBER(v_miesiac) > 12 THEN
        v_miesiac := TO_NUMBER(v_miesiac) - 20;
        IF v_miesiac < 10 THEN
            v_miesiac := '0' || TO_CHAR(v_miesiac);
        ELSE
            v_miesiac := TO_CHAR(v_miesiac);
        END IF;
        v_rok := '20';
    ELSE
        v_rok := '19';
    END IF;
    v_rok := v_rok || SUBSTR(p_pesel, 1, 2);
    v_dzien := SUBSTR(p_pesel, 5, 2);
    v_data := v_rok || '-' || v_miesiac || '-' || v_dzien;
    RETURN v_data;
END;

SET SERVEROUTPUT ON;
DECLARE
    v_data VARCHAR2(10);
BEGIN
    DBMS_OUTPUT.PUT_LINE('zadanie 5:');
    v_data := funkcja_zad_5('00230512345');
    DBMS_OUTPUT.PUT_LINE('Data (00230512345): ' || v_data);
END;
/*
Stwórz funkcje:
6.	Zwracaj¹c¹ liczbê pracowników oraz liczbê departamentów które znajduj¹ siê w kraju podanym jako parametr (nazwa kraju).
    W przypadku braku kraju - odpowiedni wyj¹tek
*/
CREATE OR REPLACE FUNCTION funkcja_zad_6(p_nazwa_kraju VARCHAR2) RETURN VARCHAR2
IS
    v_liczba_krajow_o_danej_nazwie NUMBER;
    v_liczba_pracownikow NUMBER;
    v_liczba_departamentow NUMBER;
    v_odpowiedz VARCHAR2(100);
BEGIN

    SELECT COUNT(*) INTO v_liczba_krajow_o_danej_nazwie
    FROM countries
    WHERE LOWER(countries.country_name) = LOWER(p_nazwa_kraju);
    
    IF(v_liczba_krajow_o_danej_nazwie = 0) THEN
        RAISE_APPLICATION_ERROR(-20006, 'NIE znaleziono kraju o podanej nazwie.');
    END IF;

    SELECT COUNT(*) INTO v_liczba_pracownikow
    FROM employees
    JOIN departments ON employees.department_id = departments.department_id
    JOIN locations ON departments.location_id = locations.location_id
    JOIN countries ON locations.country_id = countries.country_id
    WHERE LOWER(countries.country_name) = LOWER(p_nazwa_kraju);
    
    SELECT COUNT(*) INTO v_liczba_departamentow
    FROM departments
    JOIN locations ON departments.location_id = locations.location_id
    JOIN countries ON locations.country_id = countries.country_id
    WHERE LOWER(countries.country_name) = LOWER(p_nazwa_kraju);
    
    v_odpowiedz := 'Liczba pracowników: ' || v_liczba_pracownikow || ', Liczba departamentów: ' || v_liczba_departamentow;
    return v_odpowiedz;
END;

SET SERVEROUTPUT ON;
DECLARE
    v_odpowiedz VARCHAR2(100);
BEGIN
    DBMS_OUTPUT.PUT_LINE('zadanie 6:');
    v_odpowiedz := funkcja_zad_6('United States of America');
    DBMS_OUTPUT.PUT_LINE('United States of America: ' || v_odpowiedz);
    v_odpowiedz := funkcja_zad_6('Zimbabwe');
    DBMS_OUTPUT.PUT_LINE('Zimbabwe: ' || v_odpowiedz);
    v_odpowiedz := funkcja_zad_6('Poland');
    DBMS_OUTPUT.PUT_LINE('Poland: ' || v_odpowiedz);
END;
/*
Stworzyæ nastêpuj¹ce wyzwalacze:
1.	Stworzyæ tabelê archiwum_departamentów (id, nazwa, data_zamkniêcia, ostatni_manager jako imiê i nazwisko). Po usuniêciu departamentu dodaæ odpowiedni rekord do tej tabeli
*/
CREATE TABLE archiwum_departamentow (
    id NUMBER PRIMARY KEY,
    nazwa VARCHAR2(30), 
    data_zamkniecia DATE,
    ostatni_manager VARCHAR2(100)
);

CREATE OR REPLACE TRIGGER wyzwalacz_zad_1
AFTER DELETE ON departments
FOR EACH ROW
DECLARE
    v_data_zamkniecia DATE;
    v_ostatni_manager VARCHAR2(100);
BEGIN
    v_data_zamkniecia := SYSDATE;
    SELECT first_name || ' ' || last_name INTO v_ostatni_manager FROM employees
    WHERE employee_id = :OLD.manager_id;
    
    INSERT INTO archiwum_departamentow (id, nazwa, data_zamkniecia, ostatni_manager)
    VALUES (:OLD.department_id, :OLD.department_name, v_data_zamkniecia, v_ostatni_manager);
END

INSERT INTO departments VALUES (9999, 'Test', 100, 1000);
DELETE FROM departments WHERE department_id = 9999;
SELECT * FROM archiwum_departamentow;
/*
Stworzyæ nastêpuj¹ce wyzwalacze:
2.	W razie UPDATE i INSERT na tabeli employees, sprawdziæ czy zarobki ³api¹ siê w wide³kach 2000 - 26000. Jeœli nie ³api¹ siê - zabroniæ dodania. Dodaæ tabelê z³odziej(id, USER, czas_zmiany), której bêd¹ wrzucane logi, jeœli bêdzie próba dodania, b¹dŸ zmiany wynagrodzenia poza wide³ki.
*/
CREATE TABLE zlodziej (
    id  NUMBER PRIMARY KEY,
    username VARCHAR2(100),
    czas_zmiany TIMESTAMP
);
CREATE SEQUENCE zlodziej_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER wyzwalacz_zad_2
BEFORE INSERT OR UPDATE OF salary ON employees FOR EACH ROW
BEGIN
    IF :NEW.salary < 2000 OR :NEW.salary > 26000 THEN
        :NEW.salary := :OLD.salary;
        INSERT INTO zlodziej (id, username, czas_zmiany)
        VALUES (zlodziej_seq.NEXTVAL, USER, SYSDATE);
    END IF;
END;

UPDATE employees SET salary = 300000 WHERE employee_id = 101;
SELECT * FROM employees;
SELECT * FROM zlodziej;
/*
Stworzyæ nastêpuj¹ce wyzwalacze:
3.	Stworzyæ sekwencjê i wyzwalacz, który bêdzie odpowiada³ za auto_increment w tabeli employees.
*/
SET SERVEROUTPUT ON;
DECLARE
    v_max_id Number;
BEGIN
    SELECT max(employee_id) INTO v_max_id FROM employees;
    EXECUTE IMMEDIATE 'CREATE SEQUENCE employees_seq START WITH ' || v_max_id || ' INCREMENT BY 1';
END;

CREATE OR REPLACE TRIGGER wyzwalacz_zad_3
BEFORE INSERT ON employees FOR EACH ROW
BEGIN
    SELECT employees_seq.NEXTVAL INTO :NEW.employee_id FROM DUAL;
END;

INSERT INTO employees (first_name, last_name, salary, email, hire_date, job_id) 
VALUES ('Janusz', 'Tracz', 13000, 'lubie@placki.eu', '23/11/14', 'MK_MAN');

SELECT * FROM employees ORDER BY employee_id DESC FETCH FIRST 1 ROWS ONLY;
/*
Stworzyæ nastêpuj¹ce wyzwalacze:
4.	Stworzyæ wyzwalacz, który zabroni dowolnej operacji na tabeli JOD_GRADES (INSERT, UPDATE, DELETE)
*/
CREATE OR REPLACE TRIGGER wyzwalacz_zad_4
BEFORE INSERT OR UPDATE OR DELETE ON JOB_GRADES
BEGIN
  -- Zabrania wszelkich operacji na tabeli JOD_GRADES
  RAISE_APPLICATION_ERROR(-20007, 'Operacje INSERT, UPDATE oraz DELETE na tabeli JOB_GRADES s¹ zabronione.');
END;

DELETE FROM job_grades WHERE min_salary = 3000;
/*
Stworzyæ nastêpuj¹ce wyzwalacze:
5.	Stworzyæ wyzwalacz, który przy próbie zmiany max i min salary w tabeli jobs zostawia stare wartoœci.
*/
CREATE OR REPLACE TRIGGER wyzwalacz_zad_5
BEFORE UPDATE ON jobs FOR EACH ROW
BEGIN
    :NEW.min_salary := :OLD.min_salary;
    :NEW.max_salary := :OLD.max_salary;
END;

SELECT * FROM jobs WHERE job_id = 'AD_PRES';
UPDATE jobs SET min_salary = 99;
UPDATE jobs SET max_salary = 99999;
UPDATE jobs SET max_salary = 2, min_salary = 1;
SELECT * FROM jobs WHERE job_id = 'AD_PRES';
/*
Stworzyæ paczki:
1.	Sk³adaj¹c¹ siê ze stworzonych procedur i funkcji
*/
CREATE OR REPLACE PACKAGE paczka_zad_1 AS
    FUNCTION funkcja_zad_1(p_id jobs.job_id%TYPE) RETURN jobs.job_title%TYPE;
    FUNCTION funkcja_zad_2(p_employee_id employees.employee_id%TYPE) RETURN NUMBER;
    FUNCTION funkcja_zad_3(p_numer_telefonu IN VARCHAR2) RETURN VARCHAR2;
    FUNCTION funkcja_zad_4(p_napis IN VARCHAR2) RETURN VARCHAR2;
    FUNCTION funkcja_zad_5(p_pesel IN VARCHAR2) RETURN VARCHAR2;
    FUNCTION funkcja_zad_6(p_nazwa_kraju VARCHAR2) RETURN VARCHAR2;
    
    PROCEDURE zad_9_a_dodaj_job (
        p_job_id IN jobs.job_id%TYPE,
        p_job_title IN jobs.job_title%TYPE
    );
    
    PROCEDURE zad_9_b_edytuj_job_title (
        p_job_id IN jobs.job_id%TYPE,
        p_job_title IN jobs.job_title%TYPE
    );
    
    PROCEDURE zad_9_c_usun_job (
        p_job_id IN jobs.job_id%TYPE
    );
    
    PROCEDURE zad_9_d_zarobki_pracownika(
        p_employee_id Employees.employee_id%TYPE,
        o_zarobki OUT employees.salary%TYPE,
        o_nazwisko OUT employees.last_name%TYPE
    );
    
    PROCEDURE zad_9_e_dodaj_pracownika(
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
    );
END paczka_zad_1;


CREATE OR REPLACE PACKAGE BODY paczka_zad_1 AS
    FUNCTION funkcja_zad_1(p_id jobs.job_id%TYPE) RETURN jobs.job_title%TYPE
    IS
        v_job_title jobs.job_title%TYPE;
    BEGIN
        SELECT job_title INTO v_job_title
        FROM jobs
        WHERE job_id = p_id;
        RETURN v_job_title;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'NIE znaleziono pracy o podanym ID');
    END;
    
    
    FUNCTION funkcja_zad_2(p_employee_id employees.employee_id%TYPE) RETURN NUMBER
    IS
        v_salary NUMBER;
        v_commission_pct NUMBER;
    BEGIN
        SELECT salary
        INTO v_salary
        FROM employees
        WHERE employee_id = p_employee_id;
        
        SELECT commission_pct
        INTO v_commission_pct
        FROM employees
        WHERE employee_id = p_employee_id;
        
        IF v_commission_pct IS NOT NULL THEN
            RETURN (12 * (v_salary + v_salary * v_commission_pct));
        END IF;
        RETURN (12 * v_salary);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'NIE znaleziono pracownika o podanym ID');
    END;
    
    
    FUNCTION funkcja_zad_3(p_numer_telefonu IN VARCHAR2) RETURN VARCHAR2
    IS
        v_numer_telefonu VARCHAR2(15);
    BEGIN
        v_numer_telefonu := '(' || SUBSTR(p_numer_telefonu, 2, 2) || ')' || SUBSTR(p_numer_telefonu, 4);
        RETURN v_numer_telefonu;
    END;
    
    FUNCTION funkcja_zad_4(p_napis IN VARCHAR2) RETURN VARCHAR2
    IS
        v_napis VARCHAR2(100);
    BEGIN
        v_napis := UPPER(SUBSTR(p_napis, 1, 1)) || LOWER(SUBSTR(p_napis, 2, LENGTH(p_napis)-2)) || UPPER(SUBSTR(p_napis, LENGTH(p_napis)));
        RETURN v_napis;
    END;
    
    FUNCTION funkcja_zad_5(p_pesel IN VARCHAR2) RETURN VARCHAR2
    IS
        v_rok VARCHAR2(4);
        v_miesiac VARCHAR2(2);
        v_dzien VARCHAR2(2);
        v_data VARCHAR2(10);
    BEGIN
        v_miesiac := SUBSTR(p_pesel, 3, 2);
        IF TO_NUMBER(v_miesiac) > 12 THEN
            v_miesiac := TO_NUMBER(v_miesiac) - 20;
            IF v_miesiac < 10 THEN
                v_miesiac := '0' || TO_CHAR(v_miesiac);
            ELSE
                v_miesiac := TO_CHAR(v_miesiac);
            END IF;
            v_rok := '20';
        ELSE
            v_rok := '19';
        END IF;
        v_rok := v_rok || SUBSTR(p_pesel, 1, 2);
        v_dzien := SUBSTR(p_pesel, 5, 2);
        v_data := v_rok || '-' || v_miesiac || '-' || v_dzien;
        RETURN v_data;
    END;
    
    
    FUNCTION funkcja_zad_6(p_nazwa_kraju VARCHAR2) RETURN VARCHAR2
    IS
        v_liczba_krajow_o_danej_nazwie NUMBER;
        v_liczba_pracownikow NUMBER;
        v_liczba_departamentow NUMBER;
        v_odpowiedz VARCHAR2(100);
    BEGIN
    
        SELECT COUNT(*) INTO v_liczba_krajow_o_danej_nazwie
        FROM countries
        WHERE LOWER(countries.country_name) = LOWER(p_nazwa_kraju);
        
        IF(v_liczba_krajow_o_danej_nazwie = 0) THEN
            RAISE_APPLICATION_ERROR(-20006, 'NIE znaleziono kraju o podanej nazwie.');
        END IF;
    
        SELECT COUNT(*) INTO v_liczba_pracownikow
        FROM employees
        JOIN departments ON employees.department_id = departments.department_id
        JOIN locations ON departments.location_id = locations.location_id
        JOIN countries ON locations.country_id = countries.country_id
        WHERE LOWER(countries.country_name) = LOWER(p_nazwa_kraju);
        
        SELECT COUNT(*) INTO v_liczba_departamentow
        FROM departments
        JOIN locations ON departments.location_id = locations.location_id
        JOIN countries ON locations.country_id = countries.country_id
        WHERE LOWER(countries.country_name) = LOWER(p_nazwa_kraju);
        
        v_odpowiedz := 'Liczba pracowników: ' || v_liczba_pracownikow || ', Liczba departamentów: ' || v_liczba_departamentow;
        return v_odpowiedz;
    END;
    
    PROCEDURE zad_9_a_dodaj_job (
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
    
    
    PROCEDURE zad_9_b_edytuj_job_title (
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
    
    
    PROCEDURE zad_9_c_usun_job (
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
    
    
    PROCEDURE zad_9_d_zarobki_pracownika(
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
    
    PROCEDURE zad_9_e_dodaj_pracownika(
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
END paczka_zad_1;


/*
Stworzyæ paczki:
2.	Stworzyæ paczkê z procedurami i funkcjami do obs³ugi tabeli REGIONS (CRUD), gdzie odczyt z ró¿nymi parametrami
*/

CREATE OR REPLACE PACKAGE paczka_zad_2 AS
    PROCEDURE dodaj_region(p_region_id NUMBER, p_nazwa_regionu VARCHAR2);
    PROCEDURE aktualizuj_region(p_region_id NUMBER, p_nazwa_regionu VARCHAR2);
    PROCEDURE usun_region(p_region_id NUMBER);
    
    FUNCTION znajdz_region(p_region_id NUMBER) RETURN VARCHAR2;
    FUNCTION znajdz_region(p_nazwa_regionu VARCHAR2) RETURN NUMBER;
END paczka_zad_2;

CREATE OR REPLACE PACKAGE BODY paczka_zad_2 AS
    PROCEDURE dodaj_region(p_region_id NUMBER, p_nazwa_regionu VARCHAR2) AS
    BEGIN
        INSERT INTO regions(region_id,region_name) VALUES (p_region_id, p_nazwa_regionu);
        COMMIT;
    END dodaj_region;
    
    PROCEDURE aktualizuj_region(p_region_id NUMBER, p_nazwa_regionu VARCHAR2) AS
    BEGIN
        UPDATE regions
        SET region_name = p_nazwa_regionu
        WHERE region_id = p_region_id;
        COMMIT;
    END aktualizuj_region;
    
    PROCEDURE usun_region(p_region_id NUMBER) AS
    BEGIN
        DELETE FROM regions
        WHERE region_id = p_region_id;
        COMMIT;
    END usun_region;
    
    FUNCTION znajdz_region(p_region_id NUMBER) RETURN VARCHAR2
    IS
        v_nazwa_regionu VARCHAR2(100);
    BEGIN
        SELECT region_name INTO v_nazwa_regionu
        FROM regions
        WHERE region_id = p_region_id;
        RETURN v_nazwa_regionu;
    END znajdz_region;
    
    FUNCTION znajdz_region(p_nazwa_regionu VARCHAR2) RETURN NUMBER
    IS
        v_region_id NUMBER;
    BEGIN
        SELECT region_id INTO v_region_id FROM regions WHERE region_name = p_nazwa_regionu;
        RETURN v_region_id;
    END znajdz_region;
END paczka_zad_2;

SET SERVEROUTPUT ON;
DECLARE
    v_id_regionu NUMBER;
    v_nazwa_regionu VARCHAR2(100);
BEGIN
    CALL paczka_zad_2.dodaj_region(5, 'Atlantyda');
    SELECT * FROM REGIONS;
    CALL paczka_zad_2.aktualizuj_region(5, 'Radom');
    SELECT * FROM REGIONS;
    CALL paczka_zad_2.usun_region(5);
    SELECT * FROM REGIONS;
    
    v_id_regionu := paczka_zad_2.znajdz_region('Europe');
    DBMS_OUTPUT.PUT_LINE('Id regionu Europe: ' || v_id_regionu);
    v_nazwa_regionu := paczka_zad_2.znajdz_region(1);
    DBMS_OUTPUT.PUT_LINE('Nazwa regionu o id 1: ' || v_id_regionu);
END;