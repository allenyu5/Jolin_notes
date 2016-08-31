Use AdventureWorks2012
GO
--Step A) Run only the below statement
BEGIN TRANSACTION
DELETE FROM DeadlockDemoNames WHERE PK_deadlockNames = 1
--STOP HERE

--Step C) Make sure to run step B) in other window before running below
SELECT * FROM DeadlockDemoADDRESS
WHERE PK_DEADLOCKADDRESS = 1

--ROLLBACK TRANSACTION
