USE retail_management_db;

-- ============================================================================
-- LAB 15: SECURITY / LEAST PRIVILEGE (ADMINISTRATOR TASK)
-- THEORY:
-- Principle of Least Privilege: Each user and service account must possess only
-- the minimum set of permissions necessary to execute its role.
-- Never use the root/superuser account for production application connections.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Read-Only Reporting Role / User
-- Restricted exclusively to designated reporting views (no direct raw table access).
-- ----------------------------------------------------------------------------
-- CREATE USER IF NOT EXISTS 'retail_report'@'localhost' IDENTIFIED BY 'SecureReportPass!2026';

-- GRANT SELECT ON retail_management_db.vw_order_sales TO 'retail_report'@'localhost';
-- GRANT SELECT ON retail_management_db.vw_product_inventory TO 'retail_report'@'localhost';
-- GRANT SELECT ON retail_management_db.vw_customer_order_summary TO 'retail_report'@'localhost';

-- ----------------------------------------------------------------------------
-- 2. Application Service Account
-- Requires DML (Data Manipulation Language) and EXECUTE rights on stored procedures.
-- No DDL (DROP, ALTER) rights permitted.
-- ----------------------------------------------------------------------------
-- CREATE USER IF NOT EXISTS 'retail_app'@'localhost' IDENTIFIED BY 'SecureAppPass!2026';

-- GRANT SELECT, INSERT, UPDATE, DELETE ON retail_management_db.customers TO 'retail_app'@'localhost';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON retail_management_db.orders TO 'retail_app'@'localhost';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON retail_management_db.order_items TO 'retail_app'@'localhost';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON retail_management_db.inventory TO 'retail_app'@'localhost';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON retail_management_db.payments TO 'retail_app'@'localhost';
-- GRANT SELECT ON retail_management_db.products TO 'retail_app'@'localhost';
-- GRANT SELECT ON retail_management_db.categories TO 'retail_app'@'localhost';
-- GRANT SELECT ON retail_management_db.suppliers TO 'retail_app'@'localhost';
-- GRANT INSERT, SELECT ON retail_management_db.inventory_audit TO 'retail_app'@'localhost';
-- GRANT EXECUTE ON PROCEDURE retail_management_db.sp_reserve_inventory TO 'retail_app'@'localhost';
-- GRANT EXECUTE ON PROCEDURE retail_management_db.sp_get_customer_orders TO 'retail_app'@'localhost';

-- FLUSH PRIVILEGES;

-- ----------------------------------------------------------------------------
-- 3. Verification Commands
-- ----------------------------------------------------------------------------
-- SHOW GRANTS FOR 'retail_report'@'localhost';
-- SHOW GRANTS FOR 'retail_app'@'localhost';

