USE tempdb
GO

SELECT * FROM sys.objects
SELECT name, (size * 8)/ 1024.0 AS file_size_mb FROM sys.database_files


DECLARE @t table (ID int PRIMARY KEY CLUSTERED, Name varchar(100))
DECLARE @n int
SET @n = 1
BEGIN TRAN
	WHILE @n < 100000 BEGIN
		INSERT INTO @t VALUES (@n, REPLICATE('n',100))
		SET @n = @n + 1
	END
WAITFOR DELAY '1:0:0'
ROLLBACK

SELECT * FROM sys.objects
SELECT name, (size * 8)/ 1024.0 AS file_size_mb FROM sys.database_files

DBCC SHRINKDATABASE ('tempdb', 0)

CREATE TABLE #t (ID int, Name varchar(100))
DECLARE @n int
SET @n = 1
BEGIN TRAN
	WHILE @n < 100000 BEGIN
		INSERT INTO #t VALUES (@n, REPLICATE('n',100))
		SET @n = @n + 1
	END
WAITFOR DELAY '1:0:0'
ROLLBACK
SELECT * FROM sys.objects
SELECT name, (size * 8)/ 1024.0 AS file_size_mb FROM sys.database_files

DBCC SHRINKDATABASE ('tempdb', 0)

--------------------------------------------------
set statistics profile on
declare @tmp table(
productid int,
orderqty int)
insert into @tmp
select productid,orderqty from dbo.salesorderdetail_test 
where salesorderid=75124
select p.name,p.color,sum(t.quantity) from @tmp t 
inner join production.product as p
on t.productid=p.productid
group by p.name,p.color
order by p.name
go

ceate table #tmp(
productid int,
orderqty int)
insert into #tmp
select productid,orderqty from dbo.salesorderdetail_test 
where salesorderid=75124
select p.name,p.color,sum(t.quantity) from #tmp t 
inner join production.product as p
on t.productid=p.productid
group by p.name,p.color
order by p.name







