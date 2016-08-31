/***********************************************************************
Author="Kenneth Wang"
Create Date="2008/6/22"
***********************************************************************/


USE Northwind
GO
EXEC spCleanIdx 'Charge'

--Ҫ�󴫻� IO ��ͳ�ƣ�Ҳ����ҳ����ʵ���Ŀ
set statistics profile off
set statistics time off
set statistics io on

--û��������ҳ��
--:Table 'charges'. Scan count 1, logical reads 9304, physical reads 0, read-ahead reads 6, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
SELECT charge_no FROM charge WHERE charge_amt BETWEEN 20 AND 3000

--ͨ���ۼ�������ѯ��ҳ��
--:Table 'charges'. Scan count 1, logical reads 6655, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
CREATE CLUSTERED INDEX ix_charge_amt ON Charge(charge_amt)

SELECT charge_no FROM charge WHERE charge_amt BETWEEN 20 AND 3000

DROP INDEX Charge.ix_charge_amt

--ǿ��ͨ���Ǿۼ�������ѯ��ҳ��,�ô������Ȳ����������ܶ౶
--:Table 'charges'. Scan count 1, logical reads 957115, physical reads 0, read-ahead reads 3, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
CREATE INDEX ix_charge_amt ON Charge(charge_amt)

SELECT charge_no FROM charge WITH(INDEX(ix_charge_amt)) WHERE charge_amt BETWEEN 20 AND 3000

DROP INDEX Charge.ix_charge_amt

--ͨ���ֶ�˳�����õĸ���������ѯҳ��
--:Table 'charges'. Scan count 1, logical reads 4565, physical reads 0, read-ahead reads 6, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
CREATE INDEX ix_charge_amt ON Charge(charge_no,charge_amt)

SELECT charge_no FROM charge WHERE charge_amt BETWEEN 20 AND 3000

DROP INDEX Charge.ix_charge_amt

--ͨ������������ѯ��ҳ��
--:Table 'charges'. Scan count 1, logical reads 2726, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
CREATE INDEX ix_charge_amt ON Charge(charge_amt,charge_no)

SELECT charge_no FROM charge WHERE charge_amt BETWEEN 20 AND 3000

DROP INDEX Charge.ix_charge_amt

--ͨ���ֶ�˳�����õĸ���������ѯҳ��
--:Table 'charges'. Scan count 1, logical reads 4560, physical reads 0, read-ahead reads 3, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
CREATE INDEX ix_charge_amt ON Charge(charge_no) INCLUDE(charge_amt)

SELECT charge_no FROM charge WHERE charge_amt BETWEEN 20 AND 3000

DROP INDEX Charge.ix_charge_amt

--ͨ����Ҷ�㸲��������ѯ��ҳ��
--:Table 'charges'. Scan count 1, logical reads 2725, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
CREATE INDEX ix_charge_amt ON Charge(charge_amt) INCLUDE(Charge_no)

SELECT charge_no FROM charge WHERE charge_amt BETWEEN 20 AND 3000

DROP INDEX Charge.ix_charge_amt
