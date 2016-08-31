/***********************************************************************
Author="Kenneth Wang"
Create Date="2008/6/23"
***********************************************************************/

USE AdventureWorks
GO

--1、创建一个存储过程
CREATE PROCEDURE Sales.GetSalesOrderByCountry (@Country_region nvarchar(60))
AS
BEGIN
    SELECT *
    FROM Sales.SalesOrderHeader AS h, Sales.Customer AS c, 
        Sales.SalesTerritory AS t
    WHERE h.CustomerID = c.CustomerID
        AND c.TerritoryID = t.TerritoryID
        AND CountryRegionCode = @Country_region
END;
GO

--2、测试存储过程执行计划
--能看到第二个包含'US'的语句将采用和第一个语句一样的执行计划
EXEC Sales.GetSalesOrderByCountry 'AU'
EXEC Sales.GetSalesOrderByCountry 'US'
--清空过程缓冲
DBCC FREEPROCCACHE
--能看到执行计划改变了，第二个语句也会改变它的执行计划先连接SalesOrderHeader和Customer
EXEC Sales.GetSalesOrderByCountry 'US'
EXEC Sales.GetSalesOrderByCountry 'AU'

--3、 创建一个计划指南
EXEC sp_create_plan_guide 
@name = N'Guide1',
@stmt = N'SELECT *FROM Sales.SalesOrderHeader AS h,
        Sales.Customer AS c,
        Sales.SalesTerritory AS t
        WHERE h.CustomerID = c.CustomerID 
            AND c.TerritoryID = t.TerritoryID
            AND CountryRegionCode = @Country_region',
@type = N'OBJECT',
@module_or_batch = N'Sales.GetSalesOrderByCountry',
@params = NULL,
@hints = N'OPTION (OPTIMIZE FOR (@Country_region = N''US''))'

--4、 重新运行存储过程，比较执行计划
EXEC Sales.GetSalesOrderByCountry 'AU'
EXEC Sales.GetSalesOrderByCountry 'US'

--5、清除环境
EXEC sp_control_plan_guide N'DROP', N'Guide1'
DBCC FREEPROCCACHE
