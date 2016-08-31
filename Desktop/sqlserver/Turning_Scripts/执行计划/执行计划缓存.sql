/***********************************************************************
Author="Kenneth Wang"
Create Date="2008/6/23"
***********************************************************************/

--==========Ad-hoc查询===========--
--当应用程序在批次(Batch)内传送一句以上update,delete或select等T-SQL语法到
--SQL Server时，称之为Ad-Hoc查询，SQL Server针对这种语法的Cache与重用，需要
--格式完全相同，包含大小写，分行或空白等差异。

--使用dbcc命令清空内存中的已经存在的计划缓存(Plan Cache)。
dbcc freeproccache

--执行下面两个批次的语法，因为有换行符分隔，将会导致不同的执行计划
select * from northwind.dbo.customers
select * from northwind.dbo.orders
go --利用go将语法的执行分成两个批次

select * from northwind.dbo.customers

select * from northwind.dbo.orders

--查看缓存的执行计划
--可以看到产生不同的执行计划
select cacheobjtype,objtype,usecounts,sql from sys.syscacheobjects
where sql not like '%cache%' and sql not like '%sys.%' and sql not like '%BatchID%'

--再次执行查询，并再查看缓存的执行计划，usecounts字段下的值增加
--说明ad-hoc语法的计划缓存被重用

--=============自动参数化缓存（Auto-parameterized queries)============--
--自动参数化缓存是针对sql语法中有where条件子句，搭配常数值来限制符合的纪录
--SQL Server在产生执行计划时，将常数部分以变量取代，这样在后续的查询中，如
--果只是常数部分不同，将会使用先前经过参数化的执行计划
select * from northwind.dbo.customers
where customerid='alfki'
go
select * from northwind.dbo.customers
where customerid='anatr'
go




--查看缓存的执行计划
select cacheobjtype,objtype,usecounts,sql from syscacheobjects
where sql not like '%cache%' and sql not like '%sys.%' and sql not like '%BatchID%'

--=============使用sp_executesql准备的查询============--
--使用dbcc命令清空内存中的已经存在的计划缓存(Plan Cache)。
dbcc freeproccache

--这种方式查询时，只对查询语法的本体建立执行计划，与参数内容无关
exec sp_executesql N'select * from northwind.dbo.customers
where customerid=@custid',N'@CustID nvarchar(5)','alfki'
go
exec sp_executesql N'select * from northwind.dbo.customers
where customerid=@custid',N'@CustID nvarchar(5)','anatr'

--=======================================存储过程========================================--
--调用存储过程可以提升执行计划的重用性，借以减少SQL Server找寻执行计划造成CPU的性能消耗
Create Proc spGetCustomers @CustID nvarchar(5)
as
select * from northwind.dbo.customers
where customerid=@custid
go

exec spGetCustomers 'alfki'
exec spGetCustomers 'anatr'

--查看缓存的执行计划
select cacheobjtype,objtype,usecounts,sql from syscacheobjects
where sql not like '%cache%' and sql not like '%sys.%' and sql not like '%BatchID%'


--如果数据分布均匀，则以不同的参数调用相同的存储过程，SQL Server直接取出旧有的执行计划
--如果数据分布不均匀，则不同的参数并不一定都会使用相同的执行计划

USE TempDB
--要比较执行后的计划，看 SQL Server 真实用什么执行计划，
--事前比统计信息时，执行计划会都相同

SET NOCOUNT ON
Create Table T1
( 
IDKey int Identity(1,1) Primary key,
Key1 Int NOT NULL, 
Key2 Int NOT NULL, 
Key3 varchar(15) 
) 
GO 

-- 插入测试资料，故意让数据有点数量，但分布极不平均 
Declare @Key1 int, @Key2 Int 
Set @Key1 =1 
While @Key1<100
	BEGIN 
	Set @Key2 =1 
	While @Key2<=20 
	BEGIN 
		Insert t1 ( Key1, key2, Key3) 
		Values(@Key1, @key2, 'Data '+Convert(varchar, @Key1) +', '+Convert(varchar, @Key2) ) 
		Set @Key2 =@Key2+1 
	END 
	Set @key1= @Key1+1 
END 
select * from t1
--插入远在一般数据范围之外的少数记录
INSERT t1 VALUES(10000,10000,'10000,10000')

-- 建立符合查询的索引
Create Index idxKey1 On t1(Key1)

--创建存储过程
CREATE PROC sp @int INT =0
AS
SELECT * FROM t1 WHERE Key1=@int
GO

--调用存储过程，包括实际的执行计划
--聚集索引扫描比较有效
EXEC sp 1

--SQL Server 会沿用先前产生的计划
--但是非聚集索引扫描其实比较有效，怎么办？
EXEC sp 10000

--使用 WITH RECOMPILE 重新查找与编译
--将采取正确有效的执行计划
EXEC sp 10000 WITH RECOMPILE


--要求查询最佳化工具在查询进行编译和最佳化时,针对特定的参数值作最佳化
ALTER PROC sp @int INT=0
AS
SELECT * FROM t1 WHERE Key1=@int
	OPTION ( OPTIMIZE FOR (@int = 10000) )
go

EXEC sp 10000

--问题：如果可能经常查询多笔符合过滤条件的记录，也可能经常查询符合过滤条件比较少的记录，怎么办？
--答：让SQL Server不要缓存执行计划，每次执行时，都重新评估最佳的执行计划。

--修改存储过程
ALTER PROC sp @int INT=0
WITH RECOMPILE
AS
SELECT * FROM t1 WHERE Key1=@int
GO

--执行存储过程
EXEC sp 1
GO

EXEC sp 10000









