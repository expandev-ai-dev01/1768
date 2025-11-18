/**
 * @summary
 * Creates a stock entry movement and updates the product's stock balance.
 * 
 * @procedure spStockMovementCreateEntry
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - POST /api/v1/internal/stock-movement/entry
 * 
 * @parameters
 * @param {INT} idAccount - Account identifier
 * @param {INT} idUser - User identifier performing the action
 * @param {INT} idProduct - Product identifier
 * @param {NUMERIC(15, 4)} quantity - Quantity to add
 * @param {INT} idSupplier - Supplier identifier
 * @param {NVARCHAR(500)} reason - Reason for the entry
 * @param {NVARCHAR(50)} referenceDocument - Reference document (e.g., invoice number)
 * @param {NVARCHAR(30)} lot - Lot number
 * @param {DATE} expirationDate - Expiration date
 */
CREATE OR ALTER PROCEDURE [functional].[spStockMovementCreateEntry]
    @idAccount INT,
    @idUser INT,
    @idProduct INT,
    @quantity NUMERIC(15, 4),
    @idSupplier INT = NULL,
    @reason NVARCHAR(500) = NULL,
    @referenceDocument NVARCHAR(50) = NULL,
    @lot NVARCHAR(30) = NULL,
    @expirationDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM [functional].[product] WHERE [idProduct] = @idProduct AND [idAccount] = @idAccount AND [deleted] = 0)
    BEGIN
        ;THROW 51000, 'ProductNotFound', 1;
    END

    IF @idSupplier IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [functional].[supplier] WHERE [idSupplier] = @idSupplier AND [idAccount] = @idAccount)
    BEGIN
        ;THROW 51000, 'SupplierNotFound', 1;
    END

    BEGIN TRY
        BEGIN TRAN;

        UPDATE [functional].[stockBalance]
        SET 
            [quantity] = [quantity] + @quantity,
            [lastUpdated] = GETUTCDATE()
        WHERE [idAccount] = @idAccount AND [idProduct] = @idProduct;

        INSERT INTO [functional].[stockMovement] 
            ([idAccount], [idUser], [idProduct], [idSupplier], [type], [quantity], [reason], [referenceDocument], [lot], [expirationDate])
        VALUES 
            (@idAccount, @idUser, @idProduct, @idSupplier, 'ENTRADA', @quantity, @reason, @referenceDocument, @lot, @expirationDate);

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;
        ;THROW;
    END CATCH
END;
GO
