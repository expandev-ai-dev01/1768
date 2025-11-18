/**
 * @schema functional
 * Contains business logic, operational procedures, and core application data.
 */
CREATE SCHEMA [functional];
GO

/**
 * @table category Stores product categories.
 * @multitenancy true
 * @softDelete true
 * @alias cat
 */
CREATE TABLE [functional].[category] (
  [idCategory] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [description] NVARCHAR(500) NULL
);
GO

/**
 * @table supplier Stores supplier information.
 * @multitenancy true
 * @softDelete true
 * @alias sup
 */
CREATE TABLE [functional].[supplier] (
  [idSupplier] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [contactName] NVARCHAR(100) NULL,
  [contactEmail] NVARCHAR(100) NULL
);
GO

/**
 * @table unitOfMeasure Stores units of measure for products.
 * @multitenancy true
 * @softDelete true
 * @alias uom
 */
CREATE TABLE [functional].[unitOfMeasure] (
  [idUnitOfMeasure] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [name] NVARCHAR(50) NOT NULL,
  [abbreviation] NVARCHAR(10) NOT NULL
);
GO

/**
 * @table product Stores product information.
 * @multitenancy true
 * @softDelete true
 * @alias prd
 */
CREATE TABLE [functional].[product] (
  [idProduct] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idCategory] INTEGER NOT NULL,
  [idUnitOfMeasure] INTEGER NOT NULL,
  [code] VARCHAR(20) NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [description] NVARCHAR(500) NULL,
  [minimumStock] NUMERIC(15, 4) NOT NULL DEFAULT (0),
  [dateCreated] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @table stockBalance Stores the current calculated stock balance for each product.
 * @multitenancy true
 * @softDelete false
 * @alias stb
 */
CREATE TABLE [functional].[stockBalance] (
  [idAccount] INTEGER NOT NULL,
  [idProduct] INTEGER NOT NULL,
  [quantity] NUMERIC(15, 4) NOT NULL DEFAULT (0),
  [lastUpdated] DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);
GO

/**
 * @table stockMovement Logs all stock movements (entries, exits, adjustments).
 * @multitenancy true
 * @softDelete false
 * @alias stm
 */
CREATE TABLE [functional].[stockMovement] (
  [idStockMovement] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idUser] INTEGER NOT NULL,
  [idProduct] INTEGER NOT NULL,
  [idSupplier] INTEGER NULL,
  [type] VARCHAR(20) NOT NULL, -- 'CADASTRO', 'ENTRADA', 'SAIDA', 'AJUSTE', 'EXCLUSAO'
  [quantity] NUMERIC(15, 4) NOT NULL,
  [quantityBefore] NUMERIC(15, 4) NULL, -- For AJUSTE and EXCLUSAO
  [movementDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
  [reason] NVARCHAR(500) NULL,
  [referenceDocument] NVARCHAR(50) NULL,
  [destination] NVARCHAR(100) NULL,
  [lot] NVARCHAR(30) NULL,
  [expirationDate] DATE NULL
);
GO

-- Constraints for category
ALTER TABLE [functional].[category]
ADD CONSTRAINT [pkCategory] PRIMARY KEY CLUSTERED ([idCategory]);
GO

-- Constraints for supplier
ALTER TABLE [functional].[supplier]
ADD CONSTRAINT [pkSupplier] PRIMARY KEY CLUSTERED ([idSupplier]);
GO

-- Constraints for unitOfMeasure
ALTER TABLE [functional].[unitOfMeasure]
ADD CONSTRAINT [pkUnitOfMeasure] PRIMARY KEY CLUSTERED ([idUnitOfMeasure]);
GO

-- Constraints for product
ALTER TABLE [functional].[product]
ADD CONSTRAINT [pkProduct] PRIMARY KEY CLUSTERED ([idProduct]);
GO
ALTER TABLE [functional].[product]
ADD CONSTRAINT [fkProduct_Category] FOREIGN KEY ([idCategory])
REFERENCES [functional].[category]([idCategory]);
GO
ALTER TABLE [functional].[product]
ADD CONSTRAINT [fkProduct_UnitOfMeasure] FOREIGN KEY ([idUnitOfMeasure])
REFERENCES [functional].[unitOfMeasure]([idUnitOfMeasure]);
GO

