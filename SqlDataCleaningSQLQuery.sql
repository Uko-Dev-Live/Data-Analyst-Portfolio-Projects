select  *
from Mydatabase..NashvilleHousingData

select * -- COUNT (*) as Columns
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'NashvilleHousingData'

-- Standardization of Date Format

select SaleDate, convert(Date, SaleDate)
from Mydatabase..NashvilleHousingData

Update Mydatabase..NashvilleHousingData
Set SaleDateConverted = Convert(Date, SaleDate)

Alter Table Mydatabase..NashvilleHousingData
Add SaleDateConverted Date
Go

Select SaleDate, SaleDateConverted
From Mydatabase..NashvilleHousingData

-- Populate Property Address Data

select *
from Mydatabase..NashvilleHousingData
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
ISNULL(a.PropertyAddress, b.PropertyAddress)
from Mydatabase..NashvilleHousingData a
Join Mydatabase..NashvilleHousingData b
On a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Mydatabase..NashvilleHousingData a
Join Mydatabase..NashvilleHousingData b
On a.ParcelID = b.ParcelID
where a.PropertyAddress is null
and a.[UniqueID ] <> b.[UniqueID ]

select PropertyAddress
from Mydatabase..NashvilleHousingData

-- Breaking up Address into Individual Columns (Address, City, State)

select PropertyAddress
from Mydatabase..NashvilleHousingData
-- order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from Mydatabase..NashvilleHousingData

Alter Table Mydatabase..NashvilleHousingData
Add PropertySplitAddress nvarchar(255);

Update Mydatabase..NashvilleHousingData
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

--Alter Table Mydatabase..NashvilleHousingData
--drop column PropertySlitCity --Nvarchar(255);

Alter Table Mydatabase..NashvilleHousingData
Add PropertySplitCity Nvarchar(255);

Update Mydatabase..NashvilleHousingData
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

select *
from Mydatabase.dbo.NashvilleHousingData

-- Breaking up OwnerAddress

select OwnerAddress
from Mydatabase.dbo.NashvilleHousingData

select 
PARSENAME(Replace (OwnerAddress, ',', '.') , 3)
, PARSENAME(Replace (OwnerAddress, ',', '.') , 2)
, PARSENAME(Replace (OwnerAddress, ',', '.') , 1)
from Mydatabase.dbo.NashvilleHousingData

Alter Table Mydatabase..NashvilleHousingData
Add OwnerSplitAddress Nvarchar(255);

Update Mydatabase..NashvilleHousingData
Set OwnerSplitAddress = PARSENAME(Replace (OwnerAddress, ',', '.') , 3)

Alter Table Mydatabase..NashvilleHousingData
Add OwnerSplitCity Nvarchar(255);

Update Mydatabase..NashvilleHousingData
Set OwnerSplitCity = PARSENAME(Replace (OwnerAddress, ',', '.') , 2)

Alter Table Mydatabase..NashvilleHousingData
Add OwnerSplitState Nvarchar(255);

Update Mydatabase..NashvilleHousingData
Set OwnerSplitState = PARSENAME(Replace (OwnerAddress, ',', '.') , 1)


select *
from Mydatabase.dbo.NashvilleHousingData

-- Change Y and N to Yes and No in 'Sold as Vacant' field

select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from Mydatabase.dbo.NashvilleHousingData
Group by SoldAsVacant
Order by 2


select SoldAsVacant,
     Case 
	     When SoldAsVacant = 'Y' Then 'Yes' 
		 When SoldAsVacant = 'N' Then 'No'
		 Else SoldAsVacant
     End
from Mydatabase.dbo.NashvilleHousingData

Update Mydatabase.dbo.NashvilleHousingData
Set SoldAsVacant = Case 
	     When SoldAsVacant = 'Y' Then 'Yes' 
		 When SoldAsVacant = 'N' Then 'No'
		 Else SoldAsVacant
     End

-- Remove Duplicate

With RowNumCTE As(
Select *,
    ROW_NUMBER() Over 
	(Partition by ParcelID,
	              PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  Order by ParcelID
				  ) row_num 
From Mydatabase..NashvilleHousingData
--Order by ParcelID
)

-- finding out the duplicates
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

-- Getting rid of duplicate
--Delete
--From RowNumCTE
--Where row_num > 1

-- Delete Unused Columns

Select *
From Mydatabase.dbo.NashvilleHousingData

Alter Table Mydatabase.dbo.NashvilleHousingData
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table Mydatabase.dbo.NashvilleHousingData
Drop Column SaleDate