/***********************************************************************
Author="Kenneth Wang"
Create Date="2008/8/23"
***********************************************************************/
--创建MyCompany 数据库
USE MASTER
GO

CREATE DATABASE MyCompany
GO
USE MyCompany
GO

--创建 employee 表用于存放雇员的信息
    
CREATE TABLE employee
(
    EmployeeID int NOT NULL,
    EmpName    varchar(20) NOT NULL,
    Title      varchar(20) NULL,
    Salary     decimal(18, 2) NOT NULL,
    hireDate   datetimeoffset(0) NOT NULL,
)
GO

--下面的语句将插入公司雇员的数据

INSERT INTO employee
VALUES(6,   'David',  'CEO', 35900.00, '2000-05-23T08:30:00-08:00')

INSERT INTO employee
VALUES(46,  'Sariya', 'Specialist', 14000.00, '2002-05-23T09:00:00-08:00')

INSERT INTO employee
VALUES(271, 'John',   'Specialist', 14000.00, '2002-05-23T09:00:00-08:00')

INSERT INTO employee
VALUES(119, 'Jill',   'Specialist', 14000.00, '2007-05-23T09:00:00-08:00')

INSERT INTO employee
VALUES(269, 'Wanida', 'Assistant', 8000.00, '2003-05-23T09:00:00-08:00')

INSERT INTO employee
VALUES(272, 'Mary',   'Assistant', 8000.00, '2004-05-23T09:00:00-08:00')
GO

select * from employee
go

--结果
--EmployeeID  EmpName Title      Salary   hireDate
------------- ------- ---------- -------- --------------------------
--6           David   CEO        35900.00 2000-05-23 08:30:00 -08:00
--46          Sariya  Specialist 14000.00 2002-05-23 09:00:00 -08:00
--271         John    Specialist 14000.00 2002-05-23 09:00:00 -08:00
--119         Jill    Specialist 14000.00 2007-05-23 09:00:00 -08:00
--269         Wanida  Assistant  8000.00  2003-05-23 09:00:00 -08:00
--272         Mary    Assistant  8000.00  2004-05-23 09:00:00 -08:00

--使用 hierarchyid 重建数据库
DELETE employee
GO
ALTER TABLE employee ADD OrgNode hierarchyid NOT NULL
GO

DECLARE @child hierarchyid,
@Manager hierarchyid = hierarchyid::GetRoot()

--第一步是在树的顶端添加节点，David是CEO
--所以他的节点就是根节点

INSERT INTO employee
VALUES(6,   'David',  'CEO', 35900.00,
       '2000-05-23T08:30:00-08:00', @Manager)

--下一步是添加直接汇报给David的雇员纪录

SELECT @child = @Manager.GetDescendant(NULL, NULL)

INSERT INTO employee
VALUES(46,  'Sariya', 'Specialist', 14000.00,
       '2002-05-23T09:00:00-08:00', @child)

SELECT @child = @Manager.GetDescendant(@child, NULL)
INSERT INTO employee
VALUES(271, 'John', 'Specialist', 14000.00,
       '2002-05-23T09:00:00-08:00', @child)

SELECT @child = @Manager.GetDescendant(@child, NULL)
INSERT INTO employee
VALUES(119, 'Jill',  'Specialist', 14000.00,
       '2007-05-23T09:00:00-08:00', @child)

--添加汇报给Sariya的雇员
SELECT @manager = OrgNode.GetDescendant(NULL, NULL)
FROM employee WHERE EmployeeID = 46

INSERT INTO employee
VALUES(269,'Wanida', 'Assistant', 8000.00,
       '2003-05-23T09:00:00-08:00', @manager)

--添加汇报给John的雇员
SELECT @manager = OrgNode.GetDescendant(NULL, NULL)
FROM employee WHERE EmployeeID = 271

INSERT INTO employee
VALUES(272, 'Mary',   'Assistant', 8000.00,
       '2004-05-23T09:00:00-08:00', @manager)
GO

--查询雇员信息
SELECT EmpName, Title, Salary, OrgNode.ToString() AS OrgNode
FROM employee ORDER BY OrgNode
GO
--Results
--EmpName  Title      Salary    OrgNode
---------- ---------- --------- -------
--David    CEO        35900.00  /
--Sariya   Specialist 14000.00  /1/
--Wanida   Assistant  8000.00   /1/1/
--John     Specialist 14000.00  /2/
--Mary     Assistant  8000.00   /2/1/
--Jill     Specialist 14000.00  /3/

--谁汇报给Sariya？
DECLARE @Sariya hierarchyid

SELECT @Sariya = OrgNode
FROM employee WHERE EmployeeID = 46

SELECT EmpName, Title, Salary, OrgNode.ToString() AS 'OrgNode'
FROM employee
WHERE OrgNode.GetAncestor(1) = @Sariya
GO
--结果
--EmpName Title     Salary  OrgNode
--------- --------- ------- -------
--Wanida  Assistant 8000.00 /1/1/

/*由hierarchyid 数据类型提供的方法
GetAncestor 返回代表该 hierarchyid 节点第 n 代前辈的 hierarchyid。 
GetDescendant 返回该 hierarchyid 节点的子节点。 
GetLevel 返回一个整数，代表该 hierarchyid 节点在整个层次结构中的深度。 
GetRoot 返回该层次结构树的根 hierarchyid 节点。静态。 
IsDescendant 如果传入的子节点是该 hierarchyid 节点的后代，则返回 true。 
Parse 将层次结构的字符串表示转换成 hierarchyid 值。静态。 
Reparent 将层次结构中的某个节点移动另一个位置。 
ToString 返回包含该 hierarchyid 逻辑表示的字符串。 
*/
