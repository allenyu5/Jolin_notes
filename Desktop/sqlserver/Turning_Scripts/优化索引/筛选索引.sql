USE AdventureWorks
GO

--Step 1:����ɸѡ����
CREATE INDEX IX_Sales_SalesOrderHeader_Online
	ON Sales.SalesOrderHeader(SalesOrderID, OrderDate)
	WHERE OnlineOrderFlag = 1

CREATE INDEX IX_Sales_SalesOrderHeader_Retail
	ON Sales.SalesOrderHeader(SalesOrderID, OrderDate)
	WHERE OnlineOrderFlag = 0

--Step 2: ��ʾɸѡ������θ��ǲ�ѯ
SELECT SalesOrderID, OrderDate FROM Sales.SalesOrderHeader
	WHERE OnlineOrderFlag = 1

SELECT SalesOrderID, OrderDate FROM Sales.SalesOrderHeader
	WHERE OnlineOrderFlag = 0