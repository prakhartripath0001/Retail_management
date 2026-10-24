# Concurrency Testing Protocol: Stock Reservation (Two Sessions)

## Overview
This test validates InnoDB row-level locking behavior (`SELECT ... FOR UPDATE`), transaction isolation, and inventory race-condition prevention across concurrent client sessions.

---

## Test Environment Setup
Open two independent terminal windows or MySQL Workbench / DBeaver query tabs:
- **Session A** (User / Checkout Thread 1)
- **Session B** (User / Checkout Thread 2)

Both sessions will target **Product ID 3** (`Wireless Mouse`), currently having stock = 50.

---

## Step-by-Step Execution Sequence

### Step 1: Check Baseline Inventory
Run in **Session A**:
```sql
USE retail_management_db;
SELECT product_id, quantity_on_hand FROM inventory WHERE product_id = 3;
-- Stock shows: 50
```

---

### Step 2: Session A Begins Transaction & Acquires Lock
Run in **Session A**:
```sql
USE retail_management_db;
START TRANSACTION;

-- Session A locks the inventory row exclusively
SELECT quantity_on_hand 
FROM inventory 
WHERE product_id = 3 
FOR UPDATE;

-- DO NOT COMMIT YET. The exclusive row lock is active.
```

---

### Step 3: Session B Attempts Simultaneous Reservation
Run in **Session B** (while Session A is still open):
```sql
USE retail_management_db;

-- Attempt to call reservation procedure for 30 units:
CALL sp_reserve_inventory(3, 30, 'Session B reservation');
```

#### Observed Behavior:
- **Session B immediately blocks** and enters a lock-wait state.
- Session B pauses waiting for Session A's exclusive lock to be released.
- You can inspect the lock contention from a DBA connection:
```sql
SELECT * FROM performance_schema.data_locks;
SELECT * FROM performance_schema.data_lock_waits;
```

---

### Step 4: Session A Completes Reservation & Commits
Run in **Session A**:
```sql
-- Session A reserves 25 units
UPDATE inventory
SET quantity_on_hand = quantity_on_hand - 25
WHERE product_id = 3;

INSERT INTO inventory_audit (product_id, old_quantity, new_quantity, changed_by, change_reason)
VALUES (3, 50, 25, CURRENT_USER(), 'Session A concurrent reservation');

-- Session A releases the lock by committing
COMMIT;
```

---

### Step 5: Observe Session B Resolution
As soon as Session A commits:
1. Session B unblocks immediately.
2. In Session B, `sp_reserve_inventory(3, 30, ...)` reads the *new* stock (`25`).
3. Since requested `30 > 25`, Session B triggers an exception:
   ```
   Error Code 1644 (45000): Insufficient stock
   ```
4. Session B automatically rolls back, leaving the stock intact at `25`.

---

## Key Takeaways
1. **Pessimistic Locking (`FOR UPDATE`)** prevents overselling or race conditions.
2. **ACID Isolation** guarantees that Session B cannot read stale inventory during Session A's update.
3. If Session A holds the lock longer than `innodb_lock_wait_timeout` (default 50 seconds), Session B safely times out with `Error 1205: Lock wait timeout exceeded`.

