USE retail_management_db;

-- ============================================================================
-- STUDENT ASSIGNMENT 4: MONTH-OVER-MONTH SALES GROWTH USING LAG()
-- Objective: Compare current month sales with prior month using window functions.
-- ============================================================================

WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.quantity * oi.unit_price) AS current_month_sales
    FROM orders AS o
    JOIN order_items AS oi ON oi.order_id = o.order_id
    WHERE o.status IN ('CONFIRMED', 'SHIPPED', 'DELIVERED')
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
)
SELECT
    sales_month,
    total_orders,
    current_month_sales,
    -- Retrieve prior month sales using LAG()
    LAG(current_month_sales, 1) OVER (
        ORDER BY sales_month
    ) AS prior_month_sales,
    -- Absolute variance
    ROUND(
        current_month_sales - LAG(current_month_sales, 1) OVER (
            ORDER BY sales_month
        ), 2
    ) AS mom_revenue_change,
    -- Percentage growth
    ROUND(
        (
            (current_month_sales - LAG(current_month_sales, 1) OVER (ORDER BY sales_month))
            / LAG(current_month_sales, 1) OVER (ORDER BY sales_month)
        ) * 100, 2
    ) AS mom_growth_percentage
FROM monthly_revenue
ORDER BY sales_month;

