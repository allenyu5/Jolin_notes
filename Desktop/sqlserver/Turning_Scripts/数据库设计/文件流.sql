USE master
GO
EXEC sys.sp_configure N'filestream access level', N'2'
GO
RECONFIGURE WITH OVERRIDE
GO

--创建数据库
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

--创建数据表
CREATE TABLE Contents
(
	ID uniqueidentifier ROWGUIDCOL NOT NULL UNIQUE, 
	ContentCaption nvarchar(200) NOT NULL,
	[Version] INTEGER,
	Content VARBINARY(MAX) FILESTREAM NULL
)
GO

--插入数据
INSERT INTO Contents VALUES (newid (), 'Content 1', 1, CAST ('FileStream Demo' as varbinary(max)));
GO

--更新内容 SET Content = CAST ('FileStream Demo' as varbinary(max));

--查询数据
SELECT ID, ContentCaption, [Version], CAST(Content AS varchar(max)) AS Content FROM Contents

USE master
DROP DATABASE FSDemo