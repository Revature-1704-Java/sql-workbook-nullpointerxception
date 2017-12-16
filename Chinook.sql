/* 2.1 */
SELECT * FROM EMPLOYEE;

SELECT * FROM employee WHERE lastname='King';

SELECT * FROM employee WHERE firstname='Andrew' AND reportsto IS NULL;

/* 2.2 */
SELECT * FROM album ORDER BY title DESC;

SELECT firstname FROM customer ORDER BY city asc;

/* 2.3 */
INSERT INTO genre (genreid, name) VALUES (26,'Glitch Hop'); 
INSERT INTO genre (genreid, name) VALUES (27, 'Dubstep');

INSERT INTO employee (employeeid,lastname,firstname,title,reportsto,birthdate,hiredate,address,city,state,country,postalcode,phone,fax,email) VALUES (9,'Sagun','Steven','Software Engineer', 6, '09-SEP-95', '04-DEC-17', '713 Whalers Cove Court', 'Galloway', 'NJ', 'USA', '08205', '6092874259','6092874259', 'sagunsteven@live.com');
INSERT INTO employee (employeeid,lastname,firstname,title,reportsto,birthdate,hiredate,address,city,state,country,postalcode,phone,fax,email) VALUES (10,'Joe','Bob','Software Engineer', 6, '04-SEP-90', '04-DEC-17', '700 Whalers Cove Court', 'Galloway', 'NJ', 'USA', '08205', '6095555555','6095555555', 'bob.joe@live.com');

INSERT INTO customer (customerid,firstname,lastname,company,address,city,state,country,postalcode,phone,fax,email,supportrepid) VALUES (60,'Steven', 'Sagun','Revature','713 Whalers Cove Court', 'Galloway', 'NJ', 'USA','08205', '6092874259','609287259','sagunsteven@live.com', 3);
INSERT INTO customer (customerid,firstname,lastname,company,address,city,state,country,postalcode,phone,fax,email,supportrepid) VALUES (61,'Bob', 'JOe','Revature','700 Whalers Cove Court', 'Galloway', 'NJ', 'USA','08205', '6095555555','6095555555','bob.joe@live.com', 3);

/* 2.4 */
UPDATE customer SET firstname='Robert', lastname='Walter' WHERE firstname='Aaron' AND lastname='Mitchell';
UPDATE artist SET name='CCR' WHERE name='Creedence Clearwater Revival';

/* 2.5 */
SELECT * FROM invoice WHERE billingaddress LIKE 'T%';

/* 2.6 */
SELECT * FROM invoice WHERE total BETWEEN 15 AND 50;
SELECT * FROM employee WHERE hiredate BETWEEN '01-JUN-03' AND '01-MAR-04';

/* 2.7 */
DELETE FROM invoiceline WHERE invoiceid IN (SELECT invoiceid FROM invoice WHERE customerid=(SELECT customerid FROM customer WHERE firstname='Robert' AND lastname='Walter'));
DELETE FROM invoice WHERE customerid=(SELECT customerid FROM customer WHERE firstname='Robert' AND lastname='Walter');
DELETE FROM customer WHERE firstname='Robert' AND lastname='Walter';

/* 3.1 */
CREATE OR REPLACE FUNCTION getTime
RETURN timestamp IS thetime timestamp;
BEGIN
    SELECT localtimestamp INTO thetime FROM DUAL;
    return thetime;
END;
/

CREATE OR REPLACE FUNCTION getMediaTypeLength (mediaType IN VARCHAR2)
RETURN INTEGER IS mediaTypeLength INTEGER;
BEGIN
    SELECT COUNT(mediatypeid) INTO mediaTypeLength FROM track WHERE mediatypeid=(SELECT mediatypeid FROM mediatype WHERE name=mediaType);
    RETURN mediaTypeLength;
END;
/

/* 3,2 */
CREATE OR REPLACE FUNCTION getAverageInvoice
RETURN NUMBER IS average NUMBER;
BEGIN
    DECLARE
        thesum NUMBER := 0;
        thecount NUMBER := 0;
    BEGIN
        FOR r IN (SELECT * FROM invoice)
        LOOP
            thesum := thesum + r.total;
            thecount := thecount + 1;
           
        END LOOP;
       
        average := thesum/thecount;
        
    END;
    RETURN average;
