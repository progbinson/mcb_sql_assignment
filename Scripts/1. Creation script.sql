----------------------
-- Creating the tables
----------------------

-- All the tables are created at the same time, so all tables are dropped if one exists
IF OBJECT_ID('tblBCM_SUPPLIERS', 'U') IS NOT NULL
BEGIN
	-- Tables have to be droped int his specific order because of the keys 
	DROP TABLE tblBCM_INVOICES
	DROP TABLE tblBCM_ORDER_LINES
	DROP TABLE tblBCM_ORDERS
	DROP TABLE tblBCM_SUPPLIERS
END

-- Suppliers table
CREATE TABLE tblBCM_SUPPLIERS
(
	SUPPLIER_ID					INT IDENTITY	NOT NULL
   ,SUPPLIER_NAME				VARCHAR(22)		NOT NULL
   ,SUPPLIER_CONTACT_NAME		VARCHAR(17)		NOT NULL
   ,SUPPLIER_ADDRESS			VARCHAR(58)		NOT NULL
   ,SUPPLIER_CONTACT_NUMBER1	VARCHAR(9)		NOT NULL
   ,SUPPLIER_CONTACT_NUMBER2	VARCHAR(9)		NULL
   ,SUPPLIER_EMAIL				VARCHAR(30)		NOT NULL
   ,CONSTRAINT SUPPLIERS_PK	PRIMARY KEY(SUPPLIER_ID)
)

-- Orders table
CREATE TABLE tblBCM_ORDERS
(
	ORDER_ID			INT	IDENTITY	NOT NULL
   ,SUPPLIER_ID			INT				NOT NULL
   ,ORDER_REF			VARCHAR(7)		NOT NULL
   ,ORDER_DATE			DATE			NOT NULL
   ,ORDER_TOTAL_AMOUNT	NUMERIC(10,2)	NULL
   ,ORDER_STATUS		VARCHAR(9)		NOT NULL
   ,CONSTRAINT ORDERS_PK   PRIMARY KEY(ORDER_ID)
   ,CONSTRAINT ORDERS_UK01 UNIQUE(ORDER_REF)
   ,CONSTRAINT ORDER_FK01  FOREIGN KEY(SUPPLIER_ID) REFERENCES tblBCM_SUPPLIERS(SUPPLIER_ID)
   ,CONSTRAINT ORDERS_C01  CHECK (ORDER_STATUS IN ('Closed','Open'))
)

-- Order lines table
CREATE TABLE tblBCM_ORDER_LINES
(
	ORDER_LINE_ID		INTEGER IDENTITY	NOT NULL
   ,ORDER_REF			VARCHAR(7)			NOT NULL
   ,ORDER_LINE_NUMBER	INT         		NOT NULL
   ,ORDER_DESCRIPTION	VARCHAR(2000)		NOT NULL
   ,ORDER_STATUS		VARCHAR(9)			NOT NULL
   ,ORDER_LINE_AMOUNT	VARCHAR(15)			NULL
   ,CONSTRAINT ORDER_LINES_PK  PRIMARY KEY(ORDER_LINE_ID)
   ,CONSTRAINT ORDER_LINES_FK  FOREIGN KEY (ORDER_REF) REFERENCES tblBCM_ORDERS(ORDER_REF)
   ,CONSTRAINT ORDER_LINES_C01 CHECK (ORDER_STATUS IN ('Cancelled', 'Received'))
)

-- Invoices table
CREATE TABLE tblBCM_INVOICES
(
	INVOICE_LINE_ID		INT IDENTITY	NOT NULL
   ,INVOICE_REFERENCE	VARCHAR(11)		NOT NULL
   ,ORDER_REF			VARCHAR(7)		NOT NULL
   ,INVOICE_DATE		DATE			NOT NULL
   ,INVOICE_STATUS		VARCHAR(7)		NULL
   ,INVOICE_HOLD_REASON VARCHAR(36)		NULL
   ,INVOICE_AMOUNT		NUMERIC(10,2)	NOT NULL
   ,INVOICE_DESCRIPTION VARCHAR(40)		NULL
   ,CONSTRAINT INVOICES_PK  PRIMARY KEY(INVOICE_LINE_ID)
   ,CONSTRAINT INVOICES_FK  FOREIGN KEY (ORDER_REF) REFERENCES tblBCM_ORDERS(ORDER_REF)
   ,CONSTRAINT INVOICES_C01 CHECK (INVOICE_STATUS IN ('Paid','Pending'))
)

GO

---------------------
-- Creating functions
---------------------
-- Function to clean numeric values (replacing letters with appropriate numbers)
IF OBJECT_ID('fn_CleanNumericValue', 'FN') IS NOT NULL
BEGIN
	DROP FUNCTION fn_CleanNumericValue
END
GO

CREATE FUNCTION fn_CleanNumericValue(@value VARCHAR(12))
RETURNS VARCHAR(8)
AS
BEGIN
    SET @value = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE
										(@value, ',', '' )
											   , 'o', '0')
											   , 'S', '5')
											   , 'I', '1')
											   , 'l', '1')
											   , ' ', '' )
											   , '.', '' )
    RETURN @value
END
GO

-- Function to split phone numbers which come in the form ('XXX XXXX, YYYYYYY')
IF OBJECT_ID('fn_SplitPhoneNumbers') IS NOT NULL
BEGIN
	DROP FUNCTION fn_SplitPhoneNumbers
END
GO

CREATE FUNCTION fn_SplitPhoneNumbers (@combinedNumbers VARCHAR(100))
RETURNS @PhoneNumbers TABLE (
    PhoneNumber1 VARCHAR(50),
    PhoneNumber2 VARCHAR(50)
)
AS
BEGIN
    DECLARE @Index INT
    SET @Index = CHARINDEX(',', @combinedNumbers)

    INSERT INTO @PhoneNumbers (PhoneNumber1, PhoneNumber2)
    VALUES (
        SUBSTRING(@combinedNumbers, 1, CASE WHEN @Index > 0 THEN @Index - 1 ELSE LEN(@combinedNumbers) END),
        CASE WHEN @Index > 0 THEN SUBSTRING(@combinedNumbers, @Index + 1, LEN(@combinedNumbers) - @Index) ELSE NULL END
    )

    RETURN
END
GO

-- Function to capitalize words
IF OBJECT_ID('fn_CapitalizeWords') IS NOT NULL
BEGIN
	DROP FUNCTION fn_CapitalizeWords
END
GO

CREATE FUNCTION fn_CapitalizeWords (@inputString NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @outputString NVARCHAR(MAX);

    SELECT @outputString = STRING_AGG(
                            UPPER(LEFT(value, 1)) + LOWER(SUBSTRING(value, 2, LEN(value))),
                            ' '
                          )
    FROM STRING_SPLIT(@inputString, ' ');

    RETURN @outputString;
END
GO
