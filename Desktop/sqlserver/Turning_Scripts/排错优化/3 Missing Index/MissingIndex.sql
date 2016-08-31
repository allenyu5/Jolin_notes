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

--查询各种动态管理视图，以分析所需的索引
select * from sys.dm_db_missing_index_groups
select * from sys.dm_db_missing_index_group_stats
select * from sys.dm_db_missing_index_details

SELECT mig.*, statement AS table_name,column_id, column_name, column_usage
FROM sys.dm_db_missing_index_details AS mid
CROSS APPLY sys.dm_db_missing_index_columns (mid.index_handle)
INNER JOIN sys.dm_db_missing_index_groups AS mig ON mig.index_handle = mid.index_handle
ORDER BY mig.index_group_handle, mig.index_handle, column_id

select priority = s.avg_total_user_cost * s.user_seeks * s.avg_user_impact, * 
from sys.dm_db_missing_index_group_stats s
	join sys.dm_db_missing_index_groups g on s.group_handle = g.index_group_handle
	join sys.dm_db_missing_index_details d on g.index_handle = d.index_handle
ORDER BY priority desc


--创建索引
CREATE NONCLUSTERED INDEX [idx_SalesOrderDetail] ON [Sales].[SalesOrderDetail]
([ProductID] ASC)
INCLUDE ( 	[OrderQty],[UnitPrice],[UnitPriceDiscount]) 


--使用系统监视器监视CPU