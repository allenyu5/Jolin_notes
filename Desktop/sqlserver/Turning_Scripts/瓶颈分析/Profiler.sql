/***********************************************************************
Author="Kenneth Wang"
Create Date="2008/6/25"
***********************************************************************/

--ʾ��1
/*--------------------��������----------------*/
Locks:
	Lock: Deadlock Chain
	Deadlock Graph
	Lock: Deadlock

--A����
begin tran
update production.product set listprice=2 where productid=1

--B����
begin tran
update production.product set listprice=2 where productid=2

--A����
select * from production.product where productid=2

--B����
select * from production.product where productid=1


/*-------------------ֹͣ����---------------------*/


--��ϰ

--����һ�����٣���׽ SP:Recompile��SQL:StmtRecompile
--����Ӧ�ð���pid, StartTime, Textdata, EventSubclass, ObjectID, DatabaseID�ֶ�
--�����浽c:\recompiletrace.trc
--�������佫ǿ��SQL Server���±���洢����
use adventureworks
EXEC dbo.uspGetBillOfMaterials 991, '2001-1-1' WITH RECOMPILE
--����Ĳ�ѯ�����ظ����ļ������Ϣ
SELECT spid, StartTime, Textdata, EventSubclass, ObjectID, DatabaseID, SQLHandle 
	FROM  fn_trace_gettable ( 'c:\recompiletrace.trc' , 1) 
	WHERE EventClass in(37,75,166)