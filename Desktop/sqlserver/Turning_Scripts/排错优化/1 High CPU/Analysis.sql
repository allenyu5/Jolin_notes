DBCC SQLPERF('sys.dm_os_wait_stats',clear)

--��ostressģ��80�����ӣ�ÿ������1000000���ظ���
--C:\Program Files (x86)\Microsoft Corporation\RMLUtils>ostress -E  -dadventureworks
-- -i "C:\CPUStress.sql" -n100 -r1000000

--��һ�����鿴���ܼ�������ȷ��CPU����ƿ��
--Processor:%Processor Time  Ӧ<80%
--Process:%Processor Time (sqlservr)


--�ڶ����������ȴ�
SELECT * FROM sys.dm_os_schedulers where status='VISIBLE ONLINE'

SELECT  *
FROM    sys.dm_os_wait_stats
ORDER BY wait_time_ms DESC

SELECT  *
FROM    sys.dm_os_waiting_tasks
WHERE   session_id > 50

--����������λ�����Դ
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

---��սһ���Լ�����������չ�¼���׽

SELECT TOP 10 q.text AS query_text,
		SUM(qs.total_worker_time) AS total_cpu_time,  
		SUM(qs.execution_count) AS total_execution_count, 
		COUNT(*) AS  number_of_statements		 
	FROM sys.dm_exec_query_stats qs 
		CROSS APPLY sys.dm_exec_sql_text(plan_handle) q
	GROUP BY q.text
	ORDER BY SUM(qs.total_worker_time) DESC

	--������������ִ�мƻ����������
	----�𰸣�rtrim()��������ס�
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
