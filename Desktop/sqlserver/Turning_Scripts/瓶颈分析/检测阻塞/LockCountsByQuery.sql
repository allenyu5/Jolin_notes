-- 清理 
IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='FindBlockers')
    DROP EVENT SESSION FindBlockers ON SERVER
GO
-- 创建扩展事件会话
DECLARE @dbid int

SELECT @dbid = db_id('run0')

IF @dbid IS NULL
BEGIN
    RAISERROR('run0 is not installed. Install run0 before proceeding', 17, 1)
    RETURN
END

DECLARE @sql nvarchar(1024)
SET @sql = '
CREATE EVENT SESSION FindBlockers ON SERVER
ADD EVENT sqlserver.lock_acquired 
    (action 
        ( sqlserver.sql_text, sqlserver.database_id, sqlserver.tsql_stack,
         sqlserver.plan_handle, sqlserver.session_id)
    WHERE ( database_id=' + cast(@dbid as nvarchar) + ' AND resource_0!=0) 
    ),
ADD EVENT sqlserver.lock_released 
    (WHERE ( database_id=' + cast(@dbid as nvarchar) + ' AND resource_0!=0 ))
ADD TARGET package0.pair_matching 
    ( SET begin_event=''sqlserver.lock_acquired'', 
            begin_matching_columns=''database_id, resource_0, resource_1, resource_2, transaction_id, mode'', 
            end_event=''sqlserver.lock_released'', 
            end_matching_columns=''database_id, resource_0, resource_1, resource_2, transaction_id, mode'',
    respond_to_memory_pressure=1)
WITH (max_dispatch_latency = 1 seconds)'

EXEC (@sql)
-- 
-- Create the metadata for the event session
-- Start the event session
--
ALTER EVENT SESSION FindBlockers ON SERVER
STATE = START


-------------------------查询
SELECT 
objlocks.value('(action/value)[5]', 'int')
        AS session_id,
    objlocks.value('(data/value)[5]', 'int') 
        AS database_id,
    objlocks.value('(data/text)[1]', 'nvarchar(50)' ) 
        AS resource_type,
    objlocks.value('(data/value)[9]', 'bigint') 
        AS resource_0,
    objlocks.value('(data/value)[10]', 'bigint') 
        AS resource_1,
    objlocks.value('(data/value)[11]', 'bigint') 
        AS resource_2,
    objlocks.value('(data/text)[2]', 'nvarchar(50)') 
        AS mode,
    objlocks.value('(action/value)[1]', 'varchar(MAX)') 
        AS sql_text,
    CAST(objlocks.value('(action/value)[4]', 'varchar(MAX)') AS xml) 
        AS plan_handle,    
    CAST(objlocks.value('(action/value)[3]', 'varchar(MAX)') AS xml) 
        AS tsql_stack
INTO #unmatched_locks
FROM (
    SELECT CAST(xest.target_data as xml) 
        lockinfo
    FROM sys.dm_xe_session_targets xest
    JOIN sys.dm_xe_sessions xes ON xes.address = xest.event_session_address
    WHERE xest.target_name = 'pair_matching' AND xes.name = 'FindBlockers'
) heldlocks
CROSS APPLY lockinfo.nodes('//event[@name="lock_acquired"]') AS T(objlocks)
--
-- Join the data acquired from the pairing target with other 
-- DMVs to return provide additional information about blockers
SELECT ul.*
    FROM #unmatched_locks ul
    INNER JOIN sys.dm_tran_locks tl 
	ON ul.database_id = tl.resource_database_id AND ul.resource_type = tl.resource_type
    WHERE resource_0 IS NOT NULL
    AND session_id IN 
        (SELECT blocking_session_id FROM
		 sys.dm_exec_requests WHERE blocking_session_id != 0)
    AND tl.request_status='wait'
    AND ul.mode= tl.request_mode
 
--删除临时表和扩展事件会话
DROP TABLE #unmatched_locks
DROP EVENT SESSION FindBlockers ON SERVER



 
