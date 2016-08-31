--让设置符合建立 indexed view
--注意下面七个选项的设置（dbcc useroptions)
SET NUMERIC_ROUNDABORT OFF 
GO 
SET ANSI_PADDING,ANSI_WARNINGS,CONCAT_NULL_YIELDS_NULL,ARITHABORT,QUOTED_IDENTIFIER,ANSI_NULLS ON
GO

CREATE TABLE tmp(EmpID INT IDENTITY PRIMARY KEY,
Birthday DATETIME,Age AS DATEDIFF(yy,Birthday,GETDATE()))
GO

CREATE VIEW vwTest WITH SCHEMABINDING AS
SELECT EmpID,Birthday,Age 
FROM dbo.tmp
GO
--查看某个视图是否可以建立索引
SELECT OBJECTPROPERTY(OBJECT_ID('vwTest'),'IsIndexable')

DROP VIEW vwTest
DROP TABLE tmp




--===============================索引视图示例==========================================
SET STATISTICS IO ON
USE Northwind
-- 列出最高折扣款前五名的产品有以下两种方式：
-- 查询 1 
SELECT TOP 5 ProductID, SUM(UnitPrice*Quantity)- 
	SUM(UnitPrice*Quantity*(1.00-Discount)) 折扣款 
FROM [order details] 
GROUP BY ProductID 
ORDER BY 折扣款 DESC
 
--查询 2 
SELECT TOP 5 ProductID, SUM(UnitPrice*Quantity*Discount) 折扣款
FROM [order details] 
GROUP BY ProductID 
ORDER BY 折扣款 DESC

--以下的 indexed view 对 Q1 有用，但 Q2 则否
CREATE VIEW Vdiscount1 WITH SCHEMABINDING 
AS
SELECT SUM(UnitPrice*Quantity) SumPrice, 
	SUM(UnitPrice*Quantity*(1.00-Discount)) SumDiscountPrice, 
	COUNT_BIG(*) [Count], ProductID 
FROM dbo.[order details]
GROUP BY ProductID
GO 
CREATE UNIQUE CLUSTERED INDEX VDiscountInd ON Vdiscount1 (ProductID)

CREATE VIEW Vdiscount2 WITH SCHEMABINDING
AS
SELECT SUM(UnitPrice*Quantity) SumPrice, 
	SUM(UnitPrice*Quantity*(1.00-Discount)) SumDiscountPrice, 
	SUM(UnitPrice*Quantity*Discount) SumDiscoutPrice2, 
	COUNT_BIG(*) [Count], ProductID 
FROM dbo.[order details]
GROUP BY ProductID
GO

CREATE UNIQUE CLUSTERED INDEX VDiscountInd ON Vdiscount2 (ProductID)

--查询 3 
SELECT TOP 3 OrderID, SUM(UnitPrice*Quantity*Discount) OrderRebate 
FROM dbo.[order details]
GROUP By OrderID

--如果使用了AVG,STDEV,VARIANCE等汇总函数视图，就不可以直接建立索引。
--查询 4 
SELECT ProductName, od.ProductID, AVG(od.UnitPrice*(1.00-Discount)) AvgPrice, 
SUM(od.Quantity) Units
FROM [Order details] od JOIN Products p 
ON od.ProductID=p.ProductID 
GROUP BY ProductName, od.ProductID

CREATE VIEW vForAvg WITH SCHEMABINDING AS
SELECT od.ProductID, SUM(od.UnitPrice*(1.00-Discount)) Price, COUNT_BIG(*) Count
	,SUM(od.Quantity) Units
FROM dbo.[Order details] od
GROUP BY od.ProductID
GO
 
CREATE UNIQUE CLUSTERED INDEX idxForAvg on vForAvg (ProductID)

CREATE VIEW vForAvg1 WITH SCHEMABINDING AS
SELECT ProductName, od.ProductID, AVG(od.UnitPrice*(1.00-Discount)) AvgPrice, 
SUM(od.Quantity) Units
FROM dbo.[Order details] od JOIN dbo.Products p 
ON od.ProductID=p.ProductID 
GROUP BY ProductName, od.ProductID
GO
CREATE UNIQUE CLUSTERED INDEX idxForAvg1 on vForAvg1 (ProductID) 
/*
错误讯息如下：
讯息 10125，层级 16，状态 1，行 1
无法在视图 "Northwind.dbo.vForAvg1" 上建立 索引，因为视图使用了汇总 "AVG"。建议您删除汇总，或不要索引该视图，或使用替代的汇总。例如，用 SUM 和 COUNT取代AVG 取代 ，或用COUNT_BIG取代 COUNT  。

*/


-- 查询 5
SELECT ProductName, od.ProductID, AVG(od.UnitPrice*(1.00-Discount)) AvgPrice, 
 SUM(od.Quantity) Units
FROM [Order details] od JOIN Products p 
ON od.ProductID=p.ProductID 
WHERE p.ProductName LIKE '%tofu%'
GROUP BY ProductName, od.ProductID

-- 查询 6
SELECT ProductName, od.ProductID, AVG(od.UnitPrice*(1.00-Discount)) AvgPrice, 
 SUM(od.Quantity) Units
FROM [order details] od JOIN Products p 
ON od.ProductID=p.ProductID 
WHERE od.ProductID IN (1,2,3)
GROUP BY ProductName, od.ProductID

--查询 7
SELECT ProductName, od.ProductID, AVG(od.UnitPrice*(1.00-Discount)) AvgPrice, 
 SUM(od.Quantity) Units
FROM [order details] od JOIN Products p 
ON od.ProductID=p.ProductID 
WHERE od.UnitPrice>10
GROUP BY ProductName, od.ProductID
