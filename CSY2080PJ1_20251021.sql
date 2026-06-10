/* 
    CSY2080 Relational Databases PJ1
    File name: CSY2080PJ1_BTL.sql
    Scenario: HAVEN Retreat Management System

    Student name: Bibek Ale
    Student number: 20251021

    features included:
    - relational tables
    - object type used as column
    - object table
    - VARRAY collection
    - nested table collection
    - primary keys and foreign keys
    - check and unique constraints
    - sequences
    - well-structured uppercase data
    - built-in functions
    - procedures with parameters
    - functions with parameters and anchored datatypes
    - triggers using bind variables
    - explicit cursor with loop and cursor attribute
    - IF and CASE logic
    - positive and negative test cases
    - final data dictionary checks
*/

SET SERVEROUTPUT ON;

COLUMN object_name FORMAT A35;
COLUMN object_type FORMAT A20;
COLUMN status FORMAT A10;
COLUMN table_name FORMAT A30;
COLUMN constraint_name FORMAT A35;

/* ============================================================
   SECTION 1: SHOW EXISTING LOGIN OBJECTS
   ============================================================ */

PURGE RECYCLEBIN;

SELECT object_name, object_type
FROM user_objects
ORDER BY object_type, object_name;


/* ============================================================
   SECTION 2: DROP OLD OBJECTS
   Drops are ordered from child objects to parent objects.
   ============================================================ */

BEGIN EXECUTE IMMEDIATE 'DROP TRIGGER trig_reviews_uppercase'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TRIGGER trig_programmes_future_date'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TRIGGER trig_guests_uppercase'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

BEGIN EXECUTE IMMEDIATE 'DROP PROCEDURE proc_display_guest_summary'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP PROCEDURE proc_display_reviews'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP PROCEDURE proc_update_programme_cost'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP PROCEDURE proc_insert_review'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP PROCEDURE proc_insert_guest'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

BEGIN EXECUTE IMMEDIATE 'DROP FUNCTION func_get_retreat_programme_count'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP FUNCTION func_get_rating_grade'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP FUNCTION func_get_programme_income'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP FUNCTION func_get_average_rating'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP FUNCTION func_get_review_count'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

BEGIN EXECUTE IMMEDIATE 'DROP TABLE reviews PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE programmes PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE accommodations PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE retreats PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE guests PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE guides PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_reviews'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_programmes'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_accommodations'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_retreats'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_guests'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_guides'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

BEGIN EXECUTE IMMEDIATE 'DROP TYPE programme_activity_table_type'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TYPE retreat_practice_varray_type'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TYPE guide_type'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TYPE address_type'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

PURGE RECYCLEBIN;


/* ============================================================
   SECTION 3: USER DEFINED TYPES AND COLLECTION TYPES
   ============================================================ */

CREATE OR REPLACE TYPE address_type AS OBJECT (
    house_no        VARCHAR2(10),
    street          VARCHAR2(40),
    city            VARCHAR2(30),
    postcode        VARCHAR2(15)
);
/

CREATE OR REPLACE TYPE guide_type AS OBJECT (
    guide_id        NUMBER(4),
    firstname       VARCHAR2(25),
    surname         VARCHAR2(25),
    speciality      VARCHAR2(30),
    guide_phone     VARCHAR2(20)
);
/

CREATE OR REPLACE TYPE retreat_practice_varray_type AS VARRAY(5) OF VARCHAR2(30);
/

CREATE OR REPLACE TYPE programme_activity_table_type AS TABLE OF VARCHAR2(50);
/


/* ============================================================
   SECTION 4: OBJECT TABLE
   This demonstrates direct use of an object type as an object table.
   ============================================================ */

CREATE TABLE guides OF guide_type (
    CONSTRAINT pk_guides PRIMARY KEY (guide_id)
);


/* ============================================================
   SECTION 5: SEQUENCES
   Different entities start from different ranges.
   ============================================================ */

