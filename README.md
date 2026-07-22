# Project 3 — SQL Data Analysis (DecodeLabs)

**Track:** Data Analytics — Industrial Training Kit | **Batch:** 2026
**Author:** Fatima khalid
**Tool used:** MySQL Workbench 8.0

## About this project

This is my submission for **Project 3** of the DecodeLabs Data Analytics track. The brief for this milestone was simple but deliberate: stop just *viewing* data and start *querying for truth*. Instead of skimming a spreadsheet, the goal was to load a raw sales dataset into MySQL and use pure SQL — `SELECT`, `WHERE`, `ORDER BY`, `GROUP BY`, and aggregate functions — to pull real, actionable insights out of it.

I've included:
- 📄 [`Analysis.sql`](./Analysis.sql) — every query I wrote, in order, with comments
- 🖼️ [`/screenshots`](./screenshots) — proof that each query was actually run in MySQL Workbench, with the live result grid visible
- This README, which walks through what each query does and what it revealed about the data

## The dataset

I imported a `sales_data.csv` file into MySQL and renamed it to `SalesData` for convenience. It has **1200 rows** and tracks e-commerce orders with the following columns:

| Column | What it holds |
|---|---|
| `OrderID` | Unique order ID (e.g. `ORD200000`) |
| `Date` | Order date, stored as text in `%m/%d/%Y` format |
| `CustomerID` | Unique customer ID |
| `Product` | Item purchased — Monitor, Phone, Tablet, Chair, Printer, Laptop, Desk |
| `Quantity` | Units ordered |
| `UnitPrice` | Price per unit |
| `TotalPrice` | Total value of the order |
| `ShippingAddress` | Delivery address |
| `PaymentMethod` | Credit Card, Debit Card, Cash, Online, Gift Card |
| `OrderStatus` | Shipped, Cancelled, Returned, Pending, Delivered |
| `TrackingNumber` | Shipment tracking number |
| `ReferralSource` | How the customer found the store — Instagram, Email, Google, Facebook, Referral |

## Getting the table ready

Before I could query anything, I had to bring the CSV in and rename it so the table name wasn't the awkward `sales_data.csv`:

```sql
SELECT * FROM `sales_data.csv` LIMIT 10;
RENAME TABLE `sales_data.csv` TO SalesData;
SELECT * FROM SalesData LIMIT 10;
```

📸 **Screenshot:** [`03_preview_salesdata.png`](./screenshots/03_preview_salesdata.png)
![Preview SalesData](./screenshots/03_preview_salesdata.png)

You can actually see in the Output panel of this screenshot that my first two attempts at `sales_data.csv` failed (`Error Code: 1146 — Table doesn't exist`) before the rename took effect — leaving that in on purpose, it's part of the real process.

---

## The queries

### 1. Basic SELECT — pick only the columns you need
```sql
SELECT OrderID, Product, Quantity, UnitPrice, TotalPrice
FROM SalesData;
```
Just narrowing down to the columns that actually matter for analysis instead of pulling everything.

![Select key columns](./screenshots/04_select_key_columns.png)

---

### 2. WHERE — filter rows

**Filter by a specific product:**
```sql
SELECT OrderID, Product, Quantity, TotalPrice
FROM SalesData
WHERE Product = 'Laptop';
```
**→ 173 Laptop orders.**

![Filter Laptop](./screenshots/05_filter_laptop.png)

**Filter high-value orders:**
```sql
SELECT OrderID, Product, TotalPrice
FROM SalesData
WHERE TotalPrice > 2000;
```
**→ 180 orders above $2,000.**

![Filter TotalPrice > 2000](./screenshots/06_filter_totalprice_gt_2000.png)

**Combine conditions with AND / IN:**
```sql
SELECT OrderID, Product, PaymentMethod, OrderStatus
FROM SalesData
WHERE PaymentMethod = 'Credit Card'
  AND OrderStatus IN ('Cancelled', 'Returned');
```
**→ 103 orders.** This one's interesting from a risk perspective — it isolates credit card orders that didn't go through cleanly.

![Credit Card Cancelled/Returned](./screenshots/07_filter_creditcard_cancelled_returned.png)

**Pattern matching with LIKE:**
```sql
SELECT OrderID, ShippingAddress
FROM SalesData
WHERE ShippingAddress LIKE '%Main St';
```
Pulls every order shipped to an address ending in "Main St" — useful for area-based checks.

![LIKE Main St](./screenshots/08_like_mainst.png)

---

### 3. Working with dates stored as text

Since `Date` is stored as a string (`%m/%d/%Y`), I had to convert it before I could filter or sort on it properly:

```sql
SELECT OrderID, Date, Product
FROM SalesData
WHERE STR_TO_DATE(Date, '%m/%d/%Y') BETWEEN '2024-01-01' AND '2024-12-31';
```
**→ 459 orders placed in 2024.**

![STR_TO_DATE range filter](./screenshots/09_str_to_date_range.png)

---

### 4. ORDER BY — sort the results

**Top 10 highest-value orders:**
```sql
SELECT OrderID, Product, TotalPrice
FROM SalesData
ORDER BY TotalPrice DESC
LIMIT 10;
```

| OrderID | Product | TotalPrice |
|---|---|---|
| ORD200789 | Tablet | 3456.40 |
| ORD201122 | Monitor | 3390.95 |
| ORD200632 | Laptop | 3390.80 |
| ORD200469 | Chair | 3384.90 |
| ORD200328 | Tablet | 3370.20 |

![Top 10 orders](./screenshots/10_top10_orders_by_totalprice.png)

