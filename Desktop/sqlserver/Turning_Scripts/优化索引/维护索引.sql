/***********************************************************************
Author="Kenneth Wang"
Create Date="2008/6/22"
***********************************************************************/


--内部不连续：物理分页中有许多空间没有记录
--外部不连续：硬盘上摆放分页和扩展分页不连续



--使用dbcc showcontig观察索引不连续
use Northwind
go
EXEC spCleanIdx 'charge'

create index idx_charge_no on charge(charge_no)

dbcc showcontig(charge,idx_charge_no)


--把DBCC SHOWCONTIG查询的结果放在数据表中，以供后续观察
CREATE TABLE #fraglist (
   ObjectName CHAR (255),
   ObjectId INT,
   IndexName CHAR (255),
   IndexId INT,
   Lvl INT,
   CountPages INT,
   CountRows INT,
   MinRecSize INT,
   MaxRecSize INT,
   AvgRecSize INT,
   ForRecCount INT,
   Extents INT,
   ExtentSwitches INT,
   AvgFreeBytes INT,
   AvgPageDensity INT,
   ScanDensity DECIMAL,
   BestCount INT,
   ActualCount INT,
   LogicalFrag DECIMAL,
   ExtentFrag DECIMAL)

INSERT #fraglist EXEC('DBCC SHOWCONTIG(Charges,idx_charge_no)  WITH TABLERESULTS')

SELECT * FROM #fraglist

--使用sys.dm_db_index_physical_stats动态管理函数观察数据不连续

--简单查询
use adventureworks
select * from sys.dm_db_index_physical_stats(db_id(N'adventureworks'),object_id(N'humanresources.department'),DEFAULT, DEFAULT,'detailed')

--查询索引外部不连续状况
--可以从manament studio查看索引的属性，详细信息
select a.index_id,name,avg_fragmentation_in_percent from sys.dm_db_index_physical_stats(db_id(),object_id(N'humanresources.department'),DEFAULT, DEFAULT, 'LIMITED') as a 
inner join sys.indexes as b on a.object_id=b.object_id and a.index_id=b.index_id


--如果看到avg_fragmentation_in_percent接近30，则需要重新组织索引
--如果看到avg_fragmentation_in_percent大于30，则需要重建索引

--重建数据表上特定索引
use adventureworks
alter index pk_customer_customerid on sales.customer rebuild

--重建数据表上所有索引
alter index all on sales.customer rebuild

--带参数重建索引
alter index all on production.product rebuild with (fillfactor=80,sort_in_tempdb=on,online=on)

--重新组织索引
use adventureworks
alter index pk_customer_customerid on sales.customer reorganize

--重新组织数据表数据表上所有索引
alter index all on sales.customer reorganize


--sql server 2005新增加disable选项
use adventureworks
go
create index idxterritoryid on sales.customer(territoryID)
go
alter index idxterritoryid on sales.customer disable
--如果disable索引，需要重建或者删除再建立
alter index idxterritoryid on sales.customer rebuild
--否则使用到禁用的索引会发生错误
select territoryid from sales.customer with (index(idxterritoryid))




---通过停用聚集索引来停用某个数据表
Use Tempdb
--若是 Clustered Index 被 Disable，则整个数据表都不能用
CREATE TABLE tblT1(C1 INT)
CREATE CLUSTERED INDEX idxC1 ON tblT1(C1)
ALTER INDEX idxC1 ON tblT1 DISABLE

--使用时，会有以下的错误
--消息 8655，极别 16，状态 1，行 1
--查询处理器无法产生计划，因为数据表或视图 'tblT1' 上的索引 'idxC1' 已停用。
SELECT * FROM tblT1
INSERT tblT1 VALUES(1)
ALTER INDEX idxC1 ON tblT1 REBUILD
DROP TABLE tblT1


