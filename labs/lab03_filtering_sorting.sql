USE retail_management_db;

-- ============================================================================
-- LAB 3: SELECT, FILTERING, SORTING, STRING AND DATE FUNCTIONS
-- THEORY:
-- WHERE filters rows before grouping. ORDER BY sorts the final result.
-- LIKE supports patterns: % means zero or more characters; _ means one.
-- NULL means missing/unknown, so use IS NULL / IS NOT NULL, not = NULL.
-- ============================================================================

-- 3.1 Complete product catalog
SELECT sku, product_name, unit_price, active
FROM products
ORDER BY product_name;

-- 3.2 Products above a threshold
SELECT sku, product_name, unit_price
FROM products
WHERE unit_price > 1000
ORDER BY unit_price DESC;

-- 3.3 BETWEEN is inclusive at both ends
SELECT product_name, unit_price
FROM products
WHERE unit_price BETWEEN 500 AND 5000
ORDER BY unit_price;

-- 3.4 Pattern matching
SELECT product_name
FROM products
WHERE product_name LIKE '%Mouse%';

-- 3.5 IN operator
SELECT full_name, city
FROM customers
WHERE city IN ('Bengaluru', 'Mumbai');

-- 3.6 Missing values
SELECT customer_id, full_name, phone
FROM customers
WHERE phone IS NULL;

-- 3.7 String functions
SELECT
    full_name,
    UPPER(full_name) AS uppercase_name,
    LOWER(email) AS normalized_email,
    CHAR_LENGTH(full_name) AS name_characters,
    CONCAT(full_name, ' - ', city) AS customer_label
FROM customers;

-- 3.8 Date filtering: use a half-open interval for DATETIME values
SELECT order_id, order_date, status
FROM orders
WHERE order_date >= '2026-10-01'
  AND order_date <  '2026-11-01'
ORDER BY order_date;

-- 3.9 LIMIT: top five most expensive products
SELECT product_name, unit_price
FROM products
ORDER BY unit_price DESC
LIMIT 5;

