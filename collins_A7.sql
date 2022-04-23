-- Jamie Collins 

#Question 1
USE my_guitar_shop;

DROP PROCEDURE IF EXISTS test;

DELIMITER //
CREATE PROCEDURE test()
BEGIN
DECLARE all_products INT;

SELECT COUNT(product_id)
INTO all_products
FROM products;

IF all_products >= 7 THEN
SELECT "The number of products is greater than or equal to 7";
ELSE 
SELECT "The number of products is less than 7";
END IF;

END//
DELIMITER ;

CALL test();

#Question 2
DROP PROCEDURE IF EXISTS test;

DELIMITER //
CREATE PROCEDURE test()
BEGIN
DECLARE product_count INT;
DECLARE average_price DECIMAL(10, 2);

SELECT COUNT(product_id)
INTO product_count
FROM products;

SELECT AVG(list_price)
INTO average_price
FROM products;

IF product_count >= 7 THEN
SELECT product_count, average_price;
ELSE 
SELECT "The number of products is less than 7";
END IF;

END//
DELIMITER ;

CALL test();

#Question 3 
DROP PROCEDURE IF EXISTS test;

DELIMITER //
CREATE PROCEDURE test()
BEGIN
DECLARE ten INT DEFAULT 10;
DECLARE twenty INT DEFAULT 20;
DECLARE limit_100 INT DEFAULT 100;
DECLARE counter INT;
DECLARE finish TINYINT;

WHILE ten AND twenty < limit_100 DO
SET counter = 1;
SET finish = TRUE;

testLoop : LOOP
IF ten % counter = 0 AND twenty % counter = 0 THEN
SET finish = TRUE;
ELSE 
SET finish = FALSE;
END IF;
END LOOP testLoop;
END WHILE;

SELECT finish;
END;
DELIMITER ;

CALL test();

#Question 4 
DROP PROCEDURE IF EXISTS test;

DELIMITER //
CREATE PROCEDURE test()
BEGIN
DECLARE product_name_var VARCHAR(255);
DECLARE list_price_var DECIMAL (10, 2);
DECLARE finished TINYINT DEFAULT FALSE;

DECLARE list_price_cursor CURSOR FOR
SELECT product_name, list_price
FROM products
WHERE list_price > 700
ORDER BY list_price dESC;

DECLARE CONTINUE HANDLER FOR NOT FOUND 
SET finished = TRUE;

OPEN list_price_cursor;

FETCH list_price_cursor INTO product_name_var, list_price_var;

SELECT CONCAT('"', product_name_var,'"', ",", '"',list_price_var, '"',"|") AS product_str ;

CLOSE list_price_cursor;

END//
DELIMITER ;

CALL test();
/*
SELECT product_name, list_price
FROM products
WHERE list_price > 700
ORDER BY list_price dESC;
*/

#Question 5
DROP PROCEDURE IF EXISTS test;
DELIMITER //
CREATE PROCEDURE test()
BEGIN
INSERT INTO categories
VALUES (Guitars);
END//
DELIMITER ;

#Question 6 
DROP PROCEDURE IF EXISTS test;

DELIMITER //
CREATE PROCEDURE test()
BEGIN
DECLARE finish TINYINT DEFAULT FALSE;
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
SET finish = TRUE;

START TRANSACTION;

DELETE FROM addresses 
WHERE
    customer_id = (SELECT 
        custioner_id
    FROM
        addresses
    
    WHERE
        customer_id = 8);

DELETE FROM customers 
WHERE
    customer_id = 8;
COMMIT;
END//
DELIMITER ;

CALL test();

#Question 7 
USE my_guitar_shop;
DROP PROCEDURE IF EXISTS timing_test;
DELIMITER //
CREATE PROCEDURE timing_test()
BEGIN
DECLARE var INT;
DECLARE sql_error TINYINT DEFAULT FALSE;
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET sql_error = TRUE;

START TRANSACTION;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
UPDATE categories
SET category_id = 5
WHERE cartegory_id = 1;
IF sql_error = FALSE
THEN COMMIT;
SELECT "transaction committed";
ELSE ROLLBACK;
SELECT "transaction failed";
END IF;

START TRANSACTION;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
INSERT INTO administrators (admin_id, first_name, last_name)
VALUES("0", "unknown", "unknown");
IF sql_error = FALSE
THEN COMMIT;
SELECT "transaction committed";
ELSE ROLLBACK;
SELECT "transaction failed";
END IF;

START TRANSACTION;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
INSERT INTO administrators (admin_id, first_name, last_name)
VALUES( DEFAULT, "unknown", "unknown");
IF sql_error = FALSE
THEN COMMIT;
SELECT "transaction committed";
ELSE ROLLBACK;
SELECT "transaction failed";
END IF;


START TRANSACTION;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
DELETE FROM administrators
WHERE admin_id = 0;
IF sql_error = FALSE
THEN COMMIT;
SELECT "transaction committed";
ELSE ROLLBACK;
SELECT "transaction failed";
END IF;

END//
DELIMITER ;
DECLARE i INT DEFAULT 1
WHILE i <= 1000 DO 
CALL timing_test()
END WHILE;




