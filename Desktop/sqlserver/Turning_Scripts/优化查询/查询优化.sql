
--prepare sampel data
use AdventureWorks
go
drop table dbo.SalesOrdrHeader_test
go
drop table dbo.SalesOrderdetail_test
go
select * into dbo.SalesOrdrHeader_test from Sales.salesOrderHeader
select * into dbo.SalesOrderdetail_test from Sales.SalesOrderDetail
go
create clustered index salesorderheader_test_cl on SalesOrdrHeader_test(SalesOrderID)
create nonclustered index salesorderdetail_test_ncl on dbo.SalesOrderdetail_test(SalesOrderID)
go

declare @i int
set @i=1
while @i<=9
begin
insert into dbo.SalesOrdrHeader_test(RevisionNumber,OrderDate,DueDate,ShipDate,Status,OnlineOrderFlag,SalesOrderNumber,PurchaseOrderNumber,AccountNumber,
CustomerID,ContactID,SalesPersonID,TerritoryID,BillToAddressID,ShipToAddressID,ShipMethodID,CreditCardID,CreditCardApprovalCode,CurrencyRateID,SubTotal,TaxAmt,
Freight,TotalDue,Comment,rowguid,ModifiedDate)
select RevisionNumber,OrderDate,DueDate,ShipDate,Status,OnlineOrderFlag,SalesOrderNumber,PurchaseOrderNumber,AccountNumber,
CustomerID,ContactID,SalesPersonID,TerritoryID,BillToAddressID,ShipToAddressID,ShipMethodID,CreditCardID,CreditCardApprovalCode,CurrencyRateID,SubTotal,TaxAmt,
Freight,TotalDue,Comment,rowguid,ModifiedDate
from dbo.SalesOrdrHeader_test
where SalesOrderID=75123
insert into dbo.SalesOrderdetail_test
(SalesOrderID,CarrierTrackingNumber,OrderQty,ProductID,SpecialOfferID,UnitPrice,UnitPriceDiscount,LineTotal,rowguid,ModifiedDate)
select 75123+@i,CarrierTrackingNumber,OrderQty,ProductID,SpecialOfferID,UnitPrice,UnitPriceDiscount,LineTotal,rowguid,getdate()
from sales.SalesOrderDetail
set @i=@i+1
end
go

--Knowledge:index & statistics

-----index
set showplan_all on
set showplan_all off
select salesorderdetailid,unitprice from dbo.SalesOrderdetail_test where UnitPrice>200 --table scan
create clustered index salesorderdetail_test_cl on dbo.salesorderdetail_test(salesorderdetailid) --clustered index scan
select salesorderdetailid,unitprice from dbo.SalesOrderdetail_test where UnitPrice>200
create nonclustered index salesorderdetail_test_ncl_price on dbo.salesorderdetail_test(unitprice)
select salesorderdetailid,unitprice from dbo.SalesOrderdetail_test where UnitPrice>200

select salesorderid,salesorderdetailid,unitprice from dbo.SalesOrderdetail_test with(index(salesorderdetail_test_ncl_price ))
where UnitPrice>200

----statistics 
--SQL Server need know data volume to determine complex,chose exection plan by cost
update statistics dbo.SalesOrdrHeader_test(salesorderheader_test_cl)
dbcc show_statistics(SalesOrdrHeader_test,salesorderheader_test_cl)
dbcc show_statistics(SalesOrderdetail_test,salesorderdetail_test_ncl)

select b.SalesOrderID,b.OrderDate,a.*
from dbo.SalesOrderdetail_test as a 
inner join dbo.SalesOrdrHeader_test as b
on a.SalesOrderID=b.SalesOrderID
where b.SalesOrderID=72642

select b.SalesOrderID,b.OrderDate,a.*
from dbo.SalesOrderdetail_test as a 
inner join dbo.SalesOrdrHeader_test as b
on a.SalesOrderID=b.SalesOrderID
where b.SalesOrderID=75127

--matainance statistics
exec sp_helpstats SalesOrdrHeader_test
go

select count(*) from dbo.SalesOrdrHeader_test
where OrderDate='2004-06-11 00:00:00.000'

exec sp_helpstats SalesOrdrHeader_test
go

--table <500£¬accumulative change total>500
--table >500,accumulative change toal>(500 + 20% of table data)
--temp table have statistics, table variable cann't


----compile & recompile
--compile fist,then execute
--compile:esimate exection plan and their cost
select usecounts,cacheobjtype,objtype,text
from sys.dm_exec_cached_plans
cross apply sys.dm_exec_sql_text(plan_handle)
order by usecounts desc

--plan reuse
----adhoc
----exec()
----auto-parameterized query
----sp_executesql
----store procedure

