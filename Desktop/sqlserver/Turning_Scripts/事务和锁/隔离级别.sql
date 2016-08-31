/***********************************************************************
Author="Kenneth Wang"
Create Date="2008/6/24"
***********************************************************************/

set transaction isolation level
{READ UNCOMMITTED
|READ COMMITTED
|REPEATABLE READ
|SNAPSHOT
|SERIALIZABLE 
}[;]

--================��ȡδ�ύ(Read Uncommitted)======================--
--�������(dirty Read)�����Զ�ȡ����������Ѿ��޸ĵ��ǻ�ûȷ�ϵ�������
--���Ź�����ֱ�Ӷ�ȡ����

--�����������ݱ�,�������ʼ�¼
Use northwind
go

create table MY_TRANSACTION(userid int,username varchar(20))
go
insert into MY_TRANSACTION values(1,'kenneth')
insert into MY_TRANSACTION values(2,'ASDF')
go

--��ʼ��ʽ����
begin tran
	update MY_TRANSACTION
	set username='ASDF_CHANGED'
	where userid=2
	--(û��ִ��ROLLBACK��COMMIT�����Դ�������������)
	select @@trancount --ֵΪ1
--rollback tran

--��������һ������
--���Բ�ѯû��������������
use northwind
go

set transaction isolation level READ UNCOMMITTED
select * from MY_TRANSACTION
where userid=2

--================��ȡ�ύ(Read committed)======================--
--�����ظ���ȡ(Nonrepetable Read)��SQL ServerĬ�ϵ�������뼶��
--�������ڶ�ȡ����ʱ�����ݿ��������ù������Է�ֹ���������޸�����
--���ԣ��ø��뼶����Ա��ⷢ�����(dirty Read)

--��ʼ��ʽ����
begin transaction
--�����޸�
	update MY_TRANSACTION
	set username='ASDF_CHANGED_1'
	where userid=2
	--(û��ִ��ROLLBACK��COMMIT�����Դ�������������)
	select @@trancount --ֵΪ1
--rollback tran

--��������һ������
--�����Բ�ѯû��������������
use northwind
go

set transaction isolation level READ COMMITTED
select * from MY_TRANSACTION
where userid=2

--���SQL Server 2005���ݿ�����READ_COMMITTED_SNAPSHOTΪON��ָ��
--READ_COMMITTED ���뼶�������ʹ���а汾���ƶ�����������

--�����������ݿ�
use master
go
create database READ_COMMITTED_SNAPSHOT_TEST
go

--���ÿ��ո�������
alter database READ_COMMITTED_SNAPSHOT_TEST
set READ_COMMITTED_SNAPSHOT on

--�������ݱ�
use READ_COMMITTED_SNAPSHOT_TEST
go
create table READ_COMMITTED_SNAPSHOT_LEVEL
([id] int identity,username nvarchar(15))

--��������
insert into READ_COMMITTED_SNAPSHOT_LEVEL values(N'С��')

--��ѯ�ı�ǰ������
select id,username as '�ı�ǰ����' from READ_COMMITTED_SNAPSHOT_LEVEL

--��ʼ��ʽ����
begin transaction
	update READ_COMMITTED_SNAPSHOT_LEVEL set username='kenneth'
	where id=1
	--(û��ִ��ROLLBACK��COMMIT�����Դ�������������)
	select @@trancount --ֵΪ1
--rollback tran

--��������һ������
--��ѯ������ʼǰ�Ѿ�����ύ������
use READ_COMMITTED_SNAPSHOT_TEST
go
select id,username from READ_COMMITTED_SNAPSHOT_LEVEL where id=1

--================���ظ���ȡ(Repeatable Read)======================--
--�����Ӱ����Phantom Read��
--������������еĹ��������������������Ϊֹ�������Ƕ�ȡ�Ժ���ͷŹ�����
--���ʹ�ø�������뼶���ȡ���ݣ������ݶ����Ժ���������ֻ�ܶԴ˷�Χ��
--���ݽ��ж�ȡ�Ͳ���Ĳ��������ǲ��ܸ������ݣ�ֱ����ȡ���ݵ��������Ϊֹ��
--�ŵ㣿ȱ�㣿

--����������뼶��Ϊ���ظ���ȡ(Repeatable Read)
use northwind
go

set transaction isolation level REPEATABLE READ

