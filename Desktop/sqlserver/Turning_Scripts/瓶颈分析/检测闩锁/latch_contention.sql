-- A particular highly used portion of an LOB analysis application 
-- has recently started encountering slow downs during periods of 
-- high load on the system.  

-- To investigate the slowdowns the response time of the application
-- function has been captured.  When run alone the logic completes in 
-- ~20 ms, but can take up to 10 seconds when the system is under load
--
--truncate table AdventureWorks2008..ResponseLog
Select * from AdventureWorks..ResponseLog order by responsetime_mcs desc

use AdventureWorks
go
-- Look for any suspicious waits during execution
--
begin try
	Drop table #waits_base
end try
begin catch
	print 'base waits table does not exist'
end catch

Select * into #waits_base from sys.dm_os_wait_stats

select * from #waits_base
-- Execute workload and compare waits
--
!! ostress.exe -S. -E -Q"exec WhatIf 10" -r15 -n20 -dAdventureWorks

-- Compare base snapshot with current waits
--
Select w.wait_type, wait_count_delta = w.waiting_tasks_count - b.waiting_tasks_count, 
	wait_time = w.wait_time_ms - b.wait_time_ms
 from sys.dm_os_wait_stats w inner join #waits_base b on b.wait_type = w.wait_type
 order by wait_count_delta desc

-- Significant number of waits on latches
-- Create an event session that captures latch suspend events
-- and track down where the stalls are occurring

If Exists(select * from sys.server_event_sessions where name = 'latch_contention')
	drop event session latch_contention on server
go
create event session latch_contention on server
add event sqlserver.latch_suspend_end (
	action (sqlserver.tsql_stack, package0.callstack)
	where (mode=4 or mode=3 /*Exclusive or UP latches*/) 
	and sqlserver.is_system = 0)
add target package0.ring_buffer,
add target package0.asynchronous_bucketizer (
	set filtering_event_name = 'sqlserver.latch_suspend_end',
	source_type = 1,
	source = 'sqlserver.tsql_stack',
	slots=2048)
with (max_dispatch_latency = 5 seconds)
go
alter event session latch_contention on server
state = start
go
-- Run Workload
!! ostress.exe -S. -E -Q"exec WhatIf 10" -r15 -n20 -dAdventureWorks


go
-- Raw output from bucketizer shows the stack suspending on the most latches
--
select bucket_count, tsql_stack, 
SUBSTRING(st.text, (XmlParsedOutput.offsetStart/2)+1, 
        ((CASE XmlParsedOutput.offsetEnd
          WHEN -1 THEN DATALENGTH(st.text)
         ELSE XmlParsedOutput.offsetEnd
         END - XmlParsedOutput.offsetStart)/2) + 1) AS statement_text,
OBJECT_NAME(st.objectid, st.dbid)
from (
	select bucket_count,tsql_stack,
	convert(varbinary(64), tsql_stack.value('(//frame/@handle)[1]' , 'nvarchar(100)'), 1) as handle,
	tsql_stack.value('(//frame/@offsetStart)[1]' , 'int') offsetStart,
	tsql_stack.value('(//frame/@offsetEnd)[1]' , 'int') offsetEnd
	from (
		select bucket_count=slots.value('@count', 'bigint' ),
			tsql_stack = cast('<frames>' + slots.value('.', 'nvarchar(4000)') + '</frames>' as xml)
		FROM (select cast(xest.target_data as xml) as b
			from sys.dm_xe_session_targets xest
			join sys.dm_xe_sessions xes on xes.address = xest.event_session_address
			where xest.target_name = 'asynchronous_bucketizer' and xes.name = 'latch_contention'
		) buckets
		CROSS APPLY b.nodes('//BucketizerTarget/Slot') as T(slots)
	) as RawOutput
) as XmlParsedOutput
cross apply sys.dm_exec_sql_text(handle) as st


-- Change statement to avoid contention and run workload again
--
exec sp_helptext 'WhatIf'

!! ostress.exe -S. -E -Q"exec WhatIf 10" -r15 -n20 -dAdventureWorks


Select * from AdventureWorks..ResponseLog order by dateandtime desc

go
alter event session latch_contention on server
state = stop

go

drop event session latch_contention on server


