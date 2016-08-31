USE [AdventureWorks2012]
GO

CREATE TABLE [dbo].[DeadlockDemoNames](
                [PK_deadlocknames] [int] NULL,
                [Name] [nchar](10) NULL
) ON [PRIMARY]

GO

Insert DeadlockDemoNames
values   (1, 'bob'),(2,'John')

CREATE TABLE [dbo].[DeadlockDemoAddress](
                [PK_deadlockaddress] [int] NULL,
                [Address] [nchar](10) NULL
) ON [PRIMARY]

GO

Insert DeadlockDemoAddress
values   (1, '1111'),(2,'2222')
GO
