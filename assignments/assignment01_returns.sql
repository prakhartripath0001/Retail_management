USE retail_management_db;

-- ============================================================================
-- STUDENT ASSIGNMENT 1: RETURNS TABLE & NET SALES REPORT
-- Objective: Track product returns and compute Net Sales = (Gross Sales - Returns)
-- ============================================================================

-- 1. Create Returns Table
CREATE TABLE IF NOT EXISTS returns (
    return_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_item_id BIGINT UNSIGNED NOT NULL,
    quantity INT UNSIGNED NOT NULL,
    refund_amount DECIMAL(12,2) NOT NULL,
    return_reason VARCHAR(255) NOT NULL,
    return_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM('REQUESTED', 'APPROVED', 'PROCESSED', 'REJECTED') NOT NULL DEFAULT 'PROCESSED',
    CONSTRAINT chk_return_qty CHECK (quantity > 0),
    CONSTRAINT chk_refund_amount CHECK (refund_amount >= 0),
    CONSTRAINT fk_return_order_item FOREIGN KEY (order_item_id)
        REFERENCES order_items(order_item_id)
        ON UPDATE CASCADE,
    INDEX idx_returns_item (order_item_id)
) ENGINE=InnoDB;

-- 2. Seed Sample Return Data
INSERT INTO returns (order_item_id, quantity, refund_amount, return_reason, status)
VALUES
(1, 1, 65000.00, 'Defective screen on delivery', 'PROCESSED'),
(4, 1, 350.00, 'Ordered duplicate pack by mistake', 'PROCESSED')
ON DUPLICATE KEY UPDATE return_id = return_id;

-- 3. Net Sales Reporting Query
-- Computes Gross Revenue, Refunded Amount, and Net Revenue per Product
WITH gross_product_sales AS (
    SELECT
        p.product_id,
        p.sku,
        p.product_name,
        COALESCE(SUM(oi.quantity), 0) AS total_units_sold,
        COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS gross_sales
    FROM products AS p
    LEFT JOIN order_items AS oi ON oi.product_id = p.product_id
    LEFT JOIN orders AS o ON o.order_id = oi.order_id
        AND o.status IN ('CONFIRMED', 'SHIPPED', 'DELIVERED')
    GROUP BY p.product_id, p.sku, p.product_name
),
product_returns AS (
    SELECT
        oi.product_id,
        COALESCE(SUM(r.quantity), 0) AS units_returned,
        COALESCE(SUM(r.refund_amount), 0) AS total_refunded
    FROM returns AS r
    JOIN order_items AS oi ON oi.order_item_id = r.order_item_id
    WHERE r.status = 'PROCESSED'
    GROUP BY oi.product_id
)
SELECT
    gps.sku,
    gps.product_name,
    gps.total_units_sold,
    COALESCE(pr.units_returned, 0) AS units_returned,
    (gps.total_units_sold - COALESCE(pr.units_returned, 0)) AS net_units_sold,
    gps.gross_sales,
    COALESCE(pr.total_refunded, 0.00) AS total_refunded,
    (gps.gross_sales - COALESCE(pr.total_refunded, 0.00)) AS net_sales
FROM gross_product_sales AS gps
LEFT JOIN product_returns AS pr ON pr.product_id = gps.product_id
ORDER BY net_sales DESC;

