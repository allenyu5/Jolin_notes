USE Northwind
GO
SET NOCOUNT ON
--在游标开启后，对数据做新增、修改和删除的动作，以比较各种游标的差异
INSERT Customers(CustomerID,CompanyName) VALUES('aaaaa','aaaaa')
INSERT Customers(CustomerID,CompanyName) VALUES('abbbb','abbbb')
SELECT '原始纪录', CustomerID,CompanyName FROM Customers
WHERE CustomerID < 'AL%'

DECLARE @CustomerID NVARCHAR(5),@CompanyName NVARCHAR(40)

DECLARE cur_Customers CURSOR 
STATIC  --以 [ STATIC | KEYSET | DYNAMIC 
         ---| FAST_FORWARD ] 分别测试结果
FOR 
	SELECT CustomerID,CompanyName FROM Customers 
  WHERE CustomerID < 'AL%'

OPEN cur_Customers

--测试一段 Insert，Update，Delete 看看游标有没有感觉
INSERT Customers(CustomerID,CompanyName) VALUES('abcde','abcde')
DELETE Customers WHERE CustomerID='aaaaa'
UPDATE Customers SET CompanyName='zzzzz' 
WHERE CustomerID='abbbb' 

SELECT '开启游标结构后才修改的记录', CustomerID,CompanyName FROM Customers
WHERE CustomerID < 'AL%'


FETCH NEXT FROM cur_Customers INTO @CustomerID,@CompanyName
PRINT '***************  数据修改后，游标查询结果  ***************'
--当采用 Keyset 时，若记录被删除，@@FETCH_STATUS 会传回 -2
WHILE(@@FETCH_STATUS=0 OR @@FETCH_STATUS=-2)
BEGIN
	SELECT '通过游标查询', @CustomerID CustomerID,@CompanyName CompanyName

	FETCH NEXT FROM cur_Customers INTO 
	@CustomerID,@CompanyName
END

CLOSE cur_Customers
DEALLOCATE cur_Customers
DELETE Customers WHERE CustomerID IN('abbbb','abcde')