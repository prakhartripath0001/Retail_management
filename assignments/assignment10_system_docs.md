# Retail Management System: Technical Architecture & System Documentation

## 1. Domain Overview
The Retail Management System is an enterprise MySQL transactional database (OLTP) supporting end-to-end retail operations: customer lifecycle, product catalogs, supplier procurement, 1:1 real-time inventory management, sales orders with immutable line items, payment gateway reconciliation, returns tracking, and full ACID audit logging.

---

## 2. Entity-Relationship Diagram (ERD)

```mermaid
erDiagram
    CUSTOMERS ||--o{ ORDERS : places
    CATEGORIES ||--o{ PRODUCTS : classifies
    SUPPLIERS ||--o{ PRODUCTS : supplies
    PRODUCTS ||--|| INVENTORY : maintains
    PRODUCTS ||--o{ ORDER_ITEMS : contains
    ORDERS ||--|{ ORDER_ITEMS : includes
    ORDERS ||--o{ PAYMENTS : settles
    ORDER_ITEMS ||--o{ RETURNS : refunds
    PRODUCTS ||--o{ INVENTORY_AUDIT : audits_stock
    PRODUCTS ||--o{ PRODUCT_PRICE_AUDIT : audits_price

    CUSTOMERS {
        bigint_unsigned customer_id PK
        varchar full_name
        varchar email UK
        varchar phone
        varchar city
        timestamp created_at
    }

    CATEGORIES {
        int_unsigned category_id PK
        varchar category_name UK
    }

    SUPPLIERS {
        int_unsigned supplier_id PK
        varchar supplier_name
        varchar contact_email
    }

    PRODUCTS {
        bigint_unsigned product_id PK
        varchar sku UK
        varchar product_name
        int_unsigned category_id FK
        int_unsigned supplier_id FK
        decimal unit_price
        boolean active
        timestamp created_at
    }

    INVENTORY {
        bigint_unsigned product_id PK,FK
        int_unsigned quantity_on_hand
        int_unsigned reorder_level
        timestamp updated_at
    }

    ORDERS {
        bigint_unsigned order_id PK
        bigint_unsigned customer_id FK
        datetime order_date
        enum status
        varchar idempotency_key UK
        timestamp created_at
    }

    ORDER_ITEMS {
        bigint_unsigned order_item_id PK
        bigint_unsigned order_id FK
        bigint_unsigned product_id FK
        int_unsigned quantity
        decimal unit_price
    }

    PAYMENTS {
        bigint_unsigned payment_id PK
        bigint_unsigned order_id FK
        decimal amount
        enum payment_method
        enum payment_status
        varchar transaction_reference UK
        datetime payment_date
    }

    RETURNS {
        bigint_unsigned return_id PK
        bigint_unsigned order_item_id FK
        int_unsigned quantity
        decimal refund_amount
        varchar return_reason
        datetime return_date
        enum status
    }

    INVENTORY_AUDIT {
        bigint_unsigned audit_id PK
        bigint_unsigned product_id FK
        int_unsigned old_quantity
        int_unsigned new_quantity
        timestamp changed_at
        varchar changed_by
        varchar change_reason
    }

    PRODUCT_PRICE_AUDIT {
        bigint_unsigned audit_id PK
        bigint_unsigned product_id FK
        decimal old_price
        decimal new_price
        decimal price_change
        timestamp changed_at
        varchar changed_by
    }
```

---

## 3. Core Architectural Assumptions
1. **Single-Currency Pricing**: All monetary values (`unit_price`, `amount`, `refund_amount`) are denominated in INR (₹) and stored as `DECIMAL(12, 2)` to eliminate floating-point arithmetic inaccuracies.
2. **Pessimistic Locking for Stock Reservation**: Inventory updates utilize `SELECT ... FOR UPDATE` inside `sp_reserve_inventory` to ensure zero overselling during flash-sale or high-concurrency periods.
3. **Price Freezing at Order Creation**: Line items in `order_items` record the historical `unit_price` at the moment of checkout, ensuring product catalog price updates do not retrospectively alter finalized sales.
4. **Idempotency Guarantee**: Orders accept a unique `idempotency_key` preventing duplicate order creation caused by network drops or double-clicking customers.
5. **Reconciliation Independence**: Payment reconciliation aggregates orders and payments in separate Common Table Expressions (CTEs) before joining, avoiding Cartesian multiplication anomalies.

---

## 4. Setup & Execution Instructions

### Prerequisites
- MySQL 8.0+ / MariaDB 10.5+
- Python 3.8+ (for synthetic benchmark generation)
- Bash shell (macOS / Linux)

### Execution Order
```bash
# 1. Initialize schema and database
mysql -u root -p < database/schema/create_db.sql

# 2. Seed initial master data
mysql -u root -p < database/seed/insert.sql

# 3. Verify initial row counts
mysql -u root -p < database/tests/verify_row_count.sql

# 4. Execute all core labs (Lab 3 to Lab 17)
mysql -u root -p < labs/lab03_filtering_sorting.sql
mysql -u root -p < labs/lab04_safe_update_delete.sql
mysql -u root -p < labs/lab05_joins.sql
mysql -u root -p < labs/lab06_aggregations.sql
mysql -u root -p < labs/lab07_subqueries_window.sql
mysql -u root -p < labs/lab08_views.sql
mysql -u root -p < labs/lab09_indexing_explain.sql
mysql -u root -p < labs/lab10_transactions_sp.sql
mysql -u root -p < labs/lab11_audit_trigger.sql
mysql -u root -p < labs/lab12_payment_reconciliation.sql
mysql -u root -p < labs/lab13_low_stock_report.sql
mysql -u root -p < labs/lab14_customer_orders_sp.sql
mysql -u root -p < labs/lab15_security_rbac.sql
mysql -u root -p < labs/lab17_acceptance_tests.sql

# 5. Execute Student Assignments
mysql -u root -p < assignments/assignment01_returns.sql
mysql -u root -p < assignments/assignment02_tax_discounts.sql
mysql -u root -p < assignments/assignment03_monthly_report.sql
mysql -u root -p < assignments/assignment04_lag_growth.sql
mysql -u root -p < assignments/assignment05_top_products_by_category.sql
mysql -u root -p < assignments/assignment06_price_audit.sql
mysql -u root -p < assignments/assignment07_idempotency.sql
```

---

## 5. Known Limitations & Production Enhancements
1. **Multi-Region & Distributed Writes**: Built on a single MySQL primary instance. High-volume global deployments would require read-replicas for view queries and horizontal sharding.
2. **External Gateway Two-Phase Commit**: MySQL ACID transactions cannot hold distributed locks on external Stripe/Razorpay payment APIs. Real-world payment flows require eventual consistency, webhooks, and dead-letter queues.
3. **Partitioning**: For multi-million row order histories, range partitioning by year/month on `orders(order_date)` is recommended.
