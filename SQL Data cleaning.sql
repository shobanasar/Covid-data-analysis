/*
	Data Cleaning SQL Queries
*/
SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing


-- Standardtise SaleDate format

SELECT SaleDate, CONVERT(Date,SaleDate) FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD SaleDateConverted Date;

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted =  CONVERT(Date,SaleDate) 

--Populate Property address data

SELECT PropertyAddress 
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress 
FROM PortfolioProject.dbo.NashvilleHousing

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress =SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

-- Parse Owners Address

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'), 1),
	 PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
	  PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

-- Change Y and N to Yes and No in "Sold as Vancant" field

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant) from PortfolioProject.dbo.NashvilleHousing GROUP BY SoldAsVacant

SELECT SoldAsVacant
,	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
	END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant =
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
	END
FROM PortfolioProject.dbo.NashvilleHousing

-- Remove duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				  UniqueID
				  )row_num
FROM PortfolioProject.dbo.NashvilleHousing

)
DELETE FROM RowNumCTE
WHERE row_num >1

-- DELETE UNUSED COLUMNS

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, Owneraddress









