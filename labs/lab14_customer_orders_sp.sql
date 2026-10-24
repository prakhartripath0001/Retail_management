USE retail_management_db;

-- ============================================================================
-- LAB 14: STORED PROCEDURE FOR CUSTOMER ORDER HISTORY
-- THEORY:
-- Stored procedures encapsulate SQL queries into a parameterized, reusable
-- interface on the database server. They enforce query consistency, guard
-- against SQL injection by using native parameter bindings, and minimize
-- round-trip network overhead.
-- ============================================================================

DROP PROCEDURE IF EXISTS sp_get_customer_orders;

DELIMITER $$

CREATE PROCEDURE sp_get_customer_orders(IN p_customer_id BIGINT UNSIGNED)
BEGIN
    -- Validate customer existence
    IF NOT EXISTS (SELECT 1 FROM customers WHERE customer_id = p_customer_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Customer ID does not exist';
    END IF;

    -- Retrieve order history with aggregate value
    SELECT
        o.order_id,
        o.order_date,
        o.status,
        COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS order_value
    FROM orders AS o
    LEFT JOIN order_items AS oi ON oi.order_id = o.order_id
    WHERE o.customer_id = p_customer_id
    GROUP BY o.order_id, o.order_date, o.status
    ORDER BY o.order_date DESC;
END$$

DELIMITER ;

-- ----------------------------------------------------------------------------
-- Verification: Procedure Calls
-- ----------------------------------------------------------------------------
-- Test 1: Customer with existing orders (Customer 1 - Aarav Sharma)
CALL sp_get_customer_orders(1);

-- Test 2: Customer with no orders (Customer 5 - Kabir Das)
CALL sp_get_customer_orders(5);

