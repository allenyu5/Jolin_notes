/***********************************************************************
Author="Kenneth Wang"
Create Date="2007/12/12"
***********************************************************************/

USE Sales;
GO
SELECT $PARTITION.pf_OrderDate(OrderDate) AS Partition, 
COUNT(*) AS [COUNT] FROM dbo.Orders 
GROUP BY $PARTITION.pf_OrderDate(OrderDate)
ORDER BY Partition ;
GO

SELECT $PARTITION.pf_OrderDate(OrderDate) AS Partition, 
COUNT(*) AS [COUNT] FROM dbo.OrdersHistory 
GROUP BY $PARTITION.pf_OrderDate(OrderDate)
ORDER BY Partition ;
GO