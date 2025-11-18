/**
 * @summary
 * Creates a stock adjustment movement and updates the product's stock balance.
 * 
 * @procedure spStockMovementCreateAdjustment
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - POST /api/v1/internal/stock-movement/adjustment
 * 
 * @parameters
 * @param {INT} idAccount - Account identifier
 * @param {INT} idUser - User identifier performing the action
 * @param {INT} idProduct - Product identifier
 * @param {NUMERIC(15, 4)} newQuantity - The new, correct quantity for the stock
 * @param {NVARCHAR(500)} reason - Justification for the adjustment
 * @param {NVARCHAR(30)} lot - Lot number, if applicable
 */
CREATE OR ALTER PROCEDURE [functional].[spStockMovementCreateAdjustment]
    @idAccount INT,
    @idUser INT,
    @idProduct INT,
    @newQuantity NUMERIC(15, 4),
    @reason NVARCHAR(500),
    @lot NVARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @currentQuantity NUMERIC(15, 4);
    DECLARE @quantityDifference NUMERIC(15, 4);

    SELECT @currentQuantity = [quantity]
    FROM [functional].[stockBalance]
    WHERE [idAccount] = @idAccount AND [idProduct] = @idProduct;

    IF @currentQuantity IS NULL
    BEGIN
        ;THROW 51000, 'ProductNotFound', 1;
    END

    SET @quantityDifference = @newQuantity - @currentQuantity;

    BEGIN TRY
        BEGIN TRAN;

        UPDATE [functional].[stockBalance]
        SET 
            [quantity] = @newQuantity,
            [lastUpdated] = GETUTCDATE()
        WHERE [idAccount] = @idAccount AND [idProduct] = @idProduct;

        INSERT INTO [functional].[stockMovement] 
            ([idAccount], [idUser], [idProduct], [type], [quantity], [quantityBefore], [reason], [lot])
        VALUES 
            (@idAccount, @idUser, @idProduct, 'AJUSTE', @quantityDifference, @currentQuantity, @reason, @lot);

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;
        ;THROW;
    END CATCH
END;
GO
