USE retail_management_db;

-- ============================================================================
-- LAB 13: LOW-STOCK REPORT
-- THEORY:
-- A reorder threshold is a fundamental inventory control rule. When
-- quantity_on_hand falls to or below reorder_level, automated procurement
-- or purchase orders must trigger to avoid stockouts.
-- ============================================================================

-- Basic Low-Stock Report
SELECT
    p.sku,
    p.product_name,
    i.quantity_on_hand,
    i.reorder_level
FROM products AS p
JOIN inventory AS i ON i.product_id = p.product_id
WHERE i.quantity_on_hand <= i.reorder_level
ORDER BY i.quantity_on_hand ASC, p.product_name;

-- Enhanced Operational Low-Stock Procurement Report with Supplier Contacts
SELECT
    p.sku,
    p.product_name,
    c.category_name,
    s.supplier_name,
    s.contact_email AS supplier_email,
    i.quantity_on_hand,
    i.reorder_level,
    (i.reorder_level - i.quantity_on_hand) AS units_deficit,
    CASE
        WHEN i.quantity_on_hand = 0 THEN 'OUT_OF_STOCK_CRITICAL'
        WHEN i.quantity_on_hand <= (i.reorder_level / 2) THEN 'URGENT_REORDER'
        ELSE 'REORDER_RECOMMENDED'
    END AS replenishment_priority
FROM products AS p
JOIN inventory AS i ON i.product_id = p.product_id
JOIN categories AS c ON c.category_id = p.category_id
LEFT JOIN suppliers AS s ON s.supplier_id = p.supplier_id
WHERE i.quantity_on_hand <= i.reorder_level
ORDER BY i.quantity_on_hand ASC, units_deficit DESC;

