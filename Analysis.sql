                                                              DECODE LABS PROJECT 3
                                             ---------------SQL QUERIES FOR PROJECT 3--------------------
1. SELECT * FROM `sales_data.csv` LIMIT 10;

2. RENAME TABLE `sales_data.csv` TO SalesData;

3. SELECT * FROM SalesData LIMIT 10;

-------Basic SELECT — pick only the columns you need-------
4. SELECT OrderID, Product, Quantity, UnitPrice, TotalPrice
FROM SalesData;

-----------WHERE — filter rows-----------------------------
5. SELECT OrderID, Product, Quantity, TotalPrice
FROM SalesData
WHERE Product = 'Laptop';

6. SELECT OrderID, Product, TotalPrice
FROM SalesData
WHERE TotalPrice > 2000;

7. SELECT OrderID, Product, PaymentMethod, OrderStatus
FROM SalesData
WHERE PaymentMethod = 'Credit Card'
  AND OrderStatus IN ('Cancelled', 'Returned');

8. SELECT OrderID, ShippingAddress
FROM SalesData
WHERE ShippingAddress LIKE '%Main St';

-----------------STR_TO_DATE(Date, '%m/%d/%Y')-------------
9. SELECT OrderID, Date, Product
FROM SalesData
WHERE STR_TO_DATE(Date, '%m/%d/%Y') BETWEEN '2024-01-01' AND '2024-12-31';

---------------------ORDER BY — sort the result------------
10. SELECT OrderID, Product, TotalPrice
FROM SalesData
ORDER BY TotalPrice DESC
LIMIT 10;

11. SELECT OrderID, Date, Product
FROM SalesData
ORDER BY STR_TO_DATE(Date, '%m/%d/%Y') ASC;

------------GROUP BY + Aggregations — turn rows into insights-------
12. SELECT Product, COUNT(*) AS TotalOrders
FROM SalesData
GROUP BY Product
ORDER BY TotalOrders DESC;

13. SELECT Product, SUM(TotalPrice) AS TotalRevenue
FROM SalesData
GROUP BY Product
ORDER BY TotalRevenue DESC;

14. SELECT PaymentMethod, ROUND(AVG(TotalPrice), 2) AS AvgOrderValue
FROM SalesData
GROUP BY PaymentMethod
ORDER BY AvgOrderValue DESC;

15. SELECT
    OrderStatus,
    COUNT(*)                    AS NumOrders,
    SUM(TotalPrice)             AS TotalRevenue,
    ROUND(AVG(TotalPrice), 2)   AS AvgOrderValue
FROM SalesData
GROUP BY OrderStatus
ORDER BY TotalRevenue DESC;

16. SELECT COUNT(*) AS TotalRows,
       COUNT(TotalPrice) AS NonNullTotalPrice
FROM SalesData;

----------HAVING — filter after grouping---------------
17. SELECT Product, SUM(TotalPrice) AS TotalRevenue
FROM SalesData
GROUP BY Product
HAVING SUM(TotalPrice) > 50000
ORDER BY TotalRevenue DESC;

18. SELECT ReferralSource, COUNT(*) AS NumOrders
FROM SalesData
GROUP BY ReferralSource
HAVING COUNT(*) > 200
ORDER BY NumOrders DESC;
