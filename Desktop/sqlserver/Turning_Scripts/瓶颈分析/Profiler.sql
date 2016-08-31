/***********************************************************************
Author="Kenneth Wang"
Create Date="2008/6/25"
***********************************************************************/

--示例1
/*--------------------创建跟踪----------------*/
Locks:
	Lock: Deadlock Chain
	Deadlock Graph
	Lock: Deadlock

--A窗口
begin tran
update production.product set listprice=2 where productid=1

--B窗口
begin tran
update production.product set listprice=2 where productid=2

--A窗口
select * from production.product where productid=2

--B窗口
select * from production.product where productid=1


/*-------------------停止跟踪---------------------*/


--练习

--创建一个跟踪，捕捉 SP:Recompile和SQL:StmtRecompile
--跟踪应该包含pid, StartTime, Textdata, EventSubclass, ObjectID, DatabaseID字段
--并保存到c:\recompiletrace.trc
--下面的语句将强制SQL Server重新编译存储过程
use adventureworks
EXEC dbo.uspGetBillOfMaterials 991, '2001-1-1' WITH RECOMPILE
--下面的查询将返回跟踪文件里的信息
SELECT spid, StartTime, Textdata, EventSubclass, ObjectID, DatabaseID, SQLHandle 
	FROM  fn_trace_gettable ( 'c:\recompiletrace.trc' , 1) 
	WHERE EventClass in(37,75,166)