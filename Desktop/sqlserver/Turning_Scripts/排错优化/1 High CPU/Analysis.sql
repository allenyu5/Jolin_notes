DBCC SQLPERF('sys.dm_os_wait_stats',clear)

--用ostress模拟80个连接，每个连接1000000次重复。
--C:\Program Files (x86)\Microsoft Corporation\RMLUtils>ostress -E  -dadventureworks
-- -i "C:\CPUStress.sql" -n100 -r1000000

--第一步：查看性能计数器，确认CPU性能瓶颈
--Processor:%Processor Time  应<80%
--Process:%Processor Time (sqlservr)


--第二步：分析等待
SELECT * FROM sys.dm_os_schedulers where status='VISIBLE ONLINE'

SELECT  *
FROM    sys.dm_os_wait_stats
ORDER BY wait_time_ms DESC

SELECT  *
FROM    sys.dm_os_waiting_tasks
WHERE   session_id > 50

--第三步：定位问题根源
SELECT  wt.*,
        st.text,
        qp.query_plan
FROM    sys.dm_os_waiting_tasks wt
        LEFT JOIN sys.dm_exec_requests er 
        ON wt.waiting_task_address = er.task_address
        CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) st
        CROSS APPLY sys.dm_exec_query_plan(er.plan_handle) qp
--WHERE   wt.wait_type = 'SOS_SCHEDULER_YIELD'
ORDER BY wt.session_id

---挑战一下自己，尝试用扩展事件捕捉

SELECT TOP 10 q.text AS query_text,
		SUM(qs.total_worker_time) AS total_cpu_time,  
		SUM(qs.execution_count) AS total_execution_count, 
		COUNT(*) AS  number_of_statements		 
	FROM sys.dm_exec_query_stats qs 
		CROSS APPLY sys.dm_exec_sql_text(plan_handle) q
	GROUP BY q.text
	ORDER BY SUM(qs.total_worker_time) DESC

	--第六步：分析执行计划，解决问题
	----答案：rtrim()是罪魁祸首。
SET STATISTICS TIME ON --OFF
dbcc freeproccache
SELECT  AddressLine1, AddressLine2, City, StateProvinceID, PostalCode
FROM Person.Address 
WHERE City = 'Denver' and dbo.ufnGetAccountStatus('kim2') = 0

ALTER FUNCTION [dbo].[ufnGetAccountStatus](@User nvarchar(256))
RETURNS bit 
AS 
BEGIN
    DECLARE @Status bit;
    SELECT @Status = AccountStatus
    FROM tblUserAccounts U 
    WHERE U.UserName= 'kim2';
    RETURN @Status;
END;
