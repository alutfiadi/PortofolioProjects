#---Data Cleansing 
select * 
from housing 

#--STANDARDIZED DATE FORMAT--#
select SaleDate
from housing 

select SaleDate,date_format(str_to_date(SaleDate, '%M %d, %Y'), '%Y-%m-%d')
from housing 

update housing 
set	SaleDate = date_format(str_to_date(SaleDate, '%M %d, %Y'), '%Y-%m-%d')

ALTER TABLE portofolio.housing 
MODIFY COLUMN SaleDate DATE NULL;

#--Populate Property Address
select PropertyAddress 
from housing 
where PropertyAddress is null

select a.parcelid , a.propertyaddress , b.parcelid , b.propertyaddress, ifnull(a.PropertyAddress,b.PropertyAddress) 
from housing a
join housing b on a.parcelid = b.parcelid 
	and a.UniqueID <> b.UniqueID
where a.propertyaddress is null

update housing a
join housing b on a.parcelid = b.parcelid 
	and a.UniqueID <> b.UniqueID
set a.propertyaddress = ifnull(a.PropertyAddress,b.PropertyAddress) 
where a.propertyaddress is null

#--Breaking out address to individual column (address,city,satate)
select PropertyAddress 
from housing 

select
substring(PropertyAddress, 1, LOCATE(',',PropertyAddress)-1) as address,
substring(PropertyAddress,LOCATE(',',PropertyAddress)+2, length(PropertyAddress)) as City
from housing 

alter table housing 
add PropertySplitAddress Varchar(255);

update housing 
set PropertySplitAddress = substring(PropertyAddress, 1, LOCATE(',',PropertyAddress)-1)

alter table housing 
add PropertySplitCity Varchar(255);

update housing 
set PropertySplitCity= substring(PropertyAddress,LOCATE(',',PropertyAddress)+2, length(PropertyAddress))

select 
SUBSTRING_INDEX(OwnerAddress ,',',1), 
#find middle SUBSTRING_INDEX( SUBSTRING_INDEX( OwnerAddress, ',', 2 ), DELIM, -1 )
SUBSTRING_INDEX( SUBSTRING_INDEX( OwnerAddress, ',', 2 ), ',', -1 ),
SUBSTRING_INDEX(OwnerAddress ,',',-1) 
from housing

#add column for owner address city
alter table housing 
add column OwnerSplitAddress Varchar(255),
add column OwnerSplitCity Varchar(255),
add column OwnerSplitState Varchar(255)

#update data to column
update housing 
set OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress ,',',1),
OwnerSplitCity = SUBSTRING_INDEX( SUBSTRING_INDEX( OwnerAddress, ',', 2 ), ',', -1 ),
OwnerSplitState = SUBSTRING_INDEX(OwnerAddress ,',',-1);

#-------------CHANGE Yand N to yes and no in Sold as Vacant field
select distinct (SoldAsVacant), count(SoldAsVacant) 
from housing 
group by SoldAsVacant 
order by SoldAsVacant 

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant ='N' then 'No'
	else SoldAsVacant 
	End
from housing 

update housing 
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant ='N' then 'No'
	else SoldAsVacant 
	end;


#--------------Remove Duplicates  !!DONOTDOTHISINSOURCETABLE
select *,
row_number() Over(
	partition by ParcelID, 
				 PropertyAddress ,
				 SalePrice ,
				 SaleDate ,
				 LegalReference
				 order by UniqueID
				 )
from housing 
order by ParcelID 

#--Use CTE
with RowNumCTE as (
select *,
row_number() Over(
	partition by ParcelID, 
				 PropertyAddress ,
				 SalePrice ,
				 SaleDate ,
				 LegalReference
				 order by UniqueID
				 ) row_num
from housing 
)
select row_num, UniqueID , ParcelID , SaleDate, SalePrice , LegalReference  
from RowNumCTE
where row_num > 1
-- order by 2,3

#delete duplicate 
with RowNumCTE as (
select *,
row_number() Over(
	partition by ParcelID, 
				 PropertyAddress ,
				 SalePrice ,
				 SaleDate ,
				 LegalReference
				 order by UniqueID
				 ) row_num
from housing 
)
DELETE 
from housing 
using housing 
	join RowNumCTE on housing.parcelid = RowNumCTE.parcelid 
	and housing.UniqueID <> RowNumCTE.UniqueID
where row_num > 1

#---------DELETE unusedColumns DONOTDOTHISINREALLIFE
alter table housing  
drop column OwnerAddress, TaxDistrict, PropertyAddress;