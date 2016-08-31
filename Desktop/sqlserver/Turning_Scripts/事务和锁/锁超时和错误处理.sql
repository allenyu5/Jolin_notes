use northwind
go

CREATE PROC spTestLockTimeout @Cust1 VARCHAR(20),@Cust2 VARCHAR(20)
AS
SET LOCK_TIMEOUT 500	--等 500 ms

--若不自己撰写错误处理，就要设定 XACT_ABORT
--让错误一发生就自动放弃当下前的事务
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
		RETURN 100	--自定义错误消息
	END
COMMIT TRAN
RETURN 0

--SQL Server 2005 的 Try Catch 错误处理语法
create PROC spTestLockTimeout @Cust1 VARCHAR(20),@Cust2 VARCHAR(20)
AS
SET LOCK_TIMEOUT 500	--等 500 ms
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

--连接1
begin tran
	update customers set companyname='test1' where customerid='alfki'
	waitfor delay '00:00:30'
rollback tran


--连接2
use northwind
go

declare @ret int
exec @ret=spTestLockTimeout 'test5','test7'
select @ret

select * from customers where customerid='anatr'