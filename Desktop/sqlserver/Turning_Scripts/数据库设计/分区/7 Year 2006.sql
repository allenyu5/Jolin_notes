/***********************************************************************
Author="Kenneth Wang"
Create Date="2007/12/12"
***********************************************************************/

USE Sales
GO

--When year 2006 comes
ALTER TABLE dbo.Orders SWITCH PARTITION 2 TO dbo.OrdersHistory PARTITION 2

--Now the Partition Scheme is listed below
----Before Year 2005 use Partition 1 in FG1
----2005-2006 use Partition 2 in FG2
----After Year 2006 use Partition 3 in  FG3
ALTER PARTITION FUNCTION pf_OrderDate() MERGE RANGE ('2005/01/01')
--After executed code, now the Partition Scheme is listed below
----Before Year 2006 use Partition 1 in FG1
----After 2006 use Partition 2 in FG3
ALTER PARTITION SCHEME ps_OrderDate NEXT USED FG2
ALTER PARTITION FUNCTION pf_OrderDate() SPLIT RANGE ('2007/01/01')
--After executed code, now the Partition Scheme is listed below
----Before Year 2006 use Partition 1 in FG1
----2006-2007 use Partition 2 in FG3
----After Year 2007 use Partition 3 in  FG2
GO
--Check the order data storage localtion
SELECT * FROM dbo.Orders
SELECT * FROM dbo.OrdersHistory