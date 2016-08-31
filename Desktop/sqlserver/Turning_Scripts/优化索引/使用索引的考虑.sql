/***********************************************************************
Author="Kenneth Wang"
Create Date="2008/6/22"
***********************************************************************/



/*�������ˣ�������ûЧ�ʣ��������ˣ��������½����޸ġ�ɾ��������*/

--ѡ����(Selectivity)
ѡ����=���������ļ�¼��Ŀ/�ܼ�¼����
/*ѡ����Խ�ߣ�Ҳ�������ֵԽС����Խֵ�ý�������*/
use Northwind
go
sp_helpindex 'member'

create index idx_memberno on member(member_no)

--���⣺�Ǿۼ�����,���Ǳ�ɨ�裿
select * from member where member_no=1

--���⣺�Ǿۼ�����,���Ǳ�ɨ�裿
select * from member where member_no>=100

drop index member.idx_memberno

--�����ܶ�(density)
�����ܶ�=1/��ֵΨһ�ļ�¼��
--�ܶ�ԽС,���ֶ�Խ�ʺϽ�����

create index idx_charge_member_no on charge(member_no)
dbcc show_statistics(charge,idx_charge_member_no)  --�������ר�ŵĽű�ʾ��ͳ��

--���ݷֲ�
----���ݷֲ�(distribution)���������ݼ�¼��ɵķ�ʽ,��
�ܶȵĸ����й�.
----������ƽ���ֲ�,Ҳ��������̬�ֲ�

--�������̬�ֲ�,��ѯ�Ż�����ʹ��ͳ����������¼ĳһ��
--��Χ�ڵ�����Լ���Ƕ��ٱʼ�¼,Ȼ���жϳ�ѡ���Ը߻��,
--���������õ�������

--ʹ��set statistics�鿴��ѯ�﷨��ʹ�õ���Դ
--set statistics io on
--set statistics time on
--set statistics profile on
--set statistics xml on
select * from members where lastname like 'a%'


/*ʹ�ö�̬������ͼ���鿴������ʹ��*/
--sys.dm_db_missing_index_group_stats ��ͼ
--sys.dm_db_missing_index_groups ��ͼ
--sys.dm_db_missing_index_details ��ͼ
--sys.dm_db_missing_index_columns ����
--sys.dm_db_index_usage_stats ��ͼ

----------��������
--û��ʹ�������Ĳ�ѯ���鿴��ѯ�ƻ�
USE Northwind
SET STATISTICS IO OFF
EXEC spCleanIdx 'Charge'
EXEC spCleanIdx 'Member'
exec sp_helpindex 'member'
exec sp_helpindex 'charge'

SET STATISTICS IO ON
SELECT LastName,FirstName,charge_no,charge_amt FROM Charge c
JOIN Member m ON c.member_no=c.member_no
WHERE c.Provider_no=498 AND m.member_no=5 AND charge_amt>1000


--��ѯ���ֶ�̬������ͼ���Է������������
select * from sys.dm_db_missing_index_groups
select * from sys.dm_db_missing_index_group_stats
select * from sys.dm_db_missing_index_details

SELECT mig.*, statement AS table_name,column_id, column_name, column_usage
FROM sys.dm_db_missing_index_details AS mid
CROSS APPLY sys.dm_db_missing_index_columns (mid.index_handle)
INNER JOIN sys.dm_db_missing_index_groups AS mig ON mig.index_handle = mid.index_handle
ORDER BY mig.index_group_handle, mig.index_handle, column_id
--����ȵ������з�����ǰ��
--������ȵ������з�����������к���
--�������������з��ڷ���include�Ӿ���

--����ϵͳ������ͼ�Ľ��鴴������
CREATE INDEX idxCharge ON Charge(Provider_no,charge_amt) INCLUDE(Charge_no,member_no)
CREATE INDEX idxMember ON Member(member_no)

--����ִ�в�ѯ��䣬���鿴��ѯ�ƻ�
SELECT LastName,FirstName,charge_no,charge_amt FROM Charge c
JOIN Member m ON c.member_no=c.member_no
WHERE c.Provider_no=498 AND m.member_no=5 AND charge_amt>1000

----------��������
--�������ݻ�Ӱ�쵽����
insert charge values(1,1,1,1,1,1,1)
--ͨ��idxcharge����ɨ��member_no=1�ļ�¼
update charge set charge_code=1 where member_no=1

--�鿴��̬������ͼsys.dm_db_index_usage_stats��ȡ��������ͳ����Ϣ
--sys.dm_db_index_usage_stats���������������е�������ɨ�裬��ѯ�͸��µ��ۻ�������ÿ���õ������1��
--ע��user_updates�ֶ�,������ֵ���ߣ�˵�����´������࣬��Ӧ��ж�ظ�����
select * from sys.dm_db_index_usage_stats
where object_id=object_id('charge')

--ɾ������
set statistics io off

exec spcleanidx 'member'
go
exec spcleanidx 'charge'



