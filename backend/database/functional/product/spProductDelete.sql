/**
 * @summary
 * Logically deletes a product by setting its 'deleted' flag to 1.
 * 
 * @procedure spProductDelete
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - DELETE /api/v1/internal/product/:id
 * 
 * @parameters
 * @param {INT} idAccount - Account identifier
 * @param {INT} idUser - User identifier performing the action
 * @param {INT} idProduct - The ID of the product to delete
 * @param {NVARCHAR(500)} reason - Justification for deletion
 */
CREATE OR ALTER PROCEDURE [functional].[spProductDelete]
    @idAccount INT,
    @idUser INT,
    @idProduct INT,
    @reason NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @currentStock NUMERIC(15, 4);

    SELECT @currentStock = [quantity]
    FROM [functional].[stockBalance]
    WHERE [idAccount] = @idAccount AND [idProduct] = @idProduct;

    IF @currentStock IS NULL
    BEGIN
        ;THROW 51000, 'ProductNotFound', 1;
    END

    BEGIN TRY
        BEGIN TRAN;

        UPDATE [functional].[product]
        SET [deleted] = 1
        WHERE [idAccount] = @idAccount AND [idProduct] = @idProduct AND [deleted] = 0;

        IF @@ROWCOUNT = 0
        BEGIN
            ;THROW 51000, 'ProductNotFoundOrAlreadyDeleted', 1;
        END

        INSERT INTO [functional].[stockMovement] ([idAccount], [idUser], [idProduct], [type], [quantity], [quantityBefore], [reason])
        VALUES (@idAccount, @idUser, @idProduct, 'EXCLUSAO', 0, @currentStock, @reason);

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;
        ;THROW;
    END CATCH
END;
GO
