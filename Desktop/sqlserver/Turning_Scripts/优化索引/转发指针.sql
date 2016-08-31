CREATE TABLE dbo.HeapTest ( id INT, col1 VARCHAR(800) )

DECLARE @index INT
SET @index = 0
BEGIN TRAN
WHILE @index < 100000 
    BEGIN 
        INSERT  INTO dbo.HeapTest
                ( id, col1 )
        VALUES  ( @index, NULL )
        SET @index = @index + 1

    END
COMMIT

select object_name([object_id]) as name,page_count,index_type_desc,forwarded_record_count
 from sys.dm_db_index_physical_stats(db_id(),object_id('HeapTest'),
null,null,'detailed')

update heaptest set col1=replicate('a',10)

set statistics io on
select * from dbo.HeapTest

alter table dbo.heaptest rebuild
create clustered index cl_id on dbo.heaptest(id)

drop table dbo.heaptest