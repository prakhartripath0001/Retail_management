USE retail_management_db;

-- ============================================================================
-- LAB 9: INDEXES AND QUERY PERFORMANCE
-- THEORY:
-- An index can reduce rows examined for selective filters and joins. Composite
-- indexes are most useful when queries use the leftmost columns in the index.
-- Too many indexes increase storage and slow INSERT/UPDATE/DELETE. Measure with
-- EXPLAIN and realistic data; tiny training tables often show little benefit.
-- ============================================================================

-- 9.1 Inspect existing indexes on orders and order_items
SHOW INDEX FROM orders;
SHOW INDEX FROM order_items;
SHOW INDEX FROM payments;
SHOW INDEX FROM products;

-- 9.2 Execution plan for customer order lookup using composite index idx_orders_customer_date
EXPLAIN
SELECT order_id, order_date, status
FROM orders
WHERE customer_id = 1
ORDER BY order_date DESC;

-- 9.3 Execution plan for payment lookup using idx_payment_order_status
EXPLAIN
SELECT order_id, payment_status, amount
FROM payments
WHERE order_id = 1 AND payment_status = 'SUCCESS';

-- 9.4 Detailed format analysis (JSON format reveals cost model calculations)
EXPLAIN FORMAT=JSON
SELECT o.order_id, o.order_date, c.full_name
FROM orders AS o
JOIN customers AS c ON c.customer_id = o.customer_id
WHERE o.status = 'DELIVERED';

