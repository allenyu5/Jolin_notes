/***********************************************************************
Author="Kenneth Wang"
Create Date="2008/6/23"
***********************************************************************/

USE AdventureWorks
GO

--1������һ���洢����
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

--2�����Դ洢����ִ�мƻ�
--�ܿ����ڶ�������'US'����佫���ú͵�һ�����һ����ִ�мƻ�
EXEC Sales.GetSalesOrderByCountry 'AU'
EXEC Sales.GetSalesOrderByCountry 'US'
--��չ��̻���
DBCC FREEPROCCACHE
--�ܿ���ִ�мƻ��ı��ˣ��ڶ������Ҳ��ı�����ִ�мƻ�������SalesOrderHeader��Customer
EXEC Sales.GetSalesOrderByCountry 'US'
EXEC Sales.GetSalesOrderByCountry 'AU'

--3�� ����һ���ƻ�ָ��
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

--4�� �������д洢���̣��Ƚ�ִ�мƻ�
EXEC Sales.GetSalesOrderByCountry 'AU'
EXEC Sales.GetSalesOrderByCountry 'US'

--5���������
EXEC sp_control_plan_guide N'DROP', N'Guide1'
DBCC FREEPROCCACHE
