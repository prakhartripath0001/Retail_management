USE retail_management_db;

-- ============================================================================
-- STUDENT ASSIGNMENT 6: PRODUCT PRICE CHANGE AUDIT MECHANISM
-- Objective: Automatically track catalog price adjustments with timestamps and actors.
-- ============================================================================

-- 1. Create Price Audit Table
CREATE TABLE IF NOT EXISTS product_price_audit (
    audit_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT UNSIGNED NOT NULL,
    old_price DECIMAL(12,2) NOT NULL,
    new_price DECIMAL(12,2) NOT NULL,
    price_change DECIMAL(12,2) NOT NULL,
    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(288) NOT NULL,
    CONSTRAINT fk_price_audit_product FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    INDEX idx_price_audit_product (product_id, changed_at)
) ENGINE=InnoDB;

-- 2. Create Trigger to Log Price Modifications
DROP TRIGGER IF EXISTS trg_product_price_audit;

DELIMITER $$

CREATE TRIGGER trg_product_price_audit
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
    IF OLD.unit_price <> NEW.unit_price THEN
        INSERT INTO product_price_audit
            (product_id, old_price, new_price, price_change, changed_by)
        VALUES
            (NEW.product_id,
             OLD.unit_price,
             NEW.unit_price,
             NEW.unit_price - OLD.unit_price,
             CURRENT_USER());
    END IF;
END$$

DELIMITER ;

-- ----------------------------------------------------------------------------
-- Verification: Test Price Adjustment
-- ----------------------------------------------------------------------------
-- Update unit price for Product 1 (Laptop)
UPDATE products
SET unit_price = 68000.00
WHERE product_id = 1;

-- Check Audit Table
SELECT
    a.audit_id,
    p.sku,
    p.product_name,
    a.old_price,
    a.new_price,
    a.price_change,
    a.changed_at,
    a.changed_by
FROM product_price_audit AS a
JOIN products AS p ON p.product_id = a.product_id
ORDER BY a.audit_id DESC
LIMIT 5;

