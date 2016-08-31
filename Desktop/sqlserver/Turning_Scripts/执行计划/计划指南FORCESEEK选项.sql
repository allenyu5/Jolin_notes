USE AdventureWorks2005;
GO
set statistics io on
SELECT c.LastName, c.FirstName, HumanResources.Employee.Title
	FROM HumanResources.Employee
	JOIN Person.Contact AS c ON HumanResources.Employee.ContactID = c.ContactID
	WHERE HumanResources.Employee.ManagerID = 3
	ORDER BY c.LastName, c.FirstName;

--Step 2: Create SQL plan guide
EXEC sp_create_plan_guide 
    @name = N'SQLGuide1', 
    @stmt = N'SELECT c.LastName, c.FirstName, HumanResources.Employee.Title
				FROM HumanResources.Employee
				JOIN Person.Contact AS c ON HumanResources.Employee.ContactID = c.ContactID
				WHERE HumanResources.Employee.ManagerID = 3
				ORDER BY c.LastName, c.FirstName;', 
    @type = N'SQL',
    @module_or_batch = NULL, 
    @params = NULL, 
    @hints = N'OPTION (TABLE HINT( HumanResources.Employee, FORCESEEK))';
GO

--Step 3: Try the SQL query again and chech the execution plan
--you may check the plan guide usage in SQL Profiler with 
--event "Plan Guide Successful" under "Performance".
--If you can not see the event captured, you may run 
--DBCC FREEPROCCACHE first to ensure no cahced plan.
SELECT c.LastName, c.FirstName, HumanResources.Employee.Title
	FROM HumanResources.Employee
	JOIN Person.Contact AS c ON HumanResources.Employee.ContactID = c.ContactID
	WHERE HumanResources.Employee.ManagerID = 3
	ORDER BY c.LastName, c.FirstName;

--Step 4: Clean up the environment
EXEC sp_control_plan_guide N'DROP', N'SQLGuide1'
DBCC FREEPROCCACHE


--Step 5: Use template plan guide
DECLARE @stmt nvarchar(max);
DECLARE @params nvarchar(max);
EXEC sp_get_query_template 
	N'SELECT c.LastName, c.FirstName, HumanResources.Employee.Title
		FROM HumanResources.Employee
		JOIN Person.Contact AS c ON HumanResources.Employee.ContactID = c.ContactID
		WHERE HumanResources.Employee.ManagerID = 3
		ORDER BY c.LastName, c.FirstName;',
	@stmt OUTPUT, 
	@params OUTPUT;
EXEC sp_create_plan_guide N'TemplateGuide1', 
    @stmt, 
	N'TEMPLATE', 
	NULL, 
	@params, 
	N'OPTION(PARAMETERIZATION FORCED)';
EXEC sp_create_plan_guide 
    N'SQLGuide1', 
    @stmt, 
    N'SQL',
    NULL, 
    @params, 
    @hints = N'OPTION (TABLE HINT( HumanResources.Employee, FORCESEEK))';
GO

--Step 6: Try the SQL query again and chech the execution plan
--you may check the plan guide usage in SQL Profiler with 
--event "Plan Guide Successful" under "Performance".
--If you can not see the event captured, you may run 
--DBCC FREEPROCCACHE first to ensure no cahced plan.
SELECT c.LastName, c.FirstName, HumanResources.Employee.Title
	FROM HumanResources.Employee
	JOIN Person.Contact AS c ON HumanResources.Employee.ContactID = c.ContactID
	WHERE HumanResources.Employee.ManagerID = 3
	ORDER BY c.LastName, c.FirstName;

--Step 7: Clean up the environment
EXEC sp_control_plan_guide N'DROP', N'SQLGuide1'
DBCC FREEPROCCACHE