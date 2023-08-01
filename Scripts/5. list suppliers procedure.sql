-- List all suppliers with their respective number of orders and total amount ordered from them
-- between the period of 01 January 2022 and 31 August 2022. Output details as per below. Implement
-- a Stored Procedure or Function to return the required information.
IF OBJECT_ID('prcSupplierList') IS NOT NULL
BEGIN
	DROP PROCEDURE prcSupplierList
END
GO

CREATE PROCEDURE prcSupplierList
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY

		SELECT   tblSupp.SUPPLIER_NAME
				,tblSupp.SUPPLIER_CONTACT_NAME
				-- Contact numbers in the format XXX-XXXX or 5XXX-XXXX
				,STUFF(tblSupp.SUPPLIER_CONTACT_NUMBER1, LEN(tblSupp.SUPPLIER_CONTACT_NUMBER1) - 3, 0, '-') AS SUPPLIER_CONTACT_NUMBER1 
				,STUFF(tblSupp.SUPPLIER_CONTACT_NUMBER2, LEN(tblSupp.SUPPLIER_CONTACT_NUMBER2) - 3, 0, '-') AS SUPPLIER_CONTACT_NUMBER2
				,COUNT(tblOrders.ORDER_REF) AS TOTAL_ORDERS
				,SUM(tblOrders.ORDER_TOTAL_AMOUNT) AS ORDER_TOTAL_AMOUNT
		FROM tblBCM_SUPPLIERS tblSupp
		INNER JOIN tblBCM_ORDERS tblOrders
		ON tblSupp.SUPPLIER_ID = tblORDERS.SUPPLIER_ID
		WHERE tblORDERS.ORDER_DATE BETWEEN '2022-01-01' AND '2022-08-31'
		GROUP BY tblSupp.SUPPLIER_NAME
				,tblSupp.SUPPLIER_ID
				,tblSupp.SUPPLIER_CONTACT_NAME
				,tblSupp.SUPPLIER_CONTACT_NUMBER1
				,tblSupp.SUPPLIER_CONTACT_NUMBER2

    END TRY
    BEGIN CATCH
        -- Error handling code goes here
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        THROW;
    END CATCH
END