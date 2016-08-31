/***********************************************************************
Author="Kenneth Wang"
Create Date="2008/8/23"
***********************************************************************/
/*
MERGE，这种语法可以融合UPDATE、DELETE和INSERT。
特别适合于将交易型的记录集合并到快照性的结果集中去。
非常具有代表性的应用场景就是库存管理，库存管理应用(俗称进销存)中
经常需要获得某个时间点上的库存，也称为库存结余。
*/

--创建测试表
USE tempdb
GO

CREATE TABLE Inventory_Snapshot
(
	ProductID	int PRIMARY KEY NOT NULL,
	Quantity	int NOT NULL
)
GO

CREATE TABLE Inventory_Operation
(
	OperationID		int PRIMARY KEY	IDENTITY(1,1),
	OperationDate	datetime,
	OperationType	int,	--1:入仓; 2:出仓; 3:合并
	ProductID		int,
	Quantity		int
)
GO

--创建存储过程用于新的库存操作
CREATE PROCEDURE usp_Inventory_Operation
	@productID int,
	@operationDate datetime,
	@operationType int, --1:入仓; 2:出仓; 3:合并
	@quantity	int
AS
INSERT INTO Inventory_Operation 
	(OperationDate, OperationType, ProductID, Quantity)
VALUES
	(@operationDate, @operationType, @productID, @quantity)
	
GO

--创建存储过程用于库存快照计算
CREATE PROCEDURE usp_Inventory_Snapshot_Process
	@processDate datetime
AS
MERGE Inventory_Snapshot AS invs
USING (SELECT ProductID, Sum(ABSQuantity) AS SubTotal
		FROM (SELECT ProductID, Quantity  * 
					CASE OperationType --1:入仓; 2:出仓; 3:合并
						WHEN 1 THEN 1
						WHEN 2 THEN -1
						WHEN 3 THEN 1
						ELSE 0
					END AS ABSQuantity FROM Inventory_Operation
				WHERE OperationDate = @processDate) AggInvo		
		GROUP BY AggInvo.ProductID)
	AS invo(ProductID, SubTotal)
ON (invs.ProductID = invo.ProductID)
WHEN MATCHED AND invs.Quantity <> invo.SubTotal AND invs.Quantity <> invo.SubTotal * -1
	THEN UPDATE SET invs.Quantity = invs.Quantity + invo.SubTotal
WHEN MATCHED AND invs.Quantity = invo.SubTotal * -1
	THEN DELETE
WHEN NOT MATCHED BY TARGET
	THEN INSERT VALUES (invo.ProductID, invo.SubTotal);
GO

DELETE FROM dbo.Inventory_Snapshot

--测试应用程序逻辑
--2007-1-1
EXEC usp_Inventory_Operation 1000, '2007-1-1', 1, 500
EXEC usp_Inventory_Operation 1001, '2007-1-1', 1, 300
EXEC usp_Inventory_Operation 1002, '2007-1-1', 1, 250

EXEC usp_Inventory_Snapshot_Process '2007-1-1'

SELECT * FROM Inventory_Snapshot
GO

EXEC usp_Inventory_Operation 1001, '2007-1-2', 2, 200
EXEC usp_Inventory_Operation 1003, '2007-1-2', 1, 300
EXEC usp_Inventory_Operation 1000, '2007-1-2', 2, 200

EXEC usp_Inventory_Snapshot_Process '2007-1-2'

SELECT * FROM Inventory_Snapshot
GO

EXEC usp_Inventory_Operation 1000, '2007-1-3', 2, 200
EXEC usp_Inventory_Operation 1002, '2007-1-3', 2, 250
EXEC usp_Inventory_Operation 1004, '2007-1-3', 2, 300

EXEC usp_Inventory_Snapshot_Process '2007-1-3'

SELECT * FROM Inventory_Snapshot
GO