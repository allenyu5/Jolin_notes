select type,memory_node_id,pages_kb,
virtual_memory_committed_kb,virtual_memory_reserved_kb 
from sys.dm_os_memory_clerks
order by virtual_memory_reserved_kb desc

select name,type,pages_kb,pages_in_use_kb,entries_count,entries_in_use_count
from sys.dm_os_memory_cache_counters
order by pages_kb desc 

select count(*)*8/1024 as 'cache size(MB)',
case database_id
when 32767 then 'resourcedb'
else db_name(database_id)
end as 'database'
from sys.dm_os_buffer_descriptors
group by db_name(database_id),database_id
order by  'cache size(MB)' desc

--������
--Memory Manager:total server memory(kb)   --buffer pool size
--Memory Manager:target server memory(kb)
--buffer manager:page life expectancy        (>300s)

-----�ƻ�����
select count(*) as 'number of plans',
sum(cast(size_in_bytes as bigint))/1024/1024 as 'plan cache size(MB)'
from sys.dm_exec_cached_plans

select objtype as 'cache object type',count(*) as 'number of plans',
sum(cast(size_in_bytes as bigint))/1024/1024 as 'plan cache size(MB)',
avg(usecounts) as 'avg user count'
from sys.dm_exec_cached_plans
group by objtype

dbcc freesystemcache('SQL Plans')

--���� adhoc����

--�������ڴ�(����hash)
set statistics io on
select HireDate,LoginID
from AdventureWorks.HumanResources.Employee
order by HireDate 

--��ѯ�ȴ�ѡ��:�ȴ��ڴ���Ȩʱ�����������ʱ
--���ܼ�����:Memory Management:Memory Grants Panding

--�ȴ����ͣ�Resource_Semaphore

--ִ�мƻ���Hash Warning��Sort_Warning