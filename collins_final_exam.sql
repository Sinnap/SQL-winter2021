-- Jamie Collins Exam

USE ap;

#Question 1
SELECT 
    SUM(i.invoice_total - i.payment_total) AS credit_total,
    i.vendor_id,
    v.vendor_name,
    CONCAT(v.vendor_contact_last_name,
            ' ',
            LEFT(v.vendor_contact_first_name, 1)) AS contact,
    i.invoice_total,
    i.payment_total,
    SUM(i.invoice_total - i.payment_total) AS difference,
    IFNULL(vendor_phone, 'missing') AS phone_number
FROM
    invoices i
        JOIN
    vendors v ON i.vendor_id = v.vendor_id
GROUP BY v.vendor_id , v.vendor_name , i.invoice_total , i.payment_total
ORDER BY difference DESC;

#Question 2  
SELECT 
    COUNT(v.vendor_id) AS number_of_vendors,
    gla.account_description,
    MAX(v.default_terms_id) AS terms_id
FROM
    general_ledger_accounts gla
        JOIN
    invoice_line_items ili ON gla.account_number = ili.account_number
        JOIN
    invoices i ON ili.invoice_id = i.invoice_id
        JOIN
    vendors v ON v.vendor_id = i.vendor_id
WHERE
    LOCATE('Costs', gla.account_description) > 0
        AND NOT LOCATE('Subscription', gla.account_description)
GROUP BY gla.account_description , v.vendor_id, terms_id
HAVING number_of_vendors >= 4;

#Question 3 
SELECT 
    v.vendor_id, v.vendor_name
FROM
    vendors v
WHERE
    EXISTS( SELECT 
            *
        FROM
            invoices i,
            invoices iv
        WHERE
            i.payment_total > 0
                AND iv.payment_total = 0);

#Question 4 
USE ap;

DROP PROCEDURE IF EXISTS ili_stats;

DELIMITER //

CREATE PROCEDURE ili_stats (IN description_param CHAR)

BEGIN

 SELECT line_item_description,
-- CONCAT('$', decimal(line_item_amount, 2)) description, 
 CONCAT('$', line_item_amount) description, 
MIN(line_item_amount) minimum, 
MAX(line_item_amount) maxium, 
AVG(line_item_amount) average, 
SUM(line_item_amount) total

FROM invoice_line_items
  GROUP BY line_item_description;
  
-- description LIKE 'Freight' OR 'Telephone' OR 'Design';

-- CONCAT('$', (decimal(line_item_amount, 7)))
-- HAVING line_item_description LIKE @description_param;
  --  (invoice_total - payment_total - credit_total) >= 5000;
END //

DELIMITER ;
CALL ili_stats();
  
#Question 5
SELECT ili.invoice_id, ili.line_item_description Description, ili.line_item_amount Amount, gla.account_description Account
FROM invoice_line_items ili
JOIN general_ledger_accounts gla ON ili.account_number = gla.account_number
WHERE ili.invoice_id NOT IN
(select i.invoice_id
from invoices i)
ORDER BY invoice_id, Amount;

#Question 6
 USE my_guitar_shop;

INSERT INTO customers
(customer_id, first_name, last_name, email_address, customers.password, shipping_address_id, billing_address_id)
VALUES (DEFAULT, 'Jamie', 'Collins', 'jamie@email.com', 'password1', NULL, NULL);

 USE my_guitar_shop;
 
SELECT c.customer_id, c.email_address, c.first_name, 
COUNT(o.order_id) total_orders, 
COUNT(p.product_id) total_product, 
SUM((oi.item_price * oi.quantity - oi.discount_amount) + o.tax_amount) total_money_spent,
MAX(o.ship_amount) maximum_shipping,
DATE_FORMAT(o.order_date, '%b %c %Y') last_order_date,
MAX(LENGTH(p.product_name)) max_product_name_length
FROM customers c
JOIN orders o 
ON o.customer_id = c.customer_id
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN products p
ON p.product_id = oi.product_id
JOIN categories ca
ON ca.category_id = p.category_id
GROUP BY o.order_date, c.customer_id, ca.category_name
HAVING  ca.category_name = 'Guitars';

#Question 7
USE ap;

ALTER TABLE invoices
ADD late_fee_amount decimal(9,2) NOT NULL DEFAULT 0.00,
ADD late_fee_date date;

DROP PROCEDURE IF EXISTS late_fee;

DELIMITER //

CREATE PROCEDURE late_fee()
BEGIN
DECLARE invoice_id_var INT;
DECLARE late_amount_due_var INT;
DECLARE finish TINYINT DEFAULT FALSE;
DECLARE late_due_cursor CURSOR FOR 
SELECT invoice_id, SUM(invoice_total + late_fee_amount - payment_total - credit_total) late_amount_due
FROM invoices
WHERE late_amount_due  > 0;

DECLARE CONTINUE HANDLER FOR NOT FOUND

OPEN late_due_cursor;

FETCH late_due_cursor INTO invoice_id_var, late_amount_due_var;

SELECT 
    SUM((late_fee_amount * 0.75) + late_fee_amount),
    LATE_FEE_DATE(NOW());

CLOSE late_due_cursor;
END//

DELIMITER ;

CALL late_fee(late_fee_amount);
CALL late_fee(late_fee_date);