/***********************************************************************
Author="Kenneth Wang"
Create Date="2007/12/12"
***********************************************************************/

USE Sales
--It is year 2002 right now
CREATE PARTITION FUNCTION pf_OrderDate (datetime)
AS RANGE RIGHT FOR VALUES 
('2003/01/01', '2004/01/01')
GO

CREATE PARTITION SCHEME ps_OrderDate
AS PARTITION pf_OrderDate TO
(FG1, FG2, FG3)
GO

CREATE TABLE dbo.Orders
(
	OrderID int identity(10000,1),
	OrderDate datetime NOT NULL, 
	CustomerID int NOT NULL,
	--Since the "OrderDate" column is the paritioning column,
	--so "OrderDate" should be the part of primary key
	CONSTRAINT PK_Orders PRIMARY KEY (OrderID, OrderDate)
)
ON ps_OrderDate (OrderDate)
GO

CREATE TABLE dbo.OrdersHistory
(
	OrderID int identity(10000,1),
	OrderDate datetime NOT NULL, 
	CustomerID int NOT NULL,
	CONSTRAINT PK_OrdersHistory PRIMARY KEY (OrderID, OrderDate)
)
ON ps_OrderDate (OrderDate)
GO
