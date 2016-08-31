--Step 1: Create demo environment
CREATE DATABASE CompressionDemo
GO
USE CompressionDemo
GO

CREATE TABLE dbo.Customer_UnCompress(
	CustomerKey int NOT NULL,
	GeographyKey int NULL,
	CustomerAlternateKey nvarchar(15) NOT NULL,
	Title nvarchar(8) NULL,
	FirstName nvarchar(50) NULL,
	MiddleName nvarchar(50) NULL,
	LastName nvarchar(50) NULL,
	NameStyle bit NULL,
	BirthDate datetime NULL,
	MaritalStatus nchar(1) NULL,
	Suffix nvarchar(10) NULL,
	Gender nvarchar(1) NULL,
	EmailAddress nvarchar(50) NULL,
	YearlyIncome money NULL,
	TotalChildren tinyint NULL,
	NumberChildrenAtHome tinyint NULL,
	EnglishEducation nvarchar(40) NULL,
	SpanishEducation nvarchar(40) NULL,
	FrenchEducation nvarchar(40) NULL,
	EnglishOccupation nvarchar(100) NULL,
	SpanishOccupation nvarchar(100) NULL,
	FrenchOccupation nvarchar(100) NULL,
	HouseOwnerFlag nchar(1) NULL,
	NumberCarsOwned tinyint NULL,
	AddressLine1 nvarchar(120) NULL,
	AddressLine2 nvarchar(120) NULL,
	Phone nvarchar(20) NULL,
	DateFirstPurchase datetime NULL,
	CommuteDistance nvarchar(15) NULL,
 CONSTRAINT PK_Customer_UnCompress PRIMARY KEY CLUSTERED (CustomerKey ASC),
 CONSTRAINT IX_Customer_UnCompress_CustomerAlternateKey UNIQUE NONCLUSTERED (CustomerAlternateKey ASC)
)
GO

CREATE TABLE dbo.Customer_RowCompress(
	CustomerKey int NOT NULL,
	GeographyKey int NULL,
	CustomerAlternateKey nvarchar(15) NOT NULL,
	Title nvarchar(8) NULL,
	FirstName nvarchar(50) NULL,
	MiddleName nvarchar(50) NULL,
	LastName nvarchar(50) NULL,
	NameStyle bit NULL,
	BirthDate datetime NULL,
	MaritalStatus nchar(1) NULL,
	Suffix nvarchar(10) NULL,
	Gender nvarchar(1) NULL,
	EmailAddress nvarchar(50) NULL,
	YearlyIncome money NULL,
	TotalChildren tinyint NULL,
	NumberChildrenAtHome tinyint NULL,
	EnglishEducation nvarchar(40) NULL,
	SpanishEducation nvarchar(40) NULL,
	FrenchEducation nvarchar(40) NULL,
	EnglishOccupation nvarchar(100) NULL,
	SpanishOccupation nvarchar(100) NULL,
	FrenchOccupation nvarchar(100) NULL,
	HouseOwnerFlag nchar(1) NULL,
	NumberCarsOwned tinyint NULL,
	AddressLine1 nvarchar(120) NULL,
	AddressLine2 nvarchar(120) NULL,
	Phone nvarchar(20) NULL,
	DateFirstPurchase datetime NULL,
	CommuteDistance nvarchar(15) NULL,
 CONSTRAINT PK_Customer_RowCompress PRIMARY KEY CLUSTERED (CustomerKey ASC),
 CONSTRAINT IX_Customer_RowCompress_CustomerAlternateKey UNIQUE NONCLUSTERED (CustomerAlternateKey ASC)
) WITH (DATA_COMPRESSION = ROW)
GO

