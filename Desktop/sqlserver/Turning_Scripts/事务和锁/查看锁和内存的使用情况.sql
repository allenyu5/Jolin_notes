--查看连接当前数据库的SPID所加的锁
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SELECT DB_NAME(resource_database_id) AS DatabaseName 
, request_session_id 
, resource_type 
, CASE 
WHEN resource_type = 'OBJECT' 
THEN OBJECT_NAME(resource_associated_entity_id) 
WHEN resource_type IN ('KEY', 'PAGE', 'RID') 
THEN (SELECT OBJECT_NAME(OBJECT_ID) 
FROM sys.partitions p 
WHERE p.hobt_id = l.resource_associated_entity_id) 
END AS resource_type_name 
, request_status 
, request_mode 
FROM sys.dm_tran_locks l 
WHERE request_session_id !=@@spid 
ORDER BY request_session_id 

--查看没关闭事务的空闲Session
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SELECT es.session_id, es.login_name, es.host_name, est.text 
  , cn.last_read, cn.last_write, es.program_name 
FROM sys.dm_exec_sessions es 
INNER JOIN sys.dm_tran_session_transactions st 
            ON es.session_id = st.session_id 
INNER JOIN sys.dm_exec_connections cn 
            ON es.session_id = cn.session_id 
CROSS APPLY sys.dm_exec_sql_text(cn.most_recent_sql_handle) est 
LEFT OUTER JOIN sys.dm_exec_requests er                     
            ON st.session_id = er.session_id 
                AND er.session_id IS NULL         

--查看被阻塞的语句和它们的等待时间
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SELECT 
  Waits.wait_duration_ms / 1000 AS WaitInSeconds 
  , Blocking.session_id as BlockingSessionId 
  , DB_NAME(Blocked.database_id) AS DatabaseName 
  , Sess.login_name AS BlockingUser 
  , Sess.host_name AS BlockingLocation 
  , BlockingSQL.text AS BlockingSQL 
  , Blocked.session_id AS BlockedSessionId 
  , BlockedSess.login_name AS BlockedUser 
  , BlockedSess.host_name AS BlockedLocation 
  , BlockedSQL.text AS BlockedSQL 
  , SUBSTRING (BlockedSQL.text, (BlockedReq.statement_start_offset/2) + 1, 
    ((CASE WHEN BlockedReq.statement_end_offset = -1 
      THEN LEN(CONVERT(NVARCHAR(MAX), BlockedSQL.text)) * 2 
      ELSE BlockedReq.statement_end_offset 
      END - BlockedReq.statement_start_offset)/2) + 1) 
                    AS [Blocked Individual Query] 
  , Waits.wait_type 
FROM sys.dm_exec_connections AS Blocking                          
INNER JOIN sys.dm_exec_requests AS Blocked 
            ON Blocking.session_id = Blocked.blocking_session_id 
INNER JOIN sys.dm_exec_sessions Sess 
            ON Blocking.session_id = sess.session_id  
INNER JOIN sys.dm_tran_session_transactions st 
            ON Blocking.session_id = st.session_id 
LEFT OUTER JOIN sys.dm_exec_requests er 
            ON st.session_id = er.session_id 
                AND er.session_id IS NULL 
INNER JOIN sys.dm_os_waiting_tasks AS Waits 
            ON Blocked.session_id = Waits.session_id 
CROSS APPLY sys.dm_exec_sql_text(Blocking.most_recent_sql_handle) 
                             AS BlockingSQL 
INNER JOIN sys.dm_exec_requests AS BlockedReq                     
            ON Waits.session_id = BlockedReq.session_id 
INNER JOIN sys.dm_exec_sessions AS BlockedSess 
            ON Waits.session_id = BlockedSess.session_id 
CROSS APPLY sys.dm_exec_sql_text(Blocked.sql_handle) AS BlockedSQL 
ORDER BY WaitInSeconds 

--查看超过30秒等待的查询
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SELECT 
  Waits.wait_duration_ms / 1000 AS WaitInSeconds 
  , Blocking.session_id as BlockingSessionId 
  , Sess.login_name AS BlockingUser 
  , Sess.host_name AS BlockingLocation 
  , BlockingSQL.text AS BlockingSQL 
  , Blocked.session_id AS BlockedSessionId 
  , BlockedSess.login_name AS BlockedUser 
  , BlockedSess.host_name AS BlockedLocation 
  , BlockedSQL.text AS BlockedSQL 
  , DB_NAME(Blocked.database_id) AS DatabaseName 
FROM sys.dm_exec_connections AS Blocking                         
INNER JOIN sys.dm_exec_requests AS Blocked 
            ON Blocking.session_id = Blocked.blocking_session_id 
