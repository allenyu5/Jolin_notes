/***********************************************************************
Author="Kenneth Wang"
Create Date="2008/6/22"
***********************************************************************/


USE Northwind
GO
EXEC spCleanIdx 'Charge'

--要求传回 IO 的统计，也就是页面访问的数目
set statistics profile off
set statistics time off
set statistics io on

--没有索引的页数
--:Table 'charges'. Scan count 1, logical reads 9304, physical reads 0, read-ahead reads 6, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
SELECT charge_no FROM charge WHERE charge_amt BETWEEN 20 AND 3000

--通过聚集索引查询的页数
--:Table 'charges'. Scan count 1, logical reads 6655, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
CREATE CLUSTERED INDEX ix_charge_amt ON Charge(charge_amt)

SELECT charge_no FROM charge WHERE charge_amt BETWEEN 20 AND 3000

DROP INDEX Charge.ix_charge_amt

--强制通过非聚集索引查询的页数,用错索引比不用索引糟糕很多倍
--:Table 'charges'. Scan count 1, logical reads 957115, physical reads 0, read-ahead reads 3, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
CREATE INDEX ix_charge_amt ON Charge(charge_amt)

SELECT charge_no FROM charge WITH(INDEX(ix_charge_amt)) WHERE charge_amt BETWEEN 20 AND 3000

DROP INDEX Charge.ix_charge_amt

--通过字段顺序不适用的覆盖索引查询页数
--:Table 'charges'. Scan count 1, logical reads 4565, physical reads 0, read-ahead reads 6, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
CREATE INDEX ix_charge_amt ON Charge(charge_no,charge_amt)

SELECT charge_no FROM charge WHERE charge_amt BETWEEN 20 AND 3000

DROP INDEX Charge.ix_charge_amt

--通过覆盖索引查询的页数
--:Table 'charges'. Scan count 1, logical reads 2726, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
CREATE INDEX ix_charge_amt ON Charge(charge_amt,charge_no)

SELECT charge_no FROM charge WHERE charge_amt BETWEEN 20 AND 3000

DROP INDEX Charge.ix_charge_amt

--通过字段顺序不适用的覆盖索引查询页数
--:Table 'charges'. Scan count 1, logical reads 4560, physical reads 0, read-ahead reads 3, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
CREATE INDEX ix_charge_amt ON Charge(charge_no) INCLUDE(charge_amt)

SELECT charge_no FROM charge WHERE charge_amt BETWEEN 20 AND 3000

DROP INDEX Charge.ix_charge_amt

--通过子叶层覆盖索引查询的页数
--:Table 'charges'. Scan count 1, logical reads 2725, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
CREATE INDEX ix_charge_amt ON Charge(charge_amt) INCLUDE(Charge_no)

SELECT charge_no FROM charge WHERE charge_amt BETWEEN 20 AND 3000

DROP INDEX Charge.ix_charge_amt
