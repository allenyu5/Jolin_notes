---T-SQL增强, CTE递归演示
USE demo 
CREATE TABLE Employees
(
  empid   int         NOT NULL,
  mgrid   int         NULL,
  empname varchar(25) NOT NULL,
  salary  money       NOT NULL,
  CONSTRAINT PK_Employees PRIMARY KEY(empid),
  CONSTRAINT FK_Employees_mgrid_empid
    FOREIGN KEY(mgrid)
    REFERENCES Employees(empid)
)
CREATE INDEX idx_nci_mgrid ON Employees(mgrid)
SET NOCOUNT ON
INSERT INTO Employees VALUES(1 , NULL, 'Nancy'   , $10000.00)
INSERT INTO Employees VALUES(2 , 1   , 'Andrew'  , $5000.00)
INSERT INTO Employees VALUES(3 , 1   , 'Janet'   , $5000.00)
INSERT INTO Employees VALUES(4 , 1   , 'Margaret', $5000.00) 
INSERT INTO Employees VALUES(5 , 2   , 'Steven'  , $2500.00)
INSERT INTO Employees VALUES(6 , 2   , 'Michael' , $2500.00)
INSERT INTO Employees VALUES(7 , 3   , 'Robert'  , $2500.00)
INSERT INTO Employees VALUES(8 , 3   , 'Laura'   , $2500.00)
INSERT INTO Employees VALUES(9 , 3   , 'Ann'     , $2500.00)
INSERT INTO Employees VALUES(10, 4   , 'Ina'     , $2500.00)
INSERT INTO Employees VALUES(11, 7   , 'David'   , $2000.00)
INSERT INTO Employees VALUES(12, 7   , 'Ron'     , $2000.00)
INSERT INTO Employees VALUES(13, 7   , 'Dan'     , $2000.00)
INSERT INTO Employees VALUES(14, 11  , 'James'   , $1500.00)

--请求empid=7 的 Robert及其所有级别的下属
WITH EmpCTE(empid, empname, mgrid, lvl)
AS
( 

  -- Anchor Member (AM)
  SELECT empid, empname, mgrid, 0
  FROM Employees
  WHERE empid = 7
  UNION ALL
  -- Recursive Member (RM)
  SELECT E.empid, E.empname, E.mgrid, M.lvl+1
  FROM Employees AS E
    JOIN EmpCTE AS M
      ON E.mgrid = M.empid
)
SELECT * FROM EmpCTE