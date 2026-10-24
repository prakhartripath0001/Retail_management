USE retail_management_db;

-- ============================================================================
-- LAB 12: PAYMENT RECONCILIATION
-- THEORY:
-- In real retail workflows, orders can have multiple partial payments or failed
-- retry attempts. Joining `order_items` directly with `payments` produces a
-- Cartesian multiplication across line items and payments, corrupting sum totals.
-- The correct architectural pattern aggregates order lines and payments
-- independently in separate CTEs before joining them on `order_id`.
-- ============================================================================

WITH order_totals AS (
    SELECT
        o.order_id,
        SUM(oi.quantity * oi.unit_price) AS order_value
    FROM orders AS o
    JOIN order_items AS oi ON oi.order_id = o.order_id
    GROUP BY o.order_id
),
payment_totals AS (
    SELECT
        order_id,
        SUM(CASE WHEN payment_status = 'SUCCESS' THEN amount ELSE 0 END) AS successful_payment_total,
        COUNT(CASE WHEN payment_status = 'SUCCESS' THEN 1 END) AS successful_payment_count,
        COUNT(CASE WHEN payment_status = 'FAILED' THEN 1 END) AS failed_payment_count
    FROM payments
    GROUP BY order_id
)
SELECT
    o.order_id,
    o.status AS order_status,
    ot.order_value,
    COALESCE(pt.successful_payment_total, 0) AS successful_payment_total,
    COALESCE(pt.successful_payment_total, 0) - ot.order_value AS variance,
    CASE
        WHEN COALESCE(pt.successful_payment_total, 0) = ot.order_value THEN 'RECONCILED'
        WHEN COALESCE(pt.successful_payment_total, 0) = 0 THEN 'UNPAID'
        WHEN COALESCE(pt.successful_payment_total, 0) < ot.order_value THEN 'UNDERPAID'
        ELSE 'OVERPAID'
    END AS reconciliation_status
FROM orders AS o
JOIN order_totals AS ot ON ot.order_id = o.order_id
LEFT JOIN payment_totals AS pt ON pt.order_id = o.order_id
ORDER BY o.order_id;

-- Interpretation:
-- variance = 0: Order total perfectly matched with settled payments.
-- negative variance: Underpayment (outstanding balance remains).
-- positive variance: Overpayment (may require refund issuance).

