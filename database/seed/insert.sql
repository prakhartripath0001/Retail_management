INSERT INTO customers (full_name, email, city, phone) VALUES
('Aarav Sharma', 'aarav@example.com', 'Bengaluru', '+91-9000000001'),
('Priya Mehta', 'priya@example.com', 'Mumbai', '+91-9000000002'),
('Rahul Verma', 'rahul@example.com', 'Delhi', '+91-9000000003'),
('Sara Khan', 'sara@example.com', 'Bengaluru', '+91-9000000004'),
('Kabir Das', 'kabir@example.com', 'Hyderabad', NULL);

INSERT INTO categories (category_name) VALUES
('Electronics'), ('Accessories'), ('Office Supplies');

INSERT INTO suppliers (supplier_name, contact_email) VALUES
('TechSource India', 'sales@techsource.example'),
('OfficeHub Supplies', 'sales@officehub.example');

INSERT INTO products
    (sku, product_name, category_id, supplier_id, unit_price, active)
VALUES
('ELEC-001', 'Laptop', 1, 1, 65000.00, TRUE),
('ELEC-002', 'Monitor', 1, 1, 15000.00, TRUE),
('ACC-001', 'Wireless Mouse', 2, 1, 1200.00, TRUE),
('ACC-002', 'Keyboard', 2, 1, 1800.00, TRUE),
('OFF-001', 'Notebook Pack', 3, 2, 350.00, TRUE),
('OFF-002', 'Desk Organizer', 3, 2, 850.00, TRUE),
('ACC-003', 'USB-C Hub', 2, 1, 2400.00, TRUE);

INSERT INTO inventory (product_id, quantity_on_hand, reorder_level) VALUES
(1, 25, 5), (2, 12, 5), (3, 50, 10), (4, 8, 10),
(5, 100, 20), (6, 7, 10), (7, 0, 5);

INSERT INTO orders (customer_id, order_date, status) VALUES
(1, '2026-10-01 10:00:00', 'DELIVERED'),
(2, '2026-10-02 14:30:00', 'DELIVERED'),
(1, '2026-10-05 11:15:00', 'CONFIRMED'),
(3, '2026-10-08 09:20:00', 'PENDING'),
(4, '2026-10-10 16:00:00', 'SHIPPED');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 65000.00),
(1, 3, 2, 1200.00),
(2, 2, 2, 15000.00),
(2, 5, 4, 350.00),
(3, 4, 1, 1800.00),
(4, 3, 3, 1200.00),
(5, 7, 1, 2400.00);

INSERT INTO payments
    (order_id, amount, payment_method, payment_status, transaction_reference)
VALUES
(1, 67400.00, 'UPI', 'SUCCESS', 'TXN-10001'),
(2, 31400.00, 'CARD', 'SUCCESS', 'TXN-10002'),
(3, 1800.00, 'UPI', 'PENDING', 'TXN-10003'),
(4, 0.00, 'CASH', 'PENDING', 'TXN-10004'),
(5, 2400.00, 'CARD', 'SUCCESS', 'TXN-10005');