END;
/

CREATE OR REPLACE FUNCTION getMostExpensiveTrack
RETURN track.name%TYPE AS thename track.name%TYPE;
BEGIN
    SELECT name INTO thename FROM track WHERE unitprice=(SELECT MAX(unitprice) FROM track) AND ROWNUM = 1;
    RETURN thename;
END;
/

/* 3.3 */
CREATE OR REPLACE FUNCTION getAverageInvoicePrice
RETURN NUMBER IS average NUMBER;
BEGIN
     DECLARE
        thesum NUMBER := 0;
        thecount NUMBER := 0;
    BEGIN
        FOR r IN (SELECT * FROM invoiceline)
        LOOP
            thesum := thesum + r.unitprice;
            thecount := thecount + 1;
           
        END LOOP;
       
        average := thesum/thecount;
        
    END;
    RETURN average;
END;
/
/* 3.4 */
CREATE OR REPLACE FUNCTION getAllBornAfter
RETURN SYS_REFCURSOR AS mycursor SYS_REFCURSOR;
BEGIN
    OPEN mycursor FOR SELECT firstname, lastname FROM employee WHERE birthdate > '31-DEC-68';
    RETURN mycursor;
END getAllBornAfter;
/

DECLARE
    S SYS_REFCURSOR;
    efirstname employee.firstname%TYPE;
    elastname employee.lastname%TYPE;
BEGIN
    SELECT getAllBornAfter() INTO S FROM DUAL;
    DBMS_OUTPUT.PUT_LINE('test');
    LOOP
        FETCH S INTO efirstname, elastname;
        EXIT WHEN S%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(efirstname || ' ' || elastname);
    END LOOP;
    CLOSE S;
END;
/

/* 4.1 */
CREATE OR REPLACE PROCEDURE getFirstAndLast (mycursor OUT SYS_REFCURSOR) AS
BEGIN
    OPEN mycursor FOR SELECT firstname, lastname FROM employee;
END;
/

DECLARE
    S SYS_REFCURSOR;
    efirstname employee.firstname%TYPE;
    elastname employee.lastname%TYPE;
BEGIN
    getFirstAndLast(S);
    LOOP
        FETCH S INTO efirstname, elastname;
        EXIT WHEN S%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(efirstname || ' ' || elastname);
    END LOOP;
    CLOSE S;
END;
/

/* 4.2 */
CREATE OR REPLACE PROCEDURE changeInfo (eemployeeid IN employee.employeeid%TYPE, elastname IN employee.lastname%TYPE, efirstname employee.firstname%TYPE, eaddress IN employee.address%TYPE, ecity IN employee.city%TYPE, estate IN employee.state%TYPE, ecountry IN employee.country%TYPE, epostalcode IN employee.postalcode%TYPE, ephone IN employee.phone%TYPE, efax IN employee.fax%TYPE, eemail IN employee.email%TYPE) AS
BEGIN
    SAVEPOINT savepoint;
    UPDATE employee SET 
    lastname = elastname,
firstname = efirstname,
address = eaddress,
city = ecity,
state = estate,
country = ecountry,
postalcode = epostalcode,
phone = ephone,
fax = efax,
email = eemail
WHERE employeeid = eemployeeid;
COMMIT;

EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('FAILED TO UPDATE');
ROLLBACK TO SAVEPOINT savepoint;

END;
/

CREATE OR REPLACE PROCEDURE getManager (theemployeeid IN employee.employeeid%TYPE, managerfirstname OUT employee.firstname%TYPE, managerlastname OUT employee.lastname%TYPE) AS
BEGIN
    SELECT firstname,lastname INTO managerfirstname, managerlastname FROM employee WHERE employeeid = (SELECT reportsto FROM employee WHERE employeeid=theemployeeid);
END;
/
DECLARE
    managerfirstname employee.firstname%TYPE;
    managerlastname  employee.lastname%TYPE;
    
BEGIN
    getManager(4, managerfirstname, managerlastname);
    DBMS_OUTPUT.PUT_LINE(managerfirstname || ' ' || managerlastname);
END;
/

