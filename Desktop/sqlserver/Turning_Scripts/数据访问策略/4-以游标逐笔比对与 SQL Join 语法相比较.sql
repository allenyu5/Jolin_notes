USE Northwind
GO

--�� Cursor ģ�� Join �������������� Set �뵥��������Ч�ʲ���
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
--�����α���Ҫ�õ��Ĳ���
DECLARE @CustomerID NVARCHAR(5),@CompanyName NVARCHAR(40),
@OrderCustomerID NVARCHAR(5),@OrderID INT,@OrderDate DATETIME

--�����α���������ݶ���
DECLARE cur_Customers CURSOR FOR
	SELECT CustomerID,CompanyName FROM Customers ORDER BY CustomerID

--�����α�
OPEN cur_Customers
--��ȡ�α����ݣ��������ݷ��������
FETCH NEXT FROM cur_Customers INTO @CustomerID,@CompanyName

--����Ƿ��Ѷ������һ�ʼ�¼
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
--�ر��α�
CLOSE cur_Customers
--�ͷ��α�
DEALLOCATE cur_Customers

SELECT * FROM #Temp
Go
DROP TABLE #Temp
