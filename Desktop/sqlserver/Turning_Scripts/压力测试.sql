IF object_id('tempdb..#temp')   is   not   null      
BEGIN 
DROP TABLE #temp 
END
use adventureworks
go
DECLARE @index int 
DECLARE @count int 
  DECLARE @schemaname varchar(50) 
DECLARE @tablename varchar(50) 
set @index=1 
set @count=(select count(*) from sysobjects where xtype='U')

  select row_number() over(order by name) as rowNumber,name, 
  ( SELECT a.name from sys.tables t inner join sys.schemas a 
ON t.schema_id=a.schema_id 
WHERE t.name=ob.name) as schemaname 
into #temp from sysobjects ob where xtype='U'

WHILE(@index<@count) 
BEGIN 
set @schemaname=(SELECT schemaname from #temp where rowNumber=@index) 
set @tablename=(SELECT name from #temp where rowNumber=@index)

exec('select * from '+ @schemaname+'.'+@tablename)

set @index=@index+1

END

