/***********************************************************************
Author="Kenneth Wang"
Create Date="2007/12/12"
***********************************************************************/

Use master
Drop Database Sales
go

CREATE DATABASE Sales
PRINT 'Database ''Sales'' has been created.'
GO

ALTER DATABASE Sales ADD FILEGROUP FG1
ALTER DATABASE Sales ADD FILE 
(
	NAME = File1,
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Data\File1.ndf',
	SIZE = 1MB,
	MAXSIZE = 100MB,
	FILEGROWTH = 10%
) TO FILEGROUP FG1
GO
PRINT 'File Group 1 has been generated.'
ALTER DATABASE Sales ADD FILEGROUP FG2
ALTER DATABASE Sales ADD FILE 
(
	NAME = File2,
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Data\File2.ndf',
	SIZE = 1MB,
	MAXSIZE = 100MB,
	FILEGROWTH = 10%
) TO FILEGROUP FG2
GO
PRINT 'File Group 2 has been generated.'
ALTER DATABASE Sales ADD FILEGROUP FG3
ALTER DATABASE Sales ADD FILE 
(
	NAME = File3,
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Data\File3.ndf',
	SIZE = 1MB,
	MAXSIZE = 100MB,
	FILEGROWTH = 10%
) TO FILEGROUP FG3
GO
PRINT 'File Group 3 has been generated.'
ALTER DATABASE Sales ADD FILEGROUP FG4
ALTER DATABASE Sales ADD FILE 
(
	NAME = File4,
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Data\File4.ndf',
	SIZE = 1MB,
	MAXSIZE = 100MB,
	FILEGROWTH = 10%
) TO FILEGROUP FG4
GO
PRINT 'File Group 4 has been generated.'
ALTER DATABASE Sales ADD FILEGROUP FG5
ALTER DATABASE Sales ADD FILE 
(
	NAME = File5,
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Data\File5.ndf',
	SIZE = 1MB,
	MAXSIZE = 100MB,
	FILEGROWTH = 10%
) TO FILEGROUP FG5
GO
PRINT 'File Group 5 has been generated.'
ALTER DATABASE Sales ADD FILEGROUP FG6
ALTER DATABASE Sales ADD FILE 
(
	NAME = File6,
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Data\File6.ndf',
	SIZE = 1MB,
	MAXSIZE = 100MB,
	FILEGROWTH = 10%
) TO FILEGROUP FG6
GO
PRINT 'File Group 6 has been generated.'