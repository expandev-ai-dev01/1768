/**
 * @summary
 * Updates an existing product's information.
 * 
 * @procedure spProductUpdate
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - PUT /api/v1/internal/product/:id
 * 
 * @parameters
 * @param {INT} idAccount - Account identifier
 * @param {INT} idProduct - The ID of the product to update
 * @param {INT} idCategory - New category identifier
 * @param {INT} idUnitOfMeasure - New unit of measure identifier
 * @param {NVARCHAR(100)} name - New product name
 * @param {NVARCHAR(500)} description - New product description
 * @param {NUMERIC(15, 4)} minimumStock - New minimum stock level
 */
CREATE OR ALTER PROCEDURE [functional].[spProductUpdate]
    @idAccount INT,
    @idProduct INT,
    @idCategory INT,
    @idUnitOfMeasure INT,
    @name NVARCHAR(100),
    @description NVARCHAR(500) = NULL,
    @minimumStock NUMERIC(15, 4)
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

    UPDATE [functional].[product]
    SET 
        [idCategory] = @idCategory,
        [idUnitOfMeasure] = @idUnitOfMeasure,
        [name] = @name,
        [description] = @description,
        [minimumStock] = @minimumStock
    WHERE [idAccount] = @idAccount AND [idProduct] = @idProduct AND [deleted] = 0;

    IF @@ROWCOUNT = 0
    BEGIN
        ;THROW 51000, 'ProductNotFound', 1;
    END

    EXEC [functional].[spProductGet] @idAccount = @idAccount, @idProduct = @idProduct;
END;
GO
