USE retail_management_db;

-- ============================================================================
-- STUDENT ASSIGNMENT 2: ORDER DISCOUNTS AND TAX CALCULATION MODEL
-- Objective: Incorporate line-item discounts and GST/sales tax into order pricing.
-- ============================================================================

-- Create a comprehensive financial breakdown view that models:
-- 1. Gross Subtotal: sum(quantity * unit_price)
-- 2. Discount Rate: e.g., 10% promotional discount for orders above 2,000
-- 3. Taxable Subtotal: Gross Subtotal - Discount
-- 4. Applicable Tax (GST @ 18%): 18% of Taxable Subtotal
-- 5. Grand Total: Taxable Subtotal + Applicable Tax

CREATE OR REPLACE VIEW vw_order_financial_breakdown AS
WITH line_item_calculations AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,
        o.status,
        SUM(oi.quantity * oi.unit_price) AS gross_subtotal
    FROM orders AS o
    JOIN order_items AS oi ON oi.order_id = o.order_id
    GROUP BY o.order_id, o.customer_id, o.order_date, o.status
)
SELECT
    lic.order_id,
    c.full_name AS customer_name,
    lic.order_date,
    lic.status,
    lic.gross_subtotal,
    -- Conditional discount: 10% discount for orders exceeding 5,000, 5% for orders > 2,000
    ROUND(
        CASE
            WHEN lic.gross_subtotal >= 50000 THEN lic.gross_subtotal * 0.10
            WHEN lic.gross_subtotal >= 2000 THEN lic.gross_subtotal * 0.05
            ELSE 0.00
        END, 2
    ) AS discount_amount,
    -- Taxable Subtotal
    ROUND(
        lic.gross_subtotal - (
            CASE
                WHEN lic.gross_subtotal >= 50000 THEN lic.gross_subtotal * 0.10
                WHEN lic.gross_subtotal >= 2000 THEN lic.gross_subtotal * 0.05
                ELSE 0.00
            END
        ), 2
    ) AS taxable_amount,
    -- Standard GST (18%)
    ROUND(
        (lic.gross_subtotal - (
            CASE
                WHEN lic.gross_subtotal >= 50000 THEN lic.gross_subtotal * 0.10
                WHEN lic.gross_subtotal >= 2000 THEN lic.gross_subtotal * 0.05
                ELSE 0.00
            END
        )) * 0.18, 2
    ) AS tax_amount_gst_18,
    -- Final Invoice Total
    ROUND(
        (lic.gross_subtotal - (
            CASE
                WHEN lic.gross_subtotal >= 50000 THEN lic.gross_subtotal * 0.10
                WHEN lic.gross_subtotal >= 2000 THEN lic.gross_subtotal * 0.05
                ELSE 0.00
            END
        )) * 1.18, 2
    ) AS grand_total_payable
FROM line_item_calculations AS lic
JOIN customers AS c ON c.customer_id = lic.customer_id;

-- ----------------------------------------------------------------------------
-- Verification Query
-- ----------------------------------------------------------------------------
SELECT *
FROM vw_order_financial_breakdown
ORDER BY order_id;

