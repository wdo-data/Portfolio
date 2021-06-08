-- Cleaned DIM_Date Table
SELECT 
  DateKey, 
  FullDateAlternateKey AS Date, 
  EnglishDayNameOfWeek AS Day, 
  EnglishMonthName AS Month, 
  Left(EnglishMonthName, 3) AS MonthShort,   
  MonthNumberOfYear AS MonthNo, 
  CalendarQuarter AS Quarter, 
  CalendarYear AS Year 
 
FROM 
  AdventureWorksDW2019..DimDate
WHERE 
  CalendarYear >= 2013
