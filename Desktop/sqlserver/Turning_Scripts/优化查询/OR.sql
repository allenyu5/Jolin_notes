DECLARE @minEmp INT
DECLARE @maxEmp INT
SET @minEmp= 100 
SET @maxEmp= 200 
SELECT e.* FROM HumanResources.Employee e 
LEFT JOIN Adventureworks.Person.Contact c ON e.EmployeeID=c.ContactID 
WHERE e.EmployeeID BETWEEN @minEmp and @maxEmp 
    OR c.EmailAddress IN('sabria0@adventure-works.com','teresa0@adventure-works.com','shaun0@adventure-works.com')


--union repalce or
DECLARE @minEmp INT
DECLARE @maxEmp INT
SET @minEmp = 100
SET @maxEmp = 200
SELECT e.*FROM HumanResources.Employee e
LEFT JOIN Adventureworks.Person.Contact c ON e.EmployeeID = c.ContactID
WHERE EmployeeID BETWEEN @minEmp and @maxEmp 
UNION
SELECT e.*FROM HumanResources.Employee e
LEFT JOIN Adventureworks.Person.Contact c ON e.EmployeeID = c.ContactID
WHERE
c.EmailAddress in('sabria0@adventure-works.com','teresa0@adventure-works.com','shaun0@adventure-works.com')
