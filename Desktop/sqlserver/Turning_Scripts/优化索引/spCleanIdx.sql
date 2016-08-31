/***********************************************************************
Author="Kenneth Wang"
Create Date="2007/9/7"
***********************************************************************/


/*
** ����洢���̻�ɾ����ָ�����ݱ����е�ͳ�ƺ�����
**
**  �﷨ EXEC spCleanIdx <tablename>
**
**  ����洢���̲����� CONSTRAINTS
**  ֻ��鲢ɾ�����е�������ͳ��
*/
USE northwind
GO

-- ���Ѿ������� spCleanIdx �洢���̣������Ƴ���
IF EXISTS (SELECT name FROM sysobjects WHERE id = OBJECT_ID('spCleanIdx')
		AND OBJECTPROPERTY(OBJECT_ID('spCleanIdx'),'IsProcedure')=1)
   DROP PROCEDURE spCleanIdx
GO
CREATE PROCEDURE spCleanIdx
	@tabname nvarchar(150) -- ��Ҫɾ��ͳ�ƻ����������ݱ�
AS

/*
�����µĴ洢����
*/

DECLARE @idx_name        nvarchar(150) -- ���Ҫɾ����������ͳ�Ƶ�����
DECLARE @drop_idx_string nvarchar(200) -- ��Ŷ�̬��֯���ɵ� DROPS  index/stats �﷨

--SET NOCOUNT ON

--  �����û���ָ�������ݱ��Ƿ����
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
	       WHERE table_type = 'base table' AND table_name = @tabname)
	BEGIN
		RAISERROR(N'���ݱ� ''%s'' ��������',16, 1, @tabname)
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
PRINT N'     *** ͳ��ɾ����� ***'

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
		--ȷ��Ҫɾ�����������ǵ��� Constraint
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
PRINT N'     *** ����ɾ����� ***'

GO