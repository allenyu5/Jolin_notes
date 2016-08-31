USE AdventureWorks
GO
SET NOCOUNT ON

PRINT N'利用cursor 组织员工和经理的名称'
DECLARE @tbl TABLE(EmployeeName nvarchar(100),ManagerName nvarchar(100))
DECLARE @ContactID INT, @EmpoyeeID INT, @MgrEmpoyeeID INT
    , @FirstName VARCHAR(50), @MiddleName VARCHAR(50)
    , @LastName VARCHAR(50), @MgrFirstName VARCHAR(50)
    , @MgrMiddleName VARCHAR(50), @MgrLastName VARCHAR(50)
    , @FullName VARCHAR(100) , @MgrFullName VARCHAR(100)

DECLARE EmployeesCursor CURSOR FOR
    SELECT Employee.EmployeeID, Employee.ManagerID
    , Contact.FirstName, Contact.MiddleName, Contact.LastName
    FROM Person.Contact JOIN HumanResources.Employee
    ON Contact.ContactId=Employee.ContactId

OPEN EmployeesCursor
FETCH NEXT FROM EmployeesCursor
INTO @EmpoyeeID, @MgrEmpoyeeID, @FirstName
    , @MiddleName, @LastName

WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @MgrFirstName=Contact.FirstName
            , @MgrMiddleName=Contact.MiddleName
            , @MgrLastName= Contact.LastName
    FROM Person.Contact JOIN HumanResources.Employee
    ON Contact.ContactId=Employee.ContactId
    WHERE Employee.EmployeeID=@MgrEmpoyeeID

    --可能没有对应的经理
    IF @@ROWCOUNT = 0
    BEGIN
        SET @FullName=@FirstName+ISNULL(' '+@MiddleName+
            '. ' , ' ')+@LastName
        SET @MgrFullName=NULL
        END
    ELSE
    BEGIN
        SET @FullName=@FirstName+ISNULL(' '+@MiddleName+
            '. ' , ' ')+@LastName
        SET @MgrFullName=@MgrFirstName+
            ISNULL(' '+@MgrMiddleName+'. ',
            ' ')+@MgrLastName
    END

    --将算出的员工与经理的名称加入到数据表变量中
    INSERT @tbl VALUES(@FullName,@MgrFullName)

    FETCH NEXT FROM EmployeesCursor
    INTO @EmpoyeeID, @MgrEmpoyeeID, @FirstName , @MiddleName, @LastName
END
CLOSE EmployeesCursor
DEALLOCATE EmployeesCursor
SELECT * FROM @tbl


PRINT N'利用T-SQL 简化Cursor 所使用的变量声明'
DECLARE @tbl TABLE(EmployeeName nvarchar(100),ManagerName nvarchar(100))
DECLARE @ContactID INT, @EmpoyeeID INT, @MgrEmpoyeeID INT
        , @FullName VARCHAR(100) , @MgrFullName VARCHAR(100)

DECLARE EmployeesCursor CURSOR FOR
-- 新的指标查询语法
SELECT Employee.EmployeeID, Employee.ManagerID
        , FirstName+ISNULL(' '+MiddleName+'. ' , '')
        +LastName AS FullName
FROM Person.Contact JOIN HumanResources.Employee
ON Contact.ContactId=Employee.ContactId

OPEN EmployeesCursor
FETCH NEXT FROM EmployeesCursor
INTO @EmpoyeeID, @MgrEmpoyeeID,@FullName

WHILE @@FETCH_STATUS = 0
BEGIN
-- While 循环内，新的运算逻辑
    SELECT  @MgrFullName=FirstName+ISNULL(' '+MiddleName+
			'. ' , ' ')+LastName
    FROM Person.Contact JOIN HumanResources.Employee
    ON Contact.ContactId=Employee.ContactId
    WHERE Employee.EmployeeID=@MgrEmpoyeeID

    IF @@ROWCOUNT = 0
    BEGIN
        SET @MgrFullName=NULL
    END
    INSERT @tbl VALUES(@FullName, @MgrFullName)
	
    FETCH NEXT FROM EmployeesCursor
    INTO @EmpoyeeID, @MgrEmpoyeeID, @FullName
END
CLOSE EmployeesCursor
DEALLOCATE EmployeesCursor
SELECT * FROM @tbl


PRINT N'利用函数取代Cursor 功能'
CREATE FUNCTION dbo.MgrFullName(@MgrEmpoyeeID int)
RETURNS VARCHAR(100)
AS
BEGIN
    DECLARE @MgrFullName VARCHAR(100)
    SELECT  @MgrFullName=FirstName+ISNULL(' '+MiddleName+'. ' , ' ')+LastName
    FROM Person.Contact JOIN HumanResources.Employee
    ON Contact.ContactId=Employee.ContactId
    WHERE Employee.EmployeeID=@MgrEmpoyeeID
    IF @@ROWCOUNT = 0
    BEGIN
        SET @MgrFullName=NULL
    END
    RETURN  @MgrFullName
END
GO

SELECT FirstName+ISNULL(' '+MiddleName+'. ' , '')
        +LastName AS FullName,
		dbo.MgrFullName(Employee.ManagerID) ManagerFullName
FROM Person.Contact JOIN HumanResources.Employee
ON Contact.ContactId=Employee.ContactId


PRINT N'利用自我Join 取代Cursor 功能'
SELECT  EmpContact.FirstName+ISNULL(' '+
        EmpContact.MiddleName +'. ' , ' ')+
        EmpContact.LastName AS FullName
        , MgrContact.FirstName+ISNULL(' '+
        MgrContact.MiddleName+'. ' , ' ')+
        MgrContact.LastName ManagerName
FROM Person.Contact AS EmpContact
JOIN HumanResources.Employee
ON EmpContact.ContactId=Employee.ContactId
LEFT JOIN HumanResources.Employee AS Mgr
ON Mgr.EmployeeID=Employee.ManagerID
LEFT JOIN Person.Contact AS MgrContact
ON MgrContact.ContactId=Mgr.ContactId