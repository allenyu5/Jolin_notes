
/*
--如果通过视图修改数据:
--用来分割的键值必须要加上check约束
--用来分割的键值必须是主键的一部分
--用来分割的键值不属于任何其他的键值
--Union All视图涵盖所有的成员数据表
*/


--
Local Partition View + Insteaded of Trigger 范例
--
go

--建立数据表并插入值
Use Northwind
go

Create table Supply_0_1000
(supplyid int primary key check(supplyid between 1 and 1000),supplier char(50))
go

Create table Supply_1001_2000
(supplyid int primary key check(supplyid between 1001 and 2000),supplier char(50))
go


Create table Supply_2001_3000
(supplyid int primary key check(supplyid between 2001 and 3000),supplier char(50))
go

Create table Supply_3001_4000
(supplyid int primary key check(supplyid between 3001 and 4000),supplier char(50))
go

--建立一个视图组合以上所有的Supplier Tables
Create View SupplyAll
as
select * from supply_0_1000
union  --all  --如果不是all会无法形成联邦数据库
select * from supply_1001_2000
union all
select * from supply_2001_3000
union all
select * from supply_3001_4000
go

/*
--建立instead of trigger

--通过替代触发器取代原来对view做的新建动作
create trigger io_trig_ins_supplyall on supplyall
instead of insert as
begin
insert into supply_0_1000
	select * form inserted where supplyid between 1 and 1000

insert into supply_1001_2000
	select * form inserted where supplyid between 1001 and 2000

insert into supply_2001_3000
	select * form inserted where supplyid between 2001 and 3000

insert into supply_3001_4000
	select * form inserted where supplyid between 3001 and 4000
end --trigger action
go
*/

--插入数据
set statistics io on

insert supplyall values('1','CaliforniaCorp')
insert supplyall values('5','BraziliaLtd')
go

insert supplyall values('1231','FarEast')
insert supplyall values('1280','NZ')
go

insert supplyall values('2321','EuroGroup')
insert supplyall values('2442','UKArchip')
go

insert supplyall values('3475','India')
insert supplyall values('3521','Afrique')
go

--查看结果
select  * from supplyall
go

/*解释：程序代码一开始创建了四个数据表，并在主键上建立数据记录区分明确的Check约束。
接着建立了一个视图用来Union All四个数据表，而此处必须强调的是，如果你想要让SQL Server
自动根据Insert记录的主键值而插入到正确的数据表的位置，必须要采用Union All,而不能仅仅
是Union，否则会报错，错误如下：
服务器：信息 4416，级别16，状态 5，行 1
Union All视图'SupplyAll'视图无法更新，因为定义中包含不允许的架构

如果不愿意使用Union All，或是无法在主键上建立明确区隔数据范围的check约束，则可以考虑在
视图上建立Instead Of 触发器，让数据的修改操作由Instead Of触发器的逻辑取代掉。
*/



