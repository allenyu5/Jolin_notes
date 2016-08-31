
/*
--���ͨ����ͼ�޸�����:
--�����ָ�ļ�ֵ����Ҫ����checkԼ��
--�����ָ�ļ�ֵ������������һ����
--�����ָ�ļ�ֵ�������κ������ļ�ֵ
--Union All��ͼ�������еĳ�Ա���ݱ�
*/


--
Local Partition View + Insteaded of Trigger ����
--
go

--�������ݱ�����ֵ
Use Northwind
go

Create table Supply_0_1000
(supplyid int primary key check(supplyid between 1 and 1000),supplier char(50))
go

Create table Supply_1001_2000
(supplyid int primary key check(supplyid between 1001 and 2000),supplier char(50))
go


Create table Supply_2001_3000
(supplyid int primary key check(supplyid between 2001 and 3000),supplier char(50))
go

Create table Supply_3001_4000
(supplyid int primary key check(supplyid between 3001 and 4000),supplier char(50))
go

--����һ����ͼ����������е�Supplier Tables
Create View SupplyAll
as
select * from supply_0_1000
union  --all  --�������all���޷��γ��������ݿ�
select * from supply_1001_2000
union all
select * from supply_2001_3000
union all
select * from supply_3001_4000
go

/*
--����instead of trigger

--ͨ�����������ȡ��ԭ����view�����½�����
create trigger io_trig_ins_supplyall on supplyall
instead of insert as
begin
insert into supply_0_1000
	select * form inserted where supplyid between 1 and 1000

insert into supply_1001_2000
	select * form inserted where supplyid between 1001 and 2000

insert into supply_2001_3000
	select * form inserted where supplyid between 2001 and 3000

insert into supply_3001_4000
	select * form inserted where supplyid between 3001 and 4000
end --trigger action
go
*/

--��������
set statistics io on

insert supplyall values('1','CaliforniaCorp')
insert supplyall values('5','BraziliaLtd')
go

insert supplyall values('1231','FarEast')
insert supplyall values('1280','NZ')
go

insert supplyall values('2321','EuroGroup')
insert supplyall values('2442','UKArchip')
go

insert supplyall values('3475','India')
insert supplyall values('3521','Afrique')
go

--�鿴���
select  * from supplyall
go

/*���ͣ��������һ��ʼ�������ĸ����ݱ����������Ͻ������ݼ�¼������ȷ��CheckԼ����
���Ž�����һ����ͼ����Union All�ĸ����ݱ����˴�����ǿ�����ǣ��������Ҫ��SQL Server
�Զ�����Insert��¼������ֵ�����뵽��ȷ�����ݱ��λ�ã�����Ҫ����Union All,�����ܽ���
��Union������ᱨ���������£�
����������Ϣ 4416������16��״̬ 5���� 1
Union All��ͼ'SupplyAll'��ͼ�޷����£���Ϊ�����а���������ļܹ�

�����Ը��ʹ��Union All�������޷��������Ͻ�����ȷ�������ݷ�Χ��checkԼ��������Կ�����
��ͼ�Ͻ���Instead Of �������������ݵ��޸Ĳ�����Instead Of���������߼�ȡ������
*/



