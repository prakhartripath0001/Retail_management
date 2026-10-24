USE retail_management_db;

-- ============================================================================
-- LAB 10: TRANSACTIONS AND SAFE INVENTORY RESERVATION
-- THEORY:
-- ACID = Atomicity, Consistency, Isolation, Durability.
-- A transaction groups related changes so they commit together or roll back.
-- A conditional UPDATE prevents a stock balance being reduced below the
-- requested quantity. Check ROW_COUNT() immediately after the UPDATE.
--
-- DEMO:
-- This block reserves units of a product if enough stock is available.
-- It uses a stored procedure with row locking (SELECT ... FOR UPDATE) and rollback.
-- ============================================================================

DROP PROCEDURE IF EXISTS sp_reserve_inventory;

DELIMITER $$

CREATE PROCEDURE sp_reserve_inventory(
    IN p_product_id BIGINT UNSIGNED,
    IN p_quantity INT UNSIGNED,
    IN p_reason VARCHAR(255)
)
BEGIN
    DECLARE v_rows INT DEFAULT 0;
    DECLARE v_old_qty INT UNSIGNED DEFAULT NULL;
    DECLARE v_new_qty INT UNSIGNED DEFAULT NULL;

    -- Exit handler ensures transaction rollback on any SQL error
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- Input validation
    IF p_quantity IS NULL OR p_quantity = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Quantity must be greater than zero';
    END IF;

    START TRANSACTION;

    -- Acquire exclusive row lock on product inventory
    SELECT quantity_on_hand
      INTO v_old_qty
      FROM inventory
     WHERE product_id = p_product_id
     FOR UPDATE;

    -- Check existence
    IF v_old_qty IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Inventory record not found';
    END IF;

    -- Verify stock availability
    IF v_old_qty < p_quantity THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient stock';
    END IF;

    -- Update inventory
    UPDATE inventory
       SET quantity_on_hand = quantity_on_hand - p_quantity
     WHERE product_id = p_product_id;

    SET v_new_qty = v_old_qty - p_quantity;

    -- Audit the change
    INSERT INTO inventory_audit
        (product_id, old_quantity, new_quantity, changed_by, change_reason)
    VALUES
        (p_product_id, v_old_qty, v_new_qty, CURRENT_USER(), p_reason);

    COMMIT;

    -- Return execution summary
    SELECT p_product_id AS product_id,
           v_old_qty AS old_quantity,
           v_new_qty AS new_quantity,
           'RESERVED' AS result;
END$$

DELIMITER ;

-- ----------------------------------------------------------------------------
-- Verification and Test Calls
-- ----------------------------------------------------------------------------

-- Test 1: Successful reservation of 2 units for product 3 (Wireless Mouse)
CALL sp_reserve_inventory(3, 2, 'Training reservation');

-- Verify updated stock and audit entry:
SELECT product_id, quantity_on_hand FROM inventory WHERE product_id = 3;
SELECT * FROM inventory_audit ORDER BY audit_id DESC LIMIT 3;

-- Test 2: Rollback verification (Expected Error: Insufficient stock)
-- CALL sp_reserve_inventory(7, 99, 'Test insufficient stock');

