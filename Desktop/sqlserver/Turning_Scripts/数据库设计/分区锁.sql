/***********************************************************************
Author="Kenneth Wang"
Create Date="2008/8/23"
***********************************************************************/
--修改默认的锁升级策略
ALTER TABLE TableName SET (LOCK_ESCALATION = TABLE | AUTO | DISABLE);

--检查数据表示使用哪一种锁升级策略
SELECT lock_escalation_desc FROM sys.tables WHERE name = 'TableName';


--实例
CREATE DATABASE LockEscalationTest;
GO

USE LockEscalationTest;
GO

-- 创建三个分区: -7999, 8000-15999, 16000+
CREATE PARTITION FUNCTION MyPartitionFunction (INT) AS RANGE RIGHT FOR VALUES (8000, 16000);
GO

CREATE PARTITION SCHEME MyPartitionScheme AS PARTITION MyPartitionFunction
ALL TO ([PRIMARY]);
GO

-- 创建分区表
CREATE TABLE MyPartitionedTable (c1 INT);
GO

CREATE CLUSTERED INDEX MPT_Clust ON MyPartitionedTable (c1)
ON MyPartitionScheme (c1);
GO

-- 填充表
SET NOCOUNT ON;
GO

DECLARE @a INT = 1;
WHILE (@a < 17000)
BEGIN
INSERT INTO MyPartitionedTable VALUES (@a);
SELECT @a = @a + 1;
END;
GO

--设置锁的升级策略为Table
ALTER TABLE MyPartitionedTable SET (LOCK_ESCALATION = TABLE);
GO

--开始一个更新数据的事务
BEGIN TRAN
UPDATE MyPartitionedTable SET c1 = c1 WHERE c1 < 7500;
GO

--查询锁的分配情况
SELECT [resource_type], [resource_associated_entity_id], [request_mode],
[request_type], [request_status] FROM sys.dm_tran_locks WHERE [resource_type] <> 'DATABASE';
GO

--回滚事务
ROLLBACK TRAN;
GO

--连接1
--设置锁的升级策略为AUTO(即启用分区级别的锁)
ALTER TABLE MyPartitionedTable SET (LOCK_ESCALATION = AUTO);
GO

--开始一个更新数据的事务
BEGIN TRAN
UPDATE MyPartitionedTable SET c1 = c1 WHERE c1 < 7500;
GO

--查询锁的分配情况
SELECT [partition_id], [object_id], [index_id], [partition_number]
FROM sys.partitions WHERE object_id = OBJECT_ID ('MyPartitionedTable');
GO

SELECT [resource_type], [resource_associated_entity_id], [request_mode],
[request_type], [request_status] FROM sys.dm_tran_locks WHERE [resource_type] <> 'DATABASE';
GO

--连接2
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

--连接1
SELECT * FROM MyPartitionedTable WHERE c1 = 8500;
GO

--连接2
SELECT * FROM MyPartitionedTable WHERE c1 = 100;
GO
