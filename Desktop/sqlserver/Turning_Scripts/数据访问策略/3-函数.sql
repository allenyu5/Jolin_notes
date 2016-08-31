--创建标量函数,返回特定产品的总销量,返回值为整数型
--SalesOrderDetail表:包含与特定销售订单关联的各个产品
use adventureworks
go

CREATE FUNCTION Sales.SumSold(@ProductID int) RETURNS int
AS
BEGIN
DECLARE @ret int
SELECT @ret = SUM(OrderQty)
FROM Sales.SalesOrderDetail WHERE ProductID = @ProductID
IF (@ret IS NULL)
	SET @ret = 0
RETURN @ret
END

--调用标量函数
SELECT ProductID,Name,Sales.SumSold(ProductID) AS SumSold
FROM Production.Product

--创建嵌入式表值函数,返回属于特定经理的雇员的姓名
--使用该函数可以实现带参数的视图功能
--视图本身是不能使用输入参数的
--Employee表:包含雇员信息（例如国家/地区标识号、职位以及休假和病假小时数）。雇员姓名储存在 Contact 表中。
CREATE FUNCTION HumanResources.EmployeesForManager
(@ManagerId int)
RETURNS TABLE
AS
RETURN (
	SELECT FirstName, LastName
	FROM HumanResources.Employee Employee INNER JOIN
	Person.Contact Contact
	ON Employee.ContactID = Contact.ContactID
	WHERE ManagerID = @ManagerId )

--调用该嵌入式表值函数
SELECT * FROM HumanResources.EmployeesForManager(3)
-- 或
SELECT * FROM HumanResources.EmployeesForManager(6)


--创建多语句表值函数
--类似于视图和存储过程的整合
CREATE FUNCTION HumanResources.EmployeeNames
(@format nvarchar(9))
RETURNS @tbl_Employees TABLE
(EmployeeID int PRIMARY KEY, [Employee Name] nvarchar(100))
AS
BEGIN
 IF (@format = 'SHORTNAME')
	INSERT @tbl_Employees
	SELECT EmployeeID, LastName
	FROM HumanResources.vEmployee
 ELSE IF (@format = 'LONGNAME')
	INSERT @tbl_Employees
	SELECT EmployeeID, (FirstName + ' ' + LastName)
 	FROM HumanResources.vEmployee
 RETURN
END

--调用多语句表值函数
SELECT * FROM HumanResources.EmployeeNames('LONGNAME')
-- 或
SELECT * FROM HumanResources.EmployeeNames('SHORTNAME')