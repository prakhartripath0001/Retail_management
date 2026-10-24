USE retail_management_db;

-- ============================================================================
-- LAB 8: VIEWS
-- THEORY:
-- A view is a stored SELECT statement exposed like a virtual table. It can
-- standardize reporting logic and limit which columns reporting users see.
-- A normal MySQL view does not store a materialized copy of the result.
-- ============================================================================

-- 8.1 View: vw_order_sales
-- Summarizes order header information with calculated aggregate order value.
CREATE OR REPLACE VIEW vw_order_sales AS
SELECT
    o.order_id, o.customer_id, o.order_date, o.status,
    SUM(oi.quantity * oi.unit_price) AS order_value
FROM orders AS o
JOIN order_items AS oi ON oi.order_id = o.order_id
GROUP BY o.order_id, o.customer_id, o.order_date, o.status;

-- 8.2 View: vw_product_inventory
-- Merges catalog and inventory levels, computing a boolean reorder flag.
CREATE OR REPLACE VIEW vw_product_inventory AS
SELECT
    p.product_id, p.sku, p.product_name, cat.category_name,
    p.unit_price, i.quantity_on_hand, i.reorder_level,
    (i.quantity_on_hand <= i.reorder_level) AS needs_reorder
FROM products AS p
JOIN categories AS cat ON cat.category_id = p.category_id
JOIN inventory AS i ON i.product_id = p.product_id;

-- 8.3 View: vw_customer_order_summary
-- Lifetime customer value and order volume report.
CREATE OR REPLACE VIEW vw_customer_order_summary AS
SELECT
    c.customer_id, c.full_name, c.email, c.city,
    COUNT(DISTINCT o.order_id) AS order_count,
    COALESCE(SUM(
        CASE WHEN o.status IN ('CONFIRMED','SHIPPED','DELIVERED')
             THEN oi.quantity * oi.unit_price ELSE 0 END
    ), 0) AS selected_status_gross_sales
FROM customers AS c
LEFT JOIN orders AS o ON o.customer_id = c.customer_id
LEFT JOIN order_items AS oi ON oi.order_id = o.order_id
GROUP BY c.customer_id, c.full_name, c.email, c.city;

-- ----------------------------------------------------------------------------
-- View Invocations & Verifications
-- ----------------------------------------------------------------------------
-- Test 1: Order sales ordered by highest order value
SELECT * FROM vw_order_sales ORDER BY order_value DESC;

-- Test 2: Low-stock items needing immediate reorder
SELECT * FROM vw_product_inventory WHERE needs_reorder = TRUE;

-- Test 3: Customer summary ordered by highest gross sales
SELECT * FROM vw_customer_order_summary ORDER BY selected_status_gross_sales DESC;

