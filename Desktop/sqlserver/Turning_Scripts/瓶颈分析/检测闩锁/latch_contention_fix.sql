USE AdventureWorks
GO
/****** Object:  StoredProcedure [dbo].[WhatIf]    Script Date: 05/31/2008 21:28:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[WhatIf] (@changePercent int)
as
begin
	declare @dtstart as datetime2
	set @dtstart = SYSDATETIME()
	select IncreasedPrice = SUM((standardprice * (100.0 + @changePercent))/100.0)
	from Purchasing.ProductVendor
	insert ResponseLog values (datediff(mcs, @dtstart, SYSDATETIME()), SYSDATETIME ())
	
end

