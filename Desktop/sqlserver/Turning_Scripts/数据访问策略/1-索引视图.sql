--�����÷��Ͻ��� indexed view
--ע�������߸�ѡ������ã�dbcc useroptions)
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
--�鿴ĳ����ͼ�Ƿ���Խ�������
SELECT OBJECTPROPERTY(OBJECT_ID('vwTest'),'IsIndexable')

DROP VIEW vwTest
DROP TABLE tmp




--===============================������ͼʾ��==========================================
SET STATISTICS IO ON
USE Northwind
-- �г�����ۿۿ�ǰ�����Ĳ�Ʒ���������ַ�ʽ��
-- ��ѯ 1 
SELECT TOP 5 ProductID, SUM(UnitPrice*Quantity)- 
	SUM(UnitPrice*Quantity*(1.00-Discount)) �ۿۿ� 
FROM [order details] 
GROUP BY ProductID 
ORDER BY �ۿۿ� DESC
 
--��ѯ 2 
SELECT TOP 5 ProductID, SUM(UnitPrice*Quantity*Discount) �ۿۿ�
FROM [order details] 
GROUP BY ProductID 
ORDER BY �ۿۿ� DESC

--���µ� indexed view �� Q1 ���ã��� Q2 ���
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

--��ѯ 3 
SELECT TOP 3 OrderID, SUM(UnitPrice*Quantity*Discount) OrderRebate 
FROM dbo.[order details]
GROUP By OrderID

--���ʹ����AVG,STDEV,VARIANCE�Ȼ��ܺ�����ͼ���Ͳ�����ֱ�ӽ���������
--��ѯ 4 
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
����ѶϢ���£�
ѶϢ 10125���㼶 16��״̬ 1���� 1
�޷�����ͼ "Northwind.dbo.vForAvg1" �Ͻ��� ��������Ϊ��ͼʹ���˻��� "AVG"��������ɾ�����ܣ���Ҫ��������ͼ����ʹ������Ļ��ܡ����磬�� SUM �� COUNTȡ��AVG ȡ�� ������COUNT_BIGȡ�� COUNT  ��

*/


-- ��ѯ 5
SELECT ProductName, od.ProductID, AVG(od.UnitPrice*(1.00-Discount)) AvgPrice, 
 SUM(od.Quantity) Units
FROM [Order details] od JOIN Products p 
ON od.ProductID=p.ProductID 
WHERE p.ProductName LIKE '%tofu%'
GROUP BY ProductName, od.ProductID

-- ��ѯ 6
SELECT ProductName, od.ProductID, AVG(od.UnitPrice*(1.00-Discount)) AvgPrice, 
 SUM(od.Quantity) Units
FROM [order details] od JOIN Products p 
ON od.ProductID=p.ProductID 
WHERE od.ProductID IN (1,2,3)
GROUP BY ProductName, od.ProductID

--��ѯ 7
SELECT ProductName, od.ProductID, AVG(od.UnitPrice*(1.00-Discount)) AvgPrice, 
 SUM(od.Quantity) Units
FROM [order details] od JOIN Products p 
ON od.ProductID=p.ProductID 
WHERE od.UnitPrice>10
GROUP BY ProductName, od.ProductID
