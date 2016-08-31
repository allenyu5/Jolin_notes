set nocount on
go
while 1=1
begin
	begin tran
		update dbo.employee_demo_heap
		set birthdate=getdate()
		where nationalidnumber='480951955'
		select * from dbo.employee_demo_heap
		where nationalidnumber='480951955'
	commit tran
end