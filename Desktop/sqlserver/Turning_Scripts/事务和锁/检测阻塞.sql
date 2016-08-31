USE master
GO
EXEC sp_configure 'show advanced options', 1 ;
GO
RECONFIGURE ;
GO
EXEC sp_configure 'blocked process threshold', 20 ;
GO
RECONFIGURE ;
GO

USE AdventureWorks
GO

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN
	UPDATE Sales.SalesTerritory SET CountryRegionCode = 'USA' WHERE CountryRegionCode = 'US' 
	UPDATE Person.Address SET City = 'Dallas_B' WHERE City = 'Dallas'
ROLLBACK TRAN

USE AdventureWorks
GO

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN
	UPDATE Person.Address SET City = 'Bothell_A' WHERE City = 'Bothell'
ROLLBACK TRAN

USE master
GO
EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE ;
GO
EXEC sp_configure 'blocked process threshold', 0;
GO
RECONFIGURE ;
GO
