-- Cleaned DIM_Products Table
SELECT 
  p.ProductKey, 
  p.ProductAlternateKey AS ProductItemCode, 
  p.EnglishProductName AS [Product Name], 
  ps.EnglishProductSubcategoryName AS [Sub Category], -- Joined in from Sub Category Table
  pc.EnglishProductCategoryName AS [Product Category], -- Joined in from Category Table 
  p.Color AS [Product Color], 
  p.Size AS [Product Size], 
  p.ProductLine AS [Product Line], 
  p.ModelName AS [Product Model Name], 
  p.EnglishDescription AS [Product Description],  
  ISNULL (p.Status, 'Outdated') AS [Product Status] --Replace null values with Outdated
FROM 
  AdventureWorksDW2019..DimProduct AS p
  LEFT JOIN dbo.DimProductSubcategory AS ps ON p.ProductSubcategoryKey =ps.ProductSubcategoryKey
  LEFT JOIN dbo.DimProductCategory AS pc ON ps.ProductCategoryKey = pc.ProductCategoryKey 
order by 
  p.ProductKey ASC
