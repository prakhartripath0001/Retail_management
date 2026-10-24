USE retail_management_db;

-- ============================================================================
-- LAB 7: SUBQUERIES, CTEs, AND WINDOW FUNCTIONS
-- THEORY:
-- A subquery is a query nested inside another statement.
-- A CTE (WITH ...) names a temporary result set for one statement.
-- Window functions calculate across related rows while preserving row detail.
-- ROW_NUMBER assigns a unique sequence; RANK gives tied values equal ranks.
-- ============================================================================

-- 7.1 Products priced above the overall average
SELECT product_name, unit_price
FROM products
WHERE unit_price > (SELECT AVG(unit_price) FROM products)
ORDER BY unit_price DESC;

-- 7.2 Products with no order items (NOT EXISTS avoids NULL issues)
SELECT p.product_id, p.product_name
FROM products AS p
WHERE NOT EXISTS (
    SELECT 1
    FROM order_items AS oi
    WHERE oi.product_id = p.product_id
);

-- 7.3 Rank products by gross sales
WITH product_sales AS (
    SELECT p.product_id, p.product_name,
           SUM(oi.quantity * oi.unit_price) AS sales_value
    FROM products AS p
    JOIN order_items AS oi ON oi.product_id = p.product_id
    JOIN orders AS o ON o.order_id = oi.order_id
    WHERE o.status IN ('CONFIRMED', 'SHIPPED', 'DELIVERED')
    GROUP BY p.product_id, p.product_name
)
SELECT
    product_name, sales_value,
    RANK() OVER (ORDER BY sales_value DESC) AS sales_rank
FROM product_sales
ORDER BY sales_rank, product_name;

-- 7.4 Most recent order for each customer
WITH ranked_orders AS (
    SELECT o.*,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id
               ORDER BY order_date DESC, order_id DESC
           ) AS rn
    FROM orders AS o
)
SELECT c.full_name, ro.order_id, ro.order_date, ro.status
FROM ranked_orders AS ro
JOIN customers AS c ON c.customer_id = ro.customer_id
WHERE ro.rn = 1
ORDER BY c.full_name;

-- 7.5 Running daily sales total
WITH daily_sales AS (
    SELECT DATE(o.order_date) AS sales_date,
           SUM(oi.quantity * oi.unit_price) AS daily_sales
    FROM orders AS o
    JOIN order_items AS oi ON oi.order_id = o.order_id
    WHERE o.status IN ('CONFIRMED', 'SHIPPED', 'DELIVERED')
    GROUP BY DATE(o.order_date)
)
SELECT sales_date, daily_sales,
       SUM(daily_sales) OVER (
           ORDER BY sales_date
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS running_sales
FROM daily_sales
ORDER BY sales_date;

