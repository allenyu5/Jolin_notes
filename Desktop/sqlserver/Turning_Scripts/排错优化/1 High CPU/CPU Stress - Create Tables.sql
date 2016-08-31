USE [AdventureWorks2012]
GO

CREATE TABLE [dbo].[tblUserAccounts](
	[AccountID] [int] NULL,
	[AccountStatus] [bit] NULL,
	[UserName] [nvarchar](75) NULL
) ON [PRIMARY]
GO

CREATE FUNCTION [dbo].[ufnGetAccountStatus](@User nvarchar(256))
RETURNS bit 
AS 
BEGIN
    DECLARE @Status bit;

    SELECT @Status = AccountStatus
    FROM tblUserAccounts U 
    WHERE rtrim(U.UserName) = @User;

    RETURN @Status;
END;

GO

INSERT INTO tblUserAccounts 
SELECT ContactID, CASE WHEN EmailPromotion > 0 THEN 1 ELSE 0 END, 
REPLACE(EmailAddress, '@adventure-works.com', '')
FROM Person.Contact
GO

CREATE NONCLUSTERED INDEX NCL_UserAccts_UserName ON dbo.tblUserAccounts
(
	UserName ASC
)
INCLUDE (AccountID) 
GO




