USE Northwind
GO

--以 Cursor 模拟 Join 运作，你可以想见 Set 与单笔运作的效率差异
/*
SELECT CompanyName,OrderID,OrderDate FROM Customers C
JOIN Orders O ON C.CustomerID=O.CustomerID 
ORDER BY C.CustomerID
*/
SET NOCOUNT ON

CREATE TABLE #Temp
(
	CompanyName NVARCHAR(40),
	OrderID INT,
	OrderDate DATETIME
)
--宣告游标需要用到的参数
DECLARE @CustomerID NVARCHAR(5),@CompanyName NVARCHAR(40),
@OrderCustomerID NVARCHAR(5),@OrderID INT,@OrderDate DATETIME

--宣告游标的数据内容定义
DECLARE cur_Customers CURSOR FOR
	SELECT CustomerID,CompanyName FROM Customers ORDER BY CustomerID

--开启游标
OPEN cur_Customers
--获取游标内容，并将数据放入变量内
FETCH NEXT FROM cur_Customers INTO @CustomerID,@CompanyName

--检查是否已读完最后一笔记录
WHILE(@@FETCH_STATUS=0)
BEGIN
--	PRINT @CustomerID
	DECLARE cur_Orders CURSOR FOR
		SELECT OrderID,CustomerID,OrderDate FROM Orders 
		WHERE CustomerID=@CustomerID
	OPEN cur_Orders
	FETCH NEXT FROM cur_Orders INTO @OrderID,@OrderCustomerID,@OrderDate
	WHILE(@@FETCH_STATUS=0)
	BEGIN
		INSERT #Temp VALUES(@CompanyName , @OrderID , @OrderDate)
		FETCH NEXT FROM cur_Orders INTO @OrderID,@OrderCustomerID,@OrderDate
	End
	CLOSE cur_Orders 
	DEALLOCATE cur_Orders

	FETCH NEXT FROM cur_Customers INTO @CustomerID,@CompanyName
END
--关闭游标
CLOSE cur_Customers
--释放游标
DEALLOCATE cur_Customers

SELECT * FROM #Temp
Go
DROP TABLE #Temp
