--===================�۲�ͷ���ϵͳ���������===================--

--����1
use adventureworks
go
BEGIN TRANSACTION --��������ִ���޸����
	UPDATE HumanResources.Employee
		SET ManagerID=4
	WHERE EmployeeID=2
--rollback tran
--����2
use adventureworks
go
SELECT * FROM HumanResources.Employee
WHERE EmployeeID=2

--����ʹ�û�������۲�,�����ô��뷽ʽ

--����3
--�г������ס��Դ������һ�����������̱���ס����ʼԴͷ
IF EXISTS(SELECT * FROM master.sys.sysprocesses WHERE spid 
    IN (SELECT blocked FROM master.sys.sysprocesses))	--ȷ���н��̱������Ľ�����ס
	SELECT spid ����,status ״̬, ��½�ʺ�=SUBSTRING(SUSER_SNAME(sid),1,30), 
		�û���������=SUBSTRING(hostname,1,12), �Ƿ���ס=CONVERT(char(3),blocked),
		���ݿ����� = SUBSTRING(DB_NAME(dbid),1,20),cmd ����,waittype �ȴ�����
	FROM master.sys.sysprocesses 
	--�г���ס����(�ڱ�Ľ����� blocked �ֶγ��ֵ�ֵ)�����Լ�δ����ס(blocked=0)
	WHERE spid IN (SELECT blocked FROM master.sys.sysprocesses) 
	AND blocked=0
ELSE
	SELECT 'û�н��̱���ס'

--��
select * from master.sys.sysprocesses
where status='sleeping' and waittype=0x0000 and open_tran>0

--sql server 2005��ʼ�ṩ�˶�̬������ͼ
select t1.resource_type as [��Դ��������]
	,db_name(resource_database_id) as [���ݿ���]
	,t1.resource_associated_entity_id as [�����Ķ���]
	,t1.request_mode as [�ȴ������������������
	,t1.request_session_id as [�ȴ���sid]  
	,t2.wait_duration_ms as [�ȴ�ʱ��]	
	,(select text from sys.dm_exec_requests as r  
		cross apply sys.dm_exec_sql_text(r.sql_handle) 
		where r.session_id = t1.request_session_id) as [�ȴ���Ҫִ�е�����]
	,(select substring(qt.text,r.statement_start_offset/2+1, 
			(case when r.statement_end_offset = -1 
			then datalength(qt.text) 
			else r.statement_end_offset end - r.statement_start_offset)/2+1) 
		from sys.dm_exec_requests as r
		cross apply sys.dm_exec_sql_text(r.sql_handle) as qt
		where r.session_id = t1.request_session_id) as [�ȴ�����Ҫִ�е��﷨]
	 ,t2.blocking_session_id as [������sid] 
     ,(select text from sys.sysprocesses as p		
		cross apply sys.dm_exec_sql_text(p.sql_handle)
		where p.spid = t2.blocking_session_id) as [�����ߵ��﷨]
	from 
	sys.dm_tran_locks as t1, 
	sys.dm_os_waiting_tasks as t2
where 
	t1.lock_owner_address = t2.resource_address

--ʹ��sp_who2
sp_who2
go

dbcc inputbuffer(54)

dbcc opentran('adventureworks')

sp_lock 52

select db_name(5) '���ݿ�����',object_name('869578136') '���ݱ�����',(select name from sys.indexes where object_id=869578136 and index_id=5) '��������'

dbcc traceon(3604) --��dbcc��ִ�н���������Ļ
dbcc page(8,1,1731,3)



