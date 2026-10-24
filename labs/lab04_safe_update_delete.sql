USE retail_management_db;

-- ============================================================================
-- LAB 4: UPDATE AND DELETE SAFELY
-- THEORY:
-- UPDATE changes existing rows; DELETE removes rows. Always preview the WHERE
-- condition with SELECT first. In production, use transactions and approvals
-- for destructive changes. Foreign keys may prevent unsafe deletes.
-- ============================================================================

-- Step 1: Preview the record before updating
SELECT product_id, sku, product_name, unit_price
FROM products
WHERE sku = 'ACC-002';

-- Step 2: Perform the UPDATE using an explicit transaction with rollback safety
START TRANSACTION;

UPDATE products
SET unit_price = 1900.00
WHERE sku = 'ACC-002';

-- Step 3: Verify the modification in the active transaction
SELECT product_id, sku, product_name, unit_price
FROM products
WHERE sku = 'ACC-002';

-- Commit changes if verified
COMMIT;

-- ----------------------------------------------------------------------------
-- Safe DELETE Pattern (Demonstration)
-- ----------------------------------------------------------------------------
-- 1. Preview rows targeted for deletion:
SELECT customer_id, full_name, email
FROM customers
WHERE customer_id = 99999;

-- 2. Execute deletion inside a transaction:
START TRANSACTION;

DELETE FROM customers
WHERE customer_id = 99999;

-- Check rows affected:
SELECT ROW_COUNT() AS deleted_rows;

-- Revert or Commit:
ROLLBACK;

