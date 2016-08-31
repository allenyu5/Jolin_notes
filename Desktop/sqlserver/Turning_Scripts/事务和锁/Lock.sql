--Lock and Database Turning
use [AdventureWorks]
go
drop table employee_demo_btree
go
set ansi_nulls on
go
set quoted_identifier on
go
create table [employee_demo_btree](
employeeid int not null,
nationalidnumber nvarchar(15) not null,
contactid int not null,
loginid nvarchar(256) not null,
managerid int null,
title nvarchar(50) not null,
birthdate datetime not null,
maritalstatus nchar(1) not null,
gender nchar(1) not null,
hiredate datetime not null,
modifydate datetime not null default (getdate())
constraint pk_employee_employeeid_demo_btree primary key clustered ( employeeid asc)
)

create nonclustered index ix_employee_mamagerid_demo_btree on employee_demo_btree(managerid asc)
create nonclustered index ix_employee_modifydate_demo_btree on employee_demo_btree(modifydate asc)

insert into employee_demo_btree
select EmployeeID,NationalIDNumber,ContactID,LoginID,ManagerID,Title,BirthDate,MaritalStatus,Gender,HireDate,ModifiedDate
from HumanResources.Employee
go

drop table employee_demo_heap
go
set ansi_nulls on
go
set quoted_identifier on
go
create table [employee_demo_heap](
employeeid int not null,
nationalidnumber nvarchar(15) not null,
contactid int not null,
loginid nvarchar(256) not null,
managerid int null,
title nvarchar(50) not null,
birthdate datetime not null,
maritalstatus nchar(1) not null,
gender nchar(1) not null,
hiredate datetime not null,
modifydate datetime not null default (getdate())
constraint pk_employee_employeeid_demo_heap primary key nonclustered ( employeeid asc)
)

create nonclustered index ix_employee_mamagerid_demo_heap on employee_demo_heap(managerid asc)
create nonclustered index ix_employee_modifydate_demo_heap on employee_demo_heap(modifydate asc)

insert into employee_demo_heap
select EmployeeID,NationalIDNumber,ContactID,LoginID,ManagerID,Title,BirthDate,MaritalStatus,Gender,HireDate,ModifiedDate
from HumanResources.Employee
go

--select LOCK
set transaction isolation level repeatable read
go
set statistics profile on
go
begin tran
 select employeeid,loginid,title from employee_demo_btree
 where employeeid=3

 select request_session_id,resource_type,request_status,request_mode,resource_description,OBJECT_NAME(p.[object_id]) as 
 [object_name],p.index_id
 from sys.dm_tran_locks left join sys.partitions p
  on sys.dm_tran_locks.resource_associated_entity_id=p.hobt_id
  order by request_session_id,resource_type
  --rollback tran

begin tran
select employeeid,loginid,title
from employee_demo_heap where employeeid=3

 select request_session_id,resource_type,request_status,request_mode,resource_description,OBJECT_NAME(p.[object_id]) as 
 [object_name],p.index_id
 from sys.dm_tran_locks left join sys.partitions p
  on sys.dm_tran_locks.resource_associated_entity_id=p.hobt_id
  order by request_session_id,resource_type

--rollback tran

------update on heap table
--connection1
begin tran
	update employee_demo_heap set title='aaa' where employeeid=70

--connection 2
	begin tran
		select employeeid,loginid,title  from employee_demo_heap where employeeid in (3,30,200)

--connection 3
		select request_session_id,resource_type,request_status,request_mode,resource_description,OBJECT_NAME(p.[object_id]) as 
		 [object_name],p.index_id
		from sys.dm_tran_locks left join sys.partitions p
		on sys.dm_tran_locks.resource_associated_entity_id=p.hobt_id
		where request_session_id=58
		order by request_session_id,resource_type

----update on Btree table
begin tran
update employee_demo_btree
set title='aaa'
where employeeid=70
--rollback tran

--summary:add share lock on every record when read
--when using index,add key lock
--add intend lock on every page when read
--scan more pages or records,using more locks.
--using more index,using more locks

--suggestion:return less records
--using index seek instead of table scan
--design good index

