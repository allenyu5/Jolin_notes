--清除计划缓存
dbcc freeproccache

--查询执行计划缓存
SELECT * FROM sys.dm_exec_cached_plans
SELECT * FROM sys.dm_os_memory_cache_counters
select cacheobjtype,objtype,usecounts,sql from sys.syscacheobjects
where sql not like '%cache%' and sql not like '%sys.%' and sql not like '%BatchID%'

--Ad-hoc查询
use AdventureWorks
go
SELECT * FROM Sales.SalesOrderHeader
WHERE CustomerID between 1 and 1000
go
SELECT * FROM Sales.SalesOrderHeader
WHERE CustomerID between 600 and 601

--自动参数化
select * from northwind.dbo.customers
where customerid='alfki'
go
select * from northwind.dbo.customers
where customerid='anatr'
go



--参数嗅探
USE AdventureWorks
GO
CREATE PROC GetCustOrders (@FirstCust int, @LastCust int) 
AS 
SELECT * FROM Sales.SalesOrderHeader
WHERE CustomerID between @FirstCust and @LastCust;


USE AdventureWorks
GO
DBCC FREEPROCCACHE
EXEC GetCustOrders 1,1000

USE AdventureWorks
GO
DBCC FREEPROCCACHE
EXEC GetCustOrders 600,610

USE AdventureWorks
GO
DBCC FREEPROCCACHE
EXEC GetCustOrders 1,1000
GO
EXEC GetCustOrders 600,610

--禁用参数嗅探
DROP PROC GetCustOrders 
GO

CREATE PROC GetCustOrders (@FirstCust int, @LastCust int) 
AS
DECLARE @FC int
DECLARE @LC int
SET @FC = @FirstCust
SET @LC = @LastCust
SELECT * FROM Sales.SalesOrderHeader
WHERE CustomerID BETWEEN @FC AND @LC

--方法
DROP PROC GetCustOrders 
GO

CREATE PROC GetCustOrders (@FirstCust int, @LastCust int) 
AS 
IF @LastCust - @FirstCust < 100
	EXEC GetCustOrdersNarrow @FirstCust, @LastCust
ELSE
	EXEC GetCustOrdersWide @FirstCust, @LastCust 
GO
-- Proc for Large Range of Customers
CREATE PROC GetCustOrdersWide (@FirstCust int, @LastCust int) 
AS 
SELECT * FROM Sales.SalesOrderHeader
WHERE CustomerID BETWEEN @FirstCust AND @LastCust  
GO
-- Proc for Small Range of Customers
CREATE PROC GetCustOrdersNarrow (@FirstCust int, @LastCust int) 
AS 
SELECT * FROM Sales.SalesOrderHeader
WHERE CustomerID BETWEEN @FirstCust AND @LastCust  
GO

