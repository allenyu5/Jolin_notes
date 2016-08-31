use AdventureWorks
go

--嵌套循环
select sod.salesorderid,p.name
from production.Product as p
inner join sales.SalesOrderDetail as sod
on p.ProductID=sod.ProductID
where p.ProductID=870

select sod.salesorderid,p.name,sod.unitprice
from production.Product as p
inner join sales.SalesOrderDetail as sod
on p.ProductID=sod.ProductID
where p.ProductID=870

--合并连接
select sod.salesorderid,p.name
from production.product as p
inner join sales.salesorderdetail as sod
on p.productid=sod.productid

select sod.salesorderid,p.name,p.listprice,sod.orderqty
from production.product as p
inner join sales.salesorderdetail as sod
on p.listprice=sod.unitprice
order by p.listprice

--哈希连接
--消耗CPU，内存
select p.productid,sod.salesorderdetailid,sod.linetotal
from production.product as p
inner join sales.salesorderdetail as sod
on p.productid=sod.productid

--标量聚合
select avg(EmailPromotion)
from person.Contact

--流聚合
select sum(ReorderPoint)
from Production.Product
group by ProductLine

--哈希匹配聚合
select count(*)
from sales.SalesOrderHeader
group by ContactID,CustomerID