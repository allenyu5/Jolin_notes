CREATE PROC myScript.spListRecompile
AS
select top 25
	plan_generation_num,
	SUBSTRING(qt.text,qs.statement_start_offset/2+1, 
		(case when qs.statement_end_offset = -1 
		then DATALENGTH(qt.text) 
		else qs.statement_end_offset end -qs.statement_start_offset)/2 + 1) 
		as stmt_executing,
	qt.text,
	execution_count,
	sql_handle,
	dbid,
	db_name(dbid) DBName,
	objectid,
	object_name(objectid,dbid) ObjectName 
from sys.dm_exec_query_stats as qs
	Cross apply sys.dm_exec_sql_text(sql_handle) qt
where plan_generation_num >1
order by plan_generation_num
