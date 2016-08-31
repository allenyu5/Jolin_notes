/***********************************************************************
Author="Kenneth Wang"
Create Date="2008/8/23"
***********************************************************************/
--������ʾ���ݱ�
USE tempdb
GO

CREATE TABLE Employee
(
	ID int,
	Name nvarchar(20),
	Gender char(1),
CONSTRAINT PK_Employee PRIMARY KEY (ID)
)
GO

--������ʾ�洢����
CREATE PROCEDURE usp_NewEmployee
	@id int,
	@name nvarchar(20),
	@gender char(1)
AS
INSERT INTO Employee VALUES (@id, @name, @gender)
GO

CREATE TYPE EmployeeType AS TABLE 
	(ID int, Name nvarchar(20), Gender char(1))
GO

CREATE PROCEDURE usp_NewEmployee_Batch
	(@employees EmployeeType READONLY)
AS
INSERT INTO Employee SELECT * FROM @employees
GO

--���в���
EXEC usp_NewEmployee 1, 'Kenneth Wang', 'm'

--���в���
DECLARE @emps EmployeeType
INSERT INTO @emps VALUES (2, 'Michael Chen', 'f')
INSERT INTO @emps VALUES (3, 'Sam Chen', 'm')
INSERT INTO @emps VALUES (4, 'John Chen', 'm')

EXEC usp_NewEmployee_Batch @emps

--��ѯ
SELECT * FROM Employee