CREATE SEQUENCE seq_guides START WITH 903 INCREMENT BY 1;
CREATE SEQUENCE seq_guests START WITH 1003 INCREMENT BY 1;
CREATE SEQUENCE seq_retreats START WITH 2003 INCREMENT BY 1;
CREATE SEQUENCE seq_accommodations START WITH 3003 INCREMENT BY 1;
CREATE SEQUENCE seq_programmes START WITH 4003 INCREMENT BY 1;
CREATE SEQUENCE seq_reviews START WITH 5003 INCREMENT BY 1;


/* ============================================================
   SECTION 6: RELATIONAL TABLES
   Tables are plural. User-defined names use lowercase.
   ============================================================ */

CREATE TABLE guests (
    guest_id        NUMBER(4),
    firstname       VARCHAR2(25),
    surname         VARCHAR2(25),
    email           VARCHAR2(60),
    phone           VARCHAR2(20),
    guest_address   address_type
);

CREATE TABLE retreats (
    retreat_id      NUMBER(4),
    retreat_name    VARCHAR2(50),
    retreat_type    VARCHAR2(30),
    duration_days   NUMBER(2),
    practices       retreat_practice_varray_type,
    guide_id        NUMBER(4)
);

CREATE TABLE accommodations (
    accommodation_id      NUMBER(4),
    accommodation_name    VARCHAR2(50),
    no_of_rooms           NUMBER(3),
    price_level           VARCHAR2(15)
);

CREATE TABLE programmes (
    programme_id       NUMBER(4),
    programme_name     VARCHAR2(50),
    programme_cost     NUMBER(7,2),
    programme_date     DATE,
    retreat_id         NUMBER(4),
    accommodation_id   NUMBER(4),
    activities         programme_activity_table_type
)
NESTED TABLE activities STORE AS activities_nested_table;

CREATE TABLE reviews (
    review_id             NUMBER(4),
    guest_id              NUMBER(4),
    programme_id          NUMBER(4),
    rating                NUMBER(1),
    review_title          VARCHAR2(50),
    review_description    VARCHAR2(200),
    review_date           DATE DEFAULT SYSDATE
);


/* ============================================================
   SECTION 7: CONSTRAINTS
   Primary and foreign keys are added using ALTER TABLE.
   ============================================================ */

ALTER TABLE guests
ADD CONSTRAINT pk_guests
PRIMARY KEY (guest_id);

ALTER TABLE retreats
ADD CONSTRAINT pk_retreats
PRIMARY KEY (retreat_id);

ALTER TABLE accommodations
ADD CONSTRAINT pk_accommodations
PRIMARY KEY (accommodation_id);

ALTER TABLE programmes
ADD CONSTRAINT pk_programmes
PRIMARY KEY (programme_id);

ALTER TABLE reviews
ADD CONSTRAINT pk_reviews
PRIMARY KEY (review_id);

ALTER TABLE retreats
ADD CONSTRAINT fk_retreats_guides
FOREIGN KEY (guide_id)
REFERENCES guides(guide_id);

ALTER TABLE programmes
ADD CONSTRAINT fk_programmes_retreats
FOREIGN KEY (retreat_id)
REFERENCES retreats(retreat_id);

ALTER TABLE programmes
ADD CONSTRAINT fk_programmes_accommodations
FOREIGN KEY (accommodation_id)
REFERENCES accommodations(accommodation_id);

ALTER TABLE reviews
ADD CONSTRAINT fk_reviews_guests
FOREIGN KEY (guest_id)
REFERENCES guests(guest_id);

ALTER TABLE reviews
ADD CONSTRAINT fk_reviews_programmes
FOREIGN KEY (programme_id)
REFERENCES programmes(programme_id);

ALTER TABLE guests
ADD CONSTRAINT u_guests_email
UNIQUE (email);

ALTER TABLE reviews
ADD CONSTRAINT ck_reviews_rating
CHECK (rating BETWEEN 1 AND 5);

ALTER TABLE retreats
ADD CONSTRAINT ck_retreats_duration
CHECK (duration_days > 0);

ALTER TABLE programmes
ADD CONSTRAINT ck_programmes_cost
CHECK (programme_cost > 0);

ALTER TABLE accommodations
ADD CONSTRAINT ck_accommodations_rooms
CHECK (no_of_rooms > 0);