-- Constraints for stockBalance
ALTER TABLE [functional].[stockBalance]
ADD CONSTRAINT [pkStockBalance] PRIMARY KEY CLUSTERED ([idAccount], [idProduct]);
GO
ALTER TABLE [functional].[stockBalance]
ADD CONSTRAINT [fkStockBalance_Product] FOREIGN KEY ([idProduct])
REFERENCES [functional].[product]([idProduct]);
GO

-- Constraints for stockMovement
ALTER TABLE [functional].[stockMovement]
ADD CONSTRAINT [pkStockMovement] PRIMARY KEY CLUSTERED ([idStockMovement]);
GO
ALTER TABLE [functional].[stockMovement]
ADD CONSTRAINT [fkStockMovement_Product] FOREIGN KEY ([idProduct])
REFERENCES [functional].[product]([idProduct]);
GO
ALTER TABLE [functional].[stockMovement]
ADD CONSTRAINT [fkStockMovement_Supplier] FOREIGN KEY ([idSupplier])
REFERENCES [functional].[supplier]([idSupplier]);
GO
ALTER TABLE [functional].[stockMovement]
ADD CONSTRAINT [chkStockMovement_Type] CHECK ([type] IN ('CADASTRO', 'ENTRADA', 'SAIDA', 'AJUSTE', 'EXCLUSAO'));
GO

-- Indexes
CREATE UNIQUE NONCLUSTERED INDEX [uqProduct_Account_Code] 
ON [functional].[product]([idAccount], [code]) 
WHERE [deleted] = 0;
GO

CREATE NONCLUSTERED INDEX [ixStockMovement_Product] 
ON [functional].[stockMovement]([idAccount], [idProduct]);
GO

CREATE NONCLUSTERED INDEX [ixStockMovement_Type] 
ON [functional].[stockMovement]([idAccount], [type]);
GO

CREATE NONCLUSTERED INDEX [ixStockMovement_MovementDate] 
ON [functional].[stockMovement]([idAccount], [movementDate]);
GO

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

/**
 * @summary
 * Retrieves a single product by its ID.
 * 
 * @procedure spProductGet
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - GET /api/v1/internal/product/:id
 * 
 * @parameters
 * @param {INT} idAccount - Account identifier
 * @param {INT} idProduct - The ID of the product to retrieve
 */
CREATE OR ALTER PROCEDURE [functional].[spProductGet]
    @idAccount INT,
    @idProduct INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        [prd].[idProduct],
        [prd].[idAccount],
        [prd].[idCategory],
        [cat].[name] AS [categoryName],
        [prd].[idUnitOfMeasure],
        [uom].[name] AS [unitOfMeasureName],
        [prd].[code],
        [prd].[name],
        [prd].[description],
        [prd].[minimumStock],
        [prd].[dateCreated],
        ISNULL([stb].[quantity], 0) AS [currentStock],
        CASE
            WHEN ISNULL([stb].[quantity], 0) < 0 THEN 'NEGATIVO'
            WHEN ISNULL([stb].[quantity], 0) = 0 THEN 'ZERADO'
            WHEN [prd].[minimumStock] > 0 AND ISNULL([stb].[quantity], 0) <= ([prd].[minimumStock] * 0.2) THEN 'CRITICO'
            WHEN ISNULL([stb].[quantity], 0) <= [prd].[minimumStock] THEN 'BAIXO'
            ELSE 'NORMAL'
        END AS [stockStatus]
    FROM [functional].[product] [prd]
    JOIN [functional].[category] [cat] ON [cat].[idCategory] = [prd].[idCategory]
    JOIN [functional].[unitOfMeasure] [uom] ON [uom].[idUnitOfMeasure] = [prd].[idUnitOfMeasure]
    LEFT JOIN [functional].[stockBalance] [stb] ON [stb].[idAccount] = [prd].[idAccount] AND [stb].[idProduct] = [prd].[idProduct]
    WHERE [prd].[idAccount] = @idAccount
      AND [prd].[idProduct] = @idProduct
      AND [prd].[deleted] = 0;
END;
GO

/**
 * @summary
 * Retrieves a list of products with filtering and pagination.
 * 
 * @procedure spProductList
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - GET /api/v1/internal/product
 * 
 * @parameters
 * @param {INT} idAccount - Account identifier
 * @param {NVARCHAR(100)} searchTerm - Text to search in code, name, or description
 * @param {INT} idCategory - Filter by category ID
 */
