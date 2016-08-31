/***********************************************************************
Author="Kenneth Wang"
Create Date="2008/6/23"
***********************************************************************/

--==========Ad-hoc��ѯ===========--
--��Ӧ�ó���������(Batch)�ڴ���һ������update,delete��select��T-SQL�﷨��
--SQL Serverʱ����֮ΪAd-Hoc��ѯ��SQL Server��������﷨��Cache�����ã���Ҫ
--��ʽ��ȫ��ͬ��������Сд�����л�հ׵Ȳ��졣

--ʹ��dbcc��������ڴ��е��Ѿ����ڵļƻ�����(Plan Cache)��
dbcc freeproccache

--ִ�������������ε��﷨����Ϊ�л��з��ָ������ᵼ�²�ͬ��ִ�мƻ�
select * from northwind.dbo.customers
select * from northwind.dbo.orders
go --����go���﷨��ִ�зֳ���������

select * from northwind.dbo.customers

select * from northwind.dbo.orders

--�鿴�����ִ�мƻ�
--���Կ���������ͬ��ִ�мƻ�
select cacheobjtype,objtype,usecounts,sql from sys.syscacheobjects
where sql not like '%cache%' and sql not like '%sys.%' and sql not like '%BatchID%'

--�ٴ�ִ�в�ѯ�����ٲ鿴�����ִ�мƻ���usecounts�ֶ��µ�ֵ����
--˵��ad-hoc�﷨�ļƻ����汻����

--=============�Զ����������棨Auto-parameterized queries)============--
--�Զ����������������sql�﷨����where�����Ӿ䣬���䳣��ֵ�����Ʒ��ϵļ�¼
--SQL Server�ڲ���ִ�мƻ�ʱ�������������Ա���ȡ���������ں����Ĳ�ѯ�У���
--��ֻ�ǳ������ֲ�ͬ������ʹ����ǰ������������ִ�мƻ�
select * from northwind.dbo.customers
where customerid='alfki'
go
select * from northwind.dbo.customers
where customerid='anatr'
go




--�鿴�����ִ�мƻ�
select cacheobjtype,objtype,usecounts,sql from syscacheobjects
where sql not like '%cache%' and sql not like '%sys.%' and sql not like '%BatchID%'

--=============ʹ��sp_executesql׼���Ĳ�ѯ============--
--ʹ��dbcc��������ڴ��е��Ѿ����ڵļƻ�����(Plan Cache)��
dbcc freeproccache

--���ַ�ʽ��ѯʱ��ֻ�Բ�ѯ�﷨�ı��彨��ִ�мƻ�������������޹�
exec sp_executesql N'select * from northwind.dbo.customers
where customerid=@custid',N'@CustID nvarchar(5)','alfki'
go
exec sp_executesql N'select * from northwind.dbo.customers
where customerid=@custid',N'@CustID nvarchar(5)','anatr'

--=======================================�洢����========================================--
--���ô洢���̿�������ִ�мƻ��������ԣ����Լ���SQL Server��Ѱִ�мƻ����CPU����������
Create Proc spGetCustomers @CustID nvarchar(5)
as
select * from northwind.dbo.customers
where customerid=@custid
go

exec spGetCustomers 'alfki'
exec spGetCustomers 'anatr'

--�鿴�����ִ�мƻ�
select cacheobjtype,objtype,usecounts,sql from syscacheobjects
where sql not like '%cache%' and sql not like '%sys.%' and sql not like '%BatchID%'


--������ݷֲ����ȣ����Բ�ͬ�Ĳ���������ͬ�Ĵ洢���̣�SQL Serverֱ��ȡ�����е�ִ�мƻ�
--������ݷֲ������ȣ���ͬ�Ĳ�������һ������ʹ����ͬ��ִ�мƻ�

USE TempDB
--Ҫ�Ƚ�ִ�к�ļƻ����� SQL Server ��ʵ��ʲôִ�мƻ���
--��ǰ��ͳ����Ϣʱ��ִ�мƻ��ᶼ��ͬ

SET NOCOUNT ON
Create Table T1
( 
IDKey int Identity(1,1) Primary key,
Key1 Int NOT NULL, 
Key2 Int NOT NULL, 
Key3 varchar(15) 
) 
GO 

-- ����������ϣ������������е����������ֲ�����ƽ�� 
Declare @Key1 int, @Key2 Int 
Set @Key1 =1 
While @Key1<100
	BEGIN 
	Set @Key2 =1 
	While @Key2<=20 
	BEGIN 
		Insert t1 ( Key1, key2, Key3) 
		Values(@Key1, @key2, 'Data '+Convert(varchar, @Key1) +', '+Convert(varchar, @Key2) ) 
		Set @Key2 =@Key2+1 
	END 
	Set @key1= @Key1+1 
END 
select * from t1
--����Զ��һ�����ݷ�Χ֮���������¼
INSERT t1 VALUES(10000,10000,'10000,10000')

-- �������ϲ�ѯ������
Create Index idxKey1 On t1(Key1)

--�����洢����
CREATE PROC sp @int INT =0
AS
SELECT * FROM t1 WHERE Key1=@int
GO

--���ô洢���̣�����ʵ�ʵ�ִ�мƻ�
--�ۼ�����ɨ��Ƚ���Ч
EXEC sp 1

--SQL Server ��������ǰ�����ļƻ�
--���ǷǾۼ�����ɨ����ʵ�Ƚ���Ч����ô�죿
EXEC sp 10000

--ʹ�� WITH RECOMPILE ���²��������
--����ȡ��ȷ��Ч��ִ�мƻ�
EXEC sp 10000 WITH RECOMPILE


--Ҫ���ѯ��ѻ������ڲ�ѯ���б������ѻ�ʱ,����ض��Ĳ���ֵ����ѻ�
ALTER PROC sp @int INT=0
AS
SELECT * FROM t1 WHERE Key1=@int
	OPTION ( OPTIMIZE FOR (@int = 10000) )
go

EXEC sp 10000

--���⣺������ܾ�����ѯ��ʷ��Ϲ��������ļ�¼��Ҳ���ܾ�����ѯ���Ϲ��������Ƚ��ٵļ�¼����ô�죿
--����SQL Server��Ҫ����ִ�мƻ���ÿ��ִ��ʱ��������������ѵ�ִ�мƻ���

--�޸Ĵ洢����
ALTER PROC sp @int INT=0
WITH RECOMPILE
AS
SELECT * FROM t1 WHERE Key1=@int
GO

--ִ�д洢����
EXEC sp 1
GO

EXEC sp 10000









