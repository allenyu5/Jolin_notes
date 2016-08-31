--������ͼ
--Employee:������Ա��Ϣ���������/������ʶ�š�ְλ�Լ��ݼٺͲ���Сʱ������
--Contact:����ÿ���ͻ�����Ա��Ӧ�̵������������Ϣ��
--EmployeeAddress:�� Employee ���еĹ�Աӳ�䵽 Address �������ǵĵ�ַ��
--Address:�������� Adventure Works Cycles �ͻ�����Ӧ�̺͹�Ա�ĵ�ַ��Ϣ��
--StateProvince:��һ���������ڱ�ʶ����/�����е��ݡ�ʡ���С��������Ĺ��ʱ�׼����Ĳ��ұ�
--CountryRegion:����������������ʶ���Һ͵����ı�׼���롣
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

--��ѯ��ͼ
select * from [HumanResources].[EmployeeView]

--�޸���ͼ
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

--��ѯ��ͼ
select * from [HumanResources].[EmployeeView]

--�鿴��ͼ��Ϣ
USE AdventureWorks
GO
SELECT * FROM sys.views

EXEC sp_helptext 'HumanResources.EmployeeView'


--���������
EXEC sp_depends @objname = 'HumanResources.EmployeeView'

SELECT DISTINCT OBJECT_NAME([object_id]) AS Name
FROM sys.sql_dependencies
WHERE referenced_major_id =
OBJECT_ID(N'AdventureWorks.HumanResources.Employee')

--������ͼ
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

--ɾ����ͼ
DROP VIEW [HumanResources].[EmployeeView]

--======================================--
--���with check option
select * into authorsbackup from authors

--������ͼ
use pubs
go

CREATE VIEW authors_CA1 AS
    ( 
        SELECT * FROM Authorsbackup WHERE state='CA'
    )

select * from authors_CA1

--��������
--���еļ�¼����ͼ��ʧ����ν����
UPDATE authors_CA1 SET state='NJ'
select * from authors_CA1

--ʹ��with check option
CREATE VIEW authors_CA2 AS
    ( 
        SELECT * FROM Authors WHERE state='CA'
    )
    WITH CHECK OPTION

--�������ݣ�ʧ�ܣ�
UPDATE authors_CA2 SET state='NJ'
select * from authors_CA2


drop view authors_CA1
drop view authors_CA2