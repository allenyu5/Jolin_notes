USE AdventureWorks;
GO
-----删除数据
--查看Ghost 记录

IF EXISTS (SELECT * FROM sys.objects
WHERE name = 'viewTestIndexInfo' and type = 'V')
BEGIN
DROP VIEW dbo.viewTestIndexInfo
END
GO

CREATE VIEW dbo.viewTestIndexInfo
AS
SELECT IX.name as 'Name', PS.index_level as 'Level', PS.page_count as 'Pages'
, PS.avg_page_space_used_in_percent as 'Page Fullness (%)', PS.ghost_record_count as 'Ghost Records'
FROM sys.dm_db_index_physical_stats( db_id(), object_id('dbo.FragTest'), default, default, 'DETAILED') PS
JOIN sys.indexes IX
ON IX.object_id = PS.object_id AND IX.index_id = PS.index_id
WHERE IX.name = 'PK_FragTest_PKCol';
GO

--准备测试数据
--drop table DBO.FragTest

CREATE TABLE dbo.FragTest
(PKCol int)

BEGIN TRAN
DECLARE @index INT
SET @index=1
WHILE(@index <=20000)
BEGIN
INSERT INTO dbo.FragTest(pkcol) VALUES(@index)
SET @index=@index+1
END
COMMIT TRAN

CREATE CLUSTERED INDEX PK_FragTest_PKCol ON dbo.FragTest(pkcol)

--删除
BEGIN TRANSACTION
DELETE DBO.FragTest
WHERE PKCol <= 20000 / 2;
SELECT * FROM dbo.viewTestIndexInfo;

--COMMIT TRAN
