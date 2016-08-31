
-- Create stored procedure that creates a temp table, a clustered index and populates with 10 rows
-- The script expects a database called Demo to exist
--Create database Demo
USE Demo ;
GO
CREATE PROCEDURE [dbo].[usp_temp_table]
AS 
    CREATE TABLE #tmpTable
        (
          c1 INT,
          c2 INT,
          c3 CHAR(5000)
        ) ;
    CREATE UNIQUE CLUSTERED INDEX cix_c1 ON #tmptable ( c1 ) ;
    DECLARE @i INT = 0 ;
    WHILE ( @i < 10 ) 
        BEGIN
            INSERT  INTO #tmpTable ( c1, c2, c3 )
            VALUES  ( @i, @i + 100, 'wangh' ) ;
            SET  @i += 1 ;
        END ;
GO
-- Create stored procedure that runs usp_temp_table 50 times
CREATE PROCEDURE [dbo].[usp_loop_temp_table]
AS 
    SET nocount ON ;
    DECLARE @i INT = 0 ;
    WHILE ( @i < 100 )
        BEGIN
            EXEC demo.dbo.usp_temp_table ;
            SET  @i += 1 ;
        END ;

--清空等待的统计信息
DBCC SQLPERF('sys.dm_os_wait_stats',clear)


--ostress -E  -dadventureworks -Q"EXEC dbo.usp_loop_temp_table" -ooutput.txt -n300


--查询资源等待
SELECT  *
FROM    sys.dm_os_wait_stats
ORDER BY wait_time_ms DESC

select * from sys.dm_os_waiting_tasks
where resource_description='2:1:1'
or  resource_description='2:1:2'
or resource_description='2:1:3'

--解决方案
ALTER DATABASE tempdb 
MODIFY FILE (name=tempdev,size=512MB) ;
GO
ALTER DATABASE tempdb 
ADD FILE (name=tempdev2,size=512MB,filename='C:\data\tempdev2.ndf') ;
GO
ALTER DATABASE tempdb 
ADD FILE (name=tempdev3,size=512MB,filename='C:\data\tempdev3.ndf') ;
GO
ALTER DATABASE tempdb 
ADD FILE (name=tempdev4,size=512MB,filename='C:\data\tempdev4.ndf') ;


USE [demo] ;
GO
ALTER PROCEDURE [dbo].[usp_temp_table]
AS 
    CREATE TABLE #tmpTable
        (
          c1 INT UNIQUE CLUSTERED,
          c2 INT,
          c3 CHAR(5000)
        ) ;
    --CREATE UNIQUE CLUSTERED INDEX cix_c1 ON #tmptable ( c1 ) ;
    DECLARE @i INT = 0 ;
    WHILE ( @i < 10 ) 
        BEGIN
            INSERT  INTO #tmpTable ( c1, c2, c3 )
            VALUES  ( @i, @i + 100, 'coeo' ) ;
            SET @i += 1 ;
        END ;
GO


--显示所有数据库文件IO延迟情况
SELECT  DB_NAME(database_id) AS 'Database Name',
        file_id,
        io_stall_read_ms / num_of_reads AS 'Avg Read Transfer/ms',
        io_stall_write_ms / num_of_writes AS 'Avg Write Transfer/ms'
FROM    sys.dm_io_virtual_file_stats(-1, -1)
WHERE   num_of_reads > 0
        AND num_of_writes > 0 ;