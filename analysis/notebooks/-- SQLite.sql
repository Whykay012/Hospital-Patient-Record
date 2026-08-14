-- SQLite
SELECT COUNT(*) AS total_rows
FROM sales;

SELECT
    SUM(Sales) AS total_sales,
    SUM(Quantity) AS total_quantity,
    AVG(Sales) AS average_transaction
FROM sales;

--Sales by Branch
SELECT
    Branch,
    ROUND(SUM(Sales), 2) AS total_sales
FROM sales
GROUP BY Branch
ORDER BY total_sales DESC;

--Sales by Product Line
SELECT
    "Product line",
    ROUND(SUM(Sales), 2) AS total_sales
FROM sales
GROUP BY "Product line"
ORDER BY total_sales DESC;

--Quantity Sold by Product Line
SELECT
    "Product line",
    SUM(Quantity) AS total_quantity_sold
FROM sales
GROUP BY "Product line"
ORDER BY total_quantity_sold DESC;

--Gross Income by Product Line
SELECT
    "Product line",
    ROUND(SUM("gross income"), 2) AS total_gross_income
FROM sales
GROUP BY "Product line"
ORDER BY total_gross_income DESC;

--Average Transaction Value by Product Line
SELECT
    "Product line",
    ROUND(AVG(Sales), 2) AS average_transaction_value
FROM sales
GROUP BY "Product line"
ORDER BY average_transaction_value DESC;

-- Average Transaction Value by Customer Type
SELECT
    "Customer type",
    ROUND(AVG(Sales), 2) AS average_transaction_value
FROM sales
GROUP BY "Customer type"
ORDER BY average_transaction_value DESC;

-- Average Transaction Value by Gender

SELECT
    Gender,
    ROUND(AVG(Sales), 2) AS average_transaction_value
FROM sales
GROUP BY Gender
ORDER BY average_transaction_value DESC;

-- Total Sales by Customer Type
SELECT
    "Customer type",
    ROUND(SUM(Sales), 2) AS total_sales
FROM sales
GROUP BY "Customer type"
ORDER BY total_sales DESC;

-- Number of Transactions by Customer Type
SELECT
    "Customer type",
    COUNT(*) AS number_of_transactions
FROM sales
GROUP BY "Customer type"
ORDER BY number_of_transactions DESC;

--Total Sales by Gender
SELECT
    Gender,
    ROUND(SUM(Sales), 2) AS total_sales
FROM sales
GROUP BY Gender
ORDER BY total_sales DESC;


-- Number of Transactions by Gender
SELECT
    Gender,
    COUNT(*) AS number_of_transactions
FROM sales
GROUP BY Gender
ORDER BY number_of_transactions DESC;

-- Average Transaction Value by Gender
SELECT
    Gender,
    ROUND(AVG(Sales), 2) AS average_transaction_value
FROM sales
GROUP BY Gender
ORDER BY average_transaction_value DESC;

-- Number of Transactions by Payment Method
SELECT
    Payment,
    COUNT(*) AS number_of_transactions
FROM sales
GROUP BY Payment
ORDER BY number_of_transactions DESC;

-- Average Transaction Value by Payment Method
SELECT
    Payment,
    ROUND(AVG(Sales), 2) AS average_transaction_value
FROM sales
GROUP BY Payment
ORDER BY average_transaction_value DESC;

-- Total Sales by Payment Method

SELECT
    Payment,
    ROUND(SUM(Sales), 2) AS total_sales
FROM sales
GROUP BY Payment
ORDER BY total_sales DESC;
-- Total Sales by Month

SELECT
    Month_Name,
    ROUND(SUM(Sales), 2) AS total_sales
FROM sales
GROUP BY Month, Month_Name
ORDER BY Month;

-- Number of Transactions by Month

SELECT
    Month_Name,
    COUNT(*) AS number_of_transactions
FROM sales
GROUP BY Month, Month_Name
ORDER BY Month;

-- Average Transaction Value by Month
SELECT
    Month_Name,
    ROUND(AVG(Sales), 2) AS average_transaction_value
FROM sales
GROUP BY Month, Month_Name
ORDER BY Month;

-- Sales by Day of Week
SELECT
    Day_Name,
    ROUND(SUM(Sales), 2) AS total_sales
FROM sales
GROUP BY Day_of_Week, Day_Name
ORDER BY total_sales DESC;

-- Number of Transactions by Day
SELECT
    Day_Name,
    COUNT(*) AS number_of_transactions
FROM sales
GROUP BY Day_of_Week, Day_Name
ORDER BY number_of_transactions DESC;

-- Average Transaction Value by Day
SELECT
    Day_Name,
    ROUND(AVG(Sales), 2) AS average_transaction_value
FROM sales
GROUP BY Day_of_Week, Day_Name
ORDER BY average_transaction_value DESC;

-- Total Sales by Hour

SELECT
    Hour,
    ROUND(SUM(Sales), 2) AS total_sales
FROM sales
GROUP BY Hour
ORDER BY total_sales DESC;

-- Number of Transactions by Hour

SELECT
    Hour,
    COUNT(*) AS number_of_transactions
FROM sales
GROUP BY Hour
ORDER BY number_of_transactions DESC;

-- Average Transaction Value by Hour

SELECT
    Hour,
    ROUND(AVG(Sales), 2) AS average_transaction_value
FROM sales
GROUP BY Hour
ORDER BY average_transaction_value DESC;

--We've covered the full analysis we planned:

1. Overall business performance
Total rows
Total sales
Total quantity
Average transaction value
2. Branch analysis
Sales by branch
Average transaction value by branch
Gross income by branch
3. Product-line analysis
Sales by product line
Quantity sold by product line
Gross income by product line
Average transaction value by product line
4. Customer analysis
Sales by customer type
Number of transactions by customer type
Average transaction value by customer type
Sales by gender
Number of transactions by gender
Average transaction value by gender
5. Payment analysis
Number of transactions by payment method
Total sales by payment method
Average transaction value by payment method
6. Time analysis
Sales by month
Transactions by month
Average transaction value by month
Sales by day of week
Transactions by day of week
Average transaction value by day of week
Sales by hour
Transactions by hour
Average transaction value by hour