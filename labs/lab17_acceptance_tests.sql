USE retail_management_db;

-- ============================================================================
-- LAB 17: ACCEPTANCE TESTS & FINAL INTEGRITY VALIDATION
-- ============================================================================

-- A. Core Table Counts
SELECT 'customers' AS table_name, COUNT(*) AS rows_found FROM customers
UNION ALL SELECT 'categories', COUNT(*) FROM categories
UNION ALL SELECT 'suppliers', COUNT(*) FROM suppliers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'inventory', COUNT(*) FROM inventory
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'payments', COUNT(*) FROM payments
UNION ALL SELECT 'inventory_audit', COUNT(*) FROM inventory_audit;

-- B. Check for order items without a matching order (Expected: 0 rows)
SELECT oi.order_item_id, oi.order_id, oi.product_id
FROM order_items AS oi
LEFT JOIN orders AS o ON o.order_id = oi.order_id
WHERE o.order_id IS NULL;

-- C. Check for products without an inventory record (Expected: 0 rows)
SELECT p.product_id, p.sku, p.product_name
FROM products AS p
LEFT JOIN inventory AS i ON i.product_id = p.product_id
WHERE i.product_id IS NULL;

-- D. Verify all Views compile and return valid rows
SELECT 'vw_order_sales' AS view_tested, COUNT(*) AS records_returned FROM vw_order_sales
UNION ALL SELECT 'vw_product_inventory', COUNT(*) FROM vw_product_inventory
UNION ALL SELECT 'vw_customer_order_summary', COUNT(*) FROM vw_customer_order_summary;

-- E. Check for orphan payments without valid orders (Expected: 0 rows)
SELECT p.payment_id, p.order_id, p.amount
FROM payments AS p
LEFT JOIN orders AS o ON o.order_id = p.order_id
WHERE o.order_id IS NULL;

-- F. Integrity check: ensure no negative quantities in inventory
SELECT product_id, quantity_on_hand
FROM inventory
WHERE quantity_on_hand < 0;

