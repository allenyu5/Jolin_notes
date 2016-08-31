--查询SQL Server内存使用情况
select type,sum(virtual_memory_reserved_kb) as [vm_reserved],
sum(virtual_memory_committed_kb) as [vm_committed],
sum(awe_allocated_kb) as [AWE Allocated],
sum(shared_memory_reserved_kb) as [SM Reserved],
sum(shared_memory_committed_kb) as [SM Committed],
sum(pages_kb) as [Page Allocator]
from sys.dm_os_memory_clerks
group by type
order by [Page Allocator] desc

dbcc memorystatus

select name,type,pages_kb,pages_in_use_kb,entries_count,entries_in_use_count
from sys.dm_os_memory_cache_counters
order by pages_kb desc 

--buffer pool中数据页面缓存
declare @name nvarchar(100)
declare @cmd nvarchar(1000)
declare dbnames cursor for 
select name from [master].dbo.sysdatabases
open dbnames
fetch next from dbnames into @name
while @@FETCH_STATUS = 0
begin 
set @cmd='select b.database_id,db=db_name(b.database_id),p.object_id,p.index_id,
buffer_count=count(*) from '+ @name + '.sys.allocation_units a,'+ @name + '.sys.dm_os_buffer_descriptors b, '+ @name + '.sys.partitions p where a.allocation_unit_id=b.allocation_unit_id and a.container_id=p.hobt_id and b.database_id=db_id('''+ @name+ ''') group by b.database_id,p.object_id,P.index_id order by b.database_id,buffer_count desc'
exec (@cmd)
fetch next from dbnames into @name
end
close dbnames
deallocate dbnames
go


select count(*)*8/1024 as 'cache size(MB)',
case database_id
when 32767 then 'resourcedb'
else db_name(database_id)
end as 'database'
from sys.dm_os_buffer_descriptors
group by db_name(database_id),database_id
order by  'cache size(MB)' desc


-----执行计划缓存
select count(*) as 'number of plans',
sum(cast(size_in_bytes as bigint))/1024/1024 as 'plan cache size(MB)'
from sys.dm_exec_cached_plans

select objtype as 'cache object type',count(*) as 'number of plans',
sum(cast(size_in_bytes as bigint))/1024/1024 as 'plan cache size(MB)',
avg(usecounts) as 'avg user count'
from sys.dm_exec_cached_plans
group by objtype

select usecounts,refcounts,size_in_bytes,cacheobjtype,objtype,text
from sys.dm_exec_cached_plans cp cross apply sys.dm_exec_sql_text(plan_handle)
order by objtype desc




