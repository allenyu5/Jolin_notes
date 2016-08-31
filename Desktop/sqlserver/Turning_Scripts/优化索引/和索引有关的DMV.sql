--查看那些被大量更新，却很少被使用的索引
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SELECT                                                    
    DB_NAME() AS DatabaseName 
    , SCHEMA_NAME(o.Schema_ID) AS SchemaName 
    , OBJECT_NAME(s.[object_id]) AS TableName 
    , i.name AS IndexName 
    , s.user_updates 
    , s.system_seeks + s.system_scans + s.system_lookups 
                          AS [System usage] 
FROM   sys.dm_db_index_usage_stats s 
INNER JOIN sys.indexes i ON s.[object_id] = i.[object_id] 
    AND s.index_id = i.index_id 
INNER JOIN sys.objects o ON i.object_id = O.object_id    

--最高维护代价的索引
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SELECT                                                     
    DB_NAME() AS DatabaseName 
    , SCHEMA_NAME(o.Schema_ID) AS SchemaName 
    , OBJECT_NAME(s.[object_id]) AS TableName 
    , i.name AS IndexName 
    , (s.user_updates ) AS [update usage] 
    , (s.user_seeks + s.user_scans + s.user_lookups) AS [Retrieval usage] 
    , (s.user_updates) - 
      (s.user_seeks + s.user_scans + s.user_lookups) AS [Maintenance cost] 
    , s.system_seeks + s.system_scans + s.system_lookups AS [System usage] 
    , s.last_user_seek 
    , s.last_user_scan 
    , s.last_user_lookup 
FROM   sys.dm_db_index_usage_stats s 
INNER JOIN sys.indexes i ON  s.[object_id] = i.[object_id] 
    AND s.index_id = i.index_id 
INNER JOIN sys.objects o ON i.object_id = O.object_id    

--使用频繁的索引 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SELECT                                           
    DB_NAME() AS DatabaseName 
        , SCHEMA_NAME(o.Schema_ID) AS SchemaName 
    , OBJECT_NAME(s.[object_id]) AS TableName 
    , i.name AS IndexName 
    , (s.user_seeks + s.user_scans + s.user_lookups) AS [Usage] 
    , s.user_updates 
    , i.fill_factor  
FROM sys.dm_db_index_usage_stats s 
INNER JOIN sys.indexes i ON s.[object_id] = i.[object_id] 
    AND s.index_id = i.index_id 
INNER JOIN sys.objects o ON i.object_id = O.object_id    

--碎片最多的索引
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SELECT                                                     
    DB_NAME() AS DatbaseName 
    , SCHEMA_NAME(o.Schema_ID) AS SchemaName 
    , OBJECT_NAME(s.[object_id]) AS TableName 
    , i.name AS IndexName 
    , ROUND(s.avg_fragmentation_in_percent,2) AS [Fragmentation %] 
FROM sys.dm_db_index_physical_stats(db_id(),null, null, null, null) s 
INNER JOIN sys.indexes i ON s.[object_id] = i.[object_id] 
    AND s.index_id = i.index_id 
INNER JOIN sys.objects o ON i.object_id = O.object_id  

--查看索引统计的相关信息
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SELECT 
    ss.name AS SchemaName 
    , st.name AS TableName 
    , s.name AS IndexName 
    , STATS_DATE(s.id,s.indid) AS 'Statistics Last Updated' 
    , s.rowcnt AS 'Row Count' 
    , s.rowmodctr AS 'Number Of Changes' 
    , CAST((CAST(s.rowmodctr AS DECIMAL(28,8))/CAST(s.rowcnt AS 
DECIMAL(28,2)) * 100.0) 
                             AS DECIMAL(28,2)) AS '% Rows Changed' 
FROM sys.sysindexes s 
INNER JOIN sys.tables st ON st.[object_id] = s.[id] 
INNER JOIN sys.schemas ss ON ss.[schema_id] = st.[schema_id] 
WHERE s.id > 100 
  AND s.indid > 0 
  AND s.rowcnt >= 500 
ORDER BY SchemaName, TableName, IndexName 
