USE AdventureWorks
GO
SET NOCOUNT ON

PRINT N'����cursor ��֯Ա���;��������'
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

    --����û�ж�Ӧ�ľ���
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

    --�������Ա���뾭������Ƽ��뵽���ݱ������
    INSERT @tbl VALUES(@FullName,@MgrFullName)

    FETCH NEXT FROM EmployeesCursor
    INTO @EmpoyeeID, @MgrEmpoyeeID, @FirstName , @MiddleName, @LastName
END
CLOSE EmployeesCursor
DEALLOCATE EmployeesCursor
SELECT * FROM @tbl


PRINT N'����T-SQL ��Cursor ��ʹ�õı�������'
DECLARE @tbl TABLE(EmployeeName nvarchar(100),ManagerName nvarchar(100))
DECLARE @ContactID INT, @EmpoyeeID INT, @MgrEmpoyeeID INT
        , @FullName VARCHAR(100) , @MgrFullName VARCHAR(100)

DECLARE EmployeesCursor CURSOR FOR
-- �µ�ָ���ѯ�﷨
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
-- While ѭ���ڣ��µ������߼�
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


PRINT N'���ú���ȡ��Cursor ����'
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


PRINT N'��������Join ȡ��Cursor ����'
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