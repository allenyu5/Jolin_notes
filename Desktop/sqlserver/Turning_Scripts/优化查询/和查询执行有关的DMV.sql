--查看被缓存的查询计划
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SELECT TOP 20 
    st.text AS [SQL] 
    , cp.cacheobjtype 
    , cp.objtype 
    , COALESCE(DB_NAME(st.dbid), 
        DB_NAME(CAST(pa.value AS INT))+'*', 
        'Resource') AS [DatabaseName] 
    , cp.usecounts AS [Plan usage] 
    , qp.query_plan 
FROM sys.dm_exec_cached_plans cp                       
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st 
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp 
OUTER APPLY sys.dm_exec_plan_attributes(cp.plan_handle) pa 
WHERE pa.attribute = 'dbid' 
  AND st.text LIKE '%sales%'   

--查看数据库中跑的最慢的前20个查询以及它们的执行计划
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SELECT TOP 20 
  CAST(qs.total_elapsed_time / 1000000.0 AS DECIMAL(28, 2)) 
                                     AS [Total Duration (s)] 
  , CAST(qs.total_worker_time * 100.0 / qs.total_elapsed_time 
                               AS DECIMAL(28, 2)) AS [% CPU] 
  , CAST((qs.total_elapsed_time - qs.total_worker_time)* 100.0 / 
        qs.total_elapsed_time AS DECIMAL(28, 2)) AS [% Waiting] 
  , qs.execution_count 
  , CAST(qs.total_elapsed_time / 1000000.0 / qs.execution_count 
                AS DECIMAL(28, 2)) AS [Average Duration (s)] 
  , SUBSTRING (qt.text,(qs.statement_start_offset/2) + 1,      
    ((CASE WHEN qs.statement_end_offset = -1 
      THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2 
      ELSE qs.statement_end_offset 
      END - qs.statement_start_offset)/2) + 1) AS [Individual Query 
  , qt.text AS [Parent Query] 
  , DB_NAME(qt.dbid) AS DatabaseName 
  , qp.query_plan 
FROM sys.dm_exec_query_stats qs 
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt 
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp 
WHERE qs.total_elapsed_time > 0 
ORDER BY qs.total_elapsed_time DESC                

--被阻塞时间最长的前20个查询以及它们的执行计划
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SELECT TOP 20 
  CAST((qs.total_elapsed_time - qs.total_worker_time) /      
        1000000.0 AS DECIMAL(28,2)) AS [Total time blocked (s)] 
  , CAST(qs.total_worker_time * 100.0 / qs.total_elapsed_time 
        AS DECIMAL(28,2)) AS [% CPU] 
  , CAST((qs.total_elapsed_time - qs.total_worker_time)* 100.0 / 
        qs.total_elapsed_time AS DECIMAL(28, 2)) AS [% Waiting] 
  , qs.execution_count 
  , CAST((qs.total_elapsed_time  - qs.total_worker_time) / 1000000.0 
    / qs.execution_count AS DECIMAL(28, 2)) AS [Blocking average (s)] 
  , SUBSTRING (qt.text,(qs.statement_start_offset/2) + 1,     
  ((CASE WHEN qs.statement_end_offset = -1 
    THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2 
    ELSE qs.statement_end_offset 
    END - qs.statement_start_offset)/2) + 1) AS [Individual Query] 
  , qt.text AS [Parent Query] 
  , DB_NAME(qt.dbid) AS DatabaseName 
  , qp.query_plan 
FROM sys.dm_exec_query_stats qs 
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt 
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp 
WHERE qs.total_elapsed_time > 0 
ORDER BY [Total time blocked (s)] DESC                       

--最耗费CPU的前20个查询以及它们的执行计划 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SELECT TOP 20 
  CAST((qs.total_worker_time) / 1000000.0 AS DECIMAL(28,2)) 
                                           AS [Total CPU time (s)] 
  , CAST(qs.total_worker_time * 100.0 / qs.total_elapsed_time 
                                      AS DECIMAL(28,2)) AS [% CPU] 
  , CAST((qs.total_elapsed_time - qs.total_worker_time)* 100.0 / 
           qs.total_elapsed_time AS DECIMAL(28, 2)) AS [% Waiting] 
             , qs.execution_count 
  , CAST((qs.total_worker_time) / 1000000.0 
    / qs.execution_count AS DECIMAL(28, 2)) AS [CPU time average (s)] 
  , SUBSTRING (qt.text,(qs.statement_start_offset/2) + 1,      
    ((CASE WHEN qs.statement_end_offset = -1 
      THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2 
      ELSE qs.statement_end_offset 
      END - qs.statement_start_offset)/2) + 1) AS [Individual Query] 
  , qt.text AS [Parent Query] 
  , DB_NAME(qt.dbid) AS DatabaseName 
  , qp.query_plan 
FROM sys.dm_exec_query_stats qs 
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt 
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp 
WHERE qs.total_elapsed_time > 0 
ORDER BY [Total CPU time (s)] DESC          

 --最占IO的前20个查询以及它们的执行计划
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SELECT TOP 20 
  [Total IO] = (qs.total_logical_reads + qs.total_logical_writes) 
  , [Average IO] = (qs.total_logical_reads + qs.total_logical_writes) / 
                                            qs.execution_count 
  , qs.execution_count 
  , SUBSTRING (qt.text,(qs.statement_start_offset/2) + 1,      
  ((CASE WHEN qs.statement_end_offset = -1 
    THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2 
    ELSE qs.statement_end_offset 
    END - qs.statement_start_offset)/2) + 1) AS [Individual Query] 
  , qt.text AS [Parent Query] 
  , DB_NAME(qt.dbid) AS DatabaseName 
  , qp.query_plan 
FROM sys.dm_exec_query_stats qs 
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt 
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp 
ORDER BY [Total IO] DESC 

--查找被执行次数最多的查询以及它们的执行计划
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SELECT TOP 20 
    qs.execution_count 
    , SUBSTRING (qt.text,(qs.statement_start_offset/2) + 1,   
    ((CASE WHEN qs.statement_end_offset = -1 
      THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2 
      ELSE qs.statement_end_offset 
      END - qs.statement_start_offset)/2) + 1) AS [Individual Query] 
    , qt.text AS [Parent Query] 
    , DB_NAME(qt.dbid) AS DatabaseName 
    , qp.query_plan 
FROM sys.dm_exec_query_stats qs 
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt 
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp 
ORDER BY qs.execution_count DESC;  


