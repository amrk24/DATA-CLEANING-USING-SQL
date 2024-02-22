/*
data cleaning 
sql project 2
*/

--foramt date 

--add column to table
alter table [portfolio project]..[nash housing] 
add saledateconvert date;
--add values to column
update [portfolio project]..[nash housing] 
set saledateconvert = convert(date,saledate)

select saledateconvert 
from [portfolio project]..[nash housing]

--format property addrese data 
select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)
from [portfolio project]..[nash housing] a
join [portfolio project]..[nash housing] b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set propertyaddress = isnull(a.PropertyAddress,b.PropertyAddress)  --replace any null value in a.PropertyAddress
from [portfolio project]..[nash housing] a                         --with the value in b.PropertyAddress     
join [portfolio project]..[nash housing] b 
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--breaking out propertyaddrese into individual columns(address,city)

select PropertyAddress 
from [portfolio project]..[nash housing]

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))
from [portfolio project]..[nash housing]

alter table [portfolio project] .. [nash housing] 
add address nvarchar(255),city nvarchar(255)

update [portfolio project]..[nash housing]
set 
address = substring(propertyaddress,1,charindex(',',propertyaddress)-1),
city = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) 

select address,city 
from [portfolio project]..[nash housing]

--breaking out owneraddress into individual columns(address,city,state)
select 
--PARSENAME(owneraddress,1)                         /*بيقسم عناصر العمود كمقاطع بناء على النقطة
PARSENAME(replace(owneraddress,',','.'),3),   
PARSENAME(replace(owneraddress,',','.'),2),
PARSENAME(replace(owneraddress,',','.'),1)
from [portfolio project]..[nash housing]


alter table [portfolio project] .. [nash housing] 
add 
ownsplitaddress nvarchar(255),
ownsplitcity nvarchar(255),
ownsplitstate nvarchar(255)

update [portfolio project]..[nash housing]
set 
ownsplitaddress = PARSENAME(replace(owneraddress,',','.'),3),
ownsplitcity = PARSENAME(replace(owneraddress,',','.'),2),
ownsplitstate = PARSENAME(replace(owneraddress,',','.'),1)

--change Y , N to Yes , No in soldasvacant

select distinct(SoldAsVacant),COUNT(SoldAsVacant)
from [portfolio project] .. [nash housing]
group by SoldAsVacant
order by 2

--select SoldAsVacant,
--case 
--when SoldAsVacant='Y' then 'Yes'
--when SoldAsVacant= 'N' then 'No'
--else SoldAsVacant 
--end
--from [portfolio project] .. [nash housing]

update [portfolio project] .. [nash housing]
set SoldAsVacant = 
case 
when SoldAsVacant='Y' then 'Yes'
when SoldAsVacant= 'N' then 'No'
else SoldAsVacant 
end

--remove duplicate rows 

with rownumcte as 
(
select *,ROW_NUMBER()
 over (partition by    parcelid,                        --قسمت الصفوف عندي بناءان كل القيم في الاعمدة المختارة متشابهه
					   saleprice,                      --وكتبت جنب كل صف العدد المتكرر منه 
					   legalreference,
					   propertyaddress,
					   saledate
					   order by 
					   uniqueid
					   ) as  rownum
from [portfolio project] .. [nash housing]
)

delete 
from rownumcte 
where rownum>1


--delete unused columns 
alter table [portfolio project] .. [nash housing]
drop column owneraddress,propertyaddress


--update name of column 

select * 
from [portfolio project] .. [nash housing]

exec sp_rename
'[nash housing].city',
'prcity','column'

exec sp_rename                       
'[nash housing].address',
'praddress','column'