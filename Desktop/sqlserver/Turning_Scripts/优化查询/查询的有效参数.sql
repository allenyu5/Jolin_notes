
set statistics io on

--��������
create index idx_ModifiedDate 
on adventureworks.sales.SalesOrderDetail(ModifiedDate)
include(ProductID)
--drop index sales.SalesOrderDetail.idx_ModifiedDate 

--SARG
--logical reads 175
select ProductID,ModifiedDate
from adventureworks.sales.SalesOrderDetail
where ModifiedDate between '2003-01-01' and '2004-01-01'

--logical reads 395
select ProductID,ModifiedDate
from adventureworks.sales.SalesOrderDetail
where Year(ModifiedDate)=2003

declare @StartDate Date,@EndDate Date
set @StartDate='2003-01-01'
set @EndDate='2004-01-01'
select ProductID,ModifiedDate
from adventureworks.sales.SalesOrderDetail
where ModifiedDate between @StartDate and @EndDate

--���ʽ����
create index idx_FirstName on [Person].[Contact](FirstName)
go
--drop index [Person].[Contact].idx_FirstName

--SARG
select Title from Person.Contact
where LastName='Achong' and Firstname='Gustavo'

select Title from Person.Contact
where LastName+','+Firstname='Achong,Gustavo'

--ʹ�ø����ѯnot��!=��<>��!>��!<��not exists��not in��not like
create index idx_SpecialOfferID 
on sales.salesorderdetail(SpecialOfferID)
include(SalesOrderID)
--drop index sales.salesorderdetail.idx_SpecialOfferID

select SalesOrderID from sales.SalesOrderDetail
where SpecialOfferID!=2

select SalesOrderID from sales.SalesOrderDetail
where SpecialOfferID>2 or SpecialOfferID<2

--ʹ��OR
select * into  Sales.OrderDetails from sales.salesorderdetail
create index idx_SalesOrderID on sales.OrderDetails(SalesOrderID )
create index idx_SalesOrderDetailID on sales.OrderDetails(SalesOrderDetailID )

select ProductID,OrderQty from Sales.OrderDetails
where SalesOrderID=43659 and SalesOrderDetailID=3

select ProductID,OrderQty from Sales.OrderDetails
where SalesOrderID=43659 or SalesOrderDetailID=3

--ʹ��IN(���鲻Ҫ��,ֻ�ڹ̶�ֵ��ʱ��ʹ��),���ʹ��EXISTS�����
select name from Production.product
where ProductID in 
(select productid from sales.SalesOrderDetail where 
SalesOrderID>43659)

select name from Production.product as p
where exists (select * from sales.SalesOrderDetail as sod
where p.ProductID=sod.ProductID and SalesOrderID>43659)

--����ʹ�ò�����BETWEEN
select ProductID,ModifiedDate
from adventureworks.sales.SalesOrderDetail
where ModifiedDate in( '2003-01-01' , '2003-01-02' , '2003-01-03' , '2003-01-04' )

select ProductID,ModifiedDate
from adventureworks.sales.SalesOrderDetail
where ModifiedDate  between '2003-01-01' and  '2003-01-04' 

--����ʹ��ANY��ALL
select FirstName,MiddleName,LastName
from person.Contact 
where ContactID in (select EmployeeID
from HumanResources.Employee
where SickLeaveHours>68)

select FirstName,MiddleName,LastName
from person.Contact 
where ContactID=ANY(select EmployeeID
from HumanResources.Employee
where SickLeaveHours>68)

--ʹ�÷Ǵ�ͷ��ĸ����
Create index idx_FirstName on person.Contact(FirstName)

select FirstName,MiddleName,LastName
from person.Contact 
where FirstName like 'Kim%'

select FirstName,MiddleName,LastName
from person.Contact 
where FirstName like '%Kim%'
