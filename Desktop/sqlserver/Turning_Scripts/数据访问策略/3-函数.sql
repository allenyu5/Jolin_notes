--������������,�����ض���Ʒ��������,����ֵΪ������
--SalesOrderDetail��:�������ض����۶��������ĸ�����Ʒ
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

--���ñ�������
SELECT ProductID,Name,Sales.SumSold(ProductID) AS SumSold
FROM Production.Product

--����Ƕ��ʽ��ֵ����,���������ض�����Ĺ�Ա������
--ʹ�øú�������ʵ�ִ���������ͼ����
--��ͼ�����ǲ���ʹ�����������
--Employee��:������Ա��Ϣ���������/������ʶ�š�ְλ�Լ��ݼٺͲ���Сʱ��������Ա���������� Contact ���С�
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

--���ø�Ƕ��ʽ��ֵ����
SELECT * FROM HumanResources.EmployeesForManager(3)
-- ��
SELECT * FROM HumanResources.EmployeesForManager(6)


--����������ֵ����
--��������ͼ�ʹ洢���̵�����
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

--���ö�����ֵ����
SELECT * FROM HumanResources.EmployeeNames('LONGNAME')
-- ��
SELECT * FROM HumanResources.EmployeeNames('SHORTNAME')