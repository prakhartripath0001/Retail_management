DROP DATABASE IF EXISTS retail_management_db;

CREATE DATABASE retail_management_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

-- Use utf8mb4 to support a wide range of Unicode characters, including emojis.
-- Use utf8mb4_0900_ai_ci for case-insensitive and accent-insensitive text comparisons.

USE retail_management_db;


-- ============================================================================
-- Table: customers
-- Purpose: Stores customer profile and account details.
-- Relationships: Referenced by `orders` to associate sales with a customer.
-- ============================================================================
CREATE TABLE customers (
    customer_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20) NULL,
    city VARCHAR(100),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;


-- ============================================================================
-- Table: categories
-- Purpose: Classifies products into distinct merchandise categories/departments.
-- Relationships: Referenced by `products` (one category has many products).
-- ============================================================================
CREATE TABLE categories (
    category_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;


-- ============================================================================
-- Table: suppliers
-- Purpose: Stores vendor and supplier directory information for product procurement.
-- Relationships: Referenced by `products` (a supplier provides one or more products).
-- ============================================================================
CREATE TABLE suppliers (
    supplier_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(150) NOT NULL,
    contact_email VARCHAR(255)
) ENGINE=InnoDB;


-- ============================================================================
-- Table: products
-- Purpose: Product catalog containing SKU, name, pricing, and active status.
-- Relationships:
--   - Belongs to a category (`category_id`)
--   - Optionally linked to a supplier (`supplier_id`)
--   - Referenced by `inventory`, `order_items`, and `inventory_audit`
-- ============================================================================
CREATE TABLE products (
    product_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    sku VARCHAR(50) NOT NULL UNIQUE,
    product_name VARCHAR(150) NOT NULL,
    category_id INT UNSIGNED NOT NULL,
    supplier_id INT UNSIGNED NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_product_price CHECK (unit_price >= 0),
    CONSTRAINT fk_product_category FOREIGN KEY (category_id)
        REFERENCES categories(category_id)
        ON UPDATE CASCADE,
    CONSTRAINT fk_product_supplier FOREIGN KEY (supplier_id)
        REFERENCES suppliers(supplier_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    INDEX idx_products_category (category_id),
    INDEX idx_products_supplier (supplier_id)
) ENGINE=InnoDB;


-- ============================================================================
-- Table: inventory
-- Purpose: Tracks current on-hand stock quantities and reorder thresholds (1:1 with products).
-- Relationships: Primary key `product_id` references `products.product_id` (cascades on delete).
-- ============================================================================
CREATE TABLE inventory (
    product_id BIGINT UNSIGNED PRIMARY KEY,
    quantity_on_hand INT UNSIGNED NOT NULL DEFAULT 0,
    reorder_level INT UNSIGNED NOT NULL DEFAULT 10,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_inventory_product FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;


-- ============================================================================
-- Table: orders
-- Purpose: Header records for customer sales orders, capturing status and order dates.
-- Relationships:
--   - Belongs to a customer (`customer_id`)
--   - Has many `order_items` and `payments`
-- ============================================================================
CREATE TABLE orders (
    order_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT UNSIGNED NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM('PENDING','CONFIRMED','SHIPPED','DELIVERED','CANCELLED')
        NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_order_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON UPDATE CASCADE,
    INDEX idx_orders_customer_date (customer_id, order_date),
    INDEX idx_orders_status_date (status, order_date)
) ENGINE=InnoDB;


-- ============================================================================
-- Table: order_items
-- Purpose: Stores individual line items for each order, recording purchased quantity
--          and the historical unit price at the time of purchase.
-- Relationships:
--   - Belongs to an order (`order_id`) (cascades on delete)
--   - References a product (`product_id`) (restricted from deletion if ordered)
-- ============================================================================
CREATE TABLE order_items (
    order_item_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    quantity INT UNSIGNED NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    CONSTRAINT chk_item_quantity CHECK (quantity > 0),
    CONSTRAINT chk_item_price CHECK (unit_price >= 0),
    CONSTRAINT fk_item_order FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_item_product FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON UPDATE CASCADE,
    CONSTRAINT uq_order_product UNIQUE (order_id, product_id),
    INDEX idx_order_items_product (product_id)
) ENGINE=InnoDB;


-- ============================================================================
-- Table: payments
-- Purpose: Records payment transactions for orders, tracking payment method, gateway
--          transaction reference, amount, and payment processing status.
-- Relationships: Belongs to an order (`order_id`).
-- ============================================================================
CREATE TABLE payments (
    payment_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT UNSIGNED NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    payment_method ENUM('CARD','UPI','BANK_TRANSFER','CASH') NOT NULL,
    payment_status ENUM('PENDING','SUCCESS','FAILED','REFUNDED')
        NOT NULL DEFAULT 'PENDING',
    transaction_reference VARCHAR(100) UNIQUE,
    payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_payment_amount CHECK (amount >= 0),
    CONSTRAINT fk_payment_order FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON UPDATE CASCADE,
    INDEX idx_payment_order_status (order_id, payment_status)
) ENGINE=InnoDB;


-- ============================================================================
-- Table: inventory_audit
-- Purpose: Maintains an immutable historical audit trail of stock adjustments, tracking
--          quantity changes, who initiated the change, timestamps, and reasons.
-- Relationships: References `products.product_id` (cascades on delete).
-- ============================================================================
CREATE TABLE inventory_audit (
    audit_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT UNSIGNED NOT NULL,
    old_quantity INT UNSIGNED NOT NULL,
    new_quantity INT UNSIGNED NOT NULL,
    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(288) NOT NULL,
    change_reason VARCHAR(255) NOT NULL,
    CONSTRAINT fk_audit_product FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    INDEX idx_inventory_audit_product_time (product_id, changed_at)
) ENGINE=InnoDB;

) ENGINE=InnoDB;