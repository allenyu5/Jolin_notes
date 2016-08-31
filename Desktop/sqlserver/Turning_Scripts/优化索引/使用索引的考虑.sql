/***********************************************************************
Author="Kenneth Wang"
Create Date="2008/6/22"
***********************************************************************/



/*索引少了，找数据没效率，索引多了，不利于新建、修改、删除的运行*/

--选择性(Selectivity)
选择性=符合条件的纪录数目/总记录笔数
/*选择性越高，也就是这个值越小，才越值得建立索引*/
use Northwind
go
sp_helpindex 'member'

create index idx_memberno on member(member_no)

--问题：非聚集索引,还是表扫描？
select * from member where member_no=1

--问题：非聚集索引,还是表扫描？
select * from member where member_no>=100

drop index member.idx_memberno

--数据密度(density)
数据密度=1/键值唯一的记录数
--密度越小,该字段越适合建索引

create index idx_charge_member_no on charge(member_no)
dbcc show_statistics(charge,idx_charge_member_no)  --后面会有专门的脚本示范统计

--数据分布
----数据分布(distribution)代表多笔数据记录组成的方式,与
密度的概念有关.
----可以是平均分布,也可以是正态分布

--如果是正态分布,查询优化程序将使用统计数据来记录某一个
--范围内的数据约略是多少笔记录,然后判断出选择性高或低,
--最后决定合用的索引。

--使用set statistics查看查询语法所使用的资源
--set statistics io on
--set statistics time on
--set statistics profile on
--set statistics xml on
select * from members where lastname like 'a%'


/*使用动态管理视图来查看索引的使用*/
--sys.dm_db_missing_index_group_stats 视图
--sys.dm_db_missing_index_groups 视图
--sys.dm_db_missing_index_details 视图
--sys.dm_db_missing_index_columns 函数
--sys.dm_db_index_usage_stats 视图

----------索引不足
--没有使用索引的查询，查看查询计划
USE Northwind
SET STATISTICS IO OFF
EXEC spCleanIdx 'Charge'
EXEC spCleanIdx 'Member'
exec sp_helpindex 'member'
exec sp_helpindex 'charge'

SET STATISTICS IO ON
SELECT LastName,FirstName,charge_no,charge_amt FROM Charge c
JOIN Member m ON c.member_no=c.member_no
WHERE c.Provider_no=498 AND m.member_no=5 AND charge_amt>1000


--查询各种动态管理视图，以分析所需的索引
select * from sys.dm_db_missing_index_groups
select * from sys.dm_db_missing_index_group_stats
select * from sys.dm_db_missing_index_details

SELECT mig.*, statement AS table_name,column_id, column_name, column_usage
FROM sys.dm_db_missing_index_details AS mid
CROSS APPLY sys.dm_db_missing_index_columns (mid.index_handle)
INNER JOIN sys.dm_db_missing_index_groups AS mig ON mig.index_handle = mid.index_handle
ORDER BY mig.index_group_handle, mig.index_handle, column_id
--将相等的数据行放在最前面
--将不相等的数据行放在相等数据行后面
--将包含的数据行放在放在include子句中

--根据系统管理视图的建议创建索引
CREATE INDEX idxCharge ON Charge(Provider_no,charge_amt) INCLUDE(Charge_no,member_no)
CREATE INDEX idxMember ON Member(member_no)

--重新执行查询语句，，查看查询计划
SELECT LastName,FirstName,charge_no,charge_amt FROM Charge c
JOIN Member m ON c.member_no=c.member_no
WHERE c.Provider_no=498 AND m.member_no=5 AND charge_amt>1000

----------索引过多
--插入数据会影响到索引
insert charge values(1,1,1,1,1,1,1)
--通过idxcharge索引扫描member_no=1的记录
update charge set charge_code=1 where member_no=1

--查看动态管理视图sys.dm_db_index_usage_stats，取得索引的统计信息
--sys.dm_db_index_usage_stats返回利用索引进行的搜索，扫描，查询和更新的累积次数，每次用到都会加1。
--注意user_updates字段,如果这个值过高，说明更新次数过多，则应该卸载该索引
select * from sys.dm_db_index_usage_stats
where object_id=object_id('charge')

--删除索引
set statistics io off

exec spcleanidx 'member'
go
exec spcleanidx 'charge'



