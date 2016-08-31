--===================观察和分析系统锁定的情况===================--

--连接1
use adventureworks
go
BEGIN TRANSACTION --启动事务，执行修改语句
	UPDATE HumanResources.Employee
		SET ManagerID=4
	WHERE EmployeeID=2
--rollback tran
--连接2
use adventureworks
go
SELECT * FROM HumanResources.Employee
WHERE EmployeeID=2

--可以使用活动监视器观察,下面用代码方式

--连接3
--列出最初锁住资源，导致一连串其他进程被锁住的起始源头
IF EXISTS(SELECT * FROM master.sys.sysprocesses WHERE spid 
    IN (SELECT blocked FROM master.sys.sysprocesses))	--确定有进程被其他的进程锁住
	SELECT spid 进程,status 状态, 登陆帐号=SUBSTRING(SUSER_SNAME(sid),1,30), 
		用户电脑名称=SUBSTRING(hostname,1,12), 是否被锁住=CONVERT(char(3),blocked),
		数据库名称 = SUBSTRING(DB_NAME(dbid),1,20),cmd 命令,waittype 等待类型
	FROM master.sys.sysprocesses 
	--列出锁住别人(在别的进程中 blocked 字段出现的值)，但自己未被锁住(blocked=0)
	WHERE spid IN (SELECT blocked FROM master.sys.sysprocesses) 
	AND blocked=0
ELSE
	SELECT '没有进程被锁住'

--或
select * from master.sys.sysprocesses
where status='sleeping' and waittype=0x0000 and open_tran>0

--sql server 2005开始提供了动态管理视图
select t1.resource_type as [资源锁定类型]
	,db_name(resource_database_id) as [数据库名]
	,t1.resource_associated_entity_id as [锁定的对象]
	,t1.request_mode as [等待者需求的锁定型类型
	,t1.request_session_id as [等待者sid]  
	,t2.wait_duration_ms as [等待时间]	
	,(select text from sys.dm_exec_requests as r  
		cross apply sys.dm_exec_sql_text(r.sql_handle) 
		where r.session_id = t1.request_session_id) as [等待者要执行的批次]
	,(select substring(qt.text,r.statement_start_offset/2+1, 
			(case when r.statement_end_offset = -1 
			then datalength(qt.text) 
			else r.statement_end_offset end - r.statement_start_offset)/2+1) 
		from sys.dm_exec_requests as r
		cross apply sys.dm_exec_sql_text(r.sql_handle) as qt
		where r.session_id = t1.request_session_id) as [等待者正要执行的语法]
	 ,t2.blocking_session_id as [锁定者sid] 
     ,(select text from sys.sysprocesses as p		
		cross apply sys.dm_exec_sql_text(p.sql_handle)
		where p.spid = t2.blocking_session_id) as [锁定者的语法]
	from 
	sys.dm_tran_locks as t1, 
	sys.dm_os_waiting_tasks as t2
where 
	t1.lock_owner_address = t2.resource_address

--使用sp_who2
sp_who2
go

dbcc inputbuffer(54)

dbcc opentran('adventureworks')

sp_lock 52

select db_name(5) '数据库名称',object_name('869578136') '数据表名称',(select name from sys.indexes where object_id=869578136 and index_id=5) '索引名称'

dbcc traceon(3604) --把dbcc的执行结果输出到屏幕
dbcc page(8,1,1731,3)



