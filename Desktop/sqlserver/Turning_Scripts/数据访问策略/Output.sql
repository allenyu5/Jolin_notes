USE AdventureWorks
GO
IF EXISTS(SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
      WHERE TABLE_NAME = 'TestTbl')
   DROP TABLE dbo.TestTbl
GO
CREATE TABLE TestTbl (a INT NOT NULL IDENTITY(1,1),b INT)
GO
INSERT TestTbl VALUES (1)
INSERT TestTbl VALUES (2)
SELECT * FROM TestTbl
GO

DECLARE @InsertOutput TABLE(a INT,B INT)
--将插入的记录输出
INSERT TestTbl
OUTPUT INSERTED.a, INSERTED.b INTO @InsertOutput
VALUES (3)
SELECT * FROM @InsertOutput

DECLARE @UpdateOutput TABLE(oldA INT,oldB INT,A INT,B INT)
--输出的时候通过 AS 字段位名称，或是用 * 代表所有的字段
UPDATE TestTbl 
SET b=5 
OUTPUT DELETED.*,INSERTED.* INTO @UpdateOutput
WHERE a=3
SELECT * FROM @UpdateOutput
