/*

Cleaning Data in SQL Queries

*/


SELECT * 
FROM Portfolio.dbo.HousingData

-- Changing date format

SELECT SaleDate, CONVERT(Date, SaleDate) as SaleDateNew
FROM Portfolio.dbo.HousingData

ALTER TABLE Portfolio.dbo.HousingData
ADD SaleDateNew date

UPDATE Portfolio.dbo.HousingData
SET SaleDateNew = CONVERT(Date, SaleDate)

--Populate Property Address data

SELECT *
FROM Portfolio.dbo.HousingData
WHERE PropertyAddress is null

SELECT a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, 
ISNULL(a.PropertyAddress, b.PropertyAddress) as PropertyAddressNew
FROM Portfolio.dbo.HousingData a
JOIN Portfolio.dbo.HousingData b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID 
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio.dbo.HousingData a
JOIN Portfolio.dbo.HousingData b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID 
WHERE a.PropertyAddress is null

-- Breaking out Property Address into Individual Columns (Address, City, State)

SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM Portfolio.dbo.HousingData

ALTER TABLE Portfolio.dbo.HousingData
ADD PropertyAddressNew Nvarchar(50)

UPDATE Portfolio.dbo.HousingData
SET PropertyAddressNew = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Portfolio.dbo.HousingData
ADD PropertyCityNew Nvarchar(50)

UPDATE Portfolio.dbo.HousingData
SET PropertyCityNew = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--  Breaking out Owner Address into Individual Columns (Address, City, State)

SELECT OwnerAddress
FROM Portfolio.dbo.HousingData

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) as Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) as City,
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) as State
FROM Portfolio.dbo.HousingData

ALTER TABLE Portfolio.dbo.HousingData
ADD OwnerAddressNew Nvarchar (50)

ALTER TABLE Portfolio.dbo.HousingData
ADD OwnerCityNew Nvarchar (50)

ALTER TABLE Portfolio.dbo.HousingData
ADD OwnerStateNew Nvarchar (50)

UPDATE Portfolio.dbo.HousingData
SET OwnerAddressNew = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

UPDATE Portfolio.dbo.HousingData
SET OwnerCityNew = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

UPDATE Portfolio.dbo.HousingData
SET OwnerStateNew = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT distinct(SoldasVacant), count(SoldasVacant)
FROM Portfolio.dbo.HousingData
GROUP BY SoldasVacant

SELECT SoldasVacant,
CASE when SoldasVacant = 'y' then 'Yes'
			when SoldasVacant = 'n' then 'No'
			ELSE SoldasVacant
			END
FROM Portfolio.dbo.HousingData

UPDATE Portfolio.dbo.HousingData
SET SoldasVacant = CASE when SoldasVacant = 'y' then 'Yes'
			when SoldasVacant = 'n' then 'No'
			ELSE SoldasVacant
			END

-- Remove duplicates

SELECT *, row_num
FROM (
SELECT * , ROW_NUMBER() OVER (PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM Portfolio.dbo.HousingData) a
WHERE row_num > 1

-- Populating nulls in Owner Address AND Owner City

SELECT UniqueID, ParcelID, PropertyAddressNew, OwnerAddressNew 
FROM Portfolio.dbo.HousingData
ORDER BY ParcelID

SELECT PropertyAddressNew, OwnerAddressNew, ISNULL( OwnerAddressNew, PropertyAddressNew) as populating
FROM Portfolio.dbo.HousingData
WHERE OwnerAddressNew is null

UPDATE Portfolio.dbo.HousingData
SET OwnerAddressNew = ISNULL( OwnerAddressNew, PropertyAddressNew) 
WHERE OwnerAddressNew is null

SELECT PropertyCityNew, OwnerCityNew, ISNULL( OwnerCityNew, PropertyCityNew) as populating
FROM Portfolio.dbo.HousingData
WHERE OwnerCityNew is null

UPDATE Portfolio.dbo.HousingData
SET OwnerCityNew = ISNULL( OwnerCityNew, PropertyCityNew) 
WHERE OwnerCityNew is null
