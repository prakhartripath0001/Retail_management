USE retail_management_db;

-- ============================================================================
-- LAB 11: TRIGGER FOR INVENTORY AUDIT
-- THEORY:
-- A trigger runs automatically in response to a table event (INSERT/UPDATE/DELETE).
-- It enforces auditing directly at the database engine level regardless of
-- which application or query initiated the modification.
--
-- ARCHITECTURAL NOTE:
-- In Lab 10, sp_reserve_inventory explicitly writes to inventory_audit.
-- If both this trigger and sp_reserve_inventory's INSERT run, duplicate audit
-- entries will be generated. This trigger is provided as an automated alternative.
-- ============================================================================

DROP TRIGGER IF EXISTS trg_inventory_after_update;

DELIMITER $$

CREATE TRIGGER trg_inventory_after_update
AFTER UPDATE ON inventory
FOR EACH ROW
BEGIN
    IF OLD.quantity_on_hand <> NEW.quantity_on_hand THEN
        INSERT INTO inventory_audit
            (product_id, old_quantity, new_quantity, changed_by, change_reason)
        VALUES
            (NEW.product_id,
             OLD.quantity_on_hand,
             NEW.quantity_on_hand,
             CURRENT_USER(),
             'Inventory quantity changed by UPDATE trigger');
    END IF;
END$$

DELIMITER ;

-- ----------------------------------------------------------------------------
-- Verification: Trigger Test
-- ----------------------------------------------------------------------------
-- Update quantity directly on product 4 (Keyboard)
UPDATE inventory
SET quantity_on_hand = quantity_on_hand + 5
WHERE product_id = 4;

-- Check if the trigger automatically recorded the change in inventory_audit:
SELECT *
FROM inventory_audit
WHERE product_id = 4
ORDER BY audit_id DESC
LIMIT 1;