----update Lock
set transaction isolation level repeatable read
go
begin tran
 update employee_demo_heap
 set title = 'changeheap'
 where employeeid in (3,30,200)

 		select request_session_id,resource_type,request_status,request_mode,resource_description,OBJECT_NAME(p.[object_id]) as 
		 [object_name],p.index_id
		from sys.dm_tran_locks left join sys.partitions p
		on sys.dm_tran_locks.resource_associated_entity_id=p.hobt_id
		order by request_session_id,resource_type

--rollback tran

--add index on title
 create nonclustered index employee_demo_btree_title on [employee_demo_btree](title)

 --update again
 begin tran
 update employee_demo_btree
 set title = 'changeheap'
 where employeeid in (3,30,200)

 		select request_session_id,resource_type,request_status,request_mode,resource_description,OBJECT_NAME(p.[object_id]) as 
		 [object_name],p.index_id
		from sys.dm_tran_locks left join sys.partitions p
		on sys.dm_tran_locks.resource_associated_entity_id=p.hobt_id
		order by request_session_id,resource_type
--rollback tran

drop index employee_demo_btree_title on dbo.employee_demo_btree

--delete Lock
set transaction isolation level read committed
go
 begin tran
	delete employee_demo_btree
		where loginid='adventure-works\kim1'

		 select request_session_id,resource_type,request_status,request_mode,resource_description,OBJECT_NAME(p.[object_id]) as 
		 [object_name],p.index_id
		from sys.dm_tran_locks left join sys.partitions p
		on sys.dm_tran_locks.resource_associated_entity_id=p.hobt_id
		order by request_session_id,resource_type

--rollback tran

set transaction isolation level repeatable read
go
begin tran
  delete employee_demo_heap
  where loginid='adventure-works\tete0'

   		select request_session_id,resource_type,request_status,request_mode,resource_description,OBJECT_NAME(p.[object_id]) as 
		 [object_name],p.index_id
		from sys.dm_tran_locks left join sys.partitions p
		on sys.dm_tran_locks.resource_associated_entity_id=p.hobt_id
		order by request_session_id,resource_type
--rollback tran

--summary: first select,then delete ,so good index using less lock
--delete row will delete assiocation index key

----insert Lock
set transaction isolation level repeatable read
go
begin tran
insert into employee_demo_heap values(501,480168528,1009,'adventure-works\thierry0',263,'Tool Designer',
'1949-06-29 00:00:00.000','M','M','1998-01-11 00:00:00.000','2004-07-31 00:00:00.000')

 		select request_session_id,resource_type,request_status,request_mode,resource_description,OBJECT_NAME(p.[object_id]) as 
		 [object_name],p.index_id
		from sys.dm_tran_locks left join sys.partitions p
		on sys.dm_tran_locks.resource_associated_entity_id=p.hobt_id
		order by request_session_id,resource_type

--rollback tran
begin tran
insert into employee_demo_btree values(501,480168528,1009,'adventure-works\thierry0',263,'Tool Designer',
'1949-06-29 00:00:00.000','M','M','1998-01-11 00:00:00.000','2004-07-31 00:00:00.000')

 		select request_session_id,resource_type,request_status,request_mode,resource_description,OBJECT_NAME(p.[object_id]) as 
		 [object_name],p.index_id
		from sys.dm_tran_locks left join sys.partitions p
		on sys.dm_tran_locks.resource_associated_entity_id=p.hobt_id
		order by request_session_id,resource_type
--rollback tran

---summary
--select correct isolation level
--keep transascion short and simple
--single transaction shouldn't process more data
--create suitable index


---------------------------------------------------------------------Find Blocking-------------------------------------------------------
--connection 1
begin tran
update employee_demo_heap
set title='aaa'
where employeeid=70

update employee_demo_btree
set title='aaa'
where employeeid=70

--connection 2
select employeeid,loginid,title 
from employee_demo_heap
where employeeid in (3,30,200)


--find process infomation
--spid,kpid,blocked,waittime,waittype,open_tran,dbid,host_name,program_name,loginame.mac_address
select * from master.sys.sysprocesses

