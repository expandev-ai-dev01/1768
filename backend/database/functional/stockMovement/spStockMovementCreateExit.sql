/**
 * @summary
 * Creates a stock exit movement and updates the product's stock balance.
 * 
 * @procedure spStockMovementCreateExit
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - POST /api/v1/internal/stock-movement/exit
 * 
 * @parameters
 * @param {INT} idAccount - Account identifier
 * @param {INT} idUser - User identifier performing the action
 * @param {INT} idProduct - Product identifier
 * @param {NUMERIC(15, 4)} quantity - Quantity to remove
 * @param {NVARCHAR(500)} reason - Reason for the exit
 * @param {BIT} allowNegativeStock - Flag to allow negative stock
 * @param {NVARCHAR(50)} referenceDocument - Reference document
 * @param {NVARCHAR(100)} destination - Destination of the product
 * @param {NVARCHAR(30)} lot - Lot number
 */
CREATE OR ALTER PROCEDURE [functional].[spStockMovementCreateExit]
    @idAccount INT,
    @idUser INT,
    @idProduct INT,
    @quantity NUMERIC(15, 4),
    @reason NVARCHAR(500),
    @allowNegativeStock BIT = 0,
    @referenceDocument NVARCHAR(50) = NULL,
    @destination NVARCHAR(100) = NULL,
    @lot NVARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @currentQuantity NUMERIC(15, 4);

    SELECT @currentQuantity = [quantity]
    FROM [functional].[stockBalance]
    WHERE [idAccount] = @idAccount AND [idProduct] = @idProduct;

    IF @currentQuantity IS NULL
    BEGIN
        ;THROW 51000, 'ProductNotFound', 1;
    END

    IF @allowNegativeStock = 0 AND (@currentQuantity < @quantity)
    BEGIN
        ;THROW 51000, 'InsufficientStock', 1;
    END

    BEGIN TRY
        BEGIN TRAN;

        UPDATE [functional].[stockBalance]
        SET 
            [quantity] = [quantity] - @quantity,
            [lastUpdated] = GETUTCDATE()
        WHERE [idAccount] = @idAccount AND [idProduct] = @idProduct;

        INSERT INTO [functional].[stockMovement] 
            ([idAccount], [idUser], [idProduct], [type], [quantity], [reason], [referenceDocument], [destination], [lot])
        VALUES 
            (@idAccount, @idUser, @idProduct, 'SAIDA', @quantity, @reason, @referenceDocument, @destination, @lot);

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;
        ;THROW;
    END CATCH
END;
GO
