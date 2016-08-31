use adventureworks
go

--测试统计过期的结果
set nocount on
set statistics io off

create table tbltest(
userid int identity(1,1) primary key nonclustered,
username nvarchar(20),
gender nchar(1))

--开始营造10000笔'女'，一笔'男‘的悬殊纪录差异
insert tbltest values('hello world','男')

declare @int int
set @int=1
while @int<10000
begin
	insert tbltest values('hello'+convert(nvarchar,@int),
	--case when @int%2=0 then ’男' else '女' end
	'女'
	)
	set @int=@int+1
end

--此时建立索引所同时产生的统计记录如此悬殊的笔数
create index idxgender on tbltest(gender)
exec sp_helpindex tbltest
exec sp_helpstats tbltest

--查看统计分布
dbcc show_statistics(tbltest,idxgender)

--统计是正确的，索引合用于当前的查询
set statistics io on
select * from tbltest where gender='男'

--强迫数据表扫描
select * from tbltest(index(0)) where gender='男'
set statistics io off

--故意要求不要自动更新统计数据
--exec sp_dboption 'northwind','auto update statistics',{false | true } --针对整个数据表
exec sp_autostats 'tbltest','off',idxgender

--将记录改成1:1
update tbltest set gender='男' where userid %2=0
select gender,count(*) from tbltest group by gender

--比对一下用错索引时，两者的I/O差异
set statistics io on

--通过set statistics profile输出的Rows和EstimateRowes
--可以比较真实与估计的纪录数差异
set statistics profile on

select * from tbltest where gender='男'

--强迫数据表扫描
select * from tbltest(index(0)) where gender='男'

dbcc show_statistics(tbltest,idxgender)

--做完统计更新后，可以再试一次前述的范例
update statistics tbltest
select * from tbltest where gender='男'

drop table tbltest