--plan recompile
----sp_recompile
----exec....with recompile
----shema change
----set option change
----statistics change

----understanding execution plan
set showplan_all on
set showplan_xml on
set statistics profile on

set showplan_all on
go
select a.SalesOrderID,a.OrderDate,a.CustomerID,b.SalesOrderDetailID,b.ProductID,b.OrderQty,b.UnitPrice
from dbo.SalesOrdrHeader_test a
inner join dbo.SalesOrderdetail_test b
on a.SalesOrderID=b.SalesOrderID
where a.SalesOrderID=43659
go
set showplan_all off
go
set statistics profile on
go
select a.SalesOrderID,a.OrderDate,a.CustomerID,b.SalesOrderDetailID,b.ProductID,b.OrderQty,b.UnitPrice
from dbo.SalesOrdrHeader_test a
inner join dbo.SalesOrderdetail_test b
on a.SalesOrderID=b.SalesOrderID
where a.SalesOrderID=43659
go

set statistics profile off
go

--join
set statistics io on
go
select count(b.salesorderid)
from dbo.SalesOrdrHeader_test a
inner loop join dbo.SalesOrderdetail_test b
on a.SalesOrderID=b.SalesOrderID
where a.SalesOrderID>43659 and a.SalesOrderID<53660
go
select count(b.salesorderid)
from dbo.SalesOrdrHeader_test a
inner merge join dbo.SalesOrderdetail_test b
on a.SalesOrderID=b.SalesOrderID
where a.SalesOrderID>43659 and a.SalesOrderID<53660
go
select count(b.salesorderid)
from dbo.SalesOrdrHeader_test a
inner hash join dbo.SalesOrderdetail_test b
on a.SalesOrderID=b.SalesOrderID
where a.SalesOrderID>43659 and a.SalesOrderID<53660
go

--nested looop join,doesn't need addtional data structure(memory),doesn't use tempdb
----outer table should sort first to improve select performance
----outer table should not too large
----inner table should has a index on lookup column

--many-to-many merge join need addtional memory and tempdb space
----only equal join ,if data set will have repeated data,merge join will use many-to-many join,
drop index SalesOrdrHeader_test.salesorderheader_test_cl
create unique clustered index salesorderheader_test_cl on SalesOrdrHeader_test(SalesOrderID)

--hash join need addtional memory or tempdb to store hash table,and need cpu when build hash table or join table(probe)

drop index SalesOrdrHeader_test.salesorderheader_test_cl
create clustered index salesorderheader_test_cl on SalesOrdrHeader_test(SalesOrderID)

select count(b.salesorderid)
from dbo.SalesOrdrHeader_test a
inner  join dbo.SalesOrderdetail_test b
on a.SalesOrderID=b.SalesOrderID
where a.SalesOrderID>43659 and a.SalesOrderID<53660
go

--aggration
select max(SalesOrderDetailID)
from dbo.SalesOrderdetail_test
go
select salesorderid,count(salesorderdetailid)
from dbo.SalesOrderdetail_test
group by salesorderid
go

select customerid,count(*)
from dbo.SalesOrdrHeader_test
group by customerid
go

--union all & union
select distinct productid,unitprice from dbo.SalesOrderdetail_test where productid=776
union all
select distinct productid,unitprice from dbo.SalesOrderdetail_test where productid=776
go

select distinct productid,unitprice from dbo.SalesOrderdetail_test where productid=776
union
select distinct productid,unitprice from dbo.SalesOrderdetail_test where productid=776
go

--parallelism
select distinct productid,unitprice from dbo.SalesOrderdetail_test
where productid=776
go


----statement stattistcs information
set statistics profile off
set statistics time on
dbcc dropcleanbuffers
go
select distinct productid,unitprice from dbo.SalesOrderdetail_test where ProductID=777
union
select distinct productid,unitprice from dbo.SalesOrderdetail_test where ProductID=777
go
set statistics time off
go


set statistics time on
go
select distinct productid,unitprice from dbo.SalesOrderdetail_test where ProductID=777
union
select distinct productid,unitprice from dbo.SalesOrderdetail_test where ProductID=777
go
set statistics time off
go

set statistics io on
go
dbcc dropcleanbuffers
go
select distinct productid,unitprice from dbo.SalesOrderdetail_test where ProductID=777
go

select distinct productid,unitprice from dbo.SalesOrderdetail_test where ProductID=777
go

set statistics io off
go


set statistics profile on
go
select distinct productid,unitprice from dbo.SalesOrderdetail_test
where ProductID=777
go

--so we need create nonclustered index on productid to reduce the cost

select count(b.salesorderid)
from dbo.SalesOrderdetail_test a inner join dbo.SalesOrdrHeader_test b
on a.SalesOrderID=b.SalesOrderID
where a.SalesOrderID>43659 and a.SalesOrderID<53660

