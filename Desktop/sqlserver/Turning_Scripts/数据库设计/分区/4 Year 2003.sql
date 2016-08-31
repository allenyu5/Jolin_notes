/***********************************************************************
Author="Kenneth Wang"
Create Date="2007/12/12"
***********************************************************************/

USE Sales
GO

--When year 2003 comes
--Use partition switch to quick archive order data before 2003/01/01
ALTER TABLE dbo.Orders SWITCH PARTITION 1 TO dbo.OrdersHistory PARTITION 1
GO
--After switch partition, check the order data storage localtion
SELECT * FROM dbo.Orders
SELECT * FROM dbo.OrdersHistory
GO

--Business runs in year 2003
INSERT INTO dbo.Orders (OrderDate, CustomerID) VALUES ('2003/6/25', 1000)
INSERT INTO dbo.Orders (OrderDate, CustomerID) VALUES ('2003/8/13', 1000)
INSERT INTO dbo.Orders (OrderDate, CustomerID) VALUES ('2003/8/25', 1000)
INSERT INTO dbo.Orders (OrderDate, CustomerID) VALUES ('2003/9/23', 1000)
--Check the order data storage localtion
SELECT * FROM dbo.Orders
SELECT * FROM dbo.OrdersHistory
GO