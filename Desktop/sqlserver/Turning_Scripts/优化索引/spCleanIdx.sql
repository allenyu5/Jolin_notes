/***********************************************************************
Author="Kenneth Wang"
Create Date="2007/9/7"
***********************************************************************/


/*
** 这个存储过程会删除掉指定数据表所有的统计和索引
**
**  语法 EXEC spCleanIdx <tablename>
**
**  这个存储过程不处理 CONSTRAINTS
**  只检查并删除现有的索引和统计
*/
USE northwind
GO

-- 若已经存在了 spCleanIdx 存储过程，则先移除它
IF EXISTS (SELECT name FROM sysobjects WHERE id = OBJECT_ID('spCleanIdx')
		AND OBJECTPROPERTY(OBJECT_ID('spCleanIdx'),'IsProcedure')=1)
   DROP PROCEDURE spCleanIdx
GO
CREATE PROCEDURE spCleanIdx
	@tabname nvarchar(150) -- 需要删除统计或索引的数据表
AS

/*
建立新的存储过程
*/

DECLARE @idx_name        nvarchar(150) -- 存放要删除的索引或统计的名称
DECLARE @drop_idx_string nvarchar(200) -- 存放动态组织而成的 DROPS  index/stats 语法

--SET NOCOUNT ON

--  检视用户所指定的数据表是否存在
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
	       WHERE table_type = 'base table' AND table_name = @tabname)
	BEGIN
		RAISERROR(N'数据表： ''%s'' 并不存在',16, 1, @tabname)
		RETURN (1)
	END

SET @tabname = OBJECT_ID(@tabname)
IF EXISTS (SELECT id FROM sysindexes
	   WHERE id=@tabname AND indid BETWEEN 1 AND 254
			     AND status IN (96,10485856,8388704))
BEGIN
   DECLARE idx_cursor CURSOR 
      FOR SELECT name FROM sysindexes
	  WHERE id=@tabname AND indid BETWEEN 1 AND 254
			    AND status IN (96,10485856,8388704)
   OPEN idx_cursor
   FETCH NEXT FROM idx_cursor INTO @idx_name
     WHILE @@FETCH_STATUS = 0
	BEGIN
	   SET @drop_idx_string = ('DROP STATISTICS '+OBJECT_NAME(@tabname)+'.'+@idx_name)
	   EXECUTE(@drop_idx_string)
	   FETCH NEXT FROM idx_cursor INTO @idx_name
	END
   CLOSE idx_cursor
   DEALLOCATE idx_cursor
END
PRINT N'     *** 统计删除完毕 ***'

IF EXISTS (SELECT id FROM sysindexes
	   WHERE id=@tabname AND indid BETWEEN 1 AND 254
			     AND status NOT IN (96,10485856,8388704))
BEGIN
   DECLARE idx_cursor CURSOR 
      FOR SELECT name FROM sysindexes
	  WHERE id=@tabname AND indid BETWEEN 1 AND 254
			    AND status NOT IN (96,10485856,8388704)
   OPEN idx_cursor
   FETCH NEXT FROM idx_cursor INTO @idx_name
     WHILE @@FETCH_STATUS = 0
	BEGIN
		--确定要删除的索引不是当做 Constraint
		IF OBJECTPROPERTY (OBJECT_ID(@idx_name),'IsConstraint') IS NULL
		BEGIN
		   SET @drop_idx_string = ('DROP INDEX '+OBJECT_NAME(@tabname)+'.'+@idx_name)
		   EXECUTE(@drop_idx_string)
		END
	   FETCH NEXT FROM idx_cursor INTO @idx_name
	END
   CLOSE idx_cursor
   DEALLOCATE idx_cursor
END
PRINT N'     *** 索引删除完毕 ***'

GO