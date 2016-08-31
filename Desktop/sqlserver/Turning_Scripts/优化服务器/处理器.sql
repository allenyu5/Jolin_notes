USE master;

--When your affinity mask set to 0
--You will see cpu_id was 255 for all rows under dm_os_scheduler
SELECT * FROM sys.dm_os_schedulers;

--When you set the affinity mask to 3, 
--You will see the actual cou_id for each scheduler 
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'affinity mask', 3;
RECONFIGURE;
SELECT * FROM sys.dm_os_schedulers;

--When you set the affinity mask to bring some processor offline
--You will see a scheduler bound to that processor was set to OFFLINE
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'affinity mask', 1;
RECONFIGURE;
SELECT * FROM sys.dm_os_schedulers;

--Recovery the affinity mask to managed automatically
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'affinity mask', 0;
RECONFIGURE;