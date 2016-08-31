
--ִ��ģ��
--SQLOS��SQL�Լ�����Դ������
----һ���߼�CPUһ��Scheduler
---�����̷߳��䵽��������ά��һ�������̳߳أ�ͬһʱ��ֻ������һ�������̣߳�
------5���б��Զ��ó����ƣ���
 --------Worker�б�û�з����������ȴ����������߳��б�
--------- Waiter�б���������Դ�Ĺ����߳�
---------Runnable�б����ȴ���Դ���ȴ�CPU����
---------I/O�б���ҪIO�����Ĺ����߳�
---------��ʱ���б���Waitfordelay

select * from sys.dm_os_schedulers where status='VISIBLE ONLINE'  --���еĵ�����
select * from sys.dm_os_workers    --�������ϵĹ����߳�
select * from sys.dm_os_waiting_tasks where session_id>50   --���ڵȴ�������
	select wait_type,count(*) as num_waiting_tasks,sum(wait_duration_ms) total_wait_time_ms
	from  sys.dm_os_waiting_tasks  where session_id>50
	group by wait_type
	order by wait_type

select * from sys.dm_exec_requests where session_id>50--�������б��еȴ�CPU���ȵ�����
select * from  sys.dm_os_wait_stats  where wait_time_ms>0 order by wait_time_ms desc --�ۼƵȴ�ͳ����Ϣ

--��Դ�ȴ�����
--1���ڴ�ȴ���CMEMTHREAD(�ƻ�����),RESOURCE_SEMAPHORE�������ڴ棩
---------��ؼ�������Memory Manager:Memory Grants Pending(�ȴ����ڴ�������) �����Դ���0
------------------------��Memory Manager:Memory Grants OUtstanding(��ȡ���ڴ�������)
------------------------��Buffer Manager��Buffer Cache Hit Ratio�������������ʣ� ������С��95%
------------------------��Buffer Manager��Page Life Expentancy��ҳ���������ڣ�  ������С��300
------------------------��Buffer Manager��Free Pages������ҳ������
------------------------��Buffer Manager��Free List Stalls/Sec(ÿ��ȴ�����ҳ��������)
------------------------��Memory��Available Mbytes�������ڴ棩    ������С��100MB

--IO�ȴ���IO_Completion,Async_IO_Completion,Writelog,Pageiolatch_* ��������
--------��ؼ�������Average disk sec/read,Average disk sec/write �����Դ���20ms
-----------------------Access Methods��Full Scans/sec��Index Searchs/sec��Forwarded Records/sec
--------��غ���fn_virtualfilestats
select mf.name,mf.physical_name,vfs.IoStallMS,
vfs.IoStallReadMS/NumberReads as avgreadsec,
vfs.IoStallWriteMS/NumberWrites as avgreadsec
from sys.fn_virtualfilestats(null,null) as vfs 
join sys.master_files as mf 
on mf.database_id=vfs.DbId and mf.file_id=vfs.FileId

--CPU�ȴ���SOS_SCHEDULER_YIELD���ȴ�ʱ��Ƭ����CXPACKET�����д���


--�����ȴ���LCK_*
----���DMV
select * from sys.dm_tran_active_transactions

