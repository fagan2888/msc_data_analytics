
------ Available Variables in data:
-- Categories: ret, int, cat  -> Retail, Internet, Catalogue
-- Seasons: F or S
-- Years: 07,06,05,04, pre04
-- FirstYYMM, FirstChannel and FirstDollar
-- Monetary units: dollars, gdollars, ngdollars, orders, trips, lines, recency
-- For Retail: dollar, trips, lines, recency
-- For Internet: gdollars, ngdollars, orders, lines, recency
-- For Catalogue: gdollars, ngdollars, orders, lines, recency
------------------------------------------------------------------------
-- ambiguous / limitied fields in the data:
--    - (emails|catcir|giftsrec|newgr)(s|f)(07|06|05)
--    - giftsrec and newgr has 04|pre04 too


select * from extractsummary limit 10;

-- Top Categories By average Spend
select	
	-- 1. Total Sales
	sum(ret_total_dollar) as Ret_TotalSales,
	sum(int_total_ngdollar+int_total_gdollar) as Int_TotalSales,
	sum(cat_total_ngdollar+cat_total_gdollar) as Cat_TotalSales,
	-- 1. Average Sales
	round(avg(ret_total_dollar),2) as Ret_TotalSales,
	round(avg(int_total_ngdollar+int_total_gdollar),2) as Int_AvgSales,
	round(avg(cat_total_ngdollar+cat_total_gdollar),2) as Cat_AvgSales,
	-- Trips / Orders
	sum(ret_total_trips) as Ret_TotalTrips,
	sum(int_total_orders) as Int_TotalOrders,
	sum(cat_total_orders) as Cat_TotalOrders,
	-- Avg
	avg(ret_total_trips) as Ret_AvgTrips,
	avg(int_total_orders) as Int_AvgOrders,
	avg(cat_total_orders) as Cat_AvgOrders,
	-- 2. Sales Per Trip/Order: Basket Size
	round(sum(ret_total_dollar)/sum(ret_total_trips),2) as Ret_SalesPerTip,
	round(sum(int_total_ngdollar+int_total_gdollar)/sum(int_total_orders),2) as Int_SalesPerOrders,
	round(sum(cat_total_ngdollar+cat_total_gdollar)/sum(cat_total_orders),2) as Cat_SalesPerOrders
	
from
	extractsummary;


-- 3. Top sale channel by zipcode
select	SCF_Code,
	-- Total Sales
	sum(ret_total_dollar+int_total_ngdollar+int_total_gdollar+cat_total_ngdollar+cat_total_gdollar) as TotalSales,
	sum(ret_total_dollar) as Ret_TotalSales,
	sum(int_total_ngdollar+int_total_gdollar) as Int_TotalSales,
	sum(cat_total_ngdollar+cat_total_gdollar) as Cat_TotalSales,
	-- Average Sales
	round(avg(ret_total_dollar),2) as Ret_TotalSales,
	round(avg(int_total_ngdollar+int_total_gdollar),2) as Int_AvgSales,
	round(avg(cat_total_ngdollar+cat_total_gdollar),2) as Cat_AvgSales,
	-- Trips / Orders
	sum(ret_total_trips) as Ret_TotalTrips,
	sum(int_total_orders) as Int_TotalOrders,
	sum(cat_total_orders) as Cat_TotalOrders,
	-- Avg
	avg(ret_total_trips) as Ret_AvgTrips,
	avg(int_total_orders) as Int_AvgOrders,
	avg(cat_total_orders) as Cat_AvgOrders,
	-- Sales Per Trip/Order
	case when sum(ret_total_trips) = 0 then sum(ret_total_trips) else round(sum(ret_total_dollar)/sum(ret_total_trips),2) end as Ret_SalesPerTip,
	case when sum(int_total_orders) = 0 then sum(ret_total_trips) else round(sum(int_total_ngdollar+int_total_gdollar)/sum(int_total_orders),2)  end as Int_SalesPerOrders,
	case when sum(cat_total_orders) = 0 then sum(ret_total_trips) else round(sum(cat_total_ngdollar+cat_total_gdollar)/sum(cat_total_orders),2) end as Cat_SalesPerOrders
	
from
	extractsummary
group by
	SCF_Code
order by
	TotalSales desc
limit 10
;


-- 4. Time between signup and first purchase
select acqdate, firstyymm, to_date(acqdate,'YYYYMM') - to_date(firstyymm,'YYYYMM') as TimeBetweenSignup,
	to_date(firstyymm,'YYYYMM') - to_date(acqdate,'YYYYMM') as TimeBetweenSignup2
	from extractsummary
	order by TimeBetweenSignup
	limit 10;



-- 5. What sale channel has experiecne the greatest growth between 2004-2007?
SELECT	
	-- Total Retail 2004 - 2007
	SUM(ret_total04) AS ret_total04,
	SUM(ret_total05) AS ret_total05,
	SUM(ret_total06) AS ret_total06,
	SUM(ret_total07) AS ret_total07,
	-- Total Internet 2004 - 2007
	SUM(int_total_orders04) AS int_total04,
	SUM(int_total_orders05) AS int_total05,
	SUM(int_total_orders05) AS int_total06,
	SUM(int_total_orders07) AS int_total07,
	-- Total Catalogue 2004 - 2007
	SUM(cat_total_orders04) AS cat_total04,
	SUM(cat_total_orders05) AS cat_total05,
	SUM(cat_total_orders06) AS cat_total06,
	SUM(cat_total_orders07) AS cat_total07,

FROM extractsummary;



