USE retail_management_db;

-- ============================================================================
-- STUDENT ASSIGNMENT 5: TOP-FIVE PRODUCTS BY CATEGORY
-- Objective: Rank products within each category based on total units sold
--            and revenue generated using window partitioning functions.
-- ============================================================================

WITH category_product_performance AS (
    SELECT
        c.category_id,
        c.category_name,
        p.product_id,
        p.sku,
        p.product_name,
        p.unit_price,
        COALESCE(SUM(oi.quantity), 0) AS total_units_sold,
        COALESCE(SUM(oi.quantity * oi.unit_price), 0.00) AS gross_category_revenue,
        DENSE_RANK() OVER (
            PARTITION BY c.category_id
            ORDER BY COALESCE(SUM(oi.quantity), 0) DESC, COALESCE(SUM(oi.quantity * oi.unit_price), 0.00) DESC
        ) AS rank_in_category
    FROM categories AS c
    JOIN products AS p ON p.category_id = c.category_id
    LEFT JOIN order_items AS oi ON oi.product_id = p.product_id
    LEFT JOIN orders AS o ON o.order_id = oi.order_id
        AND o.status IN ('CONFIRMED', 'SHIPPED', 'DELIVERED')
    GROUP BY c.category_id, c.category_name, p.product_id, p.sku, p.product_name, p.unit_price
)
SELECT
    category_name,
    rank_in_category,
    sku,
    product_name,
    unit_price,
    total_units_sold,
    gross_category_revenue
FROM category_product_performance
WHERE rank_in_category <= 5
ORDER BY category_name, rank_in_category;

