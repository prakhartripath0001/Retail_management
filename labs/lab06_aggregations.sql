USE retail_management_db;

-- ============================================================================
-- LAB 6: AGGREGATIONS, GROUP BY, HAVING, CONDITIONAL AGGREGATION
-- THEORY:
-- COUNT counts rows/values; SUM totals values; AVG calculates averages.
-- GROUP BY creates groups. HAVING filters groups after aggregation.
-- COUNT(DISTINCT ...) is useful when joins can repeat a business entity.
-- Revenue definitions must explicitly address status, discounts, tax, returns,
-- and refunds. These examples calculate item gross value for selected statuses.
-- ============================================================================

-- 6.1 Value per order (all statuses shown for learning)
SELECT
    o.order_id, o.status,
    SUM(oi.quantity * oi.unit_price) AS order_value
FROM orders AS o
JOIN order_items AS oi ON oi.order_id = o.order_id
GROUP BY o.order_id, o.status
ORDER BY order_value DESC;

-- 6.2 Product sales for non-cancelled operational orders
SELECT
    p.product_id, p.product_name,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * oi.unit_price) AS gross_sales
FROM products AS p
JOIN order_items AS oi ON oi.product_id = p.product_id
JOIN orders AS o ON o.order_id = oi.order_id
WHERE o.status IN ('CONFIRMED', 'SHIPPED', 'DELIVERED')
GROUP BY p.product_id, p.product_name
ORDER BY gross_sales DESC;

-- 6.3 Monthly sales
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(oi.quantity * oi.unit_price) AS gross_sales
FROM orders AS o
JOIN order_items AS oi ON oi.order_id = o.order_id
WHERE o.status IN ('CONFIRMED', 'SHIPPED', 'DELIVERED')
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY sales_month;

-- 6.4 Average order value (based on the selected order statuses)
WITH order_totals AS (
    SELECT o.order_id, SUM(oi.quantity * oi.unit_price) AS order_value
    FROM orders AS o
    JOIN order_items AS oi ON oi.order_id = o.order_id
    WHERE o.status IN ('CONFIRMED', 'SHIPPED', 'DELIVERED')
    GROUP BY o.order_id
)
SELECT AVG(order_value) AS average_order_value
FROM order_totals;

-- 6.5 Customers whose selected-status sales exceed 50,000
SELECT
    c.customer_id, c.full_name,
    SUM(oi.quantity * oi.unit_price) AS gross_sales
FROM customers AS c
JOIN orders AS o ON o.customer_id = c.customer_id
JOIN order_items AS oi ON oi.order_id = o.order_id
WHERE o.status IN ('CONFIRMED', 'SHIPPED', 'DELIVERED')
GROUP BY c.customer_id, c.full_name
HAVING SUM(oi.quantity * oi.unit_price) > 50000
ORDER BY gross_sales DESC;

-- 6.6 Order counts by status
SELECT status, COUNT(*) AS order_count
FROM orders
GROUP BY status
ORDER BY order_count DESC;

-- 6.7 Sales by customer city
SELECT
    c.city,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(oi.quantity * oi.unit_price) AS gross_sales
FROM customers AS c
JOIN orders AS o ON o.customer_id = c.customer_id
JOIN order_items AS oi ON oi.order_id = o.order_id
WHERE o.status IN ('CONFIRMED', 'SHIPPED', 'DELIVERED')
GROUP BY c.city
HAVING SUM(oi.quantity * oi.unit_price) > 1000
ORDER BY gross_sales DESC;

