USE Northwind
GO
SET NOCOUNT ON
--���α꿪���󣬶��������������޸ĺ�ɾ���Ķ������ԱȽϸ����α�Ĳ���
INSERT Customers(CustomerID,CompanyName) VALUES('aaaaa','aaaaa')
INSERT Customers(CustomerID,CompanyName) VALUES('abbbb','abbbb')
SELECT 'ԭʼ��¼', CustomerID,CompanyName FROM Customers
WHERE CustomerID < 'AL%'

DECLARE @CustomerID NVARCHAR(5),@CompanyName NVARCHAR(40)

DECLARE cur_Customers CURSOR 
STATIC  --�� [ STATIC | KEYSET | DYNAMIC 
         ---| FAST_FORWARD ] �ֱ���Խ��
FOR 
	SELECT CustomerID,CompanyName FROM Customers 
  WHERE CustomerID < 'AL%'

OPEN cur_Customers

--����һ�� Insert��Update��Delete �����α���û�ио�
INSERT Customers(CustomerID,CompanyName) VALUES('abcde','abcde')
DELETE Customers WHERE CustomerID='aaaaa'
UPDATE Customers SET CompanyName='zzzzz' 
WHERE CustomerID='abbbb' 

SELECT '�����α�ṹ����޸ĵļ�¼', CustomerID,CompanyName FROM Customers
WHERE CustomerID < 'AL%'


FETCH NEXT FROM cur_Customers INTO @CustomerID,@CompanyName
PRINT '***************  �����޸ĺ��α��ѯ���  ***************'
--������ Keyset ʱ������¼��ɾ����@@FETCH_STATUS �ᴫ�� -2
WHILE(@@FETCH_STATUS=0 OR @@FETCH_STATUS=-2)
BEGIN
	SELECT 'ͨ���α��ѯ', @CustomerID CustomerID,@CompanyName CompanyName

	FETCH NEXT FROM cur_Customers INTO 
	@CustomerID,@CompanyName
END

CLOSE cur_Customers
DEALLOCATE cur_Customers
DELETE Customers WHERE CustomerID IN('abbbb','abcde')