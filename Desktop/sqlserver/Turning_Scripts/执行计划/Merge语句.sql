/***********************************************************************
Author="Kenneth Wang"
Create Date="2008/8/23"
***********************************************************************/
/*
MERGE�������﷨�����ں�UPDATE��DELETE��INSERT��
�ر��ʺ��ڽ������͵ļ�¼���ϲ��������ԵĽ������ȥ��
�ǳ����д����Ե�Ӧ�ó������ǿ�����������Ӧ��(�׳ƽ�����)��
������Ҫ���ĳ��ʱ����ϵĿ�棬Ҳ��Ϊ�����ࡣ
*/

--�������Ա�
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
	OperationType	int,	--1:���; 2:����; 3:�ϲ�
	ProductID		int,
	Quantity		int
)
GO

--�����洢���������µĿ�����
CREATE PROCEDURE usp_Inventory_Operation
	@productID int,
	@operationDate datetime,
	@operationType int, --1:���; 2:����; 3:�ϲ�
	@quantity	int
AS
INSERT INTO Inventory_Operation 
	(OperationDate, OperationType, ProductID, Quantity)
VALUES
	(@operationDate, @operationType, @productID, @quantity)
	
GO

--�����洢�������ڿ����ռ���
CREATE PROCEDURE usp_Inventory_Snapshot_Process
	@processDate datetime
AS
MERGE Inventory_Snapshot AS invs
USING (SELECT ProductID, Sum(ABSQuantity) AS SubTotal
		FROM (SELECT ProductID, Quantity  * 
					CASE OperationType --1:���; 2:����; 3:�ϲ�
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

--����Ӧ�ó����߼�
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