/**
 * @summary
 * Creates a new product and its initial stock movement.
 * 
 * @procedure spProductCreate
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - POST /api/v1/internal/product
 * 
 * @parameters
 * @param {INT} idAccount - Account identifier
 * @param {INT} idUser - User identifier performing the action
 * @param {INT} idCategory - Category identifier
 * @param {INT} idUnitOfMeasure - Unit of measure identifier
 * @param {VARCHAR(20)} code - Unique product code
 * @param {NVARCHAR(100)} name - Product name
 * @param {NVARCHAR(500)} description - Product description
 * @param {NUMERIC(15, 4)} minimumStock - Minimum stock level
 * 
 * @returns {TABLE} The newly created product record.
 */
CREATE OR ALTER PROCEDURE [functional].[spProductCreate]
    @idAccount INT,
    @idUser INT,
    @idCategory INT,
    @idUnitOfMeasure INT,
    @code VARCHAR(20),
    @name NVARCHAR(100),
    @description NVARCHAR(500) = NULL,
    @minimumStock NUMERIC(15, 4) = 0
AS
BEGIN
    SET NOCOUNT ON;

    -- Validation
    IF NOT EXISTS (SELECT 1 FROM [functional].[category] WHERE [idCategory] = @idCategory AND [idAccount] = @idAccount)
    BEGIN
        ;THROW 51000, 'CategoryNotFound', 1;
    END

    IF NOT EXISTS (SELECT 1 FROM [functional].[unitOfMeasure] WHERE [idUnitOfMeasure] = @idUnitOfMeasure AND [idAccount] = @idAccount)
    BEGIN
        ;THROW 51000, 'UnitOfMeasureNotFound', 1;
    END

    IF EXISTS (SELECT 1 FROM [functional].[product] WHERE [code] = @code AND [idAccount] = @idAccount AND [deleted] = 0)
    BEGIN
        ;THROW 51000, 'ProductCodeAlreadyExists', 1;
    END

    BEGIN TRY
        BEGIN TRAN;

        DECLARE @newProductId INT;

        INSERT INTO [functional].[product] ([idAccount], [idCategory], [idUnitOfMeasure], [code], [name], [description], [minimumStock])
        VALUES (@idAccount, @idCategory, @idUnitOfMeasure, @code, @name, @description, @minimumStock);

        SET @newProductId = SCOPE_IDENTITY();

        INSERT INTO [functional].[stockBalance] ([idAccount], [idProduct], [quantity])
        VALUES (@idAccount, @newProductId, 0);

        INSERT INTO [functional].[stockMovement] ([idAccount], [idUser], [idProduct], [type], [quantity], [reason])
        VALUES (@idAccount, @idUser, @newProductId, 'CADASTRO', 0, 'Produto cadastrado no sistema');

        SELECT 
            [idProduct],
            [idAccount],
            [idCategory],
            [idUnitOfMeasure],
            [code],
            [name],
            [description],
            [minimumStock],
            [dateCreated]
        FROM [functional].[product]
        WHERE [idProduct] = @newProductId;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;
        ;THROW;
    END CATCH
END;
GO
