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
