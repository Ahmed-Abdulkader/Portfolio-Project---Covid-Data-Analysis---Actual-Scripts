--Cleaning Data 

--------------------------------------------------------------------------------------------------------------------------
--Looking at all the data

SELECT *
FROM DataCleaning.dbo.ToClean
ORDER BY UniqueID

--------------------------------------------------------------------------------------------------------------------------
--Standardising Date Format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM DataCleaning.dbo.ToClean

ALTER TABLE ToClean
ADD SaleDateConverted Date;

Update ToClean	
SET SaleDateConverted = CONVERT(Date,SaleDate)

--------------------------------------------------------------------------------------------------------------------------
--Populate Property Address Data

SELECT *
FROM DataCleaning.dbo.ToClean
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaning.dbo.ToClean a
JOIN DataCleaning.dbo.ToClean b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE A.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaning.dbo.ToClean a
JOIN DataCleaning.dbo.ToClean b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID

--------------------------------------------------------------------------------------------------------------------------
--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM DataCleaning.dbo.ToClean

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Adress
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Addres
FROM DataCleaning.dbo.ToClean

--------------------------------------------------------------------------------------------------------------------------
--Adding the new columns and updating the table Using Substring

ALTER TABLE ToClean
ADD PropertySplitAddress Nvarchar(255);

Update ToClean	
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE ToClean
ADD PropertySplitCity Nvarchar(255);

Update ToClean	
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM DataCleaning.dbo.ToClean

--------------------------------------------------------------------------------------------------------------------------
--Splitting the Owner Address Column Using PARSNAME

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM DataCleaning.dbo.ToClean

ALTER TABLE ToClean
ADD OwnerSplitAddress varchar(255);

Update ToClean	
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

-----

ALTER TABLE ToClean
ADD OwnerSplitCity varchar(255);

Update ToClean	
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

-----

ALTER TABLE ToClean
ADD OwnerSplitState varchar(255);

Update ToClean	
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

SELECT *
FROM DataCleaning.dbo.ToClean

------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field Using Case statement 

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM DataCleaning.dbo.ToClean
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
	CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM DataCleaning.dbo.ToClean

UPDATE ToClean 
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

------------------------------------------------------------------------------------------------------------------------
-- Removing Duplicates Using CTE

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
	ORDER BY UniqueID) row_num
FROM DataCleaning.dbo.ToClean
)

--DELETE
--FROM RowNumCTE
--Where row_num > 1


SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

------------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns

SELECT *
FROM DataCleaning.dbo.ToClean

ALTER TABLE DataCleaning.dbo.ToClean
DROP COLUMN SaleDate