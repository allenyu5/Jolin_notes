/***********************************************************************
Author="Kenneth Wang"
Create Date="2008/6/25"
***********************************************************************/

-- ��ʼ���� - ��������
USE AdventureWorks
BEGIN TRANSACTION
UPDATE Production.ProductCategory
SET [Name] = [Name] + ' - Bike Stuff'

-- ��������һ���� - ��������
UPDATE Production.Product
SET ListPrice = ListPrice * 1.1

-- �ع����� - ���ͷ���
ROLLBACK TRANSACTION