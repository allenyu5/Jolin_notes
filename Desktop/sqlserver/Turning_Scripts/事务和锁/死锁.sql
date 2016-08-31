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
SET DEADLOCK_PRIORITY LOW
BEGIN TRAN
	UPDATE Person.Address SET City = 'Bothell_A' WHERE City = 'Bothell'
	UPDATE Sales.SalesTerritory SET CountryRegionCode = 'GB' WHERE CountryRegionCode = 'UK'
ROLLBACK TRAN

-------------------处理死锁
--重试次数
DECLARE @retry INT

SET @retry = 3

WHILE ( @retry > 0 ) 
    BEGIN
        BEGIN TRY
   --这里是业务代码
   
   --事务成功，将重试次数变为
            SET @retry = 0
        END TRY
   
        BEGIN CATCH
   --如果是死锁，则重试
            IF ( ERROR_NUMBER() = 1205 ) 
                SET @retry = @retry
            ELSE 
                BEGIN
      --如果是其它错误，记录到日志等..
                END
      
        END CATCH
    END