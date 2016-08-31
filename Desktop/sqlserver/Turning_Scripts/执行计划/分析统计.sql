use adventureworks
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