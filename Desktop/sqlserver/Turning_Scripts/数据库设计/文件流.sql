USE master
GO
EXEC sys.sp_configure N'filestream access level', N'2'
GO
RECONFIGURE WITH OVERRIDE
GO

--�������ݿ�
CREATE DATABASE FSDemo ON
PRIMARY 
( 
	NAME = FSDemo_Data,
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\FSDemo_Data.mdf'
),
FILEGROUP FileStreamGroup CONTAINS FILESTREAM
( 
	NAME = FSDemo_FS,
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\FSDemo_FS'
)
LOG ON 
( 
	NAME = FSDemo_Log,
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\FSDemo_Log.ldf'
)
GO

USE FSDemo
GO

--�������ݱ�
CREATE TABLE Contents
(
	ID uniqueidentifier ROWGUIDCOL NOT NULL UNIQUE, 
	ContentCaption nvarchar(200) NOT NULL,
	[Version] INTEGER,
	Content VARBINARY(MAX) FILESTREAM NULL
)
GO

--��������
INSERT INTO Contents VALUES (newid (), 'Content 1', 1, CAST ('FileStream Demo' as varbinary(max)));
GO

--�������� SET Content = CAST ('FileStream Demo' as varbinary(max));

--��ѯ����
SELECT ID, ContentCaption, [Version], CAST(Content AS varchar(max)) AS Content FROM Contents

USE master
DROP DATABASE FSDemo