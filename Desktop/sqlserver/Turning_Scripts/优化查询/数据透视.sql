USE AdventureWorks
GO
CREATE TABLE SalesOrderTotalsMonthly
(
	CustomerID int NOT NULL,
	OrderMonth int NOT NULL,
	SubTotal money NOT NULL
)
GO

--客户 1,2,4,6 在各月的订单金额
INSERT SalesOrderTotalsMonthly
SELECT CustomerID,DatePart(m,OrderDate),SubTotal FROM Sales.SalesOrderHeader
WHERE CustomerID IN (1,2,4,6)
GO
SELECT * FROM SalesOrderTotalsMonthly

--在没有 PIVOT 语法时可用的查询方式
SELECT CustomerID,
SUM(CASE WHEN OrderMonth=1 THEN SubTotal END) AS [1],
SUM(CASE WHEN OrderMonth=2 THEN SubTotal END) AS [2],
SUM(CASE WHEN OrderMonth=3 THEN SubTotal END) AS [3]
FROM SalesOrderTotalsMonthly
GROUP BY CustomerID

--转成以月为栏，客户编号为列的枢纽表格，中间放 Sum(SubTotal)的数值细节
SELECT * FROM SalesOrderTotalsMonthly
PIVOT(SUM(SubTotal) 
FOR OrderMonth IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])) AS a

--给予查询结果的字段新的别名
SELECT a.CustomerID [客户编号],a.[1] [一月],a.[2] [二月],a.[3] [三月] 
FROM SalesOrderTotalsMonthly
PIVOT(SUM(SubTotal) FOR OrderMonth 
IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])) AS a

--将查询结果通过函数进一步地修改内容
SELECT CustomerID [客户编号],
ISNULL([1],0) [一月],ISNULL([2],0) [二月],ISNULL([3],0) [三月] 
FROM SalesOrderTotalsMonthly
PIVOT(SUM(SubTotal) FOR OrderMonth IN ([1],[2],[3])) AS a

--PIVOT 是取语法中 FROM 子句所提供的临时数据表，
--JOIN 子句会让该临时数据表最起码重复 Join 所用的字段
--会出现如下的错误
--信息 8156，级别 16，状态 1，行 1
--为 'a' 指定了数据行 'CustomerID' 多次。
SELECT * FROM 
SalesOrderTotalsMonthly s JOIN Sales.Customer c ON s.CustomerID=c.CustomerID
PIVOT(SUM(SubTotal) FOR OrderMonth 
IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])) AS a

--必须通过 CTE 或是临时数据表来提供明确的临时数据表栏位
--通过 CTE
WITH tmpCTE
AS
(
	SELECT s.CustomerID,c.TerritoryID,s.SubTotal,s.OrderMonth
	FROM SalesOrderTotalsMonthly s
	JOIN Sales.Customer c ON s.CustomerID=c.CustomerID
)
SELECT * FROM tmpCTE
PIVOT(SUM(SubTotal) FOR OrderMonth 
IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])) AS a
go

--通过临时数据表
SELECT * FROM (
	SELECT s.CustomerID,c.TerritoryID,s.SubTotal,s.OrderMonth
	FROM SalesOrderTotalsMonthly s
	JOIN Sales.Customer c ON s.CustomerID=c.CustomerID
)
tmpTbl
PIVOT(SUM(SubTotal) FOR OrderMonth 
IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])) AS a

--UNPIVOT ：将 Pivot 后的数据以传统数据表的行列来显示
CREATE TABLE SalesOrderTotalsYearly
(
	CustomerID INT NOT NULL,
	OrderYear INT NOT NULL,
	SubTotal money
)
GO

INSERT SalesOrderTotalsYearly
SELECT CustomerID,Year(OrderDate), SubTotal
FROM Sales.SalesOrderHeader
WHERE CustomerID IN (1,2,4,6,8)
GO

--创建存放 PIVOT 后的数据表
CREATE TABLE YearlySalesPivot
(
	OrderYear INT NOT NULL,
	[1] Money NULL,
	[2] Money NULL,
	[4] Money NULL,
	[6] Money NULL
)
GO
--将 Pivot 查询的结果存入数据表
INSERT YearlySalesPivot
SELECT * FROM SalesOrderTotalsYearly
PIVOT(SUM(SubTotal) FOR CustomerID IN([1],[2],[4],[6])) AS A

SELECT * FROM YearlySalesPivot

--通过 UnPivot 将数据重新转成年、汇总值与客户编号三个字段的数据表显示方式
SELECT * FROM YearlySalesPivot
UNPIVOT(SubTotal FOR CustomerID IN([1],[2],[4],[6]))
AS a
ORDER BY CustomerID


DROP TABLE SalesOrderTotalsYearly
DROP TABLE YearlySalesPivot
