#!/usr/bin/env python3
"""
Assignment 9: Synthetic Data Generator & Query Plan Benchmark Tool
Generates 100,000 synthetic order items with realistic pricing, orders,
and product distributions to evaluate index selectivity and execution plans.
"""

import random
import os
import time

def generate_benchmark_sql(output_path=None, total_records=100_000):
    if output_path is None:
        repository_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        output_path = os.path.join(
            repository_root, "database", "benchmarks", "benchmark_100k_data.sql"
        )

    print(f"Generating {total_records:,} synthetic order items into '{output_path}'...")
    start_time = time.time()

    # Product IDs 1 to 7 with approximate retail unit prices
    product_prices = {
        1: 65000.00,  # Laptop
        2: 15000.00,  # Monitor
        3: 1200.00,   # Mouse
        4: 1800.00,   # Keyboard
        5: 350.00,    # Notebook
        6: 850.00,    # Organizer
        7: 2400.00    # USB Hub
    }
    product_keys = list(product_prices.keys())

    # We assume 25,000 orders to support 100,000 items (avg 4 items/order)
    total_orders = 25_000

    batch_size = 5000

    with open(output_path, "w", encoding="utf-8") as f:
        f.write("-- ============================================================\n")
        f.write("-- BENCHMARK DATASET: 100,000 ORDER ITEMS\n")
        f.write("-- ============================================================\n")
        f.write("USE retail_management_db;\n\n")
        f.write("SET FOREIGN_KEY_CHECKS = 0;\n")
        f.write("SET UNIQUE_CHECKS = 0;\n")
        f.write("SET AUTOCOMMIT = 0;\n\n")

        # Generate orders in batches
        f.write("-- 1. Generate Supporting Orders\n")
        for order_id in range(100, total_orders + 100):
            customer_id = random.randint(1, 5)
            # Spread order dates across 2024 to 2026
            day = random.randint(1, 28)
            month = random.randint(1, 12)
            year = random.choice([2024, 2025, 2026])
            status = random.choice(['PENDING', 'CONFIRMED', 'SHIPPED', 'DELIVERED', 'CANCELLED'])
            order_date = f"{year}-{month:02d}-{day:02d} {random.randint(8,21):02d}:{random.randint(0,59):02d}:00"
            
            if (order_id - 100) % batch_size == 0:
                if order_id > 100:
                    f.write(";\nCOMMIT;\n")
                f.write("INSERT INTO orders (order_id, customer_id, order_date, status) VALUES\n")
            else:
                f.write(",\n")
            f.write(f"({order_id}, {customer_id}, '{order_date}', '{status}')")

        f.write(";\nCOMMIT;\n\n")

        # Generate 100,000 order items
        f.write("-- 2. Generate 100,000 Order Items\n")
        order_item_id = 100
        for i in range(total_records):
            order_id = random.randint(100, total_orders + 99)
            prod_id = random.choice(product_keys)
            qty = random.randint(1, 8)
            price = product_prices[prod_id]

            if i % batch_size == 0:
                if i > 0:
                    f.write(";\nCOMMIT;\n")
                f.write("INSERT INTO order_items (order_item_id, order_id, product_id, quantity, unit_price) VALUES\n")
            else:
                f.write(",\n")
            f.write(f"({order_item_id}, {order_id}, {prod_id}, {qty}, {price:.2f})")
            order_item_id += 1

        f.write(";\nCOMMIT;\n\n")
        f.write("SET FOREIGN_KEY_CHECKS = 1;\n")
        f.write("SET UNIQUE_CHECKS = 1;\n")
        f.write("COMMIT;\n\n")

        # Benchmark Queries
        f.write("-- ============================================================\n")
        f.write("-- BENCHMARK QUERIES & EXECUTION PLAN ANALYSIS\n")
        f.write("-- ============================================================\n")
        f.write("-- Query 1: Aggregation across 100,000 items by product\n")
        f.write("EXPLAIN ANALYZE\n")
        f.write("SELECT product_id, SUM(quantity) AS units, SUM(quantity * unit_price) AS revenue\n")
        f.write("FROM order_items\n")
        f.write("GROUP BY product_id;\n\n")

        f.write("-- Query 2: Selective filter on order line items\n")
        f.write("EXPLAIN ANALYZE\n")
        f.write("SELECT * FROM order_items WHERE product_id = 1 AND unit_price > 50000;\n\n")

        f.write("-- Query 3: Multi-table Join with Customer & Orders at scale\n")
        f.write("EXPLAIN ANALYZE\n")
        f.write("SELECT c.city, SUM(oi.quantity * oi.unit_price) AS city_gross\n")
        f.write("FROM customers c\n")
        f.write("JOIN orders o ON o.customer_id = c.customer_id\n")
        f.write("JOIN order_items oi ON oi.order_id = o.order_id\n")
        f.write("WHERE o.status = 'DELIVERED'\n")
        f.write("GROUP BY c.city;\n")

    elapsed = time.time() - start_time
    file_size_mb = os.path.getsize(output_path) / (1024 * 1024)
    print(f"Generated {output_path} ({file_size_mb:.2f} MB) in {elapsed:.2f} seconds.")

if __name__ == "__main__":
    generate_benchmark_sql()
