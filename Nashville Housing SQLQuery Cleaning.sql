-- Cleaning Data in SQL Queries 

SELECT *
FROM NashvilleHousing;

-- Standardize Date Format

SELECT  SalesDateConverted, CONVERT(DATE, SaleDate)
FROM NashvilleHousing;

UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE, SaleDate);

ALTER TABLE NashvilleHousing
ADD SalesDateConverted DATE;

UPDATE NashvilleHousing
SET SalesDateConverted = CONVERT(DATE, SaleDate);

SELECT SalesDateConverted
FROM NashvilleHousing;


-- Populate Property Address Data

SELECT  *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

-- Self Join table before updating 
SELECT a.ParcelID, a.PropertyAddress, b.parcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

-- Updating property address field 
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

----------------------------------------------------------------------------------

--Breaking down property address into individual columns (address, city, state) 
-- Delemeter (separates different columns or values)
SELECT PropertyAddress
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID;

-- CHARINDEX alone returns a value so we must add -1 to remove the comma from the address column
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address
FROM NashvilleHousing;


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity  = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));


SELECT * 
FROM NashvilleHousing;



-- Breaking down Owners address column

SELECT OwnerAddress
FROM NashvilleHousing;

SELECT PARSENAME(REPLACE(OwnerAddress,',', '.'),3), PARSENAME(REPLACE(OwnerAddress,',', '.'),2), PARSENAME(REPLACE(OwnerAddress,',', '.'),1)
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'),3);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'),2);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'),1);


-- Comfirming updates
SELECT *
FROM NashvilleHousing;


-- Change Y or N to Yes and No in "Solid as Vacant" field 

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing;



--Removing Duplicates (partition by unique values)

WITH RowNumCTE AS (
SELECT *, ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) Row_Num
FROM NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE Row_Num > 1
--ORDER BY PropertyAddress;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END



-- Delete Unused Columns 

SELECT *
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate;
