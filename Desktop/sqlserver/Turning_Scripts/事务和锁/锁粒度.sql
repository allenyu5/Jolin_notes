SELECT * FROM sys.dm_tran_locks

BEGIN TRAN
	UPDATE HumanResources.Department WITH (ROWLOCK)
	SET ModifiedDate = getdate()
ROLLBACK
BEGIN TRAN
	UPDATE HumanResources.Department WITH (PAGLOCK)
	SET ModifiedDate = getdate()
ROLLBACK
BEGIN TRAN
	UPDATE HumanResources.Department WITH (TABLOCK)
	SET ModifiedDate = getdate()
ROLLBACK


BEGIN TRAN
	SELECT * FROM HumanResources.Department WITH (TABLOCK)
ROLLBACK
BEGIN TRAN
	SELECT * FROM HumanResources.Department WITH (TABLOCKX)
ROLLBACK
BEGIN TRAN
	SELECT * FROM HumanResources.Department WITH (ROWLOCK, XLOCK)
ROLLBACK
BEGIN TRAN
	SELECT * FROM HumanResources.Department WITH (PAGLOCK, XLOCK)
ROLLBACK