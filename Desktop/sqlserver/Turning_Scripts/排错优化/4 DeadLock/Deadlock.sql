CREATE TABLE dbo.conn1 (col1 INT)
INSERT dbo.conn1 (col1)
VALUES(1)

CREATE TABLE dbo.conn2 (col1 INT)
INSERT dbo.Conn2 (col1)
VALUES(1)

/*SESSION 1*/
BEGIN TRAN
UPDATE dbo.conn1 SET col1 = 1
GO
--Cut and paste the code wrapped in comment lines in a second session 
-----------------------------
/*SESSION 2 */
BEGIN TRAN
UPDATE dbo.conn2 SET col1 = 1
UPDATE dbo.conn1 SET col1 = 1

-----------------------------

--Return to session 1 and execute the following to generate the deadlock
/*SESSION 1*/
UPDATE dbo.conn2 SET col1 = 1

--Use the following code to see the locked resource. 
-- If you are doing this for yourself you will need to change the  '1:118:0' and '1:114:0' resource values from your XDL file as the resource values used will likely be different.
SELECT  %%lockres%%
        ,* 
FROM    dbo.Conn2
WHERE   %%LockRes%% = '1:118:0'

SELECT  %%lockres%%
        ,* 
FROM    dbo.Conn1
WHERE   %%LockRes%% = '1:114:0'
