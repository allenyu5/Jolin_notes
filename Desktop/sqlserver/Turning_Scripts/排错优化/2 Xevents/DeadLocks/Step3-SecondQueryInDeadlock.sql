Use AdventureWorks2012
go
--Step B) run only the below
BEGIN TRANSACTION
DELETE FROM DeadlockDemoADDRESS WHERE PK_deadlockADDRESS = 2

--Step D)
SELECT * FROM DeadlockDemoNames
WHERE PK_DEADLOCKNames = 2
