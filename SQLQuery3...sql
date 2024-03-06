Select *
From PortfolioProject..NationalHousing

--Standardize date format

Select SaleDateConverted, Convert(Date, SaleDate)
From PortfolioProject..NationalHousing

Update PortfolioProject..NationalHousing
Set SaleDate = Convert(Date, SaleDate)

Alter Table PortfolioProject..NationalHousing
Add SaleDateConverted Date

Update PortfolioProject..NationalHousing
Set SaleDateConverted = Convert(Date, SaleDate)

--Populate Property address data

Select *
From PortfolioProject..NationalHousing
--Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NationalHousing a
Join PortfolioProject..NationalHousing b
	On a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID] 
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NationalHousing a
Join PortfolioProject..NationalHousing b
	On a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

--Breaking out address into individual columns (Address, City, State)

Select PropertyAddress
From PortfolioProject..NationalHousing
--Where PropertyAddress is null
--Order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address 
From PortfolioProject..NationalHousing

Alter Table PortfolioProject..NationalHousing
Add PropertySplitAddress Nvarchar(255)

Update PortfolioProject..NationalHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter Table PortfolioProject..NationalHousing
Add PropertySplitCity Nvarchar(255)

Update PortfolioProject..NationalHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
From PortfolioProject..NationalHousing

Select OwnerAddress
From PortfolioProject..NationalHousing

Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 2)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From PortfolioProject..NationalHousing

Alter Table PortfolioProject..NationalHousing
Add OwnerSplitAddress Nvarchar(255)

Update PortfolioProject..NationalHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Alter Table PortfolioProject..NationalHousing
Add OwnerSplitCity Nvarchar(255)

Update PortfolioProject..NationalHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Alter Table PortfolioProject..NationalHousing
Add OwnerSplitState Nvarchar(255)

Update PortfolioProject..NationalHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

Select *
From PortfolioProject..NationalHousing

--Change Y and N to Yes and No in the 'SoldAsVacant' Field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NationalHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
,CASE When SoldAsVacant = 'Y' Then 'Yes'
	  When SoldAsVacant = 'N' Then 'No'
	  Else SoldAsVacant
END
From PortfolioProject..NationalHousing

Update PortfolioProject..NationalHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	  When SoldAsVacant = 'N' Then 'No'
	  Else SoldAsVacant
END

--Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProject..NationalHousing
--Order by ParcelID
)
Delete
From RowNumCTE
Where row_num>1
--Order by PropertyAddress

--Delete unused columns

Select *
From PortfolioProject..NationalHousing

ALTER TABLE PortfolioProject..NationalHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

ALTER TABLE PortfolioProject..NationalHousing
DROP COLUMN SaleDate