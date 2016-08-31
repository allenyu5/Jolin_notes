USE AdventureWorks
GO

DECLARE @stmt nvarchar(max);
DECLARE @params nvarchar(max);
EXEC sp_get_query_template 
    N'SELECT pi.ProductID, SUM(pi.Quantity) AS Total 
      FROM Production.ProductModel AS pm 
      INNER JOIN Production.ProductInventory AS pi ON pm.ProductModelID = pi.ProductID 
      WHERE pi.ProductID = 101 
      GROUP BY pi.ProductID, pi.Quantity 
      HAVING SUM(pi.Quantity) > 50',
    @stmt OUTPUT, 
    @params OUTPUT;
EXEC sp_create_plan_guide 
    N'TemplateGuide1', 
    @stmt, 
    N'TEMPLATE', 
    NULL, 
    @params, 
    N'OPTION(PARAMETERIZATION FORCED)';