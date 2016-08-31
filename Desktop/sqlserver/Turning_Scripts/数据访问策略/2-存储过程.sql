--创建存储过程
--Product:包含售出的或在售出产品的生产过程中使用的产品
--DaysToManufacture:生产产品所需的天数
use adventureworks
go

CREATE PROC Production.LongLeadProducts
AS
SELECT Name, ProductNumber
FROM Production.Product
WHERE DaysToManufacture >= 1
GO

-测试存储过程
EXEC Production.LongLeadProducts

--修改存储过程
ALTER PROC Production.LongLeadProducts
AS
SELECT Name, ProductNumber, DaysToManufacture
FROM Production.Product
WHERE DaysToManufacture >= 1
ORDER BY DaysToManufacture DESC, Name
GO

--检查依从性
EXEC sp_depends @objname = N'Production.LongLeadProducts'

--删除存储过程
DROP PROC Production.LongLeadProducts


--使用带有输入参数的存储过程
CREATE PROC Production.LongLeadProducts
@MinimumLength int = 1 -- 默认值
AS

IF (@MinimumLength < 0) -- 验证
BEGIN
RAISERROR('Invalid lead time.', 14, 1)
RETURN
END

SELECT Name, ProductNumber, DaysToManufacture
FROM Production.Product
WHERE DaysToManufacture >= @MinimumLength
ORDER BY DaysToManufacture DESC, Name

--测试存储过程
EXEC Production.LongLeadProducts @MinimumLength=4
EXEC Production.LongLeadProducts 4
EXEC Production.LongLeadProducts
EXEC Production.LongLeadProducts -2

--使用带有输出参数的存储过程
--如果在过程定义中为参数指定 OUTPUT 关键字，则存储过程在退出时可将该参数的当前值返回至调用程序。
--若要用变量保存参数值以便在调用程序中使用，则调用程序必须在执行存储过程时使用 OUTPUT 关键字
--返回插入到同一作用域中的标识列内的最后一个标识值
--Department：包含 Adventure Works Cycles 公司中的部门
--GroupName：部门所属的组名称

CREATE PROC HumanResources.AddDepartment
@Name nvarchar(50), @GroupName nvarchar(50),
@DeptID smallint OUTPUT
AS

INSERT INTO HumanResources.Department (Name, GroupName)
VALUES (@Name, @GroupName)

SET @DeptID = SCOPE_IDENTITY() --返回插入到同一作用域中的标识列内的最后一个标识值。

--测试存储过程
DECLARE @dept int
EXEC HumanResources.AddDepartment 'Refunds', '', @dept OUTPUT
SELECT @dept

select * from HumanResources.Department
select @@rowcount

--在带有输出参数的存储过程中使用返回值，默认为0
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

--测试存储过程
DECLARE @dept int, @result int
EXEC @result = HumanResources.AddDepartment 'Refunds', '', @dept OUTPUT
IF (@result = 0)
	SELECT @dept
ELSE
	SELECT N'插入时发生错误'