set nocount on
go
while 1=1
begin
	begin tran
		update dbo.employee_demo_heap
		set birthdate=getdate()
		where nationalidnumber='407505660'
		select * from dbo.employee_demo_heap
		where nationalidnumber='407505660'
	commit tran
end