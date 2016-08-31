USE AdventureWorks
GO
SELECT p.Name AS ProductName, 
NonDiscountSales = (OrderQty * UnitPrice),
Discounts = ((OrderQty * UnitPrice) * UnitPriceDiscount)
FROM Production.Product p 
    INNER JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID 
ORDER BY ProductName DESC;

SELECT 'Total income is', ((OrderQty * UnitPrice) * (1.0 - UnitPriceDiscount)), ' for ',p.Name AS ProductName 
FROM Production.Product p 
    INNER JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID 
ORDER BY ProductName ASC;