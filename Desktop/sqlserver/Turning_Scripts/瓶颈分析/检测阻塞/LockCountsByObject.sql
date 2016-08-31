IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='LockCountsByObject')
DROP EVENT SESSION LockCountsByObject ON SERVER
GO
CREATE EVENT SESSION LockCountsByObject ON SERVER
ADD EVENT sqlserver.lock_acquired (WHERE database_id = 20 AND [resource_type] = 5) -- Database [run], resource_type = OBJECT
ADD TARGET package0.histogram( 
SET filtering_event_name='sqlserver.lock_acquired', source_type=0, source='resource_0') --The ID of the locked object, when lock_resource_type is OBJECT.
GO
ALTER EVENT SESSION LockCountsByObject ON SERVER 
STATE=start
GO
WAITFOR DELAY '00:00:10'
GO
SELECT name, object_id, lock_count FROM 
(SELECT objstats.value('.','bigint') AS lobject_id, 
objstats.value('@count', 'bigint') AS lock_count
FROM (
SELECT CAST(xest.target_data AS XML)
LockData
FROM sys.dm_xe_session_targets xest
JOIN sys.dm_xe_sessions xes ON xes.address = xest.event_session_address
JOIN sys.server_event_sessions ses ON xes.name = ses.name
WHERE xest.target_name = 'histogram' AND xes.name = 'LockCountsByObject'
) Locks
CROSS APPLY LockData.nodes('//HistogramTarget/Slot') AS T(objstats)
 ) LockedObjects 
INNER JOIN sys.objects o
ON LockedObjects.lobject_id = o.object_id
WHERE o.type != 'S' AND o.type = 'U'
ORDER BY lock_count desc
GO
ALTER EVENT SESSION LockCountsByObject ON SERVER
STATE=STOP
GO
IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='LockCountsByObject')
DROP EVENT SESSION LockCountsByObject ON SERVER
GO