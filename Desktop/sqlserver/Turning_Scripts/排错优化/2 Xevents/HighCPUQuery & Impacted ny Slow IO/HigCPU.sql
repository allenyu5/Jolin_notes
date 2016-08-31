use AdventureWorks2012 
go 
select count_big(*) from [Production].[ProductInventory] a 
cross join [Production].[ProductInventory] b 
cross join [Production].[ProductInventory] c 
cross join [Production].[ProductInventory] d 
where a.Quantity > 200

go 

select count_big(*) from [Production].[ProductInventory] a 
cross join [Production].[ProductInventory] b 
cross join [Production].[ProductInventory] c 
cross join [Production].[ProductInventory] d 
where a.Quantity > 250 

go 
select count_big(*) from [Production].[ProductInventory] a 
cross join [Production].[ProductInventory] b 
cross join [Production].[ProductInventory] c 
cross join [Production].[ProductInventory] d 
where a.Quantity > 300 
