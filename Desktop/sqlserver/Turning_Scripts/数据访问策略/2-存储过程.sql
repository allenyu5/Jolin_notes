--�����洢����
--Product:�����۳��Ļ����۳���Ʒ������������ʹ�õĲ�Ʒ
--DaysToManufacture:������Ʒ���������
use adventureworks
go

CREATE PROC Production.LongLeadProducts
AS
SELECT Name, ProductNumber
FROM Production.Product
WHERE DaysToManufacture >= 1
GO

-���Դ洢����
EXEC Production.LongLeadProducts

--�޸Ĵ洢����
ALTER PROC Production.LongLeadProducts
AS
SELECT Name, ProductNumber, DaysToManufacture
FROM Production.Product
WHERE DaysToManufacture >= 1
ORDER BY DaysToManufacture DESC, Name
GO

--���������
EXEC sp_depends @objname = N'Production.LongLeadProducts'

--ɾ���洢����
DROP PROC Production.LongLeadProducts


--ʹ�ô�����������Ĵ洢����
CREATE PROC Production.LongLeadProducts
@MinimumLength int = 1 -- Ĭ��ֵ
AS

IF (@MinimumLength < 0) -- ��֤
BEGIN
RAISERROR('Invalid lead time.', 14, 1)
RETURN
END

SELECT Name, ProductNumber, DaysToManufacture
FROM Production.Product
WHERE DaysToManufacture >= @MinimumLength
ORDER BY DaysToManufacture DESC, Name

--���Դ洢����
EXEC Production.LongLeadProducts @MinimumLength=4
EXEC Production.LongLeadProducts 4
EXEC Production.LongLeadProducts
EXEC Production.LongLeadProducts -2

--ʹ�ô�����������Ĵ洢����
--����ڹ��̶�����Ϊ����ָ�� OUTPUT �ؼ��֣���洢�������˳�ʱ�ɽ��ò����ĵ�ǰֵ���������ó���
--��Ҫ�ñ����������ֵ�Ա��ڵ��ó�����ʹ�ã�����ó��������ִ�д洢����ʱʹ�� OUTPUT �ؼ���
--���ز��뵽ͬһ�������еı�ʶ���ڵ����һ����ʶֵ
--Department������ Adventure Works Cycles ��˾�еĲ���
--GroupName������������������

CREATE PROC HumanResources.AddDepartment
@Name nvarchar(50), @GroupName nvarchar(50),
@DeptID smallint OUTPUT
AS

INSERT INTO HumanResources.Department (Name, GroupName)
VALUES (@Name, @GroupName)

SET @DeptID = SCOPE_IDENTITY() --���ز��뵽ͬһ�������еı�ʶ���ڵ����һ����ʶֵ��

--���Դ洢����
DECLARE @dept int
EXEC HumanResources.AddDepartment 'Refunds', '', @dept OUTPUT
SELECT @dept

select * from HumanResources.Department
select @@rowcount

--�ڴ�����������Ĵ洢������ʹ�÷���ֵ��Ĭ��Ϊ0
ALTER PROC HumanResources.AddDepartment
@Name nvarchar(50), @GroupName nvarchar(50),
@DeptID smallint OUTPUT
AS
IF ((@Name = '') OR (@GroupName = ''))
RETURN -1

INSERT INTO HumanResources.Department (Name, GroupName)
VALUES (@Name, @GroupName)

SET @DeptID = SCOPE_IDENTITY()
RETURN 0

--���Դ洢����
DECLARE @dept int, @result int
EXEC @result = HumanResources.AddDepartment 'Refunds', '', @dept OUTPUT
IF (@result = 0)
	SELECT @dept
ELSE
	SELECT N'����ʱ��������'