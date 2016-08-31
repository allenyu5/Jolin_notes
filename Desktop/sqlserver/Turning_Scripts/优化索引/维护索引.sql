/***********************************************************************
Author="Kenneth Wang"
Create Date="2008/6/22"
***********************************************************************/


--�ڲ��������������ҳ�������ռ�û�м�¼
--�ⲿ��������Ӳ���ϰڷŷ�ҳ����չ��ҳ������



--ʹ��dbcc showcontig�۲�����������
use Northwind
go
EXEC spCleanIdx 'charge'

create index idx_charge_no on charge(charge_no)

dbcc showcontig(charge,idx_charge_no)


--��DBCC SHOWCONTIG��ѯ�Ľ���������ݱ��У��Թ������۲�
CREATE TABLE #fraglist (
   ObjectName CHAR (255),
   ObjectId INT,
   IndexName CHAR (255),
   IndexId INT,
   Lvl INT,
   CountPages INT,
   CountRows INT,
   MinRecSize INT,
   MaxRecSize INT,
   AvgRecSize INT,
   ForRecCount INT,
   Extents INT,
   ExtentSwitches INT,
   AvgFreeBytes INT,
   AvgPageDensity INT,
   ScanDensity DECIMAL,
   BestCount INT,
   ActualCount INT,
   LogicalFrag DECIMAL,
   ExtentFrag DECIMAL)

INSERT #fraglist EXEC('DBCC SHOWCONTIG(Charges,idx_charge_no)  WITH TABLERESULTS')

SELECT * FROM #fraglist

--ʹ��sys.dm_db_index_physical_stats��̬�������۲����ݲ�����

--�򵥲�ѯ
use adventureworks
select * from sys.dm_db_index_physical_stats(db_id(N'adventureworks'),object_id(N'humanresources.department'),DEFAULT, DEFAULT,'detailed')

--��ѯ�����ⲿ������״��
--���Դ�manament studio�鿴���������ԣ���ϸ��Ϣ
select a.index_id,name,avg_fragmentation_in_percent from sys.dm_db_index_physical_stats(db_id(),object_id(N'humanresources.department'),DEFAULT, DEFAULT, 'LIMITED') as a 
inner join sys.indexes as b on a.object_id=b.object_id and a.index_id=b.index_id


--�������avg_fragmentation_in_percent�ӽ�30������Ҫ������֯����
--�������avg_fragmentation_in_percent����30������Ҫ�ؽ�����

--�ؽ����ݱ����ض�����
use adventureworks
alter index pk_customer_customerid on sales.customer rebuild

--�ؽ����ݱ�����������
alter index all on sales.customer rebuild

--�������ؽ�����
alter index all on production.product rebuild with (fillfactor=80,sort_in_tempdb=on,online=on)

--������֯����
use adventureworks
alter index pk_customer_customerid on sales.customer reorganize

--������֯���ݱ����ݱ�����������
alter index all on sales.customer reorganize


--sql server 2005������disableѡ��
use adventureworks
go
create index idxterritoryid on sales.customer(territoryID)
go
alter index idxterritoryid on sales.customer disable
--���disable��������Ҫ�ؽ�����ɾ���ٽ���
alter index idxterritoryid on sales.customer rebuild
--����ʹ�õ����õ������ᷢ������
select territoryid from sales.customer with (index(idxterritoryid))




---ͨ��ͣ�þۼ�������ͣ��ĳ�����ݱ�
Use Tempdb
--���� Clustered Index �� Disable�����������ݱ�������
CREATE TABLE tblT1(C1 INT)
CREATE CLUSTERED INDEX idxC1 ON tblT1(C1)
ALTER INDEX idxC1 ON tblT1 DISABLE

--ʹ��ʱ���������µĴ���
--��Ϣ 8655������ 16��״̬ 1���� 1
--��ѯ�������޷������ƻ�����Ϊ���ݱ����ͼ 'tblT1' �ϵ����� 'idxC1' ��ͣ�á�
SELECT * FROM tblT1
INSERT tblT1 VALUES(1)
ALTER INDEX idxC1 ON tblT1 REBUILD
DROP TABLE tblT1


