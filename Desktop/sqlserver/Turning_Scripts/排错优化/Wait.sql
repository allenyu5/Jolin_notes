
--执行模型
--SQLOS：SQL自己的资源管理器
----一个逻辑CPU一个Scheduler
---工作线程分配到调度器（维护一个工作线程池，同一时间只能运行一个工作线程）
------5个列表（自动让出机制）：
 --------Worker列表：没有分配任务正等待分配任务线程列表
--------- Waiter列表：请求了资源的工作线程
---------Runnable列表：不等待资源但等待CPU调度
---------I/O列表：需要IO操作的工作线程
---------定时器列表：如Waitfordelay

select * from sys.dm_os_schedulers where status='VISIBLE ONLINE'  --所有的调度器
select * from sys.dm_os_workers    --调度器上的工作线程
select * from sys.dm_os_waiting_tasks where session_id>50   --正在等待的任务
	select wait_type,count(*) as num_waiting_tasks,sum(wait_duration_ms) total_wait_time_ms
	from  sys.dm_os_waiting_tasks  where session_id>50
	group by wait_type
	order by wait_type

select * from sys.dm_exec_requests where session_id>50--可运行列表中等待CPU调度的任务
select * from  sys.dm_os_wait_stats  where wait_time_ms>0 order by wait_time_ms desc --累计等待统计信息

--资源等待类型
--1、内存等待：CMEMTHREAD(计划缓存),RESOURCE_SEMAPHORE（请求内存）
---------相关计数器：Memory Manager:Memory Grants Pending(等待的内存授予数) 不可以大于0
------------------------：Memory Manager:Memory Grants OUtstanding(获取的内存授予数)
------------------------：Buffer Manager：Buffer Cache Hit Ratio（缓冲区命中率） 不可以小于95%
------------------------：Buffer Manager：Page Life Expentancy（页面期望周期）  不可以小于300
------------------------：Buffer Manager：Free Pages（空闲页面数）
------------------------：Buffer Manager：Free List Stalls/Sec(每秒等待空闲页的请求数)
------------------------：Memory：Available Mbytes（可用内存）    不可以小于100MB

--IO等待：IO_Completion,Async_IO_Completion,Writelog,Pageiolatch_* （闩锁）
--------相关计数器：Average disk sec/read,Average disk sec/write 不可以大于20ms
-----------------------Access Methods：Full Scans/sec，Index Searchs/sec，Forwarded Records/sec
--------相关函数fn_virtualfilestats
select mf.name,mf.physical_name,vfs.IoStallMS,
vfs.IoStallReadMS/NumberReads as avgreadsec,
vfs.IoStallWriteMS/NumberWrites as avgreadsec
from sys.fn_virtualfilestats(null,null) as vfs 
join sys.master_files as mf 
on mf.database_id=vfs.DbId and mf.file_id=vfs.FileId

--CPU等待：SOS_SCHEDULER_YIELD（等待时间片），CXPACKET（并行处理）


--阻塞等待：LCK_*
----相关DMV
select * from sys.dm_tran_active_transactions