/* 4.3 */
CREATE OR REPLACE PROCEDURE getNameAndCompany (inputcustomerid IN customer.customerid%TYPE, cusfirstname OUT customer.firstname%TYPE, cuslastname OUT customer.lastname%TYPE, cuscompany OUT customer.company%TYPE) AS
BEGIN
    SELECT firstname, lastname, company INTO cusfirstname, cuslastname, cuscompany FROM customer WHERE customerid=inputcustomerid;
END;
/

DECLARE
    cusfirstname customer.firstname%TYPE;
    cuslastname customer.lastname%TYPE;
    cuscompany customer.company%TYPE;
BEGIN
    getNameAndCompany(5, cusfirstname, cuslastname, cuscompany);
    DBMS_OUTPUT.PUT_LINE('Name: ' || cusfirstname || ' ' || cuslastname || 'Company: ' || cuscompany);
END;
/


/* 5.0 */
CREATE OR REPLACE PROCEDURE deleteInvoice (inputinvoiceid IN invoice.invoiceid%TYPE) AS
BEGIN
    SAVEPOINT savepoint;
    DELETE FROM invoiceline WHERE invoiceid=inputinvoiceid;
    DELETE FROM invoice WHERE invoiceid=inputinvoiceid;
    COMMIT;
    EXCEPTION WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Failed to delete.');
        ROLLBACK TO SAVEPOINT savepoint;
END;
/


CREATE OR REPLACE PROCEDURE insertnewcustomer (inputcustomerid IN customer.customerid%TYPE, inputfirstname IN customer.firstname%TYPE, inputlastname IN customer.lastname%TYPE, inputcompany IN customer.company%TYPE, inputaddress IN customer.address%TYPE, inputcity IN customer.city%TYPE, inputstate IN customer.state%TYPE, inputcountry IN customer.country%TYPE, inputpostalcode IN customer.postalcode%TYPE, inputphone IN customer.phone%TYPE, inputfax IN customer.fax%TYPE, inputemail IN customer.email%TYPE, inputsupportrepid IN customer.supportrepid%TYPE ) AS
BEGIN
    SAVEPOINT savepoint;
    INSERT INTO customer VALUES (inputcustomerid, inputfirstname, inputlastname, inputcompany, inputaddress, inputcity, inputstate, inputcountry, inputpostalcode, inputphone, inputfax, inputemail, inputsupportrepid);
    COMMIT;
    EXCEPTION WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Could not insert.');
        ROLLBACK TO SAVEPOINT savepoint;
END;
/


/* 6.1 */
CREATE OR REPLACE TRIGGER afterTriggerInsertEmployee
AFTER INSERT ON employee
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('Inserted.');
END;
/

CREATE OR REPLACE TRIGGER afterTriggerUpdateAlbum
AFTER UPDATE ON album
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('Updated.');
END;
/

CREATE OR REPLACE TRIGGER afterTriggerDeleteCustomer
AFTER DELETE ON customer
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('Deleted');
END;
/

/* 7.1 */
SELECT customer.firstname, customer.lastname, invoice.invoiceid FROM customer INNER JOIN invoice ON customer.customerid=invoice.customerid;

/* 7.2 */
SELECT customer.customerid, customer.firstname, customer.lastname, invoice.invoiceid, invoice.total FROM customer LEFT JOIN invoice ON customer.customerid=invoice.customerid;

/* 7.3 */
SELECT artist.name, album.title FROM album RIGHT JOIN artist ON album.artistid=artist.artistid;

/* 7.4 */
SELECT * FROM album CROSS JOIN artist ORDER BY artist.name;

/* 7.5 */
SELECT * FROM employee a, employee b WHERE a.reportsto=b.reportsto;

/* 7.6 */
SELECt * FROM invoiceline INNER JOIN invoice ON invoiceline.invoiceid=invoice.invoiceid INNER JOIN customer ON invoice.customerid=customer.customerid INNER JOIN employee ON customer.supportrepid=employee.employeeid INNER JOIN track ON invoiceline.trackid=track.trackid INNER JOIN mediatype ON track.mediatypeid=mediatype.mediatypeid INNER JOIN genre ON track.genreid=genre.genreid INNER JOIN album ON track.albumid=album.albumid INNER JOIN artist ON album.artistid=artist.artistid INNER JOIN playlisttrack ON playlisttrack.trackid=track.trackid INNER JOIN playlist ON playlisttrack.playlistid=playlist.playlistid;

/* 9.0 */
