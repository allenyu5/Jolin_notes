--Step 1 Create the Database
CREATE DATABASE [BlockingDEMO]
-- Step 2: Create the capture Blocking session to a file

CREATE EVENT SESSION [capture_blocking] ON SERVER 
ADD EVENT sqlserver.blocked_process_report(
    WHERE ([database_name]=N'BlockingDEMO')) 
ADD TARGET package0.event_file(SET filename=N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Log\capture_blocking.xel')
GO

ALTER EVENT SESSION capture_blocking
ON SERVER
STATE=START
GO

-- Step 3: View the Session Properties
Open SQL Server Management Studio -> Management -> 
Extended Events -> Right Click Properties on capture_blocking

-- Step 4: Configure Blocking Threshold

EXECUTE sp_configure 'show advanced options', 1
GO
RECONFIGURE
GO
EXECUTE sp_configure 'blocked process threshold', 5
GO
RECONFIGURE WITH OVERRIDE
GO
EXECUTE sp_configure 'show advanced options', 0
GO
RECONFIGURE
GO
-- Step 5:  Open New Query Windows lets call it connection 1
USE [BlockingDEMO]
GO
CREATE TABLE t1 (c1 INT);
BEGIN TRANSACTION
INSERT INTO t1 VALUES (2);
WAITFOR DELAY '00:00:50'
COMMIT

--Step 6: Open New Query Windows lets call it connections 2
USE [BlockingDEMO]
GO
SELECT * FROM t1

-- Step 7: Watch Live Data
Open SQL Server Management Studio -> Management -> 
Extended Events -> Right Click Properties on capture_blocking -> Watch Live Data
-- Step 8:  View Output from File
Open SQL Server Management Studio -> Management -> 
Extended Events -> capture_blocking -> package0.event_file -> Right Click -> View Target Data

Double Click on the Blocked report output and view the output in XML format in a new window
















