/***********************************************************************
Author="Kenneth Wang"
Create Date="2007/12/12"
***********************************************************************/

USE Sales
GO

--When year 2005 comes
ALTER TABLE dbo.Orders SWITCH PARTITION 2 TO dbo.OrdersHistory PARTITION 2

--Now the Partition Scheme is listed below
----Before Year 2004 use Partition 1 in FG1
----2004-2005 use Partition 2 in FG3
----After Year 2005 use Partition 3 in  FG2
ALTER PARTITION FUNCTION pf_OrderDate() MERGE RANGE ('2004/01/01')
GO
--After executed code, now the Partition Scheme is listed below
----Before Year 2005 use Partition 1 in FG1
----After 2005 use Partition 2 in FG2
ALTER PARTITION SCHEME ps_OrderDate NEXT USED FG3
ALTER PARTITION FUNCTION pf_OrderDate() SPLIT RANGE ('2006/01/01')
--After executed code, now the Partition Scheme is listed below
----Before Year 2005 use Partition 1 in FG1
----2005-2006 use Partition 2 in FG2
----After Year 2006 use Partition 3 in  FG3
GO

--Business runs in Year 2005
INSERT INTO dbo.Orders (OrderDate, CustomerID) VALUES ('2005/6/25', 1000)
INSERT INTO dbo.Orders (OrderDate, CustomerID) VALUES ('2005/8/13', 1000)
INSERT INTO dbo.Orders (OrderDate, CustomerID) VALUES ('2005/8/25', 1000)
INSERT INTO dbo.Orders (OrderDate, CustomerID) VALUES ('2005/9/23', 1000)

--Check the order data storage localtion
SELECT * FROM dbo.Orders
SELECT * FROM dbo.OrdersHistory