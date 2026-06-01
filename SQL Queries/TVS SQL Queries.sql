use TVS_Project;

#SALES QUERIES
#1.Total Revenue Generated
SELECT 
    SUM(b.On_Road_Price) AS Total_Revenue
FROM orders o
JOIN bikes b
    ON o.Model_Code = b.Model_Code;

#2. Monthly Sales Trend
SELECT 
    YEAR(o.Order_Date) AS Order_Year,
    MONTH(o.Order_Date) AS Order_Month,
    COUNT(o.Order_ID) AS Total_Orders,
    SUM(b.On_Road_Price) AS Monthly_Revenue
FROM orders o
JOIN bikes b
    ON o.Model_Code = b.Model_Code
GROUP BY 
    YEAR(o.Order_Date),
    MONTH(o.Order_Date)
ORDER BY 
    Order_Year,
    Order_Month;

#3. Top Bike Models
SELECT 
    b.Bike_Model,
    COUNT(o.Order_ID) AS Total_Orders,
    SUM(b.On_Road_Price) AS Revenue
FROM orders o
JOIN bikes b
    ON o.Model_Code = b.Model_Code
GROUP BY b.Bike_Model
ORDER BY Revenue DESC;

#DELIVERY QUERIES
#4. Pending Deliveries
SELECT 
    COUNT(*) AS Pending_Orders
FROM orders
WHERE Actual_Delivery_Date IS NULL;

#5. Average Delivery Time
SELECT 
    AVG(
        DATEDIFF(
            Actual_Delivery_Date,
            Order_Date
        )
    ) AS Avg_Delivery_Days
FROM orders
WHERE Actual_Delivery_Date IS NOT NULL;

#6. Delivery Status Analysis
SELECT 
    CASE
        WHEN Actual_Delivery_Date IS NULL
            THEN 'Pending'
		ELSE 'Delivered'
	END AS Delivery_Status,
COUNT(*) AS Total_Orders
FROM orders
GROUP BY Delivery_Status;

#DEALER QUERIES
#7. Top Dealers by Revenue
SELECT 
    d.Dealer_Name,
    COUNT(o.Order_ID) AS Total_Orders,
    SUM(b.On_Road_Price) AS Revenue
FROM orders o
JOIN dealers d
    ON o.Dealer_Code = d.Dealer_Code
JOIN bikes b
    ON o.Model_Code = b.Model_Code
GROUP BY d.Dealer_Name
ORDER BY Revenue DESC;

#8. Revenue Contribution by Dealer
SELECT 
    d.Dealer_Name,
    SUM(b.On_Road_Price) AS Revenue
FROM orders o
JOIN dealers d
    ON o.Dealer_Code = d.Dealer_Code
JOIN bikes b
    ON o.Model_Code = b.Model_Code
GROUP BY d.Dealer_Name
ORDER BY Revenue DESC;

#9. Dealer Ranking Based on Revenue
SELECT 
    d.Dealer_Name,
    SUM(b.On_Road_Price) AS Revenue,
RANK() OVER(
        ORDER BY SUM(b.On_Road_Price) DESC
    ) AS Dealer_Rank
FROM orders o
JOIN dealers d
    ON o.Dealer_Code = d.Dealer_Code
JOIN bikes b
    ON o.Model_Code = b.Model_Code
GROUP BY d.Dealer_Name;

#ADVANCED QUERIES
#10. CTE Query (Top Performing Dealers using CTE)
WITH Dealer_Sales AS (
SELECT 
        d.Dealer_Name,
        SUM(b.On_Road_Price) AS Total_Revenue
FROM orders o
JOIN dealers d
        ON o.Dealer_Code = d.Dealer_Code
JOIN bikes b
        ON o.Model_Code = b.Model_Code
GROUP BY d.Dealer_Name
)
SELECT *
FROM Dealer_Sales
ORDER BY Total_Revenue DESC;

#11. Window Function Query ( Running Revenue Total)
SELECT 
    o.Order_Date,
    SUM(b.On_Road_Price) AS Daily_Revenue,
SUM(
        SUM(b.On_Road_Price)
    ) OVER(
        ORDER BY o.Order_Date
    ) AS Running_Total_Revenue
FROM orders o
JOIN bikes b
    ON o.Model_Code = b.Model_Code
GROUP BY o.Order_Date
ORDER BY o.Order_Date;

#12. ROW_NUMBER Query (Top Bike Model for Each Dealer)
SELECT *
FROM (
SELECT 
        d.Dealer_Name,
		b.Bike_Model,
        SUM(b.On_Road_Price) AS Revenue,
ROW_NUMBER() OVER(
PARTITION BY d.Dealer_Name
ORDER BY SUM(b.On_Road_Price) DESC
) AS Row_Num
FROM orders o
JOIN dealers d
ON o.Dealer_Code = d.Dealer_Code
JOIN bikes b
ON o.Model_Code = b.Model_Code
GROUP BY 
        d.Dealer_Name,
        b.Bike_Model
) Ranked_Models
WHERE Row_Num = 1;

#13. DENSE_RANK Query (Bike Model Revenue Ranking)
SELECT 
    b.Bike_Model,
    SUM(b.On_Road_Price) AS Revenue,
DENSE_RANK() OVER(
        ORDER BY SUM(b.On_Road_Price) DESC
    ) AS Revenue_Rank
FROM orders o
JOIN bikes b
    ON o.Model_Code = b.Model_Code
GROUP BY b.Bike_Model;

#14. Delivery Delay Analysis (Delayed Deliveries by Dealer)
SELECT 
    d.Dealer_Name,
COUNT(*) AS Delayed_Orders
FROM orders o
JOIN dealers d
    ON o.Dealer_Code = d.Dealer_Code
WHERE o.Actual_Delivery_Date >
      o.Expected_Delivery_Date
GROUP BY d.Dealer_Name
ORDER BY Delayed_Orders DESC;

#15. Revenue Contribution Percentage (Revenue Contribution Percentage by Dealer)
SELECT 
    d.Dealer_Name,
SUM(b.On_Road_Price) AS Revenue,
ROUND(
        SUM(b.On_Road_Price) * 100.0
        /
        SUM(
            SUM(b.On_Road_Price)
        ) OVER(),
        2
    ) AS Revenue_Percentage
FROM orders o
JOIN dealers d
    ON o.Dealer_Code = d.Dealer_Code
JOIN bikes b
    ON o.Model_Code = b.Model_Code
GROUP BY d.Dealer_Name
ORDER BY Revenue DESC;