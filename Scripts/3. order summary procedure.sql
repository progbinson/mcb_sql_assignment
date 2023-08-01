-- The owner wishes to have a report displaying a summary of Orders with their corresponding list of
-- distinct invoices and their total amount to be able to reconcile his orders and payments. The report
-- shall contain the details ordered by latest Order Date on top.
IF OBJECT_ID('prcOrderSummary') IS NOT NULL
BEGIN
	DROP PROCEDURE prcOrderSummary
END
GO

CREATE PROCEDURE prcOrderSummary
AS
BEGIN
    SET NOCOUNT ON;
		
    BEGIN TRY
		    
		CREATE TABLE #tblTempSummary
		(
			 ORDER_REF				VARCHAR(10)
			,ORDER_NUMBER			INT
			,ORDER_DATE				DATE
			,ORDER_PERIOD			VARCHAR(8)
			,SUPPLIER_NAME			VARCHAR(100)
			,ORDER_TOTAL_AMOUNT		VARCHAR(12)
			,ORDER_STATUS			VARCHAR(6)
			,INVOICE_REFERENCE		VARCHAR(15)
			,INVOICE_TOTAL_AMOUNT	VARCHAR(12)
			,ACTION					VARCHAR(12)
		)

		INSERT INTO #tblTempSummary
		(
			 ORDER_REF
			,ORDER_NUMBER	
			,ORDER_DATE
			,ORDER_PERIOD		
			,SUPPLIER_NAME		
			,ORDER_TOTAL_AMOUNT	
			,ORDER_STATUS		
			,INVOICE_REFERENCE	
			,INVOICE_TOTAL_AMOUNT	
		)
		SELECT DISTINCT  tblORDERS.ORDER_REF
						-- Get only the numeric value for the ORDER_REF
						,CAST(SUBSTRING(tblORDERS.ORDER_REF, 3, LEN(tblORDERS.ORDER_REF) - 2) AS INT) AS ORDER_NUMBER
						,tblORDERS.ORDER_DATE
						,UPPER(FORMAT(tblORDERS.ORDER_DATE, 'MMM-yyyy')) AS ORDER_PERIOD
						-- Capitalize the first letter in every word in the supplier name
						,[dbo].[fn_CapitalizeWords](tblSUPP.SUPPLIER_NAME)
						,FORMAT(tblORDERS.ORDER_TOTAL_AMOUNT, 'N2') AS ORDER_TOTAL_AMOUNT
						,tblORDERS.ORDER_STATUS
						,SUBSTRING(tblINVOICES.INVOICE_REFERENCE, 0, CHARINDEX('.', tblINVOICES.INVOICE_REFERENCE + '.')) AS INVOICE_REFERENCE
						,FORMAT(SUM(tblINVOICES.INVOICE_AMOUNT), 'N2') AS INVOICE_TOTAL_AMOUNT
		FROM tblBCM_ORDERS tblORDERS
		INNER JOIN tblBCM_SUPPLIERS tblSUPP
		ON tblORDERS.SUPPLIER_ID = tblSUPP.SUPPLIER_ID
		INNER JOIN tblBCM_INVOICES tblINVOICES
		ON tblINVOICES.ORDER_REF = tblORDERS.ORDER_REF
		GROUP BY tblORDERS.ORDER_REF
				,tblORDERS.ORDER_DATE
				,tblSUPP.SUPPLIER_NAME
				,tblORDERS.ORDER_TOTAL_AMOUNT
				,tblORDERS.ORDER_STATUS
				,SUBSTRING(tblINVOICES.INVOICE_REFERENCE, 0, CHARINDEX('.', tblINVOICES.INVOICE_REFERENCE + '.'))
	

		UPDATE tblTemp
		SET tblTemp.ACTION = 'OK'
		FROM #tblTempSummary tblTemp
		WHERE NOT EXISTS(select top 1 1 
						 from	tblBCM_INVOICES tblInvoice 
						 where	tblInvoice.ORDER_REF = tblTemp.ORDER_REF 
						 and	tblInvoice.INVOICE_STATUS <> 'Paid')

		UPDATE tblTemp
		SET tblTemp.ACTION = 'To follow up'
		FROM #tblTempSummary tblTemp
		WHERE EXISTS(select top 1 1 
					 from	tblBCM_INVOICES tblInvoice 
					 where	tblInvoice.ORDER_REF = tblTemp.ORDER_REF 
					 and	tblInvoice.INVOICE_STATUS = 'Pending')

		UPDATE tblTemp
		SET tblTemp.ACTION = 'To verify'
		FROM #tblTempSummary tblTemp
		WHERE EXISTS(select top 1 1 
						 from	tblBCM_INVOICES tblInvoice 
						 where	tblInvoice.ORDER_REF = tblTemp.ORDER_REF 
						 and	ISNULL(tblInvoice.INVOICE_STATUS, '') = '')
    
		SELECT ORDER_NUMBER			
			  ,ORDER_PERIOD			
			  ,SUPPLIER_NAME			
			  ,ORDER_TOTAL_AMOUNT		
			  ,ORDER_STATUS			
			  ,INVOICE_REFERENCE		
			  ,INVOICE_TOTAL_AMOUNT	
			  ,ACTION		
		FROM #tblTempSummary
		ORDER BY ORDER_DATE

		IF OBJECT_ID('tempdb..#tblTempSummary') IS NOT NULL
		BEGIN
			DROP TABLE #tblTempSummary
		END

    END TRY
    BEGIN CATCH

	    IF OBJECT_ID('tempdb..#tblTempSummary') IS NOT NULL
		BEGIN
			DROP TABLE #tblTempSummary
		END

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        THROW;
    END CATCH
END