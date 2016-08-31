/***********************************************************************
Author="Kenneth Wang"
Create Date="2008/6/25"
***********************************************************************/

-- 开始事务 - 将创建锁
USE AdventureWorks
BEGIN TRANSACTION
UPDATE Production.ProductCategory
SET [Name] = [Name] + ' - Bike Stuff'

-- 更新另外一个表 - 将创建锁
UPDATE Production.Product
SET ListPrice = ListPrice * 1.1

-- 回滚事务 - 将释放锁
ROLLBACK TRANSACTION