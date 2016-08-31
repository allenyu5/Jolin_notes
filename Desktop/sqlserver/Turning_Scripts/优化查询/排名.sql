USE AdventureWorks
GO
--简单产生返回记录的循序记录编号
SELECT PSC.Name Category,p.Name Product,p.ListPrice, 
ROW_NUMBER() OVER(ORDER BY PSC.Name,P.ListPrice DESC) AS Row
FROM Production.Product p
JOIN Production.ProductSubCategory PSC
ON p.ProductSubCategoryID=PSC.ProductSubCategoryID
ORDER BY Category,ListPrice DESC

--依照产品类型分开编的记录编号
SELECT PSC.Name Category,p.Name Product,p.ListPrice, 
ROW_NUMBER() OVER(PARTITION BY PSC.Name ORDER BY P.ListPrice DESC) AS Row
FROM Production.Product p
JOIN Production.ProductSubCategory PSC
ON p.ProductSubCategoryID=PSC.ProductSubCategoryID
ORDER BY Category,ListPrice DESC

--比较 ROW_NUMBER 函数与以往子查询取得记录顺序编号的性能差异
SET STATISTICS TIME ON
-- SQL Server 2005 提供的 ROW_NUMBER() 较以往的性能好很多
SELECT SalesOrderID,
  ROW_NUMBER() OVER(ORDER BY SalesOrderID) AS rownum
FROM Sales.SalesOrderHeader

--SQL Server 2000 需用以下子查询的技巧
--但对大量数据时，这个查询性能极差
SELECT SalesOrderID,
  (SELECT COUNT(*)
   FROM Sales.SalesOrderHeader AS S2
   WHERE S2.SalesOrderID <= S1.SalesOrderID) AS rownum
FROM Sales.SalesOrderHeader AS S1

--通过 ROW_NUMBER 函数搭配子查询完成数据分页的动作
CREATE PROC spGetPages2 @iRowCount INT,@iPageNo INT
AS
SELECT * FROM (
SELECT ROW_NUMBER() OVER(ORDER BY ProductID ASC) RowNum,
		* FROM Production.Product ) OrderData
WHERE RowNum BETWEEN @iRowCount*(@iPageNo-1)+1 AND @iRowCount*@iPageNo
ORDER BY ProductID ASC
GO

EXEC spGetPages2 10,20

--取回第 @iPageNo 分页，而每页 @iRowCount 笔记录
CREATE PROC spGetPages @iRowCount INT,@iPageNo INT
AS
DECLARE @iMax INT,@strSQL NVARCHAR(300) 
SET @iMax=@iPageNo*@iRowCount
SET @strSQL='
SELECT * FROM (
	SELECT TOP ' + CONVERT(nvarchar(10),@iRowCount) + ' * FROM 
		(SELECT TOP '+ CONVERT(nvarchar(10),@iMax) + 
		' ROW_NUMBER() OVER(ORDER BY ProductID ASC) RowNum,
		* FROM Production.Product ORDER BY ProductID ASC) tblMax
	ORDER BY ProductID DESC) tblMin
ORDER BY ProductID ASC'
--PRINT @strSQL
EXEC(@strSQL)
GO

--测试结果
EXEC spGetPages 10,20


--依照价格排名
SELECT Name ,ListPrice, 
RANK() OVER(ORDER BY ListPrice DESC) AS Rank
FROM Production.Product

--依照各产品的类型与价格给该类的排名
SELECT PSC.Name Category, p.Name Product,p.ListPrice, 
RANK() OVER(PARTITION BY PSC.Name ORDER BY P.ListPrice DESC) AS Rank
FROM Production.Product p
JOIN Production.ProductSubCategory PSC
ON p.ProductSubCategoryID=PSC.ProductSubCategoryID
ORDER BY Category,ListPrice DESC

--依照各产品的价格排名，但名次是连续的，不会因为相同名次有 N 个，
--下一个名次就跳至 N+1 名之后
SELECT Name ,ListPrice, 
DENSE_RANK() OVER(ORDER BY ListPrice DESC) AS Rank
FROM Production.Product

--依照产品类型分开编的记录编号
--各类产品依照标价的大小排序，并切成十群，标示每一群的编号
SELECT NTILE(10) OVER(PARTITION BY PC.Name ORDER BY P.ListPrice DESC) AS PriceBand,
pc.Name Category,p.Name Produc,p.ListPrice
FROM Production.Product p
JOIN Production.ProductSubCategory PSC
ON p.ProductSubCategoryID=PSC.ProductSubCategoryID
JOIN Production.ProductCategory pc
ON PSC.ProductCategoryID=pc.ProductCategoryID
ORDER BY Category,ListPrice DESC

--通过 CASE WHEN 将各群编号转成文字叙述
SELECT ROW_NUMBER() OVER(PARTITION BY PC.Name ORDER BY P.ListPrice DESC) RowNum,
pc.Name Category,p.Name Produc,p.ListPrice,
CASE NTILE(5) OVER(PARTITION BY PC.Name ORDER BY P.ListPrice DESC) 
	WHEN 1 THEN N'最高价位'
	WHEN 2 THEN N'高价位'
	WHEN 3 THEN N'中价位'
	WHEN 4 THEN N'低价位'
	WHEN 5 THEN N'最低价位'
END PriceBank
FROM Production.Product p
JOIN Production.ProductSubCategory PSC
ON p.ProductSubCategoryID=PSC.ProductSubCategoryID
JOIN Production.ProductCategory pc
ON PSC.ProductCategoryID=pc.ProductCategoryID
ORDER BY Category ,ListPrice DESC

