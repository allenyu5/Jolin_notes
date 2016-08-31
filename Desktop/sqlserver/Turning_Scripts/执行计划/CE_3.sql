--�����ܶ�
Create table TestStatistics(id int identity(1,1),ref int)

begin tran
	declare @a int
	set @a=1
	while @a<=100
	begin 
		insert into TestStatistics(ref)  values(@a)
		set @a=@a+1
	end
commit tran

begin tran
	declare @b int
	set @b=1
	while @b<=9900
	begin 
		insert into TestStatistics(ref)  values(100)
		set @b=@b+1
	end
commit tran

--��������
create index idx_ref on TestStatistics(ref)

--�鿴ͳ��ֵ
dbcc show_statistics(TestStatistics,idx_ref)

--�ܶ�
select 1.0/(select count(distinct ref) from TestStatistics)

--���ڲ��ܸ��ݲ�����������ѡ��Ĳ�ѯ����ʹ���ܶȹ�������
select (1.0/(select count(distinct ref) from TestStatistics))*(select count(*) from TestStatistics)

select * from TestStatistics
where ref=1

declare @var int
set @var=1
select * from TestStatistics
where ref=@var

--�����������Ϸֲ�����
--SET STATISTICS IO ON
select sod.SalesOrderID,p.Name,sod.UnitPrice
from Production.Product as p 
inner join sales.SalesOrderDetail as sod 
on p.ProductID=sod.ProductID
where ListPrice>1350
		  and p.DaysToManufacture>2
		  and StandardCost>750

--��ν����
--ʹ����ʾ