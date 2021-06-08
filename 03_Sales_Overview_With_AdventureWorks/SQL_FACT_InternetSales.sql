-- Cleaned FACT_InternetSales Table
SELECT 
  ProductKey, 
  OrderDateKey, 
  DueDateKey, 
  ShipDateKey, 
  CustomerKey, 
  SalesOrderNumber, 
  TotalProductCost,
  SalesAmount
FROM 
  AdventureWorksDW2019..FactInternetSales
WHERE 
  LEFT (OrderDateKey, 4) >= 2013 
ORDER BY
  OrderDateKey ASC
