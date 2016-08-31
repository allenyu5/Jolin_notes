USE run
GO
CREATE TABLE snoorder (
	serverid	int primary key,
	lastdate	int not null,
	lastsno	int not null
)
GO
CREATE TABLE customer(
	custid	int not null primary key,
	custbalance money not null
)
GO
CREATE TABLE cusomter_security(
	custid	int not null,
	secuid	char(6) not null,
	secucount int not null
)
ALTER TABLE dbo.cusomter_security ADD CONSTRAINT
	PK_cusomter_security PRIMARY KEY CLUSTERED 
	(
	custid,
	secuid
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE TABLE orderlog(
	sno int primary key,
	secuid	char(6),
	secucount int,
	custid	int,
	price	money,
	secubalance int,
	custbalance money,
	stuffing binary(1024)
)
GO
SET NOCOUNT ON
GO
INSERT INTO snoorder VALUES (1, 20091226, 0);
DECLARE @custid INT
DECLARE @customer TABLE(
	custid	int not null,
	custbalance money not null
)
SET @custid = 1
WHILE @custid <= 100000
BEGIN
	INSERT INTO @customer VALUES(@custid, 0);
	SET @custid = @custid + 1
END
INSERT INTO customer SELECT * FROM @customer
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE nb_com_getsno
	@sno int output
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRANSACTION
	UPDATE snoorder SET lastsno = lastsno + 1 WHERE serverid = 1
	SELECT @sno = lastsno FROM snoorder
	COMMIT TRANSACTION
END
GO
CREATE PROCEDURE up_com_ordercall(
	@sno int,
	@secuid char(6),
	@secucount int,
	@custid	int,
	@price	money,
	@secubalance int output,
	@custbalance money output
)
AS
BEGIN
	DECLARE @Amount money
	SET @Amount = @secucount * @price
	
	BEGIN TRANSACTION
	IF EXISTS(SELECT 1 FROM cusomter_security WHERE custid = @custid AND secuid = @secuid)
		UPDATE cusomter_security SET secucount = secucount + @secucount WHERE custid = @custid AND secuid = @secuid
	ELSE
		INSERT INTO cusomter_security (custid, secuid, secucount) VALUES(@custid, @secuid, @secucount)
		
	SELECT @secubalance = secucount FROM cusomter_security WHERE custid = @custid AND secuid = @secuid
	
	UPDATE customer SET custbalance = custbalance + @price WHERE custid = @custid
	
	SELECT @custbalance = custbalance FROM customer WHERE custid = @custid
	COMMIT TRANSACTION	
END
GO
CREATE PROCEDURE WriteLog(
	@sno int,
	@secuid char(6),
	@secucount int,
	@custid	int,
	@price	money, 
	@secubalance int,
	@custbalance money
)
AS
BEGIN
INSERT INTO orderlog
                      (sno, secuid, secucount, custid, price, secubalance, custbalance, stuffing)
VALUES     (@sno,@secuid,@secucount,@custid,@price,@secubalance,@custbalance, CONVERT(BINARY(1024), REPLICATE(N' ', 1000)))
END
GO
CREATE PROCEDURE SecTranSim
AS
BEGIN
	declare @sno int,
	@secuid char(6),
	@secucount int,
	@custid	int,
	@price	money, 
	@secubalance int,
	@custbalance money
	
	SET @custid = FLOOR(RAND() * 10000 + 1)
	SET @secucount = FLOOR(RAND(@custid) * 100 + 1)
	SET @price = RAND(@secucount) * 50 
	SET @secuid = RIGHT('000000' + CONVERT(VARCHAR(6), FLOOR(RAND(@custid + @secucount) * 100000 + 1)), 6)
	SET NOCOUNT ON
	EXEC nb_com_getsno @sno output
	EXEC up_com_ordercall @sno, @secuid, @secucount, @custid, @price, @secubalance OUTPUT, @custbalance OUTPUT
	EXEC WriteLog @sno, @secuid, @secucount, @custid, @price, @secubalance, @custbalance 
END


