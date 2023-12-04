--Standardize Date Format

Select SaleDateConverted
from NashvilleHousing

alter table NashvilleHousing
add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(date, SaleDate)

---------------------------------------------------------------------------------
--Populate Property Addresss data


Select *
from NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select NH1.ParcelID, NH1.PropertyAddress, NH2.ParcelID, NH2.PropertyAddress, ISNULL(NH1.PropertyAddress, NH2.PropertyAddress)
from NashvilleHousing NH1
Join NashvilleHousing NH2
	on NH1.ParcelID = NH2.ParcelID
	and NH1.[UniqueID ] <> NH2.[UniqueID ]
where NH1.PropertyAddress is null

Update NH1
Set PropertyAddress = ISNULL(NH1.PropertyAddress, NH2.PropertyAddress)
from NashvilleHousing NH1
Join NashvilleHousing NH2
	on NH1.ParcelID = NH2.ParcelID
	and NH1.[UniqueID ] <> NH2.[UniqueID ]

----------------------------------------------------------------------------------
--Breaking out Address into Individual Columns(Address, City, State)

Select PropertyAddress
from NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID


select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))
From NashvilleHousing

alter table NashvilleHousing
add SplitPropertyAddress nvarchar(255);

Update NashvilleHousing
Set SplitPropertyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

alter table NashvilleHousing
add SplitPropertyCity nvarchar(255);

Update NashvilleHousing
Set SplitPropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


select * from NashvilleHousing
order by  SaleDateConverted



select OwnerAddress
from NashvilleHousing

select 
PARSENAME(Replace(OwnerAddress, ',', '.'), 3)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 2)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
from NashvilleHousing


alter table NashvilleHousing
add SplitOwnerAddress nvarchar(255);

Update NashvilleHousing
Set SplitOwnerAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)
--

alter table NashvilleHousing
add SplitOwnerCity nvarchar(255);

Update NashvilleHousing
Set SplitOwnerCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)
--

alter table NashvilleHousing
add SplitOwnerState nvarchar(255);

Update NashvilleHousing
Set SplitOwnerState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)


select * from NashvilleHousing


--CHANGE Y AND N TO YES IN "SOLD AS VACANT" FIELD


select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
from NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

Select SoldAsVacant,
	Case
		When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
	End
FROM NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case
		When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
	End

--Remove Duplicates

With RowNumCTE As(
select * ,
	ROW_NUMBER() over (
Partition by ParcelId, 
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference 
			 order by UniqueId) row_num
From NashvilleHousing
--order by ParcelID
)


Select * from RowNumCTE
Where row_num > 1
order by PropertyAddress

--Remove unused Columns

Select * 
From NashvilleHousing

Alter Table NashvilleHousing
Drop Column SaleDate







