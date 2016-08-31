USE AdventureWorks
GO

SET STATISTICS IO ON
SET STATISTICS TIME ON

DBCC DROPCLEANBUFFERS
SELECT t.Name AS Territory, oh.OrderDate, oh.SalesOrderID, od.SalesOrderDetailID, 
	p.Name AS Product, od.OrderQty, od.UnitPrice, od.UnitPriceDiscount
FROM Sales.SalesOrderHeader oh INNER JOIN 
	Sales.SalesOrderDetail od ON oh.SalesOrderID = od.SalesOrderID INNER JOIN
	Sales.Customer c ON oh.CustomerID = c.CustomerID INNER JOIN
	Sales.SalesTerritory t ON oh.TerritoryID = t.TerritoryID INNER JOIN
	Production.Product p ON od.ProductID = p.ProductID
WHERE t.Name = 'Southeast'

DBCC DROPCLEANBUFFERS
SELECT t.Name AS Territory, oh.OrderDate, oh.SalesOrderID, od.SalesOrderDetailID, 
	p.Name AS Product, od.OrderQty, od.UnitPrice, od.UnitPriceDiscount
FROM Sales.SalesOrderHeader oh INNER LOOP JOIN 
	Sales.Customer c ON oh.CustomerID = c.CustomerID INNER LOOP JOIN
	Sales.SalesTerritory t ON oh.TerritoryID = t.TerritoryID INNER LOOP JOIN
	Sales.SalesOrderDetail od ON oh.SalesOrderID = od.SalesOrderID INNER JOIN
	Production.Product p ON od.ProductID = p.ProductID
WHERE t.Name = 'Southeast'

DBCC DROPCLEANBUFFERS
SELECT t.Name AS Territory, oh.OrderDate, oh.SalesOrderID, od.SalesOrderDetailID, 
	p.Name AS Product, od.OrderQty, od.UnitPrice, od.UnitPriceDiscount
FROM Sales.SalesOrderHeader oh INNER MERGE JOIN 
	Sales.SalesOrderDetail od ON oh.SalesOrderID = od.SalesOrderID INNER LOOP JOIN
	Sales.SalesTerritory t ON oh.TerritoryID = t.TerritoryID INNER HASH JOIN
	Production.Product p ON od.ProductID = p.ProductID
WHERE t.Name = 'Southeast'
