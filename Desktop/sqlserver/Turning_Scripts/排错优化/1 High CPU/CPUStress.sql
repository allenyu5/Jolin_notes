SELECT  AddressLine1, AddressLine2, City, StateProvinceID, PostalCode
FROM Person.Address 
WHERE City = 'Denver' and dbo.ufnGetAccountStatus('kim2') = 0

SELECT ProductID, Name, ProductNumber, Color, ListPrice 
FROM Production.Product P 
WHERE P.ListPrice < 100  and dbo.ufnGetAccountStatus('kim2') = 0

SELECT *, SalesOrderNumber, PurchaseOrderNumber, AccountNumber, OrderDate, ShipDate, TotalDue
FROM sales.SalesOrderHeader
WHERE SalesOrderNumber = '' and dbo.ufnGetAccountStatus('kim2') = 0

SELECT SalesOrderNumber, OrderQty, ProductID, UnitPrice, LineTotal
FROM sales.SalesOrderDetail d
INNER JOIN sales.SalesOrderHeader h on (d.SalesOrderID = h.SalesOrderID)
WHERE SalesOrderNumber = '' and dbo.ufnGetAccountStatus('kim2') = 0

SELECT  AddressLine1, AddressLine2, City, StateProvinceID, PostalCode
FROM Person.Address 
WHERE City = 'Austin' and dbo.ufnGetAccountStatus('jay1') = 1