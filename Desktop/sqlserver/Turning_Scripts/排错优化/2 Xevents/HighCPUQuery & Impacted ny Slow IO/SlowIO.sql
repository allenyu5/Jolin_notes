--定义事件会话
CREATE EVENT SESSION [XeventIObottleneck] ON SERVER 
ADD EVENT sqlos.wait_info(

ACTION(sqlserver.session_id,sqlserver.sql_text)
WHERE (([package0].[equal_uint64]([wait_type],(68)) OR [package0].[equal_uint64]([wait_type],(66)) 
OR [package0].[equal_uint64]([wait_type],(67)) OR [package0].[equal_uint64]([wait_type],(182)))  -- notice the ORs are grouped together with parentheses
AND [package0].[greater_than_uint64]([duration],(0)) AND [package0].[equal_uint64]([opcode],(1)) AND [sqlserver].[is_system]=(0))) 

ADD TARGET package0.event_file(SET filename=N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Log\XeventIObottleneck.xel')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO

select * from sys.dm_xe_map_values 
--where map_key in (68,66,67,182)

--启动会话
ALTER EVENT SESSION [XeventIObottleneck] ON SERVER  STATE = START
SELECT * FROM sys.dm_xe_sessions WHERE name = 'XeventIObottleneck'


--执行查询，产生磁盘IO压力
DBCC DROPCLEANBUFFERS -- make sure we have cold cache so disk I/O is performed
go
use AdventureWorks2012
go
select count_big(*) from [Production].[ProductInventory] a 
cross join [Production].[ProductInventory] b 
cross join [Production].[ProductInventory] c 
cross join [Production].[ProductInventory] d 
where a.Quantity > 200

--停止会话（另开窗口）
ALTER EVENT SESSION [XeventIObottleneck] ON SERVER  STATE = STOP
