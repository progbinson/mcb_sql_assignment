-- Return details for the SECOND (2nd) highest Order Total Amount from the list. Only one record is
-- expected with the following information. Implement a Stored Procedure or Function to return the
-- required information.
IF OBJECT_ID('prcSecondTotal') IS NOT NULL
BEGIN
	DROP PROCEDURE prcSecondTotal
END
GO

CREATE PROCEDURE prcSecondTotal
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
		
		CREATE TABLE #tblTempTotal
		(
			 ORDER_REF				VARCHAR(10)
			,ORDER_NUMBER			INT
			,ORDER_DATE				VARCHAR(100)
			,SUPPLIER_NAME			VARCHAR(100)
			,ORDER_TOTAL_AMOUNT		VARCHAR(12)
			,ORDER_TOTAL_AMOUNT_NUM	NUMERIC(10,2)
			,ORDER_STATUS			VARCHAR(6)
			,INVOICE_REFERENCES		VARCHAR(2000)
		)

		INSERT INTO #tblTempTotal
		(
			 ORDER_REF			
			,ORDER_NUMBER		
			,ORDER_DATE			
			,SUPPLIER_NAME		
			,ORDER_TOTAL_AMOUNT
			,ORDER_TOTAL_AMOUNT_NUM
			,ORDER_STATUS		
			,INVOICE_REFERENCES
		)
		SELECT DISTINCT  tblORDERS.ORDER_REF
						-- ORDER_REF formatting (e.g. PO001 becomes 1)
						,CAST(SUBSTRING(tblORDERS.ORDER_REF, 3, LEN(tblORDERS.ORDER_REF) - 2) AS INT) AS ORDER_NUMBER
						-- Date in the format (e.g. January 01, 2022)
						,FORMAT(tblORDERS.ORDER_DATE, 'MMMM dd, yyyy') AS ORDER_DATE
						,UPPER(tblSUPP.SUPPLIER_NAME) SUPPLIER_NAME
						,FORMAT(tblORDERS.ORDER_TOTAL_AMOUNT, 'N2') AS ORDER_TOTAL_AMOUNT
						,tblORDERS.ORDER_TOTAL_AMOUNT
						,tblORDERS.ORDER_STATUS
						-- Invoice reference formatting (e.g. PO001 | PO002)
						,STRING_AGG(tblINVOICES.INVOICE_REFERENCE, ' | ') WITHIN GROUP (ORDER BY tblINVOICES.INVOICE_REFERENCE) AS INVOICE_REFERENCES
		FROM tblBCM_ORDERS tblORDERS
		INNER JOIN tblBCM_SUPPLIERS tblSUPP
		ON tblORDERS.SUPPLIER_ID = tblSUPP.SUPPLIER_ID
		INNER JOIN (SELECT DISTINCT INVOICE_REFERENCE
								   ,ORDER_REF 
					FROM tblBCM_INVOICES) tblINVOICES
		ON tblINVOICES.ORDER_REF = tblORDERS.ORDER_REF
		GROUP BY tblORDERS.ORDER_REF
				,tblORDERS.ORDER_DATE
				,tblSUPP.SUPPLIER_NAME
				,tblORDERS.ORDER_TOTAL_AMOUNT
				,tblORDERS.ORDER_STATUS
				,SUBSTRING(tblINVOICES.INVOICE_REFERENCE, 0, CHARINDEX('.', tblINVOICES.INVOICE_REFERENCE + '.'))
		
		-- Select required datat for second greatest total amount
		SELECT ORDER_NUMBER		
			  ,ORDER_DATE			
			  ,SUPPLIER_NAME		
			  ,ORDER_TOTAL_AMOUNT
			  ,ORDER_STATUS		
			  ,INVOICE_REFERENCES
		FROM (select *, 
					 rank() over (order by ORDER_TOTAL_AMOUNT_NUM desc) AS TOTAL_RANK 
			  from #tblTempTotal) tblTemp 
		WHERE tblTemp.TOTAL_RANK = 2
		
		IF OBJECT_ID('tempdb..#tblTempTotal') IS NOT NULL
		BEGIN
			DROP TABLE #tblTempTotal
		END

    END TRY
    BEGIN CATCH
        -- Error handling 
		IF OBJECT_ID('tempdb..#tblTempTotal') IS NOT NULL
		BEGIN
			DROP TABLE #tblTempTotal
		END

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        THROW;
    END CATCH
END