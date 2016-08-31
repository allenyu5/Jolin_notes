/***********************************************************************
Author="Kenneth Wang"
Create Date="2008/6/24"
***********************************************************************/

set transaction isolation level
{READ UNCOMMITTED
|READ COMMITTED
|REPEATABLE READ
|SNAPSHOT
|SERIALIZABLE 
}[;]

--================读取未提交(Read Uncommitted)======================--
--允许脏读(dirty Read)，可以读取到别的事务已经修改但是还没确认的数据行
--不放共享锁直接读取数据

--创建测试数据表,插入两笔记录
Use northwind
go

create table MY_TRANSACTION(userid int,username varchar(20))
go
insert into MY_TRANSACTION values(1,'kenneth')
insert into MY_TRANSACTION values(2,'ASDF')
go

--开始显式事务
begin tran
	update MY_TRANSACTION
	set username='ASDF_CHANGED'
	where userid=2
	--(没有执行ROLLBACK或COMMIT，所以此连接仍有事务)
	select @@trancount --值为1
--rollback tran

--开启另外一个连接
--可以查询没有完成事务的数据
use northwind
go

set transaction isolation level READ UNCOMMITTED
select * from MY_TRANSACTION
where userid=2

--================读取提交(Read committed)======================--
--不可重复读取(Nonrepetable Read)，SQL Server默认的事务隔离级别
--当事务在读取数据时，数据库引擎会放置共享锁以防止其他事务修改数据
--所以，该隔离级别可以避免发生脏读(dirty Read)

--开始显式事务
begin transaction
--进行修改
	update MY_TRANSACTION
	set username='ASDF_CHANGED_1'
	where userid=2
	--(没有执行ROLLBACK或COMMIT，所以此连接仍有事务)
	select @@trancount --值为1
--rollback tran

--开启另外一个连接
--不可以查询没有完成事务的数据
use northwind
go

set transaction isolation level READ COMMITTED
select * from MY_TRANSACTION
where userid=2

--如果SQL Server 2005数据库设置READ_COMMITTED_SNAPSHOT为ON，指定
--READ_COMMITTED 隔离级别的事务将使用行版本控制而不是锁定。

--创建测试数据库
use master
go
create database READ_COMMITTED_SNAPSHOT_TEST
go

--启用快照隔离设置
alter database READ_COMMITTED_SNAPSHOT_TEST
set READ_COMMITTED_SNAPSHOT on

--创建数据表
use READ_COMMITTED_SNAPSHOT_TEST
go
create table READ_COMMITTED_SNAPSHOT_LEVEL
([id] int identity,username nvarchar(15))

--插入数据
insert into READ_COMMITTED_SNAPSHOT_LEVEL values(N'小宝')

--查询改变前的数据
select id,username as '改变前数据' from READ_COMMITTED_SNAPSHOT_LEVEL

--开始显式事务
begin transaction
	update READ_COMMITTED_SNAPSHOT_LEVEL set username='kenneth'
	where id=1
	--(没有执行ROLLBACK或COMMIT，所以此连接仍有事务)
	select @@trancount --值为1
--rollback tran

--开启另外一个连接
--查询出事务开始前已经完成提交的数据
use READ_COMMITTED_SNAPSHOT_TEST
go
select id,username from READ_COMMITTED_SNAPSHOT_LEVEL where id=1

--================可重复读取(Repeatable Read)======================--
--允许幻影读（Phantom Read）
--事务过程中所有的共享锁均保留到事务结束为止，而不是读取以后就释放共享锁
--如果使用该事务隔离级别读取数据，则数据读出以后，其他事务只能对此范围的
--数据进行读取和插入的操作，但是不能更改数据，直到读取数据的事务完成为止。
--优点？缺点？

--设置事务隔离级别为可重复读取(Repeatable Read)
use northwind
go

set transaction isolation level REPEATABLE READ

--开启显示事务
begin tran
	--查询数据
	select * from MY_TRANSACTION
	where userid=2
	--(没有执行ROLLBACK或COMMIT，所以此连接仍有事务)
	select @@trancount --值为1
