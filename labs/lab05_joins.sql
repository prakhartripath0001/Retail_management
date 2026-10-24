USE retail_management_db;

-- ============================================================================
-- LAB 5: JOINS
-- THEORY:
-- INNER JOIN returns matching rows. LEFT JOIN preserves every row from the
-- left table and supplies NULLs when there is no match. Use explicit JOIN
-- syntax and qualified column names to keep complex SQL understandable.
-- ============================================================================

-- 5.1 Orders with customer names
SELECT c.customer_id, c.full_name, o.order_id, o.order_date, o.status
FROM customers AS c
INNER JOIN orders AS o ON o.customer_id = c.customer_id
ORDER BY o.order_date DESC;

-- 5.2 Customers who have never ordered
SELECT c.customer_id, c.full_name, c.email
FROM customers AS c
LEFT JOIN orders AS o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;

-- 5.3 Product and category list
SELECT p.sku, p.product_name, cat.category_name, p.unit_price
FROM products AS p
JOIN categories AS cat ON cat.category_id = p.category_id
ORDER BY cat.category_name, p.product_name;

-- 5.4 Order line details
SELECT
    o.order_id, o.order_date, c.full_name,
    p.sku, p.product_name, oi.quantity, oi.unit_price,
    oi.quantity * oi.unit_price AS line_value
FROM orders AS o
JOIN customers AS c ON c.customer_id = o.customer_id
JOIN order_items AS oi ON oi.order_id = o.order_id
JOIN products AS p ON p.product_id = oi.product_id
ORDER BY o.order_id, p.product_name;

-- 5.5 All products, including products never ordered
SELECT p.product_id, p.product_name, COUNT(oi.order_item_id) AS line_count
FROM products AS p
LEFT JOIN order_items AS oi ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY line_count DESC;

