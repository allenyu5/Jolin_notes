use AdventureWorks
go

--Ƕ��ѭ��
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

--�ϲ�����
select sod.salesorderid,p.name
from production.product as p
inner join sales.salesorderdetail as sod
on p.productid=sod.productid

select sod.salesorderid,p.name,p.listprice,sod.orderqty
from production.product as p
inner join sales.salesorderdetail as sod
on p.listprice=sod.unitprice
order by p.listprice

--��ϣ����
--����CPU���ڴ�
select p.productid,sod.salesorderdetailid,sod.linetotal
from production.product as p
inner join sales.salesorderdetail as sod
on p.productid=sod.productid

--�����ۺ�
select avg(EmailPromotion)
from person.Contact

--���ۺ�
select sum(ReorderPoint)
from Production.Product
group by ProductLine

--��ϣƥ��ۺ�
select count(*)
from sales.SalesOrderHeader
group by ContactID,CustomerID