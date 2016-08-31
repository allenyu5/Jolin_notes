CREATE DATABASE TestCE
GO

USE TestCE
GO
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'StatMember')
	DROP TABLE StatMember
GO
CREATE TABLE StatMember
(
ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
Member INT NOT NULL
)
GO
CREATE INDEX IX_StatMember_Member ON StatMember
(
Member
)
GO
--在表中插入Member为1-5000的数据，其中7的倍数插入100条，其它数字插入1条。
SET NOCOUNT ON;
DECLARE @StatMember TABLE (ID INT IDENTITY(1,1) NOT NULL, Member INT NOT NULL)
DECLARE @m INT = 1, @n INT
WHILE @m <= 5000
BEGIN
	IF @m % 7 = 0
	BEGIN
		SET @n = 1
		WHILE @n <= 100
		BEGIN
			INSERT INTO @StatMember (Member)
			VALUES (@m)
			SET @n += 1
		END
	END
	ELSE
		INSERT INTO @StatMember (Member)
		VALUES (@m)

	SET @m += 1;
END
INSERT INTO StatMember (Member)
SELECT Member FROM @StatMember

GO
--更新统计信息
UPDATE STATISTICS dbo.StatMember([IX_StatMember_Member])
    WITH FULLSCAN
GO
SELECT * FROM StatMember
WHERE Member = 49

