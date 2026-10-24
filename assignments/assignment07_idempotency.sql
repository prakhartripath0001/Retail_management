USE retail_management_db;

-- ============================================================================
-- STUDENT ASSIGNMENT 7: IDEMPOTENT ORDER CREATION MECHANISM
-- Objective: Prevent duplicate order placement from network retries using an idempotency key.
-- ============================================================================

-- 1. Ensure idempotency_key column exists on orders table
SET @col_exists := (
    SELECT COUNT(*)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'retail_management_db'
      AND TABLE_NAME = 'orders'
      AND COLUMN_NAME = 'idempotency_key'
);

SET @stmt := IF(
    @col_exists = 0,
    'ALTER TABLE orders ADD COLUMN idempotency_key VARCHAR(64) UNIQUE NULL AFTER status',
    'SELECT "idempotency_key already exists" AS message'
);

PREPARE exec_stmt FROM @stmt;
EXECUTE exec_stmt;
DEALLOCATE PREPARE exec_stmt;

-- 2. Stored Procedure for Idempotent Order Creation
DROP PROCEDURE IF EXISTS sp_create_order_idempotent;

DELIMITER $$

CREATE PROCEDURE sp_create_order_idempotent(
    IN p_customer_id BIGINT UNSIGNED,
    IN p_idempotency_key VARCHAR(64),
    OUT p_order_id BIGINT UNSIGNED,
    OUT p_action_result VARCHAR(50)
)
BEGIN
    DECLARE v_existing_order_id BIGINT UNSIGNED DEFAULT NULL;

    -- Validate customer
    IF NOT EXISTS (SELECT 1 FROM customers WHERE customer_id = p_customer_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid customer ID';
    END IF;

    -- Check if idempotency key was previously processed
    IF p_idempotency_key IS NOT NULL THEN
        SELECT order_id
          INTO v_existing_order_id
          FROM orders
         WHERE idempotency_key = p_idempotency_key
         LIMIT 1;

        IF v_existing_order_id IS NOT NULL THEN
            -- Idempotent match found: Return the existing order without creating a duplicate
            SET p_order_id = v_existing_order_id;
            SET p_action_result = 'EXISTING_ORDER_RETURNED';
        END IF;
    END IF;

    -- Create new order if not already processed
    IF v_existing_order_id IS NULL THEN
        START TRANSACTION;

        INSERT INTO orders (customer_id, status, idempotency_key)
        VALUES (p_customer_id, 'PENDING', p_idempotency_key);

        SET p_order_id = LAST_INSERT_ID();
        SET p_action_result = 'NEW_ORDER_CREATED';

        COMMIT;
    END IF;
END$$

DELIMITER ;

-- ----------------------------------------------------------------------------
-- Verification: Test Idempotent Behavior
-- ----------------------------------------------------------------------------
-- First Call: Creates a new order
CALL sp_create_order_idempotent(1, 'REQ-KEY-UUID-99901', @order_id, @action_result);
SELECT @order_id AS order_id, @action_result AS result;

-- Second Call: Same customer, same idempotency key -> MUST return EXISTING_ORDER_RETURNED
CALL sp_create_order_idempotent(1, 'REQ-KEY-UUID-99901', @order_id, @action_result);
SELECT @order_id AS order_id, @action_result AS result;

