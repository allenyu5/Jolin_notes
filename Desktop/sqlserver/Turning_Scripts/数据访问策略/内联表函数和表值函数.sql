--创建表值行数
CREATE FUNCTION tvf_multi_Test ( )
 RETURNS @SaleDetail TABLE ( ProductId INT )
 AS
     BEGIN 
         INSERT  INTO @SaleDetail
                 SELECT  ProductID
                 FROM    Sales.SalesOrderHeader soh
                         INNER JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID 
         RETURN 
     END
 --创建内联表值函数
 CREATE FUNCTION tvf_inline_Test ( )
 RETURNS TABLE
 AS
    RETURN
     SELECT  ProductID
     FROM    Sales.SalesOrderHeader soh
             INNER JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID 


set statistics io on

--表值函数做Join
 SELECT  c.personid ,
         Prod.Name ,
         COUNT(*) 'numer of unit'
 FROM    Person.BusinessEntityContact c
         INNER JOIN dbo.tvf_multi_Test() tst ON c.personid = tst.ProductId
         INNER JOIN Production.Product prod ON tst.ProductId = prod.ProductID
 GROUP BY c.personid ,
         Prod.Name 
  
 --内联表值函数做Join
 SELECT  c.personid ,
         Prod.Name ,
         COUNT(*) 'numer of unit'
 FROM    Person.BusinessEntityContact c
         INNER JOIN dbo.tvf_inline_Test() tst ON c.personid = tst.ProductId
         INNER JOIN Production.Product prod ON tst.ProductId = prod.ProductID
 GROUP BY c.personid ,
         Prod.Name 

--找出和表值函数做Join的查询
WITH XMLNAMESPACES('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS p)
 SELECT  st.text,
         qp.query_plan
 FROM    (
     SELECT  TOP 50 *
     FROM    sys.dm_exec_query_stats
     ORDER BY total_worker_time DESC
 ) AS qs
 CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
 CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
 WHERE qp.query_plan.exist('//p:RelOp[contains(@LogicalOp, "Join")]/*/p:RelOp[(@LogicalOp[.="Table-valued function"])]') = 1