CREATE TABLE dbo.Customer_PageCompress(
	CustomerKey int NOT NULL,
	GeographyKey int NULL,
	CustomerAlternateKey nvarchar(15) NOT NULL,
	Title nvarchar(8) NULL,
	FirstName nvarchar(50) NULL,
	MiddleName nvarchar(50) NULL,
	LastName nvarchar(50) NULL,
	NameStyle bit NULL,
	BirthDate datetime NULL,
	MaritalStatus nchar(1) NULL,
	Suffix nvarchar(10) NULL,
	Gender nvarchar(1) NULL,
	EmailAddress nvarchar(50) NULL,
	YearlyIncome money NULL,
	TotalChildren tinyint NULL,
	NumberChildrenAtHome tinyint NULL,
	EnglishEducation nvarchar(40) NULL,
	SpanishEducation nvarchar(40) NULL,
	FrenchEducation nvarchar(40) NULL,
	EnglishOccupation nvarchar(100) NULL,
	SpanishOccupation nvarchar(100) NULL,
	FrenchOccupation nvarchar(100) NULL,
	HouseOwnerFlag nchar(1) NULL,
	NumberCarsOwned tinyint NULL,
	AddressLine1 nvarchar(120) NULL,
	AddressLine2 nvarchar(120) NULL,
	Phone nvarchar(20) NULL,
	DateFirstPurchase datetime NULL,
	CommuteDistance nvarchar(15) NULL,
 CONSTRAINT PK_Customer_PageCompress PRIMARY KEY CLUSTERED (CustomerKey ASC),
 CONSTRAINT IX_Customer_PageCompress_CustomerAlternateKey UNIQUE NONCLUSTERED (CustomerAlternateKey ASC)
) WITH (DATA_COMPRESSION = PAGE)
GO

--Step 2: Load data into demo tables
INSERT INTO Customer_UnCompress SELECT * FROM AdventureWorksDW.dbo.DimCustomer;
INSERT INTO Customer_RowCompress SELECT * FROM AdventureWorksDW.dbo.DimCustomer;
INSERT INTO Customer_PageCompress SELECT * FROM AdventureWorksDW.dbo.DimCustomer;

--Step 3: Compare the storage cost for each compression setting
----------The storage size here are estimated value, you may check the SSMS report
----------"Disk Usage by Table" for more details
SELECT * FROM (
SELECT OBJECT_NAME(object_id) AS TableName, 
		CASE index_type_desc WHEN 'CLUSTERED INDEX' THEN 'Data' ELSE 'Index' END AS Type, 
		page_count * 8 AS Size
	FROM sys.dm_db_index_physical_stats(DB_ID('CompressionDemo'), OBJECT_ID('dbo.Customer_UnCompress'), NULL, NULL, DEFAULT)
	--WHERE index_type_desc = 'CLUSTERED INDEX'
UNION
SELECT OBJECT_NAME(object_id) AS TableName,
		CASE index_type_desc WHEN 'CLUSTERED INDEX' THEN 'Data' ELSE 'Index' END AS Type, 
		page_count * 8 AS Size
	FROM sys.dm_db_index_physical_stats(DB_ID('CompressionDemo'), OBJECT_ID('dbo.Customer_RowCompress'), NULL, NULL, DEFAULT)
	--WHERE index_type_desc = 'CLUSTERED INDEX'
UNION
SELECT OBJECT_NAME(object_id) AS TableName,
		CASE index_type_desc WHEN 'CLUSTERED INDEX' THEN 'Data' ELSE 'Index' END AS Type, 
		page_count * 8 AS Size
	FROM sys.dm_db_index_physical_stats(DB_ID('CompressionDemo'), OBJECT_ID('dbo.Customer_PageCompress'), NULL, NULL, DEFAULT)
	--WHERE index_type_desc = 'CLUSTERED INDEX'
) AS t ORDER BY TableName, Type


--Step 4: Compare the IO statistics for selecting data from three tables
DBCC DROPCLEANBUFFERS
SET STATISTICS IO ON

SELECT * FROM Customer_UnCompress

SELECT * FROM Customer_RowCompress

SELECT * FROM Customer_PageCompress