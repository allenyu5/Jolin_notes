/***********************************************************************
Author="Kenneth Wang"
Create Date="2008/8/23"
***********************************************************************/
--�޸�Ĭ�ϵ�����������
ALTER TABLE TableName SET (LOCK_ESCALATION = TABLE | AUTO | DISABLE);

--������ݱ�ʾʹ����һ������������
SELECT lock_escalation_desc FROM sys.tables WHERE name = 'TableName';


--ʵ��
CREATE DATABASE LockEscalationTest;
GO

USE LockEscalationTest;
GO

-- ������������: -7999, 8000-15999, 16000+
CREATE PARTITION FUNCTION MyPartitionFunction (INT) AS RANGE RIGHT FOR VALUES (8000, 16000);
GO

CREATE PARTITION SCHEME MyPartitionScheme AS PARTITION MyPartitionFunction
ALL TO ([PRIMARY]);
GO

-- ����������
CREATE TABLE MyPartitionedTable (c1 INT);
GO

CREATE CLUSTERED INDEX MPT_Clust ON MyPartitionedTable (c1)
ON MyPartitionScheme (c1);
GO

-- ����
SET NOCOUNT ON;
GO

DECLARE @a INT = 1;
WHILE (@a < 17000)
BEGIN
INSERT INTO MyPartitionedTable VALUES (@a);
SELECT @a = @a + 1;
END;
GO

--����������������ΪTable
ALTER TABLE MyPartitionedTable SET (LOCK_ESCALATION = TABLE);
GO

--��ʼһ���������ݵ�����
BEGIN TRAN
UPDATE MyPartitionedTable SET c1 = c1 WHERE c1 < 7500;
GO

--��ѯ���ķ������
SELECT [resource_type], [resource_associated_entity_id], [request_mode],
[request_type], [request_status] FROM sys.dm_tran_locks WHERE [resource_type] <> 'DATABASE';
GO

--�ع�����
ROLLBACK TRAN;
GO

--����1
--����������������ΪAUTO(�����÷����������)
ALTER TABLE MyPartitionedTable SET (LOCK_ESCALATION = AUTO);
GO

--��ʼһ���������ݵ�����
BEGIN TRAN
UPDATE MyPartitionedTable SET c1 = c1 WHERE c1 < 7500;
GO

--��ѯ���ķ������
SELECT [partition_id], [object_id], [index_id], [partition_number]
FROM sys.partitions WHERE object_id = OBJECT_ID ('MyPartitionedTable');
GO

SELECT [resource_type], [resource_associated_entity_id], [request_mode],
[request_type], [request_status] FROM sys.dm_tran_locks WHERE [resource_type] <> 'DATABASE';
GO

--����2
USE LockEscalationTest;
GO

BEGIN TRAN
UPDATE MyPartitionedTable set c1 = c1 WHERE c1 > 8100 AND c1 < 15900;
GO

SELECT [partition_id], [object_id], [index_id], [partition_number]
FROM sys.partitions WHERE object_id = OBJECT_ID ('MyPartitionedTable');
GO

SELECT [resource_type], [resource_associated_entity_id], [request_mode],
[request_type], [request_status] FROM sys.dm_tran_locks WHERE [resource_type] <> 'DATABASE';
GO

--����1
SELECT * FROM MyPartitionedTable WHERE c1 = 8500;
GO

--����2
SELECT * FROM MyPartitionedTable WHERE c1 = 100;
GO
