/*
Walmart Sales Data Exploration 
*/

SELECT * 
  FROM Walmart.dbo.WalmartRetailData

   -- Biggest profit by States
   
  SELECT State, AVG(Profit) as AVG_Profit
  FROM Walmart.dbo.WalmartRetailData
  GROUP BY State
  ORDER BY AVG_Profit desc

  -- Best selling months
  
  SELECT Month, AVG(Profit) as AVG_Profit
  FROM(  
  SELECT Profit, MONTH(ShipDate) as Month
  FROM Walmart.dbo.WalmartRetailData) a
  GROUP BY Month
  ORDER BY AVG_Profit DESC

  -- Best selling days in the week
  
  SELECT day, AVG(Profit) as avg_profit
  FROM(
  SELECT Profit, ShipDate, datepart(WEEKDAY, ShipDate)as day
  FROM Walmart.dbo.WalmartRetailData) a
  GROUP BY day
  ORDER BY avg_profit desc

  -- 5% most profitable customers in 2015
  
  SELECT CustomerName, Profit, percinitl
  FROM(select*, NTILE(100) OVER(partition by CustomerName order by Profit) as percinitl, YEAR(ShipDate) as Year
  FROM Walmart.dbo.WalmartRetailData) a
  WHERE percinitl < 5 and Year = 2015
  ORDER BY Profit DESC, percinitl 

  -- growth year by year
  
  SELECT year, profit_by_year, (((profit_by_year-last_year)/last_year)*100) as growth
  FROM(
  SELECT year, profit_by_year,
  LAG(profit_by_year, 1) OVER(order by year) as last_year
  FROM(
  SELECT year, SUM(profit_by_year) as profit_by_year
  FROM(
  SELECT ShipDate, YEAR(ShipDate) as year,
				SUM(Profit) profit_by_year
  FROM Walmart.dbo.WalmartRetailData
  WHERE ShipDate is not null
  GROUP BY ShipDate) a
  GROUP BY year) a 
  ) a

-- Standardize Data Format and analyzing shipping time

SELECT OrderID, ShipMode, City,
CAST(ShipDate as INT) - CAST(OrderDate as INT) as Days
FROM Walmart.dbo.WalmartRetailData
ORDER BY Days DESC

-- Ranking longest and most expencive shippment

select *
FROM(
SELECT ProductName, ShipMode, ShippingCost, Days,
RANK() OVER(Partition by ProductName order by Days, ShippingCost   ) as Rank
FROM(
SELECT  ProductName, ShipMode, ShipDate, OrderDate,ShippingCost,
CAST(ShipDate as INT) - CAST(OrderDate as INT) as Days
FROM Walmart.dbo.WalmartRetailData
GROUP BY ProductName, ShipMode, ShipDate, OrderDate,ShippingCost
 ) a
 )a
WHERE Rank <= 3
ORDER BY Rank, Days DESC, ShippingCost DESC