--������ʾ����
begin tran
	--��ѯ����
	select * from MY_TRANSACTION
	where userid=2
	--(û��ִ��ROLLBACK��COMMIT�����Դ�������������)
	select @@trancount --ֵΪ1
--rollback tran

--��������һ������
--�ɲ�ѯ�������޸�
use northwind
go

select * from MY_TRANSACTION
where userid=2
go

UPDATE MY_TRANSACTION set username='ASDF_CHANGED_2'
where userid=2

--================����(SNAPSHOT)======================--
--SQL Server 2005�����ӵ�������뼶��
--����֮��������������еĶ�ȡ���������޸ĵ�Ӱ�졣
--����TempDB���ݿ�

use master
--�����������ݿ�
create database snapshot_DB
go

--�������ո�������
alter database snapshot_DB
set allow_snapshot_isolation on

--�����������ݱ�Ͳ�������
use snapshot_DB
create table snap_level
([id] int identity,username nvarchar(15))

--��������
insert into snap_level values(N'С��')

--��ѯ�޸�ǰ������
select id,username as '�޸�ǰ����' from snap_level

--������ʽ����
begin tran
	update snap_level set username='kenneth' where id=1
	--(û��ִ��ROLLBACK��COMMIT�����Դ�������������)
	select @@trancount --ֵΪ1
--rollback tran

--��������һ������
--��ѯ������ʼǰ�Ѿ�����ύ������
use snapshot_DB
go

set transaction isolation level SNAPSHOT
select id,username from snap_level where id=1


--================�����л�(Serializable)======================--
--�ȼ���ߣ����ϸ�����������Χ����������ʹ������ȫ�������������
--�������������ǰ���������񲻿��Բ��������ݣ��������������ֵλ��
--��ǰ��������ȡ����������Χ֮��
--����select����HOLDLOCK

--����������뼶��Ϊ�����л�(Serializable)
use northwind
go

set transaction isolation level serializable

--��ʼ��ʽ����
begin tran
	--��ѯ����
	select * from MY_TRANSACTION
	where userid=2
	--(û��ִ��ROLLBACK��COMMIT�����Դ�������������)
	select @@trancount --ֵΪ1
--rollback tran

--������һ����
--�ɲ�ѯ���ݣ����޷����������޸ĺ��������
use northwind
go

select * from MY_TRANSACTION
where userid=2
go
update MY_TRANSACTION set username='ASDF_CHANGED_3'
where userid=2
go
--��������
insert into MY_TRANSACTION values(3,'QQ')


--����ʾ
SELECT * FROM sys.dm_tran_locks

--����Ĵ�����ʾ���ּ�����������
use adventureworks
go

BEGIN TRAN
	UPDATE HumanResources.Department WITH (ROWLOCK)
	SET ModifiedDate = getdate()
--ʹ��֮ǰ�Ĵ���鿴���ķ������
ROLLBACK

BEGIN TRAN
	UPDATE HumanResources.Department WITH (PAGLOCK)
	SET ModifiedDate = getdate()
--ʹ��֮ǰ�Ĵ���鿴���ķ������
ROLLBACK

BEGIN TRAN
	UPDATE HumanResources.Department WITH (TABLOCK)
	SET ModifiedDate = getdate()
--ʹ��֮ǰ�Ĵ�����Կ�����һ���µ���������
ROLLBACK


-- TABLOCK��TABLOCKX�Ĳ�֮ͬ������TABLOCK���������������б��������������ɼ��ͷ�
BEGIN TRAN
	SELECT * FROM HumanResources.Department WITH (TABLOCK)
ROLLBACK
--����TABLOCKX�����������񱣳�������
BEGIN TRAN
	SELECT * FROM HumanResources.Department WITH (TABLOCKX)
ROLLBACK
--ʹ��XLOCKѡ����ָ��ʹ�������� 
BEGIN TRAN
	SELECT * FROM HumanResources.Department WITH (ROWLOCK, XLOCK)
ROLLBACK
BEGIN TRAN
	SELECT * FROM HumanResources.Department WITH (PAGLOCK, XLOCK)
ROLLBACK

--------------------------------------------------
--����1
use northwind
go

begin tran
	update employees set lastname='kkkkk' where employeeid=1
--rollback tran
--����2
use northwind
go

select employeeid,firstname,lastname from employees(nolock)
where employeeid<5

--����3
use northwind
go
select employeeid,firstname,lastname from employees(readpast)
where employeeid<5


