/* ============================================================
   SECTION 8: TRIGGERS
   ============================================================ */

CREATE OR REPLACE TRIGGER trig_guests_uppercase
BEFORE INSERT OR UPDATE ON guests
FOR EACH ROW
BEGIN
    :NEW.firstname := UPPER(:NEW.firstname);
    :NEW.surname := UPPER(:NEW.surname);
    :NEW.email := UPPER(:NEW.email);
END trig_guests_uppercase;
/
SHOW ERRORS;

CREATE OR REPLACE TRIGGER trig_reviews_uppercase
BEFORE INSERT OR UPDATE ON reviews
FOR EACH ROW
BEGIN
    :NEW.review_title := UPPER(:NEW.review_title);
    :NEW.review_description := UPPER(:NEW.review_description);
END trig_reviews_uppercase;
/
SHOW ERRORS;

CREATE OR REPLACE TRIGGER trig_programmes_future_date
BEFORE INSERT OR UPDATE ON programmes
FOR EACH ROW
BEGIN
    IF :NEW.programme_date < TRUNC(SYSDATE) THEN
        RAISE_APPLICATION_ERROR(-20001, 'PROGRAMME DATE CANNOT BE IN THE PAST');
    END IF;
END trig_programmes_future_date;
/
SHOW ERRORS;


/* ============================================================
   SECTION 9: INSERT DATA
   Text data is stored in UPPERCASE for consistency.
   ============================================================ */

INSERT INTO guides
VALUES (guide_type(900, 'TENZING', 'SHERPA', 'YOGA', '9811111111'));

INSERT INTO guides
VALUES (guide_type(901, 'MAYA', 'GURUNG', 'FITNESS', '9822222222'));

INSERT INTO guides
VALUES (guide_type(902, 'KARMA', 'LAMA', 'MEDITATION', '9833333333'));

INSERT INTO guests
VALUES (
    1000,
    'BHAICHUNG',
    'LHOMI',
    'BHAICHUNG@EMAIL.COM',
    '9800000001',
    address_type('12', 'BUDDHA STREET', 'KATHMANDU', '44600')
);

INSERT INTO guests
VALUES (
    1001,
    'RAM',
    'LAMA',
    'RAM@EMAIL.COM',
    '9800000002',
    address_type('20', 'LAKESIDE ROAD', 'POKHARA', '33700')
);

INSERT INTO guests
VALUES (
    1002,
    'SITA',
    'SHERPA',
    'SITA@EMAIL.COM',
    '9800000003',
    address_type('33', 'MOUNTAIN ROAD', 'LALITPUR', '44700')
);

INSERT INTO retreats
VALUES (
    2000,
    'PEACEFUL MIND RETREAT',
    'REST AND RELAXATION',
    5,
    retreat_practice_varray_type('YOGA', 'MINDFULNESS', 'MEDITATION'),
    900
);

INSERT INTO retreats
VALUES (
    2001,
    'ENERGY BOOST RETREAT',
    'ENERGISING',
    7,
    retreat_practice_varray_type('HIIT', 'YOGA', 'CLEANSE'),
    901
);

INSERT INTO retreats
VALUES (
    2002,
    'MOUNTAIN SILENCE RETREAT',
    'HEALTH',
    3,
    retreat_practice_varray_type('MEDITATION', 'TIBETAN SINGING BOWLS'),
    902
);

INSERT INTO accommodations
VALUES (
    3000,
    'LAKESIDE CABIN',
    12,
    'MEDIUM'
);

INSERT INTO accommodations
VALUES (
    3001,
    'LUXURY TREEHOUSE',
    5,
    'HIGH'
);

INSERT INTO accommodations
VALUES (
    3002,
    'RUSTIC BUNK ROOM',
    20,
    'LOW'
);

INSERT INTO programmes
VALUES (
    4000,
    'BEGINNER WELLNESS PROGRAMME',
    350.00,
    TO_DATE('15-AUG-2026', 'DD-MON-YYYY'),
    2000,
    3000,
    programme_activity_table_type('MORNING YOGA', 'GUIDED MEDITATION', 'HEALTHY DINNER')
);

