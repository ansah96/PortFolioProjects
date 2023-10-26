Select * from PortfolioProject1.dbo.HousingData

-- Data Cleaning

Select SaleDateNew, convert(date,Saledate)
from PortfolioProject1.dbo.HousingData

Update HousingData
set SaleDate = convert(date,Saledate)

-- SaleDate did not get converted into the desired format

Alter Table HousingData
Add SaleDateNew Date;

Update HousingData
set SaleDateNew = convert(date,Saledate)

-- running it again to see if it worked

Select SaleDateNew, convert(date,Saledate)
from PortfolioProject1.dbo.HousingData

-- Update Property Address
Select *
from PortfolioProject1.dbo.HousingData
--Where PropertyAddress is null
order by ParcelID

-- converting double data into a single line
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull (a.PropertyAddress, b.PropertyAddress)
from PortfolioProject1.dbo.HousingData a
Join PortfolioProject1.dbo.HousingData b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull (a.PropertyAddress, b.PropertyAddress)
from PortfolioProject1.dbo.HousingData a
Join PortfolioProject1.dbo.HousingData b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking Address into Individual Colums(Address, City, State

Select PropertyAddress
from PortfolioProject1.dbo.HousingData
--Where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress)) as Address
from PortfolioProject1.dbo.HousingData

Alter Table HousingData
Add PropertySplitAddress nvarchar(255);

Update HousingData
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table HousingData
Add PropertySplitCity nvarchar(255);

Update HousingData
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress))

select *
from PortfolioProject1.dbo.HousingData

-- Change OwnerAddress

--Select OwnerAddress
--from PortfolioProject1.dbo.HousingData

Select
Parsename(Replace(OwnerAddress, ',','.'), 3)
,Parsename(Replace(OwnerAddress, ',','.'), 2)
,Parsename(Replace(OwnerAddress, ',','.'), 1)
from PortfolioProject1.dbo.HousingData

Alter Table HousingData
Add OwnerSplitAddress nvarchar(255);

Alter Table HousingData
Add OwnerSplitCity nvarchar(255);

Alter Table HousingData
Add OwnerSplitState nvarchar(255);

Update HousingData
set OwnerSplitAddress = Parsename(Replace(OwnerAddress, ',','.'), 3)


Update HousingData
set OwnerSplitCity = Parsename(Replace(OwnerAddress, ',','.'), 2)

Update HousingData
set OwnerSplitState = Parsename(Replace(OwnerAddress, ',','.'), 1)


-- Changing N and Y in SoldAsVacant into No and Yes

Select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject1.dbo.HousingData
group by SoldAsVacant
order by 2


Select SoldAsVacant
, case when SoldAsVacant = 'N' then 'No'
when SoldAsVacant = 'Y' then 'yes'
else SoldAsVacant end
from PortfolioProject1.dbo.HousingData

Update HousingData
set SoldAsVacant = case when SoldAsVacant = 'N' then 'No'
when SoldAsVacant = 'Y' then 'yes'
else SoldAsVacant end


-- Remove Duplicates

with rownumcte as(
select *,
Row_number() over (
Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
order by UniqueID
) row_num
from PortfolioProject1.dbo.HousingData
--order by ParcelID
)
select *
from rownumcte
where row_num > 1
order by PropertyAddress


-- deleting unused colums
select *
from PortfolioProject1.dbo.HousingData

alter table PortfolioProject1.dbo.HousingData
drop column SaleDate