--------------------------------------Query Turning-------------------------------------------
----1.Determine physical IO ( memory bottleneck)
set statistics io on

----2.Determine compile time
drop proc longcompile
go
create proc longcompile(@i int) as
declare @cmd varchar(max)
declare @j int
set @j=0
select @cmd='
select count(b.salesorderid),sum(p.weight)
from dbo.salesordrheader_test a
inner join dbo.salesorderdetail_test b
on a.salesorderid=b.salesorderid
inner join production.product p
on b.productid=p.productid
where a.salesorderid in (43659'
while @j<@i
begin 
set @cmd=@cmd+ ',' + str(@j+43659)
set @j=@j+1
end
set @cmd=@cmd+ ')'
exec (@cmd)
go

set statistics time on
set statistics profile off
exec longcompile 1000

----3.Esimate every step's cost correctly(esitimatedrows)
set statistics profile on
dbcc freeproccache
go
set rowcount 0
select p.productid,p.weight
from dbo.salesordrheader_test a
inner join dbo.salesorderdetail_test b
on a.salesorderid=b.salesorderid
inner join production.product p
on b.productid=p.productid --large result set
where a.SalesOrderID=75124
go
dbcc freeproccache
go
set rowcount 1
go
select p.productid,p.weight
from dbo.salesordrheader_test a
inner join dbo.salesorderdetail_test b
on a.salesorderid=b.salesorderid
inner join production.product p
on b.productid=p.productid
where a.SalesOrderID=75124
go
set rowcount 0
go
select p.productid,p.weight
from dbo.salesordrheader_test a
inner join dbo.salesorderdetail_test b
on a.salesorderid=b.salesorderid
inner join production.product p
on b.productid=p.productid
where a.SalesOrderID=75124
go

--index seek & table scan & index scan
select count(b.CarrierTrackingNumber)
from dbo.SalesOrderdetail_test b
where b.SalesOrderDetailID>10000 and b.SalesOrderDetailID<=10100
go
select count(b.CarrierTrackingNumber)
from dbo.SalesOrderdetail_test b
where convert(numeric(9,3),b.SalesOrderDetailID/100)=100
go

drop proc scan_seek
go
create proc scan_seek (@i int) as
select count(b.CarrierTrackingNumber)
from dbo.SalesOrderdetail_test b
where b.SalesOrderID>@i and b.SalesOrderID<@i+7
go

exec sp_recompile scan_seek
go
exec scan_seek 75124
go
exec sp_recompile scan_seek
go
exec scan_seek 43659
go
exec scan_seek 75124
go

--nested loop or hash(merge) join
drop proc sniff
go
create proc sniff(@i int)
as
select count(b.SalesOrderID),sum(p.weight)
from dbo.salesordrheader_test a
inner join dbo.salesorderdetail_test b
on a.salesorderid=b.salesorderid
inner join production.product p
on b.productid=p.productid
where a.SalesOrderID=@i
go

dbcc freeproccache
go
exec sniff 50000
go
exec sniff 75124
go

--filter location
--cost correct
--SARG
select count(b.productid)
from dbo.salesordrheader_test a
inner join dbo.salesorderdetail_test b
on a.salesorderid=b.salesorderid
inner join production.product p
on b.productid=p.productid
where p.ProductID between 758 and 800

select count(b.productid)
from dbo.salesordrheader_test a
inner join dbo.salesorderdetail_test b
on a.salesorderid=b.salesorderid
inner join production.product p
on b.productid=p.productid
where (p.ProductID/2) between 380 and 400

--parameter sniffing

----4.adjest index ,check table stuncture and statement logic
----adjust index
--clustered index
--nonclustered index
--covering index
--index with included columns
--indexed view
--primary key

--find missing index( profile: performance-show xml statistics profile)
select distinct productid,unitprice from dbo.SalesOrderdetail_test where productid=777
go

--adjust statement
select name from Production.product where name like 'Deca%'
go
select name from Production.product where name like '%Deca%'
go
select name from Production.Product where name not like 'Dece%'
go
select name from Production.Product where left(name,4) like 'Dece%'
go
select name from Production.Product where name+'_end'='Decal 1_end'
go
select name from Production.Product where upper(name)='Decal 1'

alter table production.product
add uppername as upper(name)
go
create nonclustered index ak_product_Uname on production.product(uppername)

select uppername from Production.Product where uppername='Decal 1'

alter table humanresources.employee
add age1 as datediff(yy,getdate(),birthdate)
go
create nonclustered index ad_employee_age on humanresources.employee(age1)

select * from HumanResources.Employee where datediff(yy,getdate(),birthdate)>30
select * from HumanResources.Employee where BirthDate<dateadd(yy,-30,getdate())


