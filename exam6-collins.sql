SELECT category_name
FROM categories c
WHERE(SELECT avg(list_price) AS average_list_price
FROM products p
WHERE c.category_id = p.category_id)

