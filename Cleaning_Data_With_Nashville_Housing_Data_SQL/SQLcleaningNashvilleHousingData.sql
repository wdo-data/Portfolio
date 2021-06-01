/*
Cleaning Data in SQL Queries
*/
SELECT *
FROM PortfolioProject.dbo.NashvilleHousingData



--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
--Convert method
SELECT SaleDate, CONVERT(Date,SaleDate)
FROM PortfolioProject.dbo.NashvilleHousingData

--FORMAT method
SELECT SaleDate, FORMAT(CAST(SaleDate as DATE),'yyyy/MM/dd')
FROM PortfolioProject.dbo.NashvilleHousingData

-- Can update the column or alternatively alter the table and add a new column, but need to remember to drop the old column 
UPDATE NashvilleHousingData
SET SaleDate = CONVERT(Date,SaleDate)

-- Alter table to create new column and fill in values with converted dates
ALTER TABLE NashvilleHousingData
ADD SaleDateConverted DATE;

UPDATE NashvilleHousingData
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDate, SaleDateConverted
FROM PortfolioProject.dbo.NashvilleHousingData


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

--Where PropertyAddress is null
SELECT *
FROM PortfolioProject.dbo.NashvilleHousingData
WHERE PropertyAddress is null 


SELECT a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress,COALESCE(a.PropertyAddress,b.PropertyAddress) 
FROM PortfolioProject.dbo.NashvilleHousingData as a
JOIN PortfolioProject.dbo.NashvilleHousingData as b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null 

UPDATE a
SET PropertyAddress = COALESCE(a.PropertyAddress,b.PropertyAddress) 
FROM PortfolioProject.dbo.NashvilleHousingData as a
JOIN PortfolioProject.dbo.NashvilleHousingData as b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null 



	

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

--For PropertyAddress
SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousingData

SELECT 
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS  City
FROM PortfolioProject.dbo.NashvilleHousingData

ALTER TABLE NashvilleHousingData
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousingData
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))





-- For OwnerAddress
SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousingData


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousingData

--Street Address
ALTER TABLE NashvilleHousingData
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

-- City
ALTER TABLE NashvilleHousingData
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

--State
ALTER TABLE NashvilleHousingData
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) 

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousingData
GROUP BY SoldAsVacant
ORDER BY 2

SELECT 
	CASE WHEN SoldAsVacant ='Y' THEN REPLACE(SoldAsVacant, 'Y', 'Yes')
	  WHEN SoldAsVacant ='N' THEN REPLACE(SoldAsVacant, 'N', 'No')
	  ELSE SoldAsVacant END as SoldAsVacantFixed
FROM PortfolioProject.dbo.NashvilleHousingData

UPDATE NashvilleHousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant ='Y' THEN REPLACE(SoldAsVacant, 'Y', 'Yes')
						WHEN SoldAsVacant ='N' THEN REPLACE(SoldAsVacant, 'N', 'No')
						ELSE SoldAsVacant END 

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					) AS Row_Num
FROM PortfolioProject.dbo.NashvilleHousingData
--ORDER BY Row_Num DESC
) 
DELETE 
FROM RowNumCTE
WHERE Row_Num >1

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
DROP COLUMN OwnerAddress, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
DROP COLUMN SaleDate

