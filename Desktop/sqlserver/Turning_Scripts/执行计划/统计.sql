/***********************************************************************
Author="Kenneth Wang"
Create Date="2008/6/22"
***********************************************************************/


/*���û��ͳ�ƣ�����ͳ�ƹ�ʱ�����ѯ�Ż������޷��ҵ���Чִ��sql���ķ����������п�������*/
--��������ȫɨ������
--��������
use Northwind

--��������
create index idx_charge_member_no on charge(member_no)

--�鿴ͳ��
dbcc show_statistics(charge,idx_charge_member_no)

--����1��1071֮��,�������˵�ļ�¼��Ŀ=9619
select count(member_no) range_rows from charge
where member_no<1071 and member_no>1

--��1071��ͬ�ļ�¼��Ŀ=80
select count(member_no) eq_rows from charge where member_no=1071

--����1��1095֮�䣬�������˵�Ĳ�ͬ��¼����=429
select count(distinct member_no) distinct_range_rows from
charge where member_no<1071 and member_no>1


--ƽ����ͬ��¼�ı���=22.4149184149184
select convert(float,count(member_no))/count(distinct member_no) avg_range_rows from charge 
where member_no<1071 and member_no>1

drop index charge.idx_charges_member_no

--����ͳ��
exec sp_dboption 'northwind','auto create statistics',false

--��Ȼ���������������һ����ѯ������Ϊλ�ڵڶ����ֶε�
--member_noû��ͳ�ƣ������Ż������޷��жϷ���member_no�����ļ�¼���ж���
exec spcleanidx 'charge'
exec sp_helpindex 'charge'
select * from charge where member_no=1000

create index idx_charges_member_no on charge(charge_no,member_no)

sp_helpstats 'charge'

select name,dpages from sysindexes where id=object_id('charges')
--���⣺��ɨ�裿������
select * from charge where member_no=1000

--����ͳ��
----�ֶ�����ͳ��
create statistics sta on charge(member_no)
--��Ҫ������ǰ��ִ�мƻ�
dbcc freeproccache
sp_updatestats
--update statistics
----�Զ�����
exec sp_dboption 'credit','auto create statistics',true
go

select * from charge where member_no=1000


/*==============ʵ��=========================*/
use northwind
go

--����ͳ�ƹ��ڵĽ��
set nocount on
set statistics io off

create table tbltest(
userid int identity(1,1) primary key nonclustered,
username nvarchar(20),
gender nchar(1))

--��ʼӪ��10000��'Ů'��һ��'�С��������¼����
insert tbltest values('hello world','��')

declare @int int
set @int=1
while @int<10000
begin
	insert tbltest values('hello'+convert(nvarchar,@int),
	--case when @int%2=0 then ����' else 'Ů' end
	'Ů'
	)
	set @int=@int+1
end

--��ʱ����������ͬʱ������ͳ�Ƽ�¼�������ı���
create index idxgender on tbltest(gender)
exec sp_helpindex tbltest
exec sp_helpstats tbltest

--�鿴ͳ�Ʒֲ�
dbcc show_statistics(tbltest,idxgender)

--ͳ������ȷ�ģ����������ڵ�ǰ�Ĳ�ѯ
set statistics io on
select * from tbltest where gender='��'

--ǿ�����ݱ�ɨ��
select * from tbltest(index(0)) where gender='��'
set statistics io off

--����Ҫ��Ҫ�Զ�����ͳ������
--exec sp_dboption 'northwind','auto update statistics',{false | true } --����������ݱ�
exec sp_autostats 'tbltest','off',idxgender

--����¼�ĳ�1:1
update tbltest set gender='��' where userid %2=0
select gender,count(*) from tbltest group by gender

--�ȶ�һ���ô�����ʱ�����ߵ�I/O����
set statistics io on

--ͨ��set statistics profile�����Rows��EstimateRowes
--���ԱȽ���ʵ����Ƶļ�¼������
set statistics profile on

select * from tbltest where gender='��'

--ǿ�����ݱ�ɨ��
select * from tbltest(index(0)) where gender='��'

dbcc show_statistics(tbltest,idxgender)

--����ͳ�Ƹ��º󣬿�������һ��ǰ���ķ���
update statistics tbltest
select * from tbltest where gender='��'

drop table tbltest