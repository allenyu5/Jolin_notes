/***********************************************************************
Author="Kenneth Wang"
Create Date="2008/6/21"
***********************************************************************/

use master
go

/*1.创建一个数据库
这个数据库包含了三个自定义文件组，每个文件组中包含了一个文件
*/
CREATE DATABASE [PartitionDemo] 
go
--2.增加文件组和文件
alter database PartitionDemo add filegroup [fg1]
go
alter database PartitionDemo add filegroup [fg2]
go
alter database PartitionDemo add filegroup [fg3]
go

alter database PartitionDemo
add file
(name='fg1',
 filename='e:\fg1.ndf',
size=5mb)
to filegroup [fg1]
go
alter database PartitionDemo
add file
(name='fg2',
 filename='f:\fg2.ndf',
size=5mb)
to filegroup [fg2]
go
alter database PartitionDemo
add file
(name='fg3',
 filename='g:\fg3.ndf',
size=5mb)
to filegroup [fg3]
go

use PartitionDemo
go
/*
3.在数据库中创建分区函数和架构
*/
Create partition function pf_OrderDate(datetime) as range right for values ('01/01/2003','01/01/2004')
go

Create partition scheme ps_OrderDate as partition pf_OrderDate to (fg1,fg2,fg3,fg1)
go
--4.创建基于以上分区架构的一个分区表
Create table SalesData(custid int, OrderDate datetime) on ps_OrderDate(OrderDate)
go

/*
5.插入范例数据
*/
insert into SalesData values(1,'12-1-2001')
insert into SalesData values(1,'12-1-2002')
insert into SalesData values(1,'12-1-2003')
insert into SalesData values(1,'12-1-2004')


/*6.查看数据的分布*/
SELECT $PARTITION.pf_OrderDate(OrderDate) AS Partition,
COUNT(*) AS [COUNT] FROM SalesData
GROUP BY $PARTITION.pf_OrderDate(OrderDate)
ORDER BY Partition ;
GO

--7.增加一个分区，来存放2005年的资料
ALTER PARTITION FUNCTION pf_OrderDate()
SPLIT RANGE('01/01/2005')

insert into SalesData values(1,'12-1-2006')

--8.再增加一个分区，来存放2006年的资料，这时应该会出错，因为没有指定可用的文件组
ALTER PARTITION FUNCTION pf_OrderDate()
SPLIT RANGE('01/01/2006')
--一个重点是，因为split操作，如果针对的分区已经有数据的话，那么可能导致性能问题.所以，一般在分区表的首尾都预留一个空白的分区.以后再拆分和合并的时候就比较方便

--9.所以，得先修改架构，指定下一个可用的文件组
ALTER PARTITION SCHEME ps_OrderDate
NEXT USED fg3
--然后再执行上面一段代码就可以增加一个分区了


--10.合并分区，假设想把第二个分区和第一个分区合并，即把第一个分区的边界设置为截至到2003年12月31日.这里要注意的是，如果第二个分区所使用的文件组，没有被别的分区使用，也没有被定义为NEXT USED，那么该文件组会从架构中删除
ALTER PARTITION FUNCTION pf_OrderDate()
MERGE RANGE('01/01/2003')


--11.准备一个表，接受ETL数据导入，然后再一次性导入到第一个分区.注意，这里的文件组要对应，而且分区列的约束也是要一样的
USE [PartitionDemo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[stagingTable](
	[custid] [int] NULL,
	[OrderDate] [datetime] NULL
) ON [fg1]

GO
ALTER TABLE [dbo].[stagingTable]  WITH CHECK ADD  CONSTRAINT [CK_stagingTable] CHECK  (([OrderDate]<='2003-12-31'))
GO
ALTER TABLE [dbo].[stagingTable] CHECK CONSTRAINT [CK_stagingTable]


--12.往这个表中插入一些数据
insert into stagingTable values(5,'2002-1-1') --这条能够插入
insert into stagingTable values(5,'2005-1-1') --这条不能插入,因为违反约束
select * from stagingTable

--13.准备把stagingTable这个表的资料切换到第一个分区里面,这时候可能会有一个错误，就是目标分区必须为空，所以切入的操作不是追加方式，而是完全替代掉
ALTER TABLE StagingTable switch TO SalesData PARTITION 1
delete from SalesData where OrderDate<='2003-12-31' --除了这样删除之外，还可以把这个分区现有资料switch到一个空的表里面去，类似下一步的做法
select * from salesData

--13.再把这第一个分区尝试切换出来看看
ALTER TABLE StagingTable switch TO SalesData PARTITION 1
select * from stagingTable

--注意：switch并不删除分区，而是把数据移动了一下

