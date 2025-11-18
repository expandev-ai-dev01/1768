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
