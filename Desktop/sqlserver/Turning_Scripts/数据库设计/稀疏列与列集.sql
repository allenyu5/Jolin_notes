USE tempdb
GO

--Step 1: Create demo table with sparse columns.
CREATE TABLE Products
(
	ID int IDENTITY(1,1) NOT NULL,
	Name nvarchar(200) NOT NULL,
	ManufactoryDate date SPARSE NULL,
	ManufactoryTime time SPARSE NULL,
	Color varchar(20) SPARSE NULL,
	Size varchar(5) SPARSE NULL,
	Style varchar(10) SPARSE NULL,
	Height float SPARSE NULL,
	Wight float SPARSE NULL,
	[Length] float SPARSE NULL,
CONSTRAINT PK_Products PRIMARY KEY (ID)
)
GO
--Step 2: Insert data into the demo table.
INSERT INTO Products (Name, ManufactoryDate)
	VALUES ('Boca Bora', '2008-1-1')
INSERT INTO Products (Name, ManufactoryDate)
	VALUES ('Boca Bora', '2008-1-2')
INSERT INTO Products (Name, ManufactoryDate)
	VALUES ('Boca Bora', '2008-1-3')

INSERT INTO Products (Name, ManufactoryDate, ManufactoryTime)
	VALUES ('Bark Milk', '2008-1-1', '12:00:00')
INSERT INTO Products (Name, ManufactoryDate, ManufactoryTime)
	VALUES ('Dark Milk', '2008-1-1', '12:30:00')
INSERT INTO Products (Name, ManufactoryDate, ManufactoryTime)
	VALUES ('Dark Milk', '2008-1-1', '13:00:00')

INSERT INTO Products (Name, Color, Size)
	VALUES ('Ipupes', 'White', '41')
INSERT INTO Products (Name, Color, Size)
	VALUES ('Ipupes', 'Black', '41')
INSERT INTO Products (Name, Color, Size)
	VALUES ('Ipupes', 'Silver', '41')

--Step 3: Get data from the demo table.
SELECT * FROM Products

--Step 4: Create the demo table again with column set.
DROP TABLE Products
GO
CREATE TABLE Products
(
	ID int IDENTITY(1,1) NOT NULL,
	Name nvarchar(200) NOT NULL,
	ManufactoryDate date SPARSE NULL,
	ManufactoryTime time SPARSE NULL,
	Color varchar(20) SPARSE NULL,
	Size varchar(5) SPARSE NULL,
	Style varchar(10) SPARSE NULL,
	Height float SPARSE NULL,
	Wight float SPARSE NULL,
	[Length] float SPARSE NULL,
	ProductAttributes XML COLUMN_SET FOR ALL_SPARSE_COLUMNS,
CONSTRAINT PK_Products PRIMARY KEY (ID)
)
GO

--Step 5: Insert data into the demo table.
----------Notice the usage of column set.
INSERT INTO Products (Name, ManufactoryDate)
	VALUES ('Boca Bora', '2008-1-1')
INSERT INTO Products (Name, ProductAttributes)
	VALUES ('Boca Bora', '<ManufactoryDate>2008-1-2</ManufactoryDate>')
INSERT INTO Products (Name, ProductAttributes)
	VALUES ('Boca Bora', '<ManufactoryDate>2008-1-3</ManufactoryDate>')

INSERT INTO Products (Name, ManufactoryDate, ManufactoryTime)
	VALUES ('Bark Milk', '2008-1-1', '12:00:00')
INSERT INTO Products (Name, ProductAttributes)
	VALUES ('Dark Milk', '<ManufactoryDate>2008-1-1</ManufactoryDate>
							<ManufactoryTime>12:30:00</ManufactoryTime>')
INSERT INTO Products (Name, ProductAttributes)
	VALUES ('Dark Milk', '<ManufactoryDate>2008-1-1</ManufactoryDate>
							<ManufactoryTime>13:00:00</ManufactoryTime>')

INSERT INTO Products (Name, Color, Size)
	VALUES ('Ipupes', 'White', '41')
INSERT INTO Products (Name, ProductAttributes)
	VALUES ('Ipupes', '<Color>Black</Color><Size>41</Size>')
INSERT INTO Products (Name, ProductAttributes)
	VALUES ('Ipupes', '<Color>Silver</Color><Size>41</Size>')

--Step 6: Demo how to get data from the demo table
----------and update the data.
SELECT * FROM Products
SELECT ID, Name, ManufactoryDate, ManufactoryTime FROM Products
SELECT ID, Name, Size FROM Products  WHERE Color = 'White'

UPDATE Products SET Size = 42 WHERE ID = 8
SELECT * FROM Products
UPDATE Products SET ProductAttributes = '<Color>Red</Color><Size>41</Size>'
	WHERE ID = 9
SELECT * FROM Products