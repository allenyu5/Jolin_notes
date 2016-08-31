/***********************************************************************
Author="Kenneth Wang"
Create Date="2008/6/25"
***********************************************************************/

--===============================示例1=============================--

--查看当前用户进程锁的情况
USE AdventureWorks
SELECT * FROM sys.dm_tran_locks
WHERE request_session_id = @@spid

-- 开始事务 - 将创建锁
USE AdventureWorks
BEGIN TRANSACTION
UPDATE Production.ProductCategory
SET [Name] = [Name] + ' - Bike Stuff'

--查看当前用户进程锁的情况
USE AdventureWorks
SELECT * FROM sys.dm_tran_locks
WHERE request_session_id = @@spid

-- 更新另外一个表 - 将创建锁
UPDATE Production.Product
SET ListPrice = ListPrice * 1.1

--查看当前用户进程锁的情况
USE AdventureWorks
SELECT * FROM sys.dm_tran_locks
WHERE request_session_id = @@spid

-- 回滚事务 - 将释放锁
ROLLBACK TRANSACTION

--查看当前用户进程锁的情况
USE AdventureWorks
SELECT * FROM sys.dm_tran_locks
WHERE request_session_id = @@spid

--==========================示例2===================================--

--如果runnable_tasks_count大于0,表示有些任务 
--正等待他们的CPU时间片
--runnable_tasks_count:已分配任务并且正在可运行队列中等待被调度的工作线程数。
SELECT scheduler_id, current_tasks_count, runnable_tasks_count
	FROM sys.dm_os_schedulers 
	WHERE scheduler_id < 255

--找出最消耗CPU时间的50个执行计划
SELECT TOP 50 q.text AS query_text,
		SUM(qs.total_worker_time) AS total_cpu_time,  
		SUM(qs.execution_count) AS total_execution_count, 
		COUNT(*) AS  number_of_statements		 
	FROM sys.dm_exec_query_stats qs 
		CROSS APPLY sys.dm_exec_sql_text(plan_handle) q
	GROUP BY q.text
	ORDER BY SUM(qs.total_worker_time) DESC

--找出消耗资源最多的10个查询
SELECT TOP 10 creation_time, last_execution_time, 
    execution_count, total_worker_time, 
	total_physical_reads, total_logical_reads + 
	total_logical_writes as total_logical_io,
    SUBSTRING(st.text, (qs.statement_start_offset/2) + 1,
    ((CASE statement_end_offset 
        WHEN -1 THEN DATALENGTH(st.text)
        ELSE qs.statement_end_offset END 
            - qs.statement_start_offset)/2) + 1) as statement_text
FROM sys.dm_exec_query_stats as qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as st
ORDER BY total_worker_time DESC
GO

--获得所有索引的碎片及密度情况
SELECT 
OBJECT_NAME (ips.[object_id]) AS 'Object Name', 
si.name AS 'Index Name', 
ROUND (ips.avg_fragmentation_in_percent, 2) AS 'Fragmentation', 
ips.page_count AS 'Pages', ROUND (ips.avg_page_space_used_in_percent, 2) AS 'Page Density' 
FROM sys.dm_db_index_physical_stats ( 
DB_ID ('northwind'), NULL, NULL, NULL, 'DETAILED') ips 
CROSS APPLY sys.indexes si  
WHERE si.object_id = ips.object_id  
AND si.index_id = ips.index_id  
AND ips.index_level = 0 -- only the leaf level  AND ips.avg_fragmentation_in_percent > 10; -- filter on fragmentation
GO