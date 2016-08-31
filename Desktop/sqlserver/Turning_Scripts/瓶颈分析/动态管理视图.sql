/***********************************************************************
Author="Kenneth Wang"
Create Date="2008/6/25"
***********************************************************************/

--===============================ʾ��1=============================--

--�鿴��ǰ�û������������
USE AdventureWorks
SELECT * FROM sys.dm_tran_locks
WHERE request_session_id = @@spid

-- ��ʼ���� - ��������
USE AdventureWorks
BEGIN TRANSACTION
UPDATE Production.ProductCategory
SET [Name] = [Name] + ' - Bike Stuff'

--�鿴��ǰ�û������������
USE AdventureWorks
SELECT * FROM sys.dm_tran_locks
WHERE request_session_id = @@spid

-- ��������һ���� - ��������
UPDATE Production.Product
SET ListPrice = ListPrice * 1.1

--�鿴��ǰ�û������������
USE AdventureWorks
SELECT * FROM sys.dm_tran_locks
WHERE request_session_id = @@spid

-- �ع����� - ���ͷ���
ROLLBACK TRANSACTION

--�鿴��ǰ�û������������
USE AdventureWorks
SELECT * FROM sys.dm_tran_locks
WHERE request_session_id = @@spid

--==========================ʾ��2===================================--

--���runnable_tasks_count����0,��ʾ��Щ���� 
--���ȴ����ǵ�CPUʱ��Ƭ
--runnable_tasks_count:�ѷ������������ڿ����ж����еȴ������ȵĹ����߳�����
SELECT scheduler_id, current_tasks_count, runnable_tasks_count
	FROM sys.dm_os_schedulers 
	WHERE scheduler_id < 255

--�ҳ�������CPUʱ���50��ִ�мƻ�
SELECT TOP 50 q.text AS query_text,
		SUM(qs.total_worker_time) AS total_cpu_time,  
		SUM(qs.execution_count) AS total_execution_count, 
		COUNT(*) AS  number_of_statements		 
	FROM sys.dm_exec_query_stats qs 
		CROSS APPLY sys.dm_exec_sql_text(plan_handle) q
	GROUP BY q.text
	ORDER BY SUM(qs.total_worker_time) DESC

--�ҳ�������Դ����10����ѯ
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

--���������������Ƭ���ܶ����
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