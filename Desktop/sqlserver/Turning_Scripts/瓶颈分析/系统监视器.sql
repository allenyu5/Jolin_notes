/***********************************************************************
Author="Kenneth Wang"
Create Date="2008/6/25"
***********************************************************************/

1、监视磁盘性能
监视磁盘I/O和过度分页
PhysicalDisk
	%Disk Time
	Avg.Disk Queue Length
	Current Disk Queue Length
Memory
	Page Faults/sec
问题：如何改善？

--隔离SQL Server创建的磁盘操作
SQL Server:Buffer Manager
	Page reads/sec
	Page writes/sec
问题：如何改善？

2、监视内存使用
Memory- Available Bytes
Memory- Pages/sec

Process - Page Faults/sec(sqlservr instance)
Process - Working Set(sqlservr instance)
SQL Server: Buffer Manager - Buffer Cache Hit Ratio
SQL Server: Buffer Manager - Total Pages
SQL Server - Memory Manager:Total Server Memory (KB)

3、监视CPU
Processor - %Processor Time
Process - %Processor Time(sqlservr instance)