
select * from PortfolioProject.dbo.NashvilleHousing

--Standardize Date format

select SaleDateConverted, Convert(date,saleDate)
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
Set SaleDate= Convert(date,saleDate)

--if update does not work
Alter Table NashvilleHousing
Add SaleDateConverted Date;

update NashvilleHousing
Set SaleDateConverted= Convert(date,saleDate)


--Populate Property Address Data



select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out Address into individual columns (Address,City,State)

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(propertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(propertyAddress,CHARINDEX(',',PropertyAddress)+1,len(propertyaddress)) as City
from PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

update NashvilleHousing
Set PropertySplitAddress= SUBSTRING(propertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255);

update NashvilleHousing
Set PropertySplitCity= SUBSTRING(propertyAddress,CHARINDEX(',',PropertyAddress)+1,len(propertyaddress))

select *
from PortfolioProject.dbo.NashvilleHousing



select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing


--seprating owner address

Select
PARSENAME(Replace(OwnerAddress,',','.'),3)
,PARSENAME(Replace(OwnerAddress,',','.'),2)
,PARSENAME(Replace(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing


Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
Set OwnerSplitAddress= PARSENAME(Replace(OwnerAddress,',','.'),3)

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

update NashvilleHousing
Set OwnerSplitCity=PARSENAME(Replace(OwnerAddress,',','.'),2)


Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255);

update NashvilleHousing
Set OwnerSplitState= PARSENAME(Replace(OwnerAddress,',','.'),1)

select *
from PortfolioProject.dbo.NashvilleHousing


--Change Y and N to Yes and NO in "Sold as Vacant" field

select distinct(SoldAsVacant),count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
Case when SoldAsVacant='Y' THEN 'Yes'
When SoldAsVacant='N' Then 'No'
Else SoldAsVacant
END
from PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
set SoldAsVacant=Case when SoldAsVacant='Y' THEN 'Yes'
When SoldAsVacant='N' Then 'No'
Else SoldAsVacant
END



--Remove Duplicates


With RowNumCTE AS( 
Select *,
	ROW_NUMBER() Over (
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SAleDate,
	LegalReference
	Order by
	UniqueID) row_num
from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select * from RowNumCTE
where row_num>1
order by PropertyAddress





--Delete Unused Columns
Select *
from PortfolioProject.dbo.NashvilleHousing


Alter Table PortfolioProject.dbo.NashvilleHousing
DROP Column SaleDate