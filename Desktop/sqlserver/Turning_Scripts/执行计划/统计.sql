/***********************************************************************
Author="Kenneth Wang"
Create Date="2008/6/22"
***********************************************************************/


/*如果没有统计，或者统计过时，则查询优化程序无法找到有效执行sql语句的方法，甚至有可能误判*/
--方法：完全扫描或抽样
--创建索引
use Northwind

--创建索引
create index idx_charge_member_no on charge(member_no)

--查看统计
dbcc show_statistics(charge,idx_charge_member_no)

--介于1到1071之间,不包含端点的记录数目=9619
select count(member_no) range_rows from charge
where member_no<1071 and member_no>1

--与1071相同的记录数目=80
select count(member_no) eq_rows from charge where member_no=1071

--介于1到1095之间，不包含端点的不同记录个数=429
select count(distinct member_no) distinct_range_rows from
charge where member_no<1071 and member_no>1


--平均不同记录的比例=22.4149184149184
select convert(float,count(member_no))/count(distinct member_no) avg_range_rows from charge 
where member_no<1071 and member_no>1

drop index charge.idx_charges_member_no

--测试统计
exec sp_dboption 'northwind','auto create statistics',false

--虽然这个索引有利于下一个查询，但因为位于第二个字段的
--member_no没有统计，所以优化程序无法判断符合member_no条件的记录数有多少
exec spcleanidx 'charge'
exec sp_helpindex 'charge'
select * from charge where member_no=1000

create index idx_charges_member_no on charge(charge_no,member_no)

sp_helpstats 'charge'

select name,dpages from sysindexes where id=object_id('charges')
--问题：表扫描？索引？
select * from charge where member_no=1000

--更新统计
----手动更新统计
create statistics sta on charge(member_no)
--需要放弃先前的执行计划
dbcc freeproccache
sp_updatestats
--update statistics
----自动更新
exec sp_dboption 'credit','auto create statistics',true
go

select * from charge where member_no=1000


/*==============实例=========================*/
use northwind
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