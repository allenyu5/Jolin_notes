--1、执行计划重用
USE Northwind;
GO
IF OBJECT_ID('dbo.usp_GetOrders') IS NOT NULL
  DROP PROC dbo.usp_GetOrders;
GO

CREATE PROC dbo.usp_GetOrders
  @odate AS DATETIME
AS

SELECT OrderID, CustomerID, EmployeeID, OrderDate
FROM dbo.Orders
WHERE OrderDate >= @odate;
GO

SET STATISTICS IO ON;

EXEC dbo.usp_GetOrders '19980506';   --高选择性

EXEC dbo.usp_GetOrders '19960101';   --低选择性


SET STATISTICS IO OFF;

SELECT cacheobjtype, objtype, usecounts, sql
FROM sys.syscacheobjects
WHERE sql NOT LIKE '%cache%'
  AND sql LIKE '%usp_GetOrders%';

ALTER PROC dbo.usp_GetOrders
  @odate AS DATETIME
WITH RECOMPILE
AS

SELECT OrderID, CustomerID, EmployeeID, OrderDate
FROM dbo.Orders
WHERE OrderDate >= @odate;
GO
 
EXEC dbo.usp_GetOrders '19980506';

SELECT * FROM sys.syscacheobjects
WHERE sql NOT LIKE '%cache%'
  AND sql LIKE '%usp_GetOrders%';

--2、SQL Server 2005 以后的新功能
ALTER PROC dbo.usp_GetOrders
  @odate AS DATETIME
AS

SELECT OrderID, CustomerID, EmployeeID, OrderDate
FROM dbo.Orders
WHERE OrderDate >= @odate
OPTION(RECOMPILE);
GO

EXEC dbo.usp_GetOrders '19980506';

EXEC dbo.usp_GetOrders '19960101';

--3、重编译
--不同SET选项
IF OBJECT_ID('dbo.usp_CustCities') IS NOT NULL
  DROP PROC dbo.usp_CustCities;
GO

CREATE PROC dbo.usp_CustCities
AS

SELECT CustomerID, Country, Region, City,
  Country + '.' + Region + '.' + City AS CRC
FROM dbo.Customers
ORDER BY Country, Region, City;
GO

EXEC dbo.usp_CustCities;


SET CONCAT_NULL_YIELDS_NULL OFF;

EXEC dbo.usp_CustCities;

SELECT cacheobjtype, objtype, usecounts, setopts, sql
FROM sys.syscacheobjects
WHERE sql NOT LIKE '%cache%'
  AND sql LIKE '%usp_CustCities%';

SET CONCAT_NULL_YIELDS_NULL ON;

--使用临时表
CREATE PROC spTest @CustID NVARCHAR(5)
AS
SELECT * FROM Northwind.dbo.Customers
WHERE CustomerID LIKE @CustID
GO

CREATE PROC spTest2 @CustID NVARCHAR(5)
AS
SELECT * INTO #tmp FROM Northwind.dbo.Customers
WHERE CustomerID LIKE @CustID
SELECT * FROM #tmp
GO
DBCC FREEPROCCACHE
GO
exec spTest 'a%'
exec spTest 'b%'
exec spTest2 'a%'
exec spTest2 'b%'
GO
EXEC myScript.spListRecompile




4、参数嗅探问题
INSERT INTO dbo.Orders(OrderDate, CustomerID, EmployeeID)
  VALUES(GETDATE(), N'ALFKI', 1);

ALTER PROC dbo.usp_GetOrders
  @d AS INT = 0
AS

DECLARE @odate AS DATETIME;
SET @odate = DATEADD(day, -@d, CONVERT(VARCHAR(8), GETDATE(), 112));

SELECT OrderID, CustomerID, EmployeeID, OrderDate
FROM dbo.Orders
WHERE OrderDate >= @odate;
GO

EXEC dbo.usp_GetOrders;

ALTER PROC dbo.usp_GetOrders
  @d AS INT = 0
AS

SELECT OrderID, CustomerID, EmployeeID, OrderDate
FROM dbo.Orders
WHERE OrderDate >= DATEADD(day, -@d, CONVERT(VARCHAR(8), GETDATE(), 112));
GO

EXEC dbo.usp_GetOrders;

IF OBJECT_ID('dbo.usp_GetOrdersQuery') IS NOT NULL
  DROP PROC dbo.usp_GetOrdersQuery;
GO

CREATE PROC dbo.usp_GetOrdersQuery
  @odate AS DATETIME
AS

SELECT OrderID, CustomerID, EmployeeID, OrderDate
FROM dbo.Orders
WHERE OrderDate >= @odate;
GO

ALTER PROC dbo.usp_GetOrders
  @d AS INT = 0
AS

DECLARE @odate AS DATETIME;
SET @odate = DATEADD(day, -@d, CONVERT(VARCHAR(8), GETDATE(), 112));

EXEC dbo.usp_GetOrdersQuery @odate;
GO

EXEC dbo.usp_GetOrders;

--5、优化提示
ALTER PROC dbo.usp_GetOrders
  @d AS INT = 0
AS

DECLARE @odate AS DATETIME;
SET @odate = DATEADD(day, -@d, CONVERT(VARCHAR(8), GETDATE(), 112));

SELECT OrderID, CustomerID, EmployeeID, OrderDate
FROM dbo.Orders
WHERE OrderDate >= @odate
OPTION(OPTIMIZE FOR(@odate = '99991231'));
GO

EXEC dbo.usp_GetOrders;

DELETE FROM dbo.Orders WHERE OrderID > 11077;
GO
IF OBJECT_ID('dbo.usp_GetOrders') IS NOT NULL
  DROP PROC dbo.usp_GetOrders;
GO
IF OBJECT_ID('dbo.usp_CustCities') IS NOT NULL
  DROP PROC dbo.usp_CustCities;
GO
IF OBJECT_ID('dbo.usp_GetOrdersQuery') IS NOT NULL
  DROP PROC dbo.usp_GetOrdersQuery;
GO






