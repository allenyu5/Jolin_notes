--׼������
select * into northwind.dbo.Member from credit.dbo.Member
select * into northwind.dbo.Charge from credit.dbo.Charge
select * into northwind.dbo.Category from credit.dbo.Category

--�ۼ�����:���ݱ�����Ǿۼ���������Ҷ��,�������ݱ�İڷ�˳���ǰ���ѡ���ļ�ֵ��С��������
--����:��ʱ�ʺ�ʹ�þۼ�����?

--�Ǿۼ�����:ʹ���Լ��Ľṹ����Ҷ��ŵ����ݿ����ǣ���ǩ��ۼ�������ֵ
--������ݱ�û�н����ۼ���������ƺ����ݱ�ΪHEAP(�ѣ�,��Ҷ��ŵ��Ǽ�ֵ��ָ����ϼ�ֵ��¼��Row ID��FileID:PageID:SlotID����
--��ǩ(bookmark)���Ҿ���ʹ��Row ID���в��ҡ�

--������ݱ����ۼ���������Ǿۼ�������Ҷ��ŵ��Ǿۼ������ļ�ֵ


--�ۼ������ǳ���Ҫ���������أ�

/*=======================�Ǿۼ�����ʾ��=====================*/
use northwind
go

sp_helpindex 'member'
go
create index idx_lastname on member(lastname)
go

select * from member with (index(idx_lastname)) 
where lastname between 'matri' and 'rudd'
/*��ע������ѯ������ѡ���Բ��ߣ�Ҳ���Ƿ��������ļ�¼ռ�ܼ�¼����С�ı���ʱ��ʹ�÷Ǿۼ�������ѯ�Ƿǳ�
û��Ч�ʵ�*/

select * from member where lastname between 'matri' and 'rudd'
--���Կ�������ʱsql server��Ըѡ���ɨ��ķ�ʽ

drop index member.idx_lastname

--��һ����ʹ�ö������
--�鿴ִ�мƻ�
exec sp_helpindex 'charge'

CREATE INDEX idx_Charge_amt ON Charge(charge_amt)
CREATE INDEX idx_Provider_no ON Charge(provider_no)
GO

--��Ϊ WHERE ��������������������ѡ���Զ��ܸ�
--���Ի����������������ϼ�¼��͸�� Hash Join ��֯��һ���
--�ٶ����ϱ�����ǩ��Ѱ
SELECT * FROM Charge 
WHERE charge_amt < 5 AND provider_no <300

--ɾ������
exec spcleanidx 'charge'
sp_helpindex 'charge'

/*========================����============================*/
/*order by,distinct,top��group by
Ҫʹ������������Ч�������ѯ���ݣ���ֱ�ӵķ�ʽ��������Ҫ����
���ֶ��Ͻ����ۼ�������*/

--Ԥ����������ݣ������ۼ�������
--��ʾִ�мƻ�
sp_helpindex 'member'
go

create clustered index idx_memberno on member(member_no)
go

select * from member order by member_no
select * from member order by lastname

drop index member.idx_memberno

--��������˳��
--��ʾִ�мƻ�
create clustered index idx_lastname on member(lastname)

select * from member order by lastname
select * from member order by lastname desc

--��ʹ�ö���ֶε��������������ʱ
--��ʾִ�мƻ�
select * from member
order by lastname asc,firstname desc

create clustered index idx_lastname on member(lastname asc,firstname desc) with drop_existing

select * from member
order by lastname asc,firstname desc

drop index member.idx_lastname

sp_helpindex 'member'
go



