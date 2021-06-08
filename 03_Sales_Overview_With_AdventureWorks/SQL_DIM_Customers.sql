-- Cleaned DIM_Customers Table --
SELECT 
  c.customerkey AS CustomerKey, 
  c.firstname AS [First Name], 
  c.lastname AS [Last Name], 
-- Combined First and Last Name for Unique Name
  c.firstname + ' ' + lastname AS [Full Name], 
  CASE c.Gender WHEN 'M' THEN 'Male' WHEN 'F' THEN 'Female' END AS Gender,
  c.datefirstpurchase AS DateFirstPurchase, 
  g.City AS [Customer City]
-- Joined in Customer City from Geography Table
FROM 
  AdventureWorksDW2019..DimCustomer as c
  LEFT JOIN AdventureWorksDW2019..DimGeography AS g 
  ON g.Geographykey = c.Geographykey 
ORDER BY 
  CustomerKey ASC 
