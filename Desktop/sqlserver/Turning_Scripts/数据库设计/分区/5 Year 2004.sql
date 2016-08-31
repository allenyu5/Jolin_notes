/***********************************************************************
Author="Kenneth Wang"
Create Date="2007/12/12"
***********************************************************************/

USE Sales
GO

--When year 2004 comes
ALTER TABLE dbo.Orders SWITCH PARTITION 2 TO dbo.OrdersHistory PARTITION 2
GO
--Now Parition Scheme is listed below
----Before Year 2003 use Partition 1 in FG1
----2003-2004 use Partition 2 in FG2
----After 2004 use Partition 3 in FG3
ALTER PARTITION FUNCTION pf_OrderDate() MERGE RANGE ('2003/01/01')
GO
--After executed code, now the Partition Scheme is listed below
----Before Year 2004 use Partition 1 in FG1
----After 2004 use Partition 2 in FG3
ALTER PARTITION SCHEME ps_OrderDate NEXT USED FG2
ALTER PARTITION FUNCTION pf_OrderDate() SPLIT RANGE ('2005/01/01')
GO
--After executed code, now the Partition Scheme is listed below
----Before Year 2004 use Partition 1 in FG1
----2004-2005 use Partition 2 in FG3
----After Year 2005 use Partition 3 in  FG2


--Business runs in Year 2004
INSERT INTO dbo.Orders (OrderDate, CustomerID) VALUES ('2004/6/25', 1000)
INSERT INTO dbo.Orders (OrderDate, CustomerID) VALUES ('2004/8/13', 1000)
INSERT INTO dbo.Orders (OrderDate, CustomerID) VALUES ('2004/8/25', 1000)
INSERT INTO dbo.Orders (OrderDate, CustomerID) VALUES ('2004/9/23', 1000)

--Check the order data storage localtion
SELECT * FROM dbo.Orders
SELECT * FROM dbo.OrdersHistory