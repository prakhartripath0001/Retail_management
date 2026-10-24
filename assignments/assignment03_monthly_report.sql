USE retail_management_db;

-- ============================================================================
-- STUDENT ASSIGNMENT 3: DYNAMIC MONTHLY SALES REPORT WITH FILTERS
-- Objective: Build a stored procedure allowing management to filter sales
--            metrics dynamically by Year and optionally Month.
-- ============================================================================

DROP PROCEDURE IF EXISTS sp_monthly_sales_report;

DELIMITER $$

CREATE PROCEDURE sp_monthly_sales_report(
    IN p_year INT,
    IN p_month INT
)
BEGIN
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m') AS report_period,
        COUNT(DISTINCT o.order_id) AS total_orders,
        COUNT(DISTINCT CASE WHEN o.status = 'DELIVERED' THEN o.order_id END) AS delivered_orders,
        COUNT(DISTINCT CASE WHEN o.status = 'CANCELLED' THEN o.order_id END) AS cancelled_orders,
        COUNT(DISTINCT o.customer_id) AS active_customers,
        COALESCE(SUM(oi.quantity), 0) AS units_sold,
        COALESCE(SUM(oi.quantity * oi.unit_price), 0.00) AS total_gross_revenue,
        ROUND(COALESCE(AVG(oi.quantity * oi.unit_price), 0.00), 2) AS avg_item_revenue
    FROM orders AS o
    LEFT JOIN order_items AS oi ON oi.order_id = o.order_id
    WHERE (p_year IS NULL OR YEAR(o.order_date) = p_year)
      AND (p_month IS NULL OR MONTH(o.order_date) = p_month)
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
    ORDER BY report_period DESC;
END$$

DELIMITER ;

-- ----------------------------------------------------------------------------
-- Verification Calls
-- ----------------------------------------------------------------------------
-- Test 1: Report for October 2026 (Year: 2026, Month: 10)
CALL sp_monthly_sales_report(2026, 10);

-- Test 2: Full Annual Rollup for 2026 (Month: NULL)
CALL sp_monthly_sales_report(2026, NULL);

