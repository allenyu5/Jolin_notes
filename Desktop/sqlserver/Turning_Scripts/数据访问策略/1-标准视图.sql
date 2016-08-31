--创建视图
--Employee:包含雇员信息（例如国家/地区标识号、职位以及休假和病假小时数）。
--Contact:包含每个客户、雇员或供应商的姓名和相关信息。
--EmployeeAddress:将 Employee 表中的雇员映射到 Address 表中他们的地址。
--Address:包含所有 Adventure Works Cycles 客户、供应商和雇员的地址信息。
--StateProvince:是一个包含用于标识国家/地区中的州、省、市、自治区的国际标准代码的查找表。
--CountryRegion:包含国际上用来标识国家和地区的标准代码。
use adventureworks
go

CREATE VIEW [HumanResources].[EmployeeView]
AS
SELECT
e.[EmployeeID],c.[Title],c.[FirstName],c.[MiddleName],c.[LastName]
,c.[Suffix],e.[Title] AS [JobTitle],c.[Phone],c.[EmailAddress]
,c.[EmailPromotion],a.[AddressLine1],a.[AddressLine2],a.[City]
,sp.[Name] AS [StateProvinceName],a.[PostalCode]
,cr.[Name] AS [CountryRegionName],c.[AdditionalContactInfo]
FROM [HumanResources].[Employee] e
INNER JOIN [Person].[Contact] c
ON c.[ContactID] = e.[ContactID]
INNER JOIN [HumanResources].[EmployeeAddress] ea
ON e.[EmployeeID] = ea.[EmployeeID]
INNER JOIN [Person].[Address] a
ON ea.[AddressID] = a.[AddressID]
INNER JOIN [Person].[StateProvince] sp
ON sp.[StateProvinceID] = a.[StateProvinceID]
INNER JOIN [Person].[CountryRegion] cr
ON cr.[CountryRegionCode] = sp.[CountryRegionCode]

--查询视图
select * from [HumanResources].[EmployeeView]

--修改视图
ALTER VIEW [HumanResources].[EmployeeView]
AS
SELECT
e.[EmployeeID]
,c.[Title]
,c.[FirstName]
,c.[MiddleName]
,c.[LastName]
,c.[Suffix]
,e.[Title] AS [JobTitle]
,c.[Phone]
,c.[EmailAddress]
FROM [HumanResources].[Employee] e
INNER JOIN [Person].[Contact] c
ON c.[ContactID] = e.[ContactID]

--查询视图
select * from [HumanResources].[EmployeeView]

--查看视图信息
USE AdventureWorks
GO
SELECT * FROM sys.views

EXEC sp_helptext 'HumanResources.EmployeeView'


--检查依从性
EXEC sp_depends @objname = 'HumanResources.EmployeeView'

SELECT DISTINCT OBJECT_NAME([object_id]) AS Name
FROM sys.sql_dependencies
WHERE referenced_major_id =
OBJECT_ID(N'AdventureWorks.HumanResources.Employee')

--加密视图
ALTER VIEW [HumanResources].[EmployeeView]
WITH ENCRYPTION
AS
SELECT
e.[EmployeeID],c.[Title],c.[FirstName],c.[MiddleName]
,c.[LastName],c.[Suffix],e.[Title] AS [JobTitle]
,c.[Phone],c.[EmailAddress]
FROM [HumanResources].[Employee] e
INNER JOIN [Person].[Contact] c
ON c.[ContactID] = e.[ContactID]

EXEC sp_helptext 'HumanResources.EmployeeView'

--删除视图
DROP VIEW [HumanResources].[EmployeeView]

--======================================--
--理解with check option
select * into authorsbackup from authors

--创建视图
use pubs
go

CREATE VIEW authors_CA1 AS
    ( 
        SELECT * FROM Authorsbackup WHERE state='CA'
    )

select * from authors_CA1

--更新数据
--所有的记录从视图消失，如何解决？
UPDATE authors_CA1 SET state='NJ'
select * from authors_CA1

--使用with check option
CREATE VIEW authors_CA2 AS
    ( 
        SELECT * FROM Authors WHERE state='CA'
    )
    WITH CHECK OPTION

--更新数据（失败）
UPDATE authors_CA2 SET state='NJ'
select * from authors_CA2


drop view authors_CA1
drop view authors_CA2