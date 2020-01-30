--Create a table to hold inventory balances:
declare @inventory table (
    ItemNumber varchar(50) not null,
    WarehouseLocation varchar(50) not null,
    QuantityOnHand int not null,
    PricePerItem decimal not null
)

--Create a table to hold accounting balances: 
declare @accounting table (
    ItemNumber varchar(50) not null,
    TotalInventoryValue decimal not null
)

--Mock up some inventory balances
INSERT INTO @inventory VALUES ('ABC123', 'WLA1', 312, 7.5)
INSERT INTO @inventory VALUES ('ABC123', 'WLA2', 146, 7.5)
INSERT INTO @inventory VALUES ('ZZZ99', 'WLA3', 47, 13.99)
INSERT INTO @inventory VALUES ('zzz99', 'WLA4', 91, 13.99)
INSERT INTO @inventory VALUES ('xxccM', 'WLA5', 32, 245.25)
INSERT INTO @inventory VALUES ('xxddM', 'WLA6', 15, 747.47)

--Mock up some accounting balances
INSERT INTO @accounting VALUES ('ABC123', 3435)
INSERT INTO @accounting VALUES ('ZZZ99', 1930.62)
INSERT INTO @accounting VALUES ('xxccM', 7602.75)
INSERT INTO @accounting VALUES ('fbr77', 17.99)

--TODO-CHALLENGE: Write a query to reconcile matches/differences between the inventory and accounting tables
--SELECT * FROM ...
select  distinct
case --Conditional to tell which item number, because due to the outer join and the dataset, we have some items with no accounting data
    when a.ItemNumber is null and i1.ItemNumber is null then i2.ItemNumber
    when a.ItemNumber is null and i2.ItemNumber is null then i1.ItemNumber
    when a.ItemNumber is not null then a.ItemNumber
end "ItemNumber",
a.TotalInventoryValue, 
case --Conditional that shows the total number for the item number in the warehouses, combining if there are multiple locations. Admittedly, this only works if there is 2 or fewer locations per item. 
    when i2.ItemNumber is null then (i1.QuantityOnHand*i1.PricePerItem) 
    when i1.ItemNumber is null then (i2.QuantityOnHand*i2.PricePerItem) 
    else (i1.QuantityOnHand * i1.PricePerItem) + (i2.QuantityOnHand * i2.PricePerItem) 
end "Total in Warehouses"
from @accounting as a
full outer join @inventory as i1
    on UPPER(a.ItemNumber) = UPPER(i1.ItemNumber)
left join @inventory as i2
    on UPPER(a.ItemNumber) = UPPER(i2.ItemNumber)
    and i1.WarehouseLocation <> i2.WarehouseLocation 
