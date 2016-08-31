USE AdventureWorks
GO
CREATE TABLE SalesOrderTotalsMonthly
(
	CustomerID int NOT NULL,
	OrderMonth int NOT NULL,
	SubTotal money NOT NULL
)
GO

--�ͻ� 1,2,4,6 �ڸ��µĶ������
INSERT SalesOrderTotalsMonthly
SELECT CustomerID,DatePart(m,OrderDate),SubTotal FROM Sales.SalesOrderHeader
WHERE CustomerID IN (1,2,4,6)
GO
SELECT * FROM SalesOrderTotalsMonthly

--��û�� PIVOT �﷨ʱ���õĲ�ѯ��ʽ
SELECT CustomerID,
SUM(CASE WHEN OrderMonth=1 THEN SubTotal END) AS [1],
SUM(CASE WHEN OrderMonth=2 THEN SubTotal END) AS [2],
SUM(CASE WHEN OrderMonth=3 THEN SubTotal END) AS [3]
FROM SalesOrderTotalsMonthly
GROUP BY CustomerID

--ת������Ϊ�����ͻ����Ϊ�е���Ŧ����м�� Sum(SubTotal)����ֵϸ��
SELECT * FROM SalesOrderTotalsMonthly
PIVOT(SUM(SubTotal) 
FOR OrderMonth IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])) AS a

--�����ѯ������ֶ��µı���
SELECT a.CustomerID [�ͻ����],a.[1] [һ��],a.[2] [����],a.[3] [����] 
FROM SalesOrderTotalsMonthly
PIVOT(SUM(SubTotal) FOR OrderMonth 
IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])) AS a

--����ѯ���ͨ��������һ�����޸�����
SELECT CustomerID [�ͻ����],
ISNULL([1],0) [һ��],ISNULL([2],0) [����],ISNULL([3],0) [����] 
FROM SalesOrderTotalsMonthly
PIVOT(SUM(SubTotal) FOR OrderMonth IN ([1],[2],[3])) AS a

--PIVOT ��ȡ�﷨�� FROM �Ӿ����ṩ����ʱ���ݱ�
--JOIN �Ӿ���ø���ʱ���ݱ��������ظ� Join ���õ��ֶ�
--��������µĴ���
--��Ϣ 8156������ 16��״̬ 1���� 1
--Ϊ 'a' ָ���������� 'CustomerID' ��Ρ�
SELECT * FROM 
SalesOrderTotalsMonthly s JOIN Sales.Customer c ON s.CustomerID=c.CustomerID
PIVOT(SUM(SubTotal) FOR OrderMonth 
IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])) AS a

--����ͨ�� CTE ������ʱ���ݱ����ṩ��ȷ����ʱ���ݱ���λ
--ͨ�� CTE
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

--ͨ����ʱ���ݱ�
SELECT * FROM (
	SELECT s.CustomerID,c.TerritoryID,s.SubTotal,s.OrderMonth
	FROM SalesOrderTotalsMonthly s
	JOIN Sales.Customer c ON s.CustomerID=c.CustomerID
)
tmpTbl
PIVOT(SUM(SubTotal) FOR OrderMonth 
IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])) AS a

--UNPIVOT ���� Pivot ��������Դ�ͳ���ݱ����������ʾ
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

--������� PIVOT ������ݱ�
CREATE TABLE YearlySalesPivot
(
	OrderYear INT NOT NULL,
	[1] Money NULL,
	[2] Money NULL,
	[4] Money NULL,
	[6] Money NULL
)
GO
--�� Pivot ��ѯ�Ľ���������ݱ�
INSERT YearlySalesPivot
SELECT * FROM SalesOrderTotalsYearly
PIVOT(SUM(SubTotal) FOR CustomerID IN([1],[2],[4],[6])) AS A

SELECT * FROM YearlySalesPivot

--ͨ�� UnPivot ����������ת���ꡢ����ֵ��ͻ���������ֶε����ݱ���ʾ��ʽ
SELECT * FROM YearlySalesPivot
UNPIVOT(SubTotal FOR CustomerID IN([1],[2],[4],[6]))
AS a
ORDER BY CustomerID


DROP TABLE SalesOrderTotalsYearly
DROP TABLE YearlySalesPivot