INSERT INTO programmes
VALUES (
    4001,
    'ADVANCED FITNESS PROGRAMME',
    550.00,
    TO_DATE('20-SEP-2026', 'DD-MON-YYYY'),
    2001,
    3001,
    programme_activity_table_type('HIIT TRAINING', 'MOUNTAIN WALK', 'CLEANSE SESSION')
);

INSERT INTO programmes
VALUES (
    4002,
    'SILENCE AND HEALING PROGRAMME',
    250.00,
    TO_DATE('10-OCT-2026', 'DD-MON-YYYY'),
    2002,
    3002,
    programme_activity_table_type('SILENT WALK', 'BREATHING PRACTICE', 'SOUND BATH')
);

INSERT INTO reviews
VALUES (
    5000,
    1000,
    4000,
    5,
    'excellent retreat',
    'the programme helped me relax and improve my health',
    SYSDATE
);

INSERT INTO reviews
VALUES (
    5001,
    1001,
    4000,
    4,
    'good experience',
    'the accommodation and yoga sessions were very good',
    SYSDATE
);

INSERT INTO reviews
VALUES (
    5002,
    1002,
    4001,
    5,
    'amazing fitness',
    'the fitness programme was challenging and energising',
    SYSDATE
);

COMMIT;


/* ============================================================
   SECTION 10: DATA EXTRACTION QUERIES
   Simple and complex queries plus built-in functions.
   ============================================================ */

SELECT *
FROM guests;

SELECT g.firstname, g.surname, g.guest_address.city AS city
FROM guests g;

SELECT r.retreat_name, r.retreat_type, r.duration_days
FROM retreats r
WHERE r.duration_days BETWEEN 3 AND 7;

SELECT p.programme_name, p.programme_cost, r.retreat_name, g.firstname AS guide_firstname
FROM programmes p, retreats r, guides g
WHERE p.retreat_id = r.retreat_id
AND r.guide_id = g.guide_id;

SELECT rv.review_title, rv.rating, guest.firstname, guest.surname, p.programme_name
FROM reviews rv, guests guest, programmes p
WHERE rv.guest_id = guest.guest_id
AND rv.programme_id = p.programme_id
ORDER BY rv.rating DESC;

SELECT COUNT(*) AS total_reviews,
       ROUND(AVG(rating), 2) AS average_rating,
       MIN(rating) AS lowest_rating,
       MAX(rating) AS highest_rating
FROM reviews;

SELECT CEIL(AVG(programme_cost)) AS ceiling_cost,
       FLOOR(AVG(programme_cost)) AS floor_cost,
       ROUND(AVG(programme_cost), 2) AS rounded_cost
FROM programmes;

SELECT CONCAT(SUBSTR(firstname, 1, 2), SUBSTR(surname, 1, 5)) AS username
FROM guests;

SELECT UPPER(TRIM(rv.review_title)) AS clean_title,
       LOWER(g.email) AS lowercase_email
FROM reviews rv, guests g
WHERE rv.guest_id = g.guest_id;

SELECT p.programme_name, a.COLUMN_VALUE AS activity
FROM programmes p, TABLE(p.activities) a
ORDER BY p.programme_name;


/* ============================================================
   SECTION 11: FUNCTIONS
   Functions return a value and use anchored datatypes where useful.
   ============================================================ */

CREATE OR REPLACE FUNCTION func_get_review_count
RETURN NUMBER IS
    vn_review_count NUMBER(4);
BEGIN
    SELECT COUNT(*)
    INTO vn_review_count
    FROM reviews;

    RETURN vn_review_count;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END func_get_review_count;
/
SHOW ERRORS;

CREATE OR REPLACE FUNCTION func_get_average_rating
RETURN NUMBER IS
    vn_average_rating NUMBER(4,2);
BEGIN
    SELECT ROUND(AVG(rating), 2)
    INTO vn_average_rating
    FROM reviews;

    RETURN vn_average_rating;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END func_get_average_rating;
/
SHOW ERRORS;

CREATE OR REPLACE FUNCTION func_get_programme_income (
    in_programme_id IN programmes.programme_id%TYPE
)
RETURN NUMBER IS
    vn_total_income NUMBER(8,2);
BEGIN
    SELECT COUNT(rv.review_id) * p.programme_cost
    INTO vn_total_income
    FROM programmes p, reviews rv
    WHERE p.programme_id = rv.programme_id
    AND p.programme_id = in_programme_id
    GROUP BY p.programme_cost;

    RETURN vn_total_income;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        RETURN 0;
END func_get_programme_income;
/
SHOW ERRORS;

CREATE OR REPLACE FUNCTION func_get_rating_grade (
    in_rating IN reviews.rating%TYPE
)
RETURN VARCHAR2 IS
    vc_grade VARCHAR2(20);
BEGIN
    CASE
        WHEN in_rating = 5 THEN vc_grade := 'EXCELLENT';
        WHEN in_rating = 4 THEN vc_grade := 'GOOD';
        WHEN in_rating = 3 THEN vc_grade := 'AVERAGE';
        WHEN in_rating = 2 THEN vc_grade := 'POOR';
        WHEN in_rating = 1 THEN vc_grade := 'VERY POOR';
        ELSE vc_grade := 'INVALID';
    END CASE;

    RETURN vc_grade;
END func_get_rating_grade;
/
SHOW ERRORS;

CREATE OR REPLACE FUNCTION func_get_retreat_programme_count (
    in_retreat_id IN retreats.retreat_id%TYPE
)
RETURN NUMBER IS
    vn_programme_count NUMBER(4);
BEGIN
    SELECT COUNT(*)
    INTO vn_programme_count
    FROM programmes
    WHERE retreat_id = in_retreat_id;

    RETURN vn_programme_count;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END func_get_retreat_programme_count;
/
SHOW ERRORS;


/* ============================================================
   SECTION 12: PROCEDURES
   Procedures perform single clear tasks.
   ============================================================ */

CREATE OR REPLACE PROCEDURE proc_insert_guest (
    in_firstname     IN guests.firstname%TYPE,
    in_surname       IN guests.surname%TYPE,
    in_email         IN guests.email%TYPE,
    in_phone         IN guests.phone%TYPE,
    in_house_no      IN VARCHAR2,
    in_street        IN VARCHAR2,
    in_city          IN VARCHAR2,
    in_postcode      IN VARCHAR2
) IS
BEGIN
    INSERT INTO guests
    VALUES (
        seq_guests.NEXTVAL,
        UPPER(in_firstname),
        UPPER(in_surname),
        UPPER(in_email),
        in_phone,
        address_type(UPPER(in_house_no), UPPER(in_street), UPPER(in_city), UPPER(in_postcode))
    );

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('GUEST ADDED SUCCESSFULLY');
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: EMAIL ALREADY EXISTS');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: GUEST WAS NOT ADDED');
END proc_insert_guest;
/
SHOW ERRORS;

CREATE OR REPLACE PROCEDURE proc_insert_review (
    in_guest_id             IN reviews.guest_id%TYPE,
    in_programme_id         IN reviews.programme_id%TYPE,
    in_rating               IN reviews.rating%TYPE,
    in_review_title         IN reviews.review_title%TYPE,
    in_review_description   IN reviews.review_description%TYPE
) IS
BEGIN
    INSERT INTO reviews (
        review_id,
        guest_id,
        programme_id,
        rating,
        review_title,
        review_description,
        review_date
    )
    VALUES (
        seq_reviews.NEXTVAL,
        in_guest_id,
        in_programme_id,
        in_rating,
        in_review_title,
        in_review_description,
        SYSDATE
    );

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('REVIEW ADDED SUCCESSFULLY');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: REVIEW WAS NOT ADDED');
END proc_insert_review;
/
SHOW ERRORS;

CREATE OR REPLACE PROCEDURE proc_update_programme_cost (
    in_programme_id     IN programmes.programme_id%TYPE,
    in_new_cost         IN programmes.programme_cost%TYPE
) IS
BEGIN
    IF in_new_cost <= 0 THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: PROGRAMME COST MUST BE GREATER THAN ZERO');
    ELSE
        UPDATE programmes
        SET programme_cost = in_new_cost
        WHERE programme_id = in_programme_id;

        IF SQL%ROWCOUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('NO PROGRAMME FOUND');
        ELSE
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('PROGRAMME COST UPDATED');
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: PROGRAMME COST WAS NOT UPDATED');
END proc_update_programme_cost;
/
SHOW ERRORS;

CREATE OR REPLACE PROCEDURE proc_display_reviews IS
    CURSOR cur_reviews IS
        SELECT rv.review_title,
               rv.rating,
               g.firstname,
               g.surname,
               p.programme_name
        FROM reviews rv, guests g, programmes p
        WHERE rv.guest_id = g.guest_id
        AND rv.programme_id = p.programme_id
        ORDER BY rv.rating DESC;

    vc_title          reviews.review_title%TYPE;
    vn_rating         reviews.rating%TYPE;
    vc_firstname      guests.firstname%TYPE;
    vc_surname        guests.surname%TYPE;
    vc_programme      programmes.programme_name%TYPE;
BEGIN
    OPEN cur_reviews;

    LOOP
        FETCH cur_reviews
        INTO vc_title, vn_rating, vc_firstname, vc_surname, vc_programme;

        EXIT WHEN cur_reviews%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(
            vc_firstname || ' ' || vc_surname || ' REVIEWED ' ||
            vc_programme || ' AS ' || vc_title ||
            ' WITH RATING ' || vn_rating ||
            ' (' || func_get_rating_grade(vn_rating) || ')'
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('ROWS FETCHED: ' || cur_reviews%ROWCOUNT);

    CLOSE cur_reviews;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR DISPLAYING REVIEWS');
END proc_display_reviews;
/
SHOW ERRORS;

CREATE OR REPLACE PROCEDURE proc_display_guest_summary (
    in_guest_id IN guests.guest_id%TYPE
) IS
    vc_firstname       guests.firstname%TYPE;
    vc_surname         guests.surname%TYPE;
    vn_review_count    NUMBER(4);
    vn_average_rating  NUMBER(4,2);
BEGIN
    SELECT firstname, surname
    INTO vc_firstname, vc_surname
    FROM guests
    WHERE guest_id = in_guest_id;

    SELECT COUNT(*), NVL(ROUND(AVG(rating), 2), 0)
    INTO vn_review_count, vn_average_rating
    FROM reviews
    WHERE guest_id = in_guest_id;

    IF vn_review_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE(vc_firstname || ' ' || vc_surname || ' HAS NO REVIEWS');
    ELSE
        DBMS_OUTPUT.PUT_LINE(vc_firstname || ' ' || vc_surname ||
                             ' HAS ' || vn_review_count ||
                             ' REVIEW(S), AVERAGE RATING ' || vn_average_rating);
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: GUEST NOT FOUND');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR DISPLAYING GUEST SUMMARY');
END proc_display_guest_summary;
/
SHOW ERRORS;


/* ============================================================
   SECTION 13: FUNCTIONAL TESTS
   Positive and negative tests are included.
   ============================================================ */

PROMPT TEST T1: Add valid guest
EXEC proc_insert_guest('DORJI', 'TAMANG', 'DORJI@EMAIL.COM', '9800000004', '44', 'GREEN ROAD', 'BHAKTAPUR', '44800');

PROMPT TEST T2: Add valid review
EXEC proc_insert_review(1003, 4000, 4, 'nice programme', 'the programme was useful and peaceful');

PROMPT TEST T3: Update programme cost
EXEC proc_update_programme_cost(4000, 375);

PROMPT TEST T4: Show reviews using explicit cursor
EXEC proc_display_reviews;

PROMPT TEST T5: Show guest summary using IF logic
EXEC proc_display_guest_summary(1000);

PROMPT TEST T6: Show function results
DECLARE
    vn_total_reviews NUMBER(4);
    vn_average       NUMBER(4,2);
    vn_income        NUMBER(8,2);
    vn_count         NUMBER(4);
BEGIN
    vn_total_reviews := func_get_review_count;
    vn_average := func_get_average_rating;
    vn_income := func_get_programme_income(4000);
    vn_count := func_get_retreat_programme_count(2000);

    DBMS_OUTPUT.PUT_LINE('TOTAL REVIEWS: ' || vn_total_reviews);
    DBMS_OUTPUT.PUT_LINE('AVERAGE RATING: ' || vn_average);
    DBMS_OUTPUT.PUT_LINE('PROGRAMME 4000 INCOME: ' || vn_income);
    DBMS_OUTPUT.PUT_LINE('RETREAT 2000 PROGRAMME COUNT: ' || vn_count);
END;
/

PROMPT TEST T7: Negative test for invalid rating, expected error handled by procedure
EXEC proc_insert_review(1000, 4000, 9, 'bad test', 'this should not insert');

PROMPT TEST T8: Negative test for invalid programme cost
EXEC proc_update_programme_cost(4000, -100);

PROMPT TEST T9: Negative test for missing guest summary
EXEC proc_display_guest_summary(9999);

/*
    Manual negative trigger test.
    Uncomment during demo if you want to show Oracle rejecting a past date.
*/

-- INSERT INTO programmes
-- VALUES (
--     seq_programmes.NEXTVAL,
--     'PAST PROGRAMME',
--     100,
--     TO_DATE('01-JAN-2020', 'DD-MON-YYYY'),
--     2000,
--     3000,
--     programme_programme_activity_table_type('TEST ACTIVITY')
-- );


/* ============================================================
   SECTION 14: USER ACCESS LEVEL TESTING EXAMPLE
   This is included as commented DCL because most student logins do not
   have privilege to CREATE USER or GRANT system privileges.
   ============================================================ */

-- CREATE USER haven_viewer IDENTIFIED BY viewerpass;
-- GRANT CREATE SESSION TO haven_viewer;
-- GRANT SELECT ON guests TO haven_viewer;
-- GRANT SELECT ON programmes TO haven_viewer;


/* ============================================================
   SECTION 15: FINAL CHECKS FOR MARKING AND VIDEO DEMO
   ============================================================ */

SELECT table_name
FROM user_tables
ORDER BY table_name;

SELECT constraint_name, constraint_type, table_name
FROM user_constraints
ORDER BY table_name, constraint_name;

SELECT object_name, object_type, status
FROM user_objects
ORDER BY object_type, object_name;

SELECT *
FROM guides;

SELECT *
FROM guests;

SELECT *
FROM retreats;

SELECT *
FROM accommodations;

SELECT *
FROM programmes;

SELECT *
FROM reviews;


/* ============================================================
   SECTION 16: DROP COMMANDS FOR END OF VIDEO DEMO
   Uncomment and run at the end if required.
   ============================================================ */

-- DROP TRIGGER trig_reviews_uppercase;
-- DROP TRIGGER trig_programmes_future_date;
-- DROP TRIGGER trig_guests_uppercase;

-- DROP PROCEDURE proc_display_guest_summary;
-- DROP PROCEDURE proc_display_reviews;
-- DROP PROCEDURE proc_update_programme_cost;
-- DROP PROCEDURE proc_insert_review;
-- DROP PROCEDURE proc_insert_guest;

-- DROP FUNCTION func_get_retreat_programme_count;
-- DROP FUNCTION func_get_rating_grade;
-- DROP FUNCTION func_get_programme_income;
-- DROP FUNCTION func_get_average_rating;
-- DROP FUNCTION func_get_review_count;

-- DROP TABLE reviews PURGE;
-- DROP TABLE programmes PURGE;
-- DROP TABLE accommodations PURGE;
-- DROP TABLE retreats PURGE;
-- DROP TABLE guests PURGE;
-- DROP TABLE guides PURGE;

-- DROP SEQUENCE seq_reviews;
-- DROP SEQUENCE seq_programmes;
-- DROP SEQUENCE seq_accommodations;
-- DROP SEQUENCE seq_retreats;
-- DROP SEQUENCE seq_guests;
-- DROP SEQUENCE seq_guides;

-- DROP TYPE programme_activity_table_type;
-- DROP TYPE retreat_practice_varray_type;
-- DROP TYPE guide_type;
-- DROP TYPE address_type;

-- PURGE RECYCLEBIN;

-- SELECT object_name, object_type
-- FROM user_objects;