**Sort chronologically (again using STR_TO_DATE, this time just to sort):**
```sql
SELECT OrderID, Date, Product
FROM SalesData
ORDER BY STR_TO_DATE(Date, '%m/%d/%Y') ASC;
```

![Order by date ascending](./screenshots/11_order_by_date_asc.png)

---

### 5. GROUP BY + aggregations — turning rows into insight

**How many orders per product?**
```sql
SELECT Product, COUNT(*) AS TotalOrders
FROM SalesData
GROUP BY Product
ORDER BY TotalOrders DESC;
```
| Product | TotalOrders |
|---|---|
| Printer | 181 |
| Tablet | 179 |
| Chair | 178 |
| Laptop | 173 |
| Desk | 170 |

![Group by product, count](./screenshots/12_groupby_product_count.png)

**Which product actually makes the most money?**
```sql
SELECT Product, SUM(TotalPrice) AS TotalRevenue
FROM SalesData
GROUP BY Product
ORDER BY TotalRevenue DESC;
```
| Product | TotalRevenue |
|---|---|
| Chair | 195,620.11 |
| Printer | 195,612.61 |
| Laptop | 192,126.56 |
| Tablet | 186,568.95 |
| Monitor | 175,651.41 |

Worth noting: Printer has the *most orders* but Chair pulls in slightly more *revenue* — a good reminder that order volume and revenue don't always rank the same way.

![Group by product, revenue](./screenshots/13_groupby_product_revenue.png)

**Average order value by payment method:**
```sql
SELECT PaymentMethod, ROUND(AVG(TotalPrice), 2) AS AvgOrderValue
FROM SalesData
GROUP BY PaymentMethod
ORDER BY AvgOrderValue DESC;
```
| PaymentMethod | AvgOrderValue |
|---|---|
| Credit Card | 1127.55 |
| Gift Card | 1070.97 |
| Cash | 1056.04 |
| Online | 1017.22 |
| Debit Card | 1001.56 |

![Avg order value by payment method](./screenshots/14_avg_by_paymentmethod.png)

**A full breakdown by order status (count, revenue, and average, all in one query):**
```sql
SELECT
    OrderStatus,
    COUNT(*)                    AS NumOrders,
    SUM(TotalPrice)             AS TotalRevenue,
    ROUND(AVG(TotalPrice), 2)   AS AvgOrderValue
FROM SalesData
GROUP BY OrderStatus
ORDER BY TotalRevenue DESC;
```
| OrderStatus | NumOrders | TotalRevenue | AvgOrderValue |
|---|---|---|---|
| Cancelled | 250 | 276,396.21 | 1105.58 |
| Pending | 237 | 256,328.15 | 1081.55 |
| Shipped | 235 | 246,159.58 | 1047.49 |
| Returned | 247 | 243,277.70 | 984.93 |
| Delivered | 231 | 242,600.32 | 1050.22 |

This one stood out to me the most — **Cancelled orders bring in the highest total *and* average revenue.** That's a flag worth raising: it suggests higher-value orders are more likely to get cancelled, which is exactly the kind of pattern this kind of query is meant to surface.

![Order status summary](./screenshots/15_orderstatus_summary.png)

**Quick data-quality check — are there any NULLs hiding in TotalPrice?**
```sql
SELECT COUNT(*) AS TotalRows,
       COUNT(TotalPrice) AS NonNullTotalPrice
FROM SalesData;
```
Both came back as **1200**, confirming the `TotalPrice` column is fully populated — no missing values skewing the SUM/AVG calculations above.

![NULL check](./screenshots/16_null_check_totalprice.png)

---

### 6. HAVING — filtering *after* grouping

**Only show products that cross $50,000 in revenue:**
```sql
SELECT Product, SUM(TotalPrice) AS TotalRevenue
FROM SalesData
GROUP BY Product
HAVING SUM(TotalPrice) > 50000
ORDER BY TotalRevenue DESC;
```
Turns out every single product clears this bar — all 7 categories generate well over $50K each, which says the product mix is fairly balanced overall.

![HAVING revenue > 50000](./screenshots/17_having_revenue_gt_50000.png)

**Which referral sources are actually driving meaningful volume (200+ orders)?**
```sql
SELECT ReferralSource, COUNT(*) AS NumOrders
FROM SalesData
GROUP BY ReferralSource
HAVING COUNT(*) > 200
ORDER BY NumOrders DESC;
```
| ReferralSource | NumOrders |
|---|---|
| Instagram | 259 |
| Email | 250 |
| Google | 241 |
| Facebook | 228 |
| Referral | 222 |

Instagram is the strongest channel here, ahead of Email and Google.

![HAVING referral source > 200](./screenshots/18_having_referralsource_gt_200.png)

---

## What I took away from this

- `STR_TO_DATE()` is essential the moment a date column is stored as plain text — you can't filter or sort it correctly otherwise.
- `WHERE` filters individual rows *before* grouping; `HAVING` filters the grouped results *after*. Mixing these up is one of the easiest mistakes to make.
- `COUNT(*)` counts every row including NULLs, but `SUM()` and `AVG()` silently skip NULLs — worth double-checking with a query like #16 above before trusting an average.
- The database doesn't execute a query top-to-bottom the way it's written — it resolves `FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY` internally, which is why an alias defined in `SELECT` can't be reused in `WHERE`.
- The most useful finding in this dataset was that **Cancelled orders have the highest revenue and average order value** of any status — a pattern worth flagging to the business.

## Repo structure

```
├── Analysis.sql          # all queries, in order, with section comments
├── README.md              # this file
└── screenshots/           # MySQL Workbench screenshots for every query above
```

---

📌 *Project 3 of the DecodeLabs Data Analytics Industrial Training Kit (Batch 2026).*
