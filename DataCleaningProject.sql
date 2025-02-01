/*
	Data exploration and cleaning in SQL
*/

---------------------------------------------------------------------------------------------------

SELECT *
FROM housing_data

/*
	Review Nulls in Property Address to see if they can be populated
	SaleDate column needs to be standerdized
	PropertyAddress column should be separated into separate columns for street address and city
	OwnerAddress column should be separated into separate columns for street address, city and state 
	Check for duplicates and remove if found
	Standardize Sold as Vacant field
	Remove any columns not needed for this project
*/

---------------------------------------------------------------------------------------------------

-- Populate PropertyAddress data where possible

SELECT *
FROM housing_data
ORDER BY ParcelID

SELECT hd1.[UniqueID ], hd1.ParcelID, hd1.PropertyAddress, hd1.OwnerName, hd2.[UniqueID ], hd2.ParcelID, hd2.PropertyAddress, hd2.OwnerName, ISNULL(hd1.PropertyAddress, hd2.PropertyAddress)
FROM housing_data hd1
	JOIN housing_data hd2
	ON hd1.ParcelID = hd2.ParcelID
	AND hd1.[UniqueID ] <> hd2.[UniqueID ]
WHERE hd1.PropertyAddress IS NULL

UPDATE hd1
SET hd1.PropertyAddress = ISNULL(hd1.PropertyAddress, hd2.PropertyAddress)
FROM housing_data hd1
	JOIN housing_data hd2
	ON hd1.ParcelID = hd2.ParcelID
	AND hd1.[UniqueID ] <> hd2.[UniqueID ]
WHERE hd1.PropertyAddress IS NULL

---------------------------------------------------------------------------------------------------

-- Standardize Date Format

ALTER TABLE housing_data
ADD SaleDateConverted date
GO

UPDATE housing_data
SET SaleDateConverted = CONVERT(Date,SaleDate)

---------------------------------------------------------------------------------------------------

-- Separate PropertyAddress column into separate columns for street address and city

ALTER TABLE housing_data
ADD PropertyAddressStreet NVARCHAR(255)
GO

ALTER TABLE housing_data
ADD PropertyAddressCity NVARCHAR(255)
GO

UPDATE housing_data
SET PropertyAddressStreet = PARSENAME(REPLACE(PropertyAddress,',','.') , 2)

UPDATE housing_data
SET PropertyAddressCity = PARSENAME(REPLACE(PropertyAddress,',','.') , 1)

---------------------------------------------------------------------------------------------------

-- Separate OwnerAddress column into separate columns for street address, city and state

ALTER TABLE housing_data
ADD OwnerAddressStreet NVARCHAR(255)
GO

ALTER TABLE housing_data
ADD OwnerAddressCity NVARCHAR(255)
GO

ALTER TABLE housing_data
ADD OwnerAddressState NVARCHAR(255)
GO

UPDATE housing_data
SET OwnerAddressStreet = PARSENAME(REPLACE(OwnerAddress,',','.') , 3)

UPDATE housing_data
SET OwnerAddressCity = PARSENAME(REPLACE(OwnerAddress,',','.') , 2)

UPDATE housing_data
SET OwnerAddressState = PARSENAME(REPLACE(OwnerAddress,',','.') , 1)

---------------------------------------------------------------------------------------------------

-- Check for duplicates based on ParcelID, PropertyAddress, LegalReference, OwnerName

SELECT *,
ROW_NUMBER()
	OVER(PARTITION BY ParcelId, PropertyAddress, LegalReference, OwnerName ORDER BY ParcelID
) AS row_dup
FROM housing_data

-- Use CTE to remove duplicates

WITH dup_rows_cte AS
(SELECT *,
ROW_NUMBER()
	OVER(PARTITION BY ParcelId, PropertyAddress, LegalReference, OwnerName ORDER BY ParcelID) AS row_dup
FROM housing_data
)

DELETE
FROM dup_rows_cte
WHERE row_dup > 1

---------------------------------------------------------------------------------------------------

-- Standardize Sold as Vacant field

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant) AS CountOfTypes
FROM housing_data
GROUP BY SoldAsVacant
ORDER BY CountOfTypes

SELECT SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM housing_data
ORDER BY SoldAsVacant

UPDATE housing_data
SET SoldAsVacant = 
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END

---------------------------------------------------------------------------------------------------

-- Remove any columns not needed for this project

SELECT *
FROM housing_data

ALTER TABLE housing_data
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict