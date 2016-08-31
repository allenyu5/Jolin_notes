USE AdventureWorks
GO
--�򵥲������ؼ�¼��ѭ���¼���
SELECT PSC.Name Category,p.Name Product,p.ListPrice, 
ROW_NUMBER() OVER(ORDER BY PSC.Name,P.ListPrice DESC) AS Row
FROM Production.Product p
JOIN Production.ProductSubCategory PSC
ON p.ProductSubCategoryID=PSC.ProductSubCategoryID
ORDER BY Category,ListPrice DESC

--���ղ�Ʒ���ͷֿ���ļ�¼���
SELECT PSC.Name Category,p.Name Product,p.ListPrice, 
ROW_NUMBER() OVER(PARTITION BY PSC.Name ORDER BY P.ListPrice DESC) AS Row
FROM Production.Product p
JOIN Production.ProductSubCategory PSC
ON p.ProductSubCategoryID=PSC.ProductSubCategoryID
ORDER BY Category,ListPrice DESC

--�Ƚ� ROW_NUMBER �����������Ӳ�ѯȡ�ü�¼˳���ŵ����ܲ���
SET STATISTICS TIME ON
-- SQL Server 2005 �ṩ�� ROW_NUMBER() �����������ܺúܶ�
SELECT SalesOrderID,
  ROW_NUMBER() OVER(ORDER BY SalesOrderID) AS rownum
FROM Sales.SalesOrderHeader

--SQL Server 2000 ���������Ӳ�ѯ�ļ���
--���Դ�������ʱ�������ѯ���ܼ���
SELECT SalesOrderID,
  (SELECT COUNT(*)
   FROM Sales.SalesOrderHeader AS S2
   WHERE S2.SalesOrderID <= S1.SalesOrderID) AS rownum
FROM Sales.SalesOrderHeader AS S1

--ͨ�� ROW_NUMBER ���������Ӳ�ѯ������ݷ�ҳ�Ķ���
CREATE PROC spGetPages2 @iRowCount INT,@iPageNo INT
AS
SELECT * FROM (
SELECT ROW_NUMBER() OVER(ORDER BY ProductID ASC) RowNum,
		* FROM Production.Product ) OrderData
WHERE RowNum BETWEEN @iRowCount*(@iPageNo-1)+1 AND @iRowCount*@iPageNo
ORDER BY ProductID ASC
GO

EXEC spGetPages2 10,20

--ȡ�ص� @iPageNo ��ҳ����ÿҳ @iRowCount �ʼ�¼
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

--���Խ��
EXEC spGetPages 10,20


--���ռ۸�����
SELECT Name ,ListPrice, 
RANK() OVER(ORDER BY ListPrice DESC) AS Rank
FROM Production.Product

--���ո���Ʒ��������۸�����������
SELECT PSC.Name Category, p.Name Product,p.ListPrice, 
RANK() OVER(PARTITION BY PSC.Name ORDER BY P.ListPrice DESC) AS Rank
FROM Production.Product p
JOIN Production.ProductSubCategory PSC
ON p.ProductSubCategoryID=PSC.ProductSubCategoryID
ORDER BY Category,ListPrice DESC

--���ո���Ʒ�ļ۸��������������������ģ�������Ϊ��ͬ������ N ����
--��һ�����ξ����� N+1 ��֮��
SELECT Name ,ListPrice, 
DENSE_RANK() OVER(ORDER BY ListPrice DESC) AS Rank
FROM Production.Product

--���ղ�Ʒ���ͷֿ���ļ�¼���
--�����Ʒ���ձ�۵Ĵ�С���򣬲��г�ʮȺ����ʾÿһȺ�ı��
SELECT NTILE(10) OVER(PARTITION BY PC.Name ORDER BY P.ListPrice DESC) AS PriceBand,
pc.Name Category,p.Name Produc,p.ListPrice
FROM Production.Product p
JOIN Production.ProductSubCategory PSC
ON p.ProductSubCategoryID=PSC.ProductSubCategoryID
JOIN Production.ProductCategory pc
ON PSC.ProductCategoryID=pc.ProductCategoryID
ORDER BY Category,ListPrice DESC

--ͨ�� CASE WHEN ����Ⱥ���ת����������
SELECT ROW_NUMBER() OVER(PARTITION BY PC.Name ORDER BY P.ListPrice DESC) RowNum,
pc.Name Category,p.Name Produc,p.ListPrice,
CASE NTILE(5) OVER(PARTITION BY PC.Name ORDER BY P.ListPrice DESC) 
	WHEN 1 THEN N'��߼�λ'
	WHEN 2 THEN N'�߼�λ'
	WHEN 3 THEN N'�м�λ'
	WHEN 4 THEN N'�ͼ�λ'
	WHEN 5 THEN N'��ͼ�λ'
END PriceBank
FROM Production.Product p
JOIN Production.ProductSubCategory PSC
ON p.ProductSubCategoryID=PSC.ProductSubCategoryID
JOIN Production.ProductCategory pc
ON PSC.ProductCategoryID=pc.ProductCategoryID
ORDER BY Category ,ListPrice DESC

