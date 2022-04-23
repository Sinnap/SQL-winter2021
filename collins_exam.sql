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

#Question 4 ----- INCOMPLETE ------
USE ap;

DROP PROCEDURE IF EXISTS ili_stats;

DELIMITER //

CREATE PROCEDURE ili_stats (IN description_param CHAR)

BEGIN

 SELECT 
line_item_description description, -- value of pass param
MIN(line_item_amount) minimum, -- matching
MAX(line_item_amount) maxium, -- matching
AVG(line_item_amount) average, -- matching
SUM(line_item_amount) total -- matching
FROM invoice_line_items
  GROUP BY line_item_description LIKE description_param;

-- HAVING line_item_description LIKE @description_param;
  --  (invoice_total - payment_total - credit_total) >= 5000;
END //

DELIMITER ;
CALL ili_stats();

-- CONCAT('$', (decimal(line_item_amounts, 7)))
 -- CONCAT line_item_description LIKE description_param
 
 
 /*
 SELECT 
line_item_description, -- value of pass param
MIN(line_item_amount) minimum, -- matching
MAX(line_item_amount) maxium, -- matching
AVG(line_item_amount) average, -- matching
SUM(line_item_amount) total -- matching

  from invoice_line_items
  GROUP BY line_item_description  */
  
#Question 5
SELECT ili.invoice_id, ili.line_item_description Description, ili.line_item_amount Amount, gla.account_description Account
FROM invoice_line_items ili
JOIN general_ledger_accounts gla ON ili.account_number = gla.account_number
WHERE ili.invoice_id NOT IN
(select i.invoice_id
from invoices i)
ORDER BY invoice_id, Amount;

#Question 6
