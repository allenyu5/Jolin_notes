/***********************************************************************
Author="Kenneth Wang"
Create Date="2006/5/7"
***********************************************************************/

SQL Server 2000的分区视图
//ServerA
Use Adventureworks
go
Create table customers (
  Customerid  varchar(5) not null,
  CompanyName varchar(50) not null,
  ContactName  varchar(30) null,

CONSTRAINT PK_customers PRIMARY KEY CLUSTERED  (Customerid), 
CONSTRAINT   CK_customerid   CHECK (Customerid  between 'AAAAA'  and  'LZZZZ')
)

//Server B 
use Adventureworks
go
Create table customers (
  Customerid  varchar(5) not null,
  CompanyName varchar(50) not null,
  ContactName  varchar(30) null,
CONSTRAINT PK_customers PRIMARY KEY CLUSTERED  (Customerid), 
CONSTRAINT   CK_customerid   CHECK (Customerid  between 'M'  and  'ZZZZZ')
)
go

//ServerA
exec  sp_addlinkedserver    
       @server='DPVSERVER1', @srvproduct='',
       @provider='SQLOLEDB', @datasrc='ServerB'
go
exec  sp_addlinkedsrvlogin 
 @rmtsrvname =  'DPVSERVER1'
     , @useself =  'false' 
     , @rmtuser =  'sa' 
     , @rmtpassword = 'password01!' 
go

//ServerB
exec  sp_addlinkedserver    
       @server='DPVSERVER2', @srvproduct='',
       @provider='SQLOLEDB', @datasrc='ServerA'
exec  sp_addlinkedsrvlogin 
 @rmtsrvname =  'DPVSERVER2'
     , @useself =  'false' 
     , @rmtuser =  'sa' 
     , @rmtpassword = 'password01!' 
go

//ServerA
Exec sp_serveroption 'DPVSERVER1', 'lazy schema validation', 'true'

//Sever B
Exec sp_serveroption 'DPVSERVER2', 'lazy schema validation', 'true'


//Server A：
  Create view DPV_Customers  As
   Select *  from Customers 
   Union all
   Select *  from  DPVSERVER1.Pubs.dbo.Customers
//Server B
   Create view DPV_Customers  As
   Select *  from  DPVSERVER2.Pubs.dbo.Customers
   UNION ALL
   Select *  from Customers


set xact_abort on
INSERT INTO DPV_CUSTOMERS VALUES('AAMAY','FUZHOU COMPANY','MARRY')
INSERT INTO DPV_CUSTOMERS VALUES('CJOHN','XIMEN COMPANY','MARRY')
INSERT INTO DPV_CUSTOMERS VALUES('SMITH','SHANGHAI COMPANY','TOM')
INSERT INTO DPV_CUSTOMERS VALUES('YOUNG','FUJIAN COMPANY','JANE')
INSERT INTO DPV_CUSTOMERS VALUES('GTOPP','BEJING COMPANY','TOM')
INSERT INTO DPV_CUSTOMERS VALUES('QUILH','BEJING COMPANY','TOM')

set statistics io on

SELECT  *  FROM  DPV_Customers  order  by  customerid

SELECT  *  FROM  DPV_Customers  WHERE  CustomerID= 'QUILH'





