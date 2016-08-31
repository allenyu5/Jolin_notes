begin try
begin tran 
DECLARE @sql nvarchar(100)
SET @sql = 'SELECT * FROM Employee'
EXEC sp_executesql @sql
update HumanResources.Employee 
set LoginID='test' where EmployeeID=1
update Employee
set LoginID='test' where EmployeeID=1
commit tran
end try
begin catch
IF XACT_STATE() <> 0
		ROLLBACK
		select ERROR_MESSAGE()
end catch
rollback tran
select @@TRANCOUNT


---------------------------
set xact_abort on
begin try
begin tran 
update HumanResources.Employee 
set LoginID='test' where EmployeeID=1
update Employee
set LoginID='test' where EmployeeID=1
commit tran
end try
begin catch
IF XACT_STATE() <> 0
		ROLLBACK
		select ERROR_MESSAGE()
end catch
rollback tran
select @@TRANCOUNT
