--准备数据
select * into northwind.dbo.Member from credit.dbo.Member
select * into northwind.dbo.Charge from credit.dbo.Charge
select * into northwind.dbo.Category from credit.dbo.Category

--聚集索引:数据表本身就是聚集索引的子叶层,整个数据表的摆放顺序是按照选定的键值由小到大排序
--问题:何时适合使用聚集索引?

--非聚集索引:使用自己的结构，子叶层放的数据可能是：书签或聚集索引键值
--如果数据表没有建立聚集索引，则称呼数据表为HEAP(堆）,子叶层放的是键值和指向符合键值记录的Row ID（FileID:PageID:SlotID）。
--书签(bookmark)查找就是使用Row ID进行查找。

--如果数据表建立聚集索引，则非聚集索引子叶层放的是聚集索引的键值


--聚集索引非常重要，慎重慎重！

/*=======================非聚集索引示范=====================*/
use northwind
go

sp_helpindex 'member'
go
create index idx_lastname on member(lastname)
go

select * from member with (index(idx_lastname)) 
where lastname between 'matri' and 'rudd'
/*备注，当查询条件的选择性不高，也就是符合条件的记录占总纪录数不小的比例时，使用非聚集索引查询是非常
没有效率的*/

select * from member where lastname between 'matri' and 'rudd'
--可以看出，此时sql server宁愿选择表扫描的方式

drop index member.idx_lastname

--对一个表使用多个索引
--查看执行计划
exec sp_helpindex 'charge'

CREATE INDEX idx_Charge_amt ON Charge(charge_amt)
CREATE INDEX idx_Provider_no ON Charge(provider_no)
GO

--因为 WHERE 条件对上述两个索引的选择性都很高
--所以会先用索引挑出符合纪录，透过 Hash Join 组织在一起后
--再对资料表做书签搜寻
SELECT * FROM Charge 
WHERE charge_amt < 5 AND provider_no <300

--删除索引
exec spcleanidx 'charge'
sp_helpindex 'charge'

/*========================排序============================*/
/*order by,distinct,top，group by
要使用索引来更有效的排序查询数据，最直接的方式就是在你要排序
的字段上建立聚集索引。*/

--预先排序的数据（创建聚集索引）
--显示执行计划
sp_helpindex 'member'
go

create clustered index idx_memberno on member(member_no)
go

select * from member order by member_no
select * from member order by lastname

drop index member.idx_memberno

--配置索引顺序
--显示执行计划
create clustered index idx_lastname on member(lastname)

select * from member order by lastname
select * from member order by lastname desc

--当使用多个字段的索引来完成排序时
--显示执行计划
select * from member
order by lastname asc,firstname desc

create clustered index idx_lastname on member(lastname asc,firstname desc) with drop_existing

select * from member
order by lastname asc,firstname desc

drop index member.idx_lastname

sp_helpindex 'member'
go



