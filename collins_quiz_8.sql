-- Jamie Collins Quiz mod 8
USE my_guitar_shop;
DELIMITER //

CREATE PROCEDURE test
(
customer_id	INT
)

BEGIN
	SELECT email_address
    FROM customers
    WHERE customer_id = 1;
    
UPDATE email_address 
SET 
    customer_id = 1 = customer_id = 2;
END //

CALL test();