INNER JOIN sys.dm_exec_sessions Sess 
            ON Blocking.session_id = sess.session_id  
INNER JOIN sys.dm_tran_session_transactions st 
            ON Blocking.session_id = st.session_id 
LEFT OUTER JOIN sys.dm_exec_requests er 
            ON st.session_id = er.session_id 
                AND er.session_id IS NULL 
INNER JOIN sys.dm_os_waiting_tasks AS Waits 
            ON Blocked.session_id = Waits.session_id 
CROSS APPLY sys.dm_exec_sql_text(Blocking.most_recent_sql_handle) 
                                     AS BlockingSQL 
INNER JOIN sys.dm_exec_requests AS BlockedReq                    
            ON Waits.session_id = BlockedReq.session_id 
INNER JOIN sys.dm_exec_sessions AS BlockedSess 
            ON Waits.session_id = BlockedSess.session_id 
CROSS APPLY sys.dm_exec_sql_text(Blocked.sql_handle) AS BlockedSQL 
WHERE Waits.wait_duration_ms > 30000 
ORDER BY WaitInSeconds

--buffer中缓存每个数据库所占的buffer
SET TRAN ISOLATION LEVEL READ UNCOMMITTED 
SELECT 
    ISNULL(DB_NAME(database_id), 'ResourceDb') AS DatabaseName 
    , CAST(COUNT(row_count) * 8.0 / (1024.0) AS DECIMAL(28,2)) 
                                                   AS [Size (MB)] 
FROM sys.dm_os_buffer_descriptors 
GROUP BY database_id 
ORDER BY DatabaseName

--当前数据库中每个表所占缓存的大小和页数
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SELECT  
     OBJECT_NAME(p.[object_id]) AS [TableName] 
     , (COUNT(*) * 8) / 1024   AS [Buffer size(MB)] 
     , ISNULL(i.name, '-- HEAP --') AS ObjectName 
     ,  COUNT(*) AS NumberOf8KPages 
FROM sys.allocation_units AS a 
INNER JOIN sys.dm_os_buffer_descriptors AS b 
    ON a.allocation_unit_id = b.allocation_unit_id 
INNER JOIN sys.partitions AS p 
INNER JOIN sys.indexes i ON p.index_id = i.index_id 
                         AND p.[object_id] = i.[object_id] 
    ON a.container_id = p.hobt_id 
WHERE b.database_id = DB_ID() 
  AND p.[object_id] > 100 
GROUP BY p.[object_id], i.name 
ORDER BY NumberOf8KPages DESC

--数据库级别等待的IO
SET TRAN ISOLATION LEVEL READ UNCOMMITTED 
SELECT DB_NAME(database_id) AS [DatabaseName] 
  , SUM(CAST(io_stall / 1000.0 AS DECIMAL(20,2))) AS [IO stall (secs)] 
  , SUM(CAST(num_of_bytes_read / 1024.0 / 1024.0 AS DECIMAL(20,2))) 
                                                        AS [IO read (MB)] 
  , SUM(CAST(num_of_bytes_written / 1024.0 / 1024.0  AS DECIMAL(20,2))) 
                                                     AS [IO written (MB)]
  , SUM(CAST((num_of_bytes_read + num_of_bytes_written) 
                   / 1024.0 / 1024.0 AS DECIMAL(20,2))) AS [TotalIO (MB) ]
FROM sys.dm_io_virtual_file_stats(NULL, NULL) 
GROUP BY database_id 
ORDER BY [IO stall (secs)] DESC

-- 按文件查看IO情况
SET TRAN ISOLATION LEVEL READ UNCOMMITTED 
SELECT DB_NAME(database_id) AS [DatabaseName] 
  , file_id 
  , SUM(CAST(io_stall / 1000.0 AS DECIMAL(20,2))) AS [IO stall (secs)] 
  , SUM(CAST(num_of_bytes_read / 1024.0 / 1024.0 AS DECIMAL(20,2))) 
                                                     AS [IO read (MB)] 
  , SUM(CAST(num_of_bytes_written / 1024.0 / 1024.0  AS DECIMAL(20,2))) 
                                                  AS [IO written (MB)] 
                                                    , SUM(CAST((num_of_bytes_read + num_of_bytes_written) 
                / 1024.0 / 1024.0 AS DECIMAL(20,2))) AS [TotalIO (MB)] 
FROM sys.dm_io_virtual_file_stats(NULL, NULL) 
GROUP BY database_id, file_id 
ORDER BY [IO stall (secs)] DESC

