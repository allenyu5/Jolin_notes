select @@version
select * from sys.dm_exec_connections
select * from sys.dm_exec_sessions  --闲置 活动
--CPU查询（50以下系统）(性能监视器)
--avg disk read/writer (0.02ms)

select * from sys.dm_exec_requests  --正在运行 
select * from sys.dm_os_tasks  --任务 
select * from sys.dm_os_workers --工作线程 执行的最小单元  一旦启动必须执行结束 等待调度 
select * from sys.dm_os_sys_info  
select * from sys.dm_os_schedulers --调度器与CPU绑定


--执行模型
SQL语句运行阶段 =编译+运行 
运行=资源+CPU
set statistics time on
dbcc cache --清空缓存
dbcc buffers

---性能调优  合作式调度机制 

--IO（资源监视器 响应时间（大于20ms）)
set statistics io on

---memory（耗内存的内部组件）
	--connection
	--buffer pool(data cache  plan cache  log cache )
	--3rd code(link server/扩展存储过程/sql clr/com+ )


--sql server wait_type（实例级别）
select * from sys.dm_os_wait_stats order by wait_time_ms desc

--检查索引效率
select top 100 * from sys.dm_db_index_usage_stats;

--强制使用索引 
select column_name from table_name with index(index_name)
create index index_name on table_name(column_name1) include (column_name2)  --区别复合索引  仅树干有column_name1 key值 
create index index_name on table_name(column_name1, column_name2)  --复合索引 

--查询缓存计划
select * from sys.dm_exec_cached_plans
select top 20 qt.text,* from sys.dm_exec_query_stats as qs
cross apply sys.dm_exec_sql_text(qs.sql_handle) as qt

--长期监控不建议profile 可以先导出 编写跟踪适应的脚本 
--profiler 短时间实时跟踪 
--sql trace 长时间实时跟踪 
exec sp_trace_setstatus 2 2  --param 1;process id    param2: 0删除监控 1开启监控 2停止监控 
select * from fn_trace_gettable('file_path',default)
order by Duration desc;

--windows性能监视器 与 sql trace profile必须加入开始/结束时间 

select @@TRANCOUNT
--查询阻塞
select * from sys.dm_exec_requests
select * from sys.sysprocesses

dbcc useroptions  --isolation level 缺省隔离级别 
--read uncommitted 
--read committed （读阻塞写 写阻塞读）
--repeatable read(可重复读取)  事务不提交共享锁不释放 普通语句执行完就释放
--serializable
set transaction isolation level read uncommitted --降低隔离级别 允许脏读（读取无效的数据，可能修改了未提交未生效）
select * from table_name with(nolock)  --允许脏读
dbcc opentran()
exec sp_lock  --look up lock
select * from sys.dm_tran_locks where request_session_id=@@SPID

dbcc traceof(3604) --打印死锁日志 process list resources list

select * from sys.dm_os_process_memory;
select * from sys.dm_os_sys_memory;




