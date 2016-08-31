use AdventureWorks
go
If exists (select * from sys.objects where name='ResponseLog')
	drop table ResponseLog
go
Create table ResponseLog (responsetime_mcs int, DateAndTime Datetime2)

go
If exists(select * from sys.procedures where name = 'WhatIf')
	drop proc WhatIf
go
Create proc WhatIf (@changePercent int)
as
begin
	declare @dtstart as datetime2
	set @dtstart = SYSDATETIME()
	begin tran
	select * into #prods 
	from Purchasing.ProductVendor
	where MinOrderQty < 30
	
	-- 
	Update #prods 
	set standardprice = (standardprice * (100.0 + @changePercent))/100.0
	
	select IncreasedPrice=SUM(standardprice) from #prods
	
	drop table #prods
	rollback
	
	insert ResponseLog values (datediff(mcs, @dtstart, SYSDATETIME()), SYSDATETIME ())
	
end

go

!!C:\Program Files\Microsoft Corporation\RMLUtils\ostress.exe -S. -E -Q"exec WhatIf 10" -r15 -n20 -dAdventureWorks
