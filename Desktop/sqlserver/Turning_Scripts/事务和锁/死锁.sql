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

-------------------��������
--���Դ���
DECLARE @retry INT

SET @retry = 3

WHILE ( @retry > 0 ) 
    BEGIN
        BEGIN TRY
   --������ҵ�����
   
   --����ɹ��������Դ�����Ϊ
            SET @retry = 0
        END TRY
   
        BEGIN CATCH
   --�����������������
            IF ( ERROR_NUMBER() = 1205 ) 
                SET @retry = @retry
            ELSE 
                BEGIN
      --������������󣬼�¼����־��..
                END
      
        END CATCH
    END