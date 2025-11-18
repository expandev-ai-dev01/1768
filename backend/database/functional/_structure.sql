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
