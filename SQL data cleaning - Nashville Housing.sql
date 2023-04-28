create schema NashvilleHousing;
use NashvilleHousing;
select * from NashvilleHousing;

-- Populate PropertyAddress Data
select PropertyAddress
from NashvilleHousing
where PropertyAddress is null;

select * from NashvilleHousing
where PropertyAddress is null;

-- populate PropertyAddress data with the immediate row above it if ParcelId is the same
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ifnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
    on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

update NashvilleHousing a
join NashvilleHousing b
    on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
set a.PropertyAddress = ifnull(a.PropertyAddress, b.PropertyAddress)
where a.PropertyAddress is null;

-- Breaking out Address into columns (Address, City)
select PropertyAddress from NashvilleHousing;
select substring_index(PropertyAddress, ',', 1) as Address,
       substring_index(substring_index(PropertyAddress, ',', 2), ',', -1) as City
from NashvilleHousing;

alter table NashvilleHousing
add column PropertySplitAddress varchar(100);
update NashvilleHousing
set PropertySplitAddress = substring_index(PropertyAddress, ',', 1);

alter table NashvilleHousing
add column PropertySplitCity varchar(100);
update NashvilleHousing
set PropertySplitCity = substring_index(substring_index(PropertyAddress, ',', 2), ',', -1);

select * from NashvilleHousing;

-- Update OwnerAddress into columns (Address, City, State)
select OwnerAddress from NashvilleHousing;
select substring_index(OwnerAddress, ',', 1) as Address,
       substring_index(substring_index(OwnerAddress, ',', 2), ',', -1) as City,
       substring_index(substring_index(OwnerAddress, ',', 3), ',', -1) as State
from NashvilleHousing;

alter table NashvilleHousing
add column OwnerSplitAddress varchar(100);
update NashvilleHousing
set OwnerSplitAddress = substring_index(OwnerAddress, ',', 1);

alter table NashvilleHousing
add column OwnerSplitCity varchar(100);
update NashvilleHousing
set OwnerSplitCity = substring_index(substring_index(OwnerAddress, ',', 2), ',', -1);

alter table NashvilleHousing
add column OwnerSplitState varchar(100);
update NashvilleHousing
set OwnerSplitState = substring_index(substring_index(OwnerAddress, ',', 3), ',', -1);

select * from NashvilleHousing;

-- Change Y and N to Yes and No in SoldAsVacant
select SoldAsVacant from NashvilleHousing;
-- count distinct values in SoldAsVacant
select distinct SoldAsVacant, count(SoldAsVacant) as Count
from NashvilleHousing
group by SoldAsVacant;

select case when SoldAsVacant = 'Y' then 'Yes'
            when SoldAsVacant = 'N' then 'No'
            else SoldAsVacant
       end as SoldAsVacant
from NashvilleHousing;

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
                        when SoldAsVacant = 'N' then 'No'
                        else SoldAsVacant
                   end;

-- Remove duplicates from NashvilleHousing
-- -- check duplicates in a cte
with cte as (
    select *,
           row_number() over(
               partition by ParcelID,
                   PropertyAddress,
                   SalePrice,
                   SaleDate,
                   LegalReference
                   order by UniqueID) as rn
    from NashvilleHousing
)
select * from cte
where rn > 1;

-- -- delete them from NashvilleHousing
with cte as (
    select *,
           row_number() over(
               partition by ParcelID,
                   PropertyAddress,
                   SalePrice,
                   SaleDate,
                   LegalReference
                   order by UniqueID) as rn
    from NashvilleHousing
)
delete from NashvilleHousing
where UniqueID in (
    select UniqueID
    from cte
    where rn > 1
);

-- Delete Unused Columns
alter table NashvilleHousing
drop column OwnerAddress,
drop column TaxDistrict,
drop column PropertyAddress;

select * from NashvilleHousing;
