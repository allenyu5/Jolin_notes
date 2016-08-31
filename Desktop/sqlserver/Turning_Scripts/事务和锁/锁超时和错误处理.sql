use northwind
go

CREATE PROC spTestLockTimeout @Cust1 VARCHAR(20),@Cust2 VARCHAR(20)
AS
SET LOCK_TIMEOUT 500	--�� 500 ms

--�����Լ�׫д��������Ҫ�趨 XACT_ABORT�A
--�ô���һ�������Զ���������ǰ������
--SET XACT_ABORT ON

DECLARE @Err1 INT, @Err2 INT
BEGIN TRAN
	UPDATE Customers SET CompanyName=@Cust2 WHERE CustomerID='anatr'
	SET @Err1=@@Error
	UPDATE Customers SET CompanyName=@Cust1 WHERE CustomerID='alfki'
	SET @Err2=@@Error
	IF @Err1 <> 0 OR @Err2 <> 0 
	BEGIN
		ROLLBACK TRAN
		RETURN 100	--�Զ��������Ϣ
	END
COMMIT TRAN
RETURN 0

--SQL Server 2005 �� Try Catch �������﷨
create PROC spTestLockTimeout @Cust1 VARCHAR(20),@Cust2 VARCHAR(20)
AS
SET LOCK_TIMEOUT 500	--�� 500 ms
DECLARE @ret INT
SET @ret=0
BEGIN TRY
	BEGIN TRAN
	  UPDATE Customers SET CompanyName=@Cust2 WHERE CustomerID='anatr'
	  UPDATE Customers SET CompanyName=@Cust1 WHERE CustomerID='alfki'
	COMMIT TRAN
END TRY
BEGIN CATCH
	IF XACT_STATE() <> 0
		ROLLBACK
	SET @ret=ERROR_NUMBER()
END CATCH
RETURN @ret

--����1
begin tran
	update customers set companyname='test1' where customerid='alfki'
	waitfor delay '00:00:30'
rollback tran


--����2
use northwind
go

declare @ret int
exec @ret=spTestLockTimeout 'test5','test7'
select @ret

select * from customers where customerid='anatr'