select convert(smallint,req_spid) as spid,rsc_dbid as dbid,rsc_objid as objid,rsc_indid as indid,
substring(v.name,1,4) as type,substring(rsc_text,1,32) as resource,substring(u.name,1,8) as mode,
substring(x.name,1,5) as status
from master.sys.syslockinfo,master.dbo.spt_values v,master.dbo.spt_values x,master.dbo.spt_values u
where master.sys.syslockinfo.rsc_type=v.number and v.type='LR'
and
master.sys.syslockinfo.req_status=x.number and x.type='LS'
and 
master.sys.syslockinfo.req_mode+1=u.number and u.type='L'
and
substring(x.name,1,5)='wait'
order by spid

select object_name(849674039)
select * from sys.sysindexes
where [object_id]=849674039

--find running statement
select p.session_id,p.request_id,p.start_time,p.command,p.blocking_session_id,p.wait_type,p.wait_time,
p.wait_resource,p.total_elapsed_time,p.open_transaction_count,p.transaction_isolation_level,
substring(qt.text,p.statement_start_offset/2,
(case 
when p.statement_end_offset=-1 then len(convert(nvarchar(max),qt.text))*2
else p.statement_end_offset
end - p.statement_start_offset)/2) as "sql statement",
p.statement_start_offset,p.statement_end_offset,batch=qt.text
from master.sys.dm_exec_requests p
cross apply
sys.dm_exec_sql_text(p.sql_handle) as qt
where p.session_id>50

--find last run statement 
dbcc inputbuffer(58)

--------------resolution
--type 1: waittype<>0 ,open_tran>=0,status=runable
--runnig time too long ,waitting system resouce
----turning stattement, resolve resource bottleneck,using DW

--type 2: waittype=0x0000 ,open_tran>0,status=sleeing
--using try catch to process error
use adventureworks
go
begin tran
	select * from person.address with (holdlock)
	select * from sysobjects s1,sysobjects s2
commit tran

select @@TRANCOUNT
go
sp_lock
go

--type 3: waittype=0x0800 or 0x0063 ,open_tran>=0,status=runnable
--don't return large result

--type 4: waittype=0x0000 ,open_tran>0,status=rollback

--------------------------------------------------------find DeadLock
--return deaklock info to errorlog
dbcc traceon(1222,-1)

--suggestion
--access objects using the same order
--avoid interactive with user in a transaction
--keep transaction short and in a batch
--use low transaction isolation level
--improve statement execution paln,reduce lock number

--connection 1
set nocount on
go
--while 1=1
begin
	begin tran
		update dbo.employee_demo_heap
		set birthdate=getdate()
		where nationalidnumber='480951955'
		select * from dbo.employee_demo_heap
		where nationalidnumber='480951955'
	commit tran
end

--connection 2
set nocount on
go
while 1=1
begin
	begin tran
		update dbo.employee_demo_heap
		set birthdate=getdate()
		where nationalidnumber='407505660'
		select * from dbo.employee_demo_heap
		where nationalidnumber='407505660'
	commit tran
end

dbcc traceon(3604)
dbcc page(9,1,6685,3)




---resolution
--1.add index
create nonclustered index nationalidnumber 
on dbo.employee_demo_heap(nationalidnumber asc)

--2. using nolock
set nocount on
go
while 1=1
begin
	begin tran
		update dbo.employee_demo_heap
		set birthdate=getdate()
		where nationalidnumber='407505660'
		select * from dbo.employee_demo_heap with (nolock)
		where nationalidnumber='407505660' 
	commit tran
end

--3.change deadlock to blocking
set nocount on
go
while 1=1
begin
	begin tran
		update dbo.employee_demo_heap with (paglock)
		set birthdate=getdate()
		where nationalidnumber='407505660'
		select * from dbo.employee_demo_heap  with (paglock)
		where nationalidnumber='407505660' 
	commit tran
end

set nocount on
go
while 1=1
begin
	begin tran
		update dbo.employee_demo_heap with (PAGELOCK)
		set birthdate=getdate()
		where nationalidnumber='480951955'
		select * from dbo.employee_demo_heap  with (PAGELOCK)
		where nationalidnumber='480951955' 
	commit tran
end

--4.using snapshot isolation level
set transaction isolation level snapshot