USE AdventureWorksdw
GO

DBCC DROPCLEANBUFFERS
SELECT SalesTerritoryKey, c.LastName, Count(*) AS OrderCount 
	FROM dbo.FactInternetSales s
	INNER JOIN dbo.DimCustomer c ON s.CustomerKey = s.CustomerKey
GROUP BY SalesTerritoryKey, c.LastName
HAVING SalesTerritoryKey = 3 AND LEFT(c.LastName, 1) = 'A'

DBCC DROPCLEANBUFFERS
SELECT SalesTerritoryKey, c.LastName, Count(*) AS OrderCount 
	FROM dbo.FactInternetSales s
	INNER JOIN dbo.DimCustomer c ON s.CustomerKey = s.CustomerKey
WHERE SalesTerritoryKey = 3 AND LEFT(c.LastName, 1) = 'A'
GROUP BY SalesTerritoryKey, c.LastName