--rollback tran

--开启另外一个连接
--可查询，不可修改
use northwind
go

select * from MY_TRANSACTION
where userid=2
go

UPDATE MY_TRANSACTION set username='ASDF_CHANGED_2'
where userid=2

--================快照(SNAPSHOT)======================--
--SQL Server 2005新增加的事务隔离级别
--启用之后，允许事务过程中的读取操作不受修改的影响。
--耗用TempDB数据库

use master
--创建测试数据库
create database snapshot_DB
go

--启动快照隔离设置
alter database snapshot_DB
set allow_snapshot_isolation on

--创建测试数据表和测试数据
use snapshot_DB
create table snap_level
([id] int identity,username nvarchar(15))

--插入数据
insert into snap_level values(N'小宝')

--查询修改前的数据
select id,username as '修改前数据' from snap_level

--启动显式事务
begin tran
	update snap_level set username='kenneth' where id=1
	--(没有执行ROLLBACK或COMMIT，所以此连接仍有事务)
	select @@trancount --值为1
--rollback tran

--开启另外一个连接
--查询出事务开始前已经完成提交的数据
use snapshot_DB
go

set transaction isolation level SNAPSHOT
select id,username from snap_level where id=1


--================可序列化(Serializable)======================--
--等级最高，最严格，锁定整个范围的索引键，使事务完全与其他事务隔离
--在现有事务完成前，其他事务不可以插入新数据，如果它的索引键值位于
--当前事务所读取的索引建范围之中
--等于select加上HOLDLOCK

--设置事务隔离级别为可序列化(Serializable)
use northwind
go

set transaction isolation level serializable

--开始显式事务
begin tran
	--查询数据
	select * from MY_TRANSACTION
	where userid=2
	--(没有执行ROLLBACK或COMMIT，所以此连接仍有事务)
	select @@trancount --值为1
--rollback tran

--开启另一连接
--可查询数据，但无法进行数据修改和添加数据
use northwind
go

select * from MY_TRANSACTION
where userid=2
go
update MY_TRANSACTION set username='ASDF_CHANGED_3'
where userid=2
go
--插入数据
insert into MY_TRANSACTION values(3,'QQ')


--锁提示
SELECT * FROM sys.dm_tran_locks

--下面的代码显示三种级别锁的区别
use adventureworks
go

BEGIN TRAN
	UPDATE HumanResources.Department WITH (ROWLOCK)
	SET ModifiedDate = getdate()
--使用之前的代码查看锁的分配情况
ROLLBACK

BEGIN TRAN
	UPDATE HumanResources.Department WITH (PAGLOCK)
	SET ModifiedDate = getdate()
--使用之前的代码查看锁的分配情况
ROLLBACK

BEGIN TRAN
	UPDATE HumanResources.Department WITH (TABLOCK)
	SET ModifiedDate = getdate()
--使用之前的代码可以看到有一个新的锁定对象
ROLLBACK


-- TABLOCK和TABLOCKX的不同之处在于TABLOCK不会在整个事务中保持锁定，语句完成即释放
BEGIN TRAN
	SELECT * FROM HumanResources.Department WITH (TABLOCK)
ROLLBACK
--但是TABLOCKX会在整个事务保持排他锁
BEGIN TRAN
	SELECT * FROM HumanResources.Department WITH (TABLOCKX)
ROLLBACK
--使用XLOCK选项来指定使用排他锁 
BEGIN TRAN
	SELECT * FROM HumanResources.Department WITH (ROWLOCK, XLOCK)
ROLLBACK
BEGIN TRAN
	SELECT * FROM HumanResources.Department WITH (PAGLOCK, XLOCK)
ROLLBACK

--------------------------------------------------
--连接1
use northwind
go

begin tran
	update employees set lastname='kkkkk' where employeeid=1
--rollback tran
--连接2
use northwind
go

select employeeid,firstname,lastname from employees(nolock)
where employeeid<5

--连接3
use northwind
go
select employeeid,firstname,lastname from employees(readpast)
where employeeid<5


