CREATE OR ALTER PROCEDURE [functional].[spProductList]
    @idAccount INT,
    @searchTerm NVARCHAR(100) = NULL,
    @idCategory INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        [prd].[idProduct],
        [prd].[idAccount],
        [prd].[idCategory],
        [cat].[name] AS [categoryName],
        [prd].[idUnitOfMeasure],
        [uom].[name] AS [unitOfMeasureName],
        [prd].[code],
        [prd].[name],
        [prd].[description],
        [prd].[minimumStock],
        [prd].[dateCreated],
        ISNULL([stb].[quantity], 0) AS [currentStock],
        CASE
            WHEN ISNULL([stb].[quantity], 0) < 0 THEN 'NEGATIVO'
            WHEN ISNULL([stb].[quantity], 0) = 0 THEN 'ZERADO'
            WHEN [prd].[minimumStock] > 0 AND ISNULL([stb].[quantity], 0) <= ([prd].[minimumStock] * 0.2) THEN 'CRITICO'
            WHEN ISNULL([stb].[quantity], 0) <= [prd].[minimumStock] THEN 'BAIXO'
            ELSE 'NORMAL'
        END AS [stockStatus]
    FROM [functional].[product] [prd]
    JOIN [functional].[category] [cat] ON [cat].[idCategory] = [prd].[idCategory]
    JOIN [functional].[unitOfMeasure] [uom] ON [uom].[idUnitOfMeasure] = [prd].[idUnitOfMeasure]
    LEFT JOIN [functional].[stockBalance] [stb] ON [stb].[idAccount] = [prd].[idAccount] AND [stb].[idProduct] = [prd].[idProduct]
    WHERE [prd].[idAccount] = @idAccount
      AND [prd].[deleted] = 0
      AND (@idCategory IS NULL OR [prd].[idCategory] = @idCategory)
      AND (@searchTerm IS NULL OR (
          [prd].[name] LIKE '%' + @searchTerm + '%'
          OR [prd].[code] LIKE '%' + @searchTerm + '%'
          OR [prd].[description] LIKE '%' + @searchTerm + '%'
      ))
    ORDER BY [prd].[name];
END;
GO

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

/**
 * @summary
 * Retrieves a list of stock movements with filtering and pagination.
 * 
 * @procedure spStockMovementList
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - GET /api/v1/internal/stock-movement
 * 
 * @parameters
 * @param {INT} idAccount - Account identifier
 * @param {INT} idProduct - Filter by product ID
 * @param {VARCHAR(20)} type - Filter by movement type
 * @param {DATE} startDate - Start date of the filter period
 * @param {DATE} endDate - End date of the filter period
 * @param {INT} idUser - Filter by user ID
 */
CREATE OR ALTER PROCEDURE [functional].[spStockMovementList]
    @idAccount INT,
    @idProduct INT = NULL,
    @type VARCHAR(20) = NULL,
    @startDate DATE = NULL,
    @endDate DATE = NULL,
    @idUser INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        [stm].[idStockMovement],
        [stm].[idAccount],
        [stm].[idUser],
        [stm].[idProduct],
        [prd].[name] AS [productName],
        [prd].[code] AS [productCode],
        [stm].[idSupplier],
        [sup].[name] AS [supplierName],
        [stm].[type],
        [stm].[quantity],
        [stm].[quantityBefore],
        [stm].[movementDate],
        [stm].[reason],
        [stm].[referenceDocument],
        [stm].[destination],
        [stm].[lot],
        [stm].[expirationDate]
    FROM [functional].[stockMovement] [stm]
    JOIN [functional].[product] [prd] ON [prd].[idProduct] = [stm].[idProduct]
    LEFT JOIN [functional].[supplier] [sup] ON [sup].[idSupplier] = [stm].[idSupplier]
    WHERE [stm].[idAccount] = @idAccount
      AND (@idProduct IS NULL OR [stm].[idProduct] = @idProduct)
      AND (@type IS NULL OR [stm].[type] = @type)
      AND (@idUser IS NULL OR [stm].[idUser] = @idUser)
      AND (@startDate IS NULL OR [stm].[movementDate] >= @startDate)
      AND (@endDate IS NULL OR [stm].[movementDate] <= @endDate)
    ORDER BY [stm].[movementDate] DESC;
END;
GO
