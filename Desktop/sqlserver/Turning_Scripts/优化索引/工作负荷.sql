USE AdventureWorks2012
SELECT *
FROM Production.Product
ORDER BY Name ASC;
go
SELECT Name, ProductNumber, ListPrice AS Price
FROM Production.Product 
WHERE ProductLine = 'R' AND DaysToManufacture < 4
ORDER BY Name ASC;
go
SELECT p.Name AS ProductName, 
NonDiscountSales = (OrderQty * UnitPrice),
Discounts = ((OrderQty * UnitPrice) * UnitPriceDiscount)
FROM Production.Product p 
    INNER JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID 
ORDER BY ProductName DESC;
go
SELECT 'Total income is', ((OrderQty * UnitPrice) * (1.0 - UnitPriceDiscount)), ' for ',p.Name AS ProductName 
FROM Production.Product p 
    INNER JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID 
ORDER BY ProductName ASC;
go