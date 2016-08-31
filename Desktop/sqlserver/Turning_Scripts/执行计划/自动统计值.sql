USE tempdb 
GO

IF object_id(N'Person.Contact','U') IS NOT NULL
	DROP TABLE Person.Contact
GO
IF EXISTS (SELECT * FROM sys.schemas WHERE name = N'Person')
	DROP SCHEMA Person
GO
CREATE SCHEMA Person
GO
CREATE TABLE Person.Contact(
	FirstName nvarchar(60), 
	LastName nvarchar(60), 
	Phone nvarchar(15), 
	Title nvarchar(15)
)
GO
INSERT INTO Person.Contact 
   VALUES(N'James',N'Smith',N'425-555-1234',N'Mr')
INSERT INTO Person.Contact 
   VALUES(N'James',N'Andersen',N'425-555-1111',N'Mr')
INSERT INTO Person.Contact 
   VALUES(N'James',N'Andersen',N'425-555-3333',N'Mr')
INSERT INTO Person.Contact 
   VALUES(N'Christine',N'Williams',N'425-555-0000',N'Dr')
INSERT INTO Person.Contact 
   VALUES(N'Susan',N'Zhang',N'425-555-2222',N'Ms')
GO

sp_helpstats N'Person.Contact', 'ALL'
GO

SELECT * FROM Person.Contact WHERE LastName = N'Andersen'
GO

sp_helpstats N'Person.Contact', 'ALL'
GO
