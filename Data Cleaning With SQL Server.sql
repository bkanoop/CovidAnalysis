--***			CLEANING DATA IN SQL			***--


use PortfolioProject;

SELECT * 
FROM NashvilleHousing;


--------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


SELECT SaleDate, convert(date,SaleDate) 
FROM NashvilleHousing;

--UPDATE NashvilleHousing 
--set SaleDate = CONVERT(date,SaleDate);

ALTER table NashvilleHousing 
ALTER column SaleDate date;


--------------------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


SELECT * 
FROM NashvilleHousing
--where PropertyAddress is null
order by ParcelID ;

SELECT a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null;

UPDATE a
SET a.PropertyAddress = b.PropertyAddress		       -- or set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null;


---------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns(Address, City, State)


SELECT PropertyAddress
FROM NashvilleHousing

SELECT substring(PropertyAddress, 1, charindex(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress)) as City
FROM NashvilleHousing

ALTER table NashvilleHousing
add PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',',PropertyAddress)-1)

ALTER table NashvilleHousing
add PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress))

select * from NashvilleHousing

SELECT OwnerAddress
from NashvilleHousing

SELECT OwnerAddress,
PARSENAME(replace(OwnerAddress,',','.'),3) as address,	           --'parsename' only recognizes full stop, so converting comma to fullstop with 'replace'
PARSENAME(replace(OwnerAddress,',','.'),2) as city,
PARSENAME(replace(OwnerAddress,',','.'),1) as state
from NashvilleHousing

ALTER table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

ALTER table NashvilleHousing
add OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

ALTER table NashvilleHousing
add OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)


--------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y to Yes and N to No in "Sold as Vacant" field


select distinct(SoldAsVacant),count(*)
from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' then 'Yes'
	 WHEN SoldAsVacant = 'N' then 'No'
	 ELSE SoldAsVacant
END
from NashvilleHousing

UPDATE NashvilleHousing 
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' then 'Yes'
						WHEN SoldAsVacant = 'N' then 'No'
						ELSE SoldAsVacant
				    END


---------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates													   ( normally not done with raw data )


SELECT * FROM NashvilleHousing

WITH cte AS
(
	SELECT *,
		ROW_NUMBER() OVER(partition by ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference order by UniqueID ) as rows
	FROM NashvilleHousing
)

DELETE  
FROM cte 
WHERE rows > 1


--------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns													( normally not done with raw data )


SELECT * FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict


