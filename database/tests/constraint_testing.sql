USE retail_management_db;

-- ============================================================================
-- CONSTRAINT & INTEGRITY VALIDATION TEST SUITE
-- Tests Primary Keys, Foreign Keys, Unique Keys, and CHECK Constraints
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. POSITIVE TESTS (Valid Data Inserts)
-- ----------------------------------------------------------------------------
-- 1.1 Valid customer with unique email
INSERT INTO customers (full_name, email, city, phone)
VALUES ('Test Valid User', 'test.valid@example.com', 'Pune', '+91-9876543210');

-- 1.2 Valid product with positive price and valid category
INSERT INTO products (sku, product_name, category_id, supplier_id, unit_price, active)
VALUES ('TEST-001', 'Test Valid Item', 1, 1, 499.00, TRUE);

-- 1.3 Valid inventory entry
INSERT INTO inventory (product_id, quantity_on_hand, reorder_level)
VALUES (LAST_INSERT_ID(), 20, 5);

-- ----------------------------------------------------------------------------
-- 2. NEGATIVE TESTS (Expected Failures - Execute individually to inspect errors)
-- ----------------------------------------------------------------------------

-- 2.1 UNIQUE constraint on customers(email)
-- Expected error: Error Code 1062 (Duplicate entry 'aarav@example.com' for key 'customers.email')
-- INSERT INTO customers (full_name, email) VALUES ('Duplicate User', 'aarav@example.com');

-- 2.2 UNIQUE constraint on products(sku)
-- Expected error: Error Code 1062 (Duplicate entry 'ELEC-001' for key 'products.sku')
-- INSERT INTO products (sku, product_name, category_id, unit_price)
-- VALUES ('ELEC-001', 'Duplicate SKU Product', 1, 999.00);

-- 2.3 FOREIGN KEY constraint on products(category_id)
-- Expected error: Error Code 1452 (Cannot add or update a child row: foreign key constraint fails)
-- INSERT INTO products (sku, product_name, category_id, unit_price)
-- VALUES ('BAD-CAT-001', 'Invalid Category ID', 9999, 100.00);

-- 2.4 FOREIGN KEY constraint on products(supplier_id)
-- Expected error: Error Code 1452 (Cannot add or update a child row: foreign key constraint fails)
-- INSERT INTO products (sku, product_name, category_id, supplier_id, unit_price)
-- VALUES ('BAD-SUP-001', 'Invalid Supplier ID', 1, 9999, 100.00);

-- 2.5 CHECK constraint on products(unit_price >= 0)
-- Expected error: Error Code 3819 (Check constraint 'chk_product_price' is violated)
-- INSERT INTO products (sku, product_name, category_id, unit_price)
-- VALUES ('NEG-PRICE-001', 'Negative Price Product', 1, -100.00);

-- 2.6 CHECK constraint on order_items(quantity > 0)
-- Expected error: Error Code 3819 (Check constraint 'chk_item_quantity' is violated)
-- INSERT INTO order_items (order_id, product_id, quantity, unit_price)
-- VALUES (1, 1, 0, 100.00);

-- 2.7 CHECK constraint on order_items(unit_price >= 0)
-- Expected error: Error Code 3819 (Check constraint 'chk_item_price' is violated)
-- INSERT INTO order_items (order_id, product_id, quantity, unit_price)
-- VALUES (1, 1, 5, -50.00);

-- 2.8 UNIQUE composite constraint on order_items(order_id, product_id)
-- Expected error: Error Code 1062 (Duplicate entry '1-1' for key 'order_items.uq_order_product')
-- INSERT INTO order_items (order_id, product_id, quantity, unit_price)
-- VALUES (1, 1, 2, 65000.00);

-- 2.9 CHECK constraint on payments(amount >= 0)
-- Expected error: Error Code 3819 (Check constraint 'chk_payment_amount' is violated)
-- INSERT INTO payments (order_id, amount, payment_method, payment_status)
-- VALUES (1, -500.00, 'CARD', 'FAILED');

-- 2.10 NOT NULL constraint on orders(customer_id)
-- Expected error: Error Code 1048 (Column 'customer_id' cannot be null)
-- INSERT INTO orders (customer_id, status) VALUES (NULL, 'PENDING');
