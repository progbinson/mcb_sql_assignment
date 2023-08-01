-- Develop a SQL procedure to trigger a migration process that will extract information from table
-- "XXBCM_ORDER_MGT" and load them in tables that you created with proper data format.
IF OBJECT_ID('prcMigration') IS NOT NULL
BEGIN
	DROP PROCEDURE prcMigration
END
GO

CREATE PROCEDURE prcMigration
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY

		-- Deleting all the entries from the tables
		DELETE FROM tblBCM_INVOICES
		DELETE FROM tblBCM_ORDER_LINES
		DELETE FROM tblBCM_ORDERS
		DELETE FROM tblBCM_SUPPLIERS
		
		-- Inserting the suppliers
		INSERT INTO tblBCM_SUPPLIERS
		(
			 SUPPLIER_NAME
			,SUPPLIER_CONTACT_NAME
			,SUPPLIER_ADDRESS
			,SUPPLIER_CONTACT_NUMBER1
			,SUPPLIER_CONTACT_NUMBER2
			,SUPPLIER_EMAIL
		)
		SELECT DISTINCT
			SUPPLIER_NAME
		   ,SUPP_CONTACT_NAME
		   ,SUPP_ADDRESS
		   ,[dbo].[fn_CleanNumericValue](TRIM(PhoneNumber1))
		   ,[dbo].[fn_CleanNumericValue](TRIM(PhoneNumber2))
		   ,SUPP_EMAIL
		FROM XXBCM_ORDER_MGT
		CROSS APPLY [dbo].[fn_SplitPhoneNumbers](SUPP_CONTACT_NUMBER)

        -- Inserting orders
        INSERT INTO tblBCM_ORDERS
		(
			ORDER_REF
		   ,SUPPLIER_ID
		   ,ORDER_DATE
		   ,ORDER_TOTAL_AMOUNT
		   ,ORDER_STATUS
		)
		SELECT DISTINCT
			LEFT(ORDER_REF, CHARINDEX('-', tblMGT.ORDER_REF + '-') - 1)
		   ,tblSUPP.SUPPLIER_ID
		   ,CONVERT(DATE, tblMGT.ORDER_DATE, 105)
		   ,CONVERT(NUMERIC(10,2),[dbo].[fn_CleanNumericValue](tblMGT.ORDER_TOTAL_AMOUNT))
		   ,tblMGT.ORDER_STATUS
		FROM XXBCM_ORDER_MGT tblMGT
		LEFT JOIN tblBCM_SUPPLIERS tblSUPP
		ON tblMGT.SUPPLIER_NAME = tblSUPP.SUPPLIER_NAME
		WHERE CHARINDEX('-', tblMGT.ORDER_REF) = 0

		-- Inserting the order lines
		INSERT INTO tblBCM_ORDER_LINES
		(
			ORDER_REF
		   ,ORDER_LINE_NUMBER
		   ,ORDER_DESCRIPTION
		   ,ORDER_STATUS
		   ,ORDER_LINE_AMOUNT
		)
		SELECT
			LEFT(ORDER_REF, CHARINDEX('-', ORDER_REF + '-') - 1)
		   ,CONVERT(INTEGER, SUBSTRING(ORDER_REF, CHARINDEX('-', ORDER_REF) + 1, LEN(ORDER_REF)))
		   ,ORDER_DESCRIPTION
		   ,ORDER_STATUS
		   ,CONVERT(NUMERIC(10,2),[dbo].[fn_CleanNumericValue](ORDER_LINE_AMOUNT))
		FROM XXBCM_ORDER_MGT
		WHERE CHARINDEX('-', ORDER_REF) > 0

		-- Inserting the invoice lines
		INSERT INTO tblBCM_INVOICES
		(
			INVOICE_REFERENCE
		   ,INVOICE_DATE
		   ,ORDER_REF
		   ,INVOICE_STATUS
		   ,INVOICE_HOLD_REASON
		   ,INVOICE_AMOUNT
		   ,INVOICE_DESCRIPTION
		)
		SELECT
			INVOICE_REFERENCE
		   ,CONVERT(DATE, INVOICE_DATE, 105)
		   ,LEFT(ORDER_REF, CHARINDEX('-', ORDER_REF + '-') - 1)
		   ,INVOICE_STATUS
		   ,INVOICE_HOLD_REASON
		   ,CONVERT(NUMERIC(10,2),[dbo].[fn_CleanNumericValue](INVOICE_AMOUNT))
		   ,INVOICE_DESCRIPTION
		FROM XXBCM_ORDER_MGT
		WHERE INVOICE_REFERENCE IS NOT NULL

    END TRY
    BEGIN CATCH
        -- Error handling
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        THROW
    END CATCH
END

GO
