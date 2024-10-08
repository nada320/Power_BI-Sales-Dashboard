use SuperStore
--1. Which customer segment contributes the most to overall sales?

SELECT Segment,ROUND (SUM(d.Sales), 2) AS total_sales,
ROUND (SUM(d.Profit), 2) AS total_profit
FROM [Order Details] d, Orders o,Customer c
where d.[Order ID]=o.[Order ID] and o.[Customer ID]=c.[Customer ID] 
GROUP BY Segment
ORDER BY total_sales DESC, total_profit DESC










--2. Which sub-category has the highest average profit margin?

SELECT TOP 1 
[Sub-Category],
ROUND((SUM(d.Profit)/SUM(d.Sales))*100,2) AS Percentage_Profit_Margin
FROM product p inner join [Order Details] d on p.[Product ID]=d.[Product ID]
GROUP BY  [Sub-Category] 
ORDER BY Percentage_Profit_Margin DESC
--3. How does the sales volume vary across different territories?

SELECT  t.Territory  , SUM(Sales) as Total_Sales, SUM(Profit) as Total_Profits
FROM Territory t inner join Orders o on
t.TerritoryID= o.TerritoryID inner join [Order Details]
on [Order Details].[Order ID]=o.[Order ID]
GROUP BY t.Territory 
ORDER BY Total_Profits ASC
--4-is there a significant difference in sales volume between different order statuses?
SELECT  s.Status  , SUM(Sales) as Total_Sales,SUM(Profit) as Total_Profits
FROM status s inner join Orders o 
on s.StatusID= o.StatusID inner join [Order Details]
on [Order Details].[Order ID]=o.[Order ID]
GROUP BY s.Status
ORDER BY Total_Profits ASC
--5-What factors influence sales more: the customer segment, the territory, or the product category? Provide a 
--detailed analysis using a decomposition tree or another BI visualization.
--for Segment
SELECT c.Segment, SUM(od.Sales) AS TotalSales
FROM [Order Details] od
JOIN Orders o ON od.[Order ID] = o.[Order ID] 
JOIN Customer c ON o.[Customer ID] = c.[Customer ID]
GROUP BY c.Segment
ORDER BY TotalSales DESC;
--------------------
--for territory
SELECT t.Territory, SUM(od.Sales) AS TotalSales
FROM [Order Details] od
JOIN Orders o ON od.[Order ID]  = o.[Order ID] 
JOIN Territory t ON o.TerritoryID = t.TerritoryID
GROUP BY t.Territory
ORDER BY TotalSales DESC;
----------Product Category
SELECT p.Category, SUM(od.Sales) AS TotalSales
FROM [Order Details] od
JOIN Product p ON od.[Product ID] = p.[Product ID]
GROUP BY p.Category
ORDER BY TotalSales DESC;



--6. Identify any seasonal trends in sales volume by analyzing the order and ship dates. How do these trends 
--vary across different product categories?


SELECT 
    p.Category AS product_category,
    MONTH(o.[Order Date])AS order_month,
    SUM(d.Sales) AS total_sales,
    COUNT(*) AS number_of_orders,
    MONTH(o.[Ship Date])AS  ship_month
    FROM [Order Details] d
JOIN product p ON d.[Product ID]= p.[Product ID]
JOIN Orders o ON o.[Order ID] = d.[Order ID] 
GROUP BY p.Category,MONTH(o.[Order Date]) , MONTH(o.[Ship Date])
ORDER BY p.category, order_month;
--7-Determine the relationship between discount rates and profit margins. How do different discount levels 
--impact overall profitability?
SELECT 
    d.Discount AS discount_rate,
    SUM(d.Profit / d.Sales) * 100 AS profit_margin,
    SUM(d.Profit) AS total_profit,
    COUNT(*) AS number_of_orders
FROM [Order Details] d
GROUP BY  d.Discount
ORDER BY d.Discount;

--8Analyze the effect of order status on delivery time. Is there a significant difference in delivery times for 
--different order statuses?
SELECT 
    s.Status AS order_status,
    AVG(DATEDIFF(day, o.[Order Date] , o.[Ship Date])) AS average_delivery_time
    ,COUNT(*) AS number_of_orders
FROM Orders o inner join status s on o.StatusID=s.StatusID
WHERE o.[Ship Date] IS NOT NULL  -- Exclude orders that haven't been shipped yet
GROUP BY s.Status
ORDER BY average_delivery_time;

--9-which product sub-categories have shown the most growth in sales over the past years? Provide a yearover-year analysis

select p.[Sub-Category], sum(d.Sales) as total_sales,
YEAR(o.[Ship Date]) as ship_years from Product p inner join [Order Details] d
on p.[Product ID] = d.[Product ID]
inner join Orders o on o.[Order ID] = d.[Order ID]
group by p.[Sub-Category], YEAR(o.[Ship Date])
order by YEAR(o.[Ship Date])


--10. 
WITH sales_per_quarter AS (
    SELECT
        o.[Order Date],
        CASE
            WHEN MONTH(o.[Order Date]) IN (1, 2, 3) THEN 'Q1'
            WHEN MONTH(o.[Order Date]) IN (4, 5, 6) THEN 'Q2'
            WHEN MONTH(o.[Order Date]) IN (7, 8, 9) THEN 'Q3'
            ELSE 'Q4'
        END AS sales_quarter,
        d.Sales,
        d.Profit
    FROM 
        Orders o
    INNER JOIN 
        [Order Details] d 
    ON 
        o.[Order ID] = d.[Order ID]
)
SELECT 
    YEAR([Order Date]) AS year,
    sales_quarter,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM 
    sales_per_quarter
GROUP BY 
    YEAR([Order Date]), 
    sales_quarter
ORDER BY 
    total_sales DESC, 
    total_profit DESC, 
    year, 
    sales_quarter;