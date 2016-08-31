select @@version
select * from sys.dm_exec_connections
select * from sys.dm_exec_sessions  --���� �
--CPU��ѯ��50����ϵͳ��(���ܼ�����)
--avg disk read/writer (0.02ms)

select * from sys.dm_exec_requests  --�������� 
select * from sys.dm_os_tasks  --���� 
select * from sys.dm_os_workers --�����߳� ִ�е���С��Ԫ  һ����������ִ�н��� �ȴ����� 
select * from sys.dm_os_sys_info  
select * from sys.dm_os_schedulers --��������CPU��


--ִ��ģ��
SQL������н׶� =����+���� 
����=��Դ+CPU
set statistics time on
dbcc cache --��ջ���
dbcc buffers

---���ܵ���  ����ʽ���Ȼ��� 

--IO����Դ������ ��Ӧʱ�䣨����20ms��)
set statistics io on

---memory�����ڴ���ڲ������
	--connection
	--buffer pool(data cache  plan cache  log cache )
	--3rd code(link server/��չ�洢����/sql clr/com+ )


--sql server wait_type��ʵ������
select * from sys.dm_os_wait_stats order by wait_time_ms desc

--�������Ч��
select top 100 * from sys.dm_db_index_usage_stats;

--ǿ��ʹ������ 
select column_name from table_name with index(index_name)
create index index_name on table_name(column_name1) include (column_name2)  --���𸴺�����  ��������column_name1 keyֵ 
create index index_name on table_name(column_name1, column_name2)  --�������� 

--��ѯ����ƻ�
select * from sys.dm_exec_cached_plans
select top 20 qt.text,* from sys.dm_exec_query_stats as qs
cross apply sys.dm_exec_sql_text(qs.sql_handle) as qt

--���ڼ�ز�����profile �����ȵ��� ��д������Ӧ�Ľű� 
--profiler ��ʱ��ʵʱ���� 
--sql trace ��ʱ��ʵʱ���� 
exec sp_trace_setstatus 2 2  --param 1;process id    param2: 0ɾ����� 1������� 2ֹͣ��� 
select * from fn_trace_gettable('file_path',default)
order by Duration desc;

--windows���ܼ����� �� sql trace profile������뿪ʼ/����ʱ�� 

select @@TRANCOUNT
--��ѯ����
select * from sys.dm_exec_requests
select * from sys.sysprocesses

dbcc useroptions  --isolation level ȱʡ���뼶�� 
--read uncommitted 
--read committed ��������д д��������
--repeatable read(���ظ���ȡ)  �����ύ���������ͷ� ��ͨ���ִ������ͷ�
--serializable
set transaction isolation level read uncommitted --���͸��뼶�� �����������ȡ��Ч�����ݣ������޸���δ�ύδ��Ч��
select * from table_name with(nolock)  --�������
dbcc opentran()
exec sp_lock  --look up lock
select * from sys.dm_tran_locks where request_session_id=@@SPID

dbcc traceof(3604) --��ӡ������־ process list resources list

select * from sys.dm_os_process_memory;
select * from sys.dm_os_sys_memory;




