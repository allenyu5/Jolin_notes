/***********************************************************************
Author="Kenneth Wang"
Create Date="2007/12/12"
***********************************************************************/

USE Sales
GO

--Business runs in Year 2002
INSERT INTO dbo.Orders (OrderDate, CustomerID) VALUES ('2002/6/25', 1000)
INSERT INTO dbo.Orders (OrderDate, CustomerID) VALUES ('2002/8/13', 1000)
INSERT INTO dbo.Orders (OrderDate, CustomerID) VALUES ('2002/8/25', 1000)
INSERT INTO dbo.Orders (OrderDate, CustomerID) VALUES ('2002/9/23', 1000)