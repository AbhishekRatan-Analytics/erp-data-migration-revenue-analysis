CREATE database sales_pipeline;

USE sales_pipeline;

CREATE TABLE accounts (
    account VARCHAR(100) PRIMARY KEY,
    sector VARCHAR(100),
    year_established INT,
    revenue DECIMAL(15,2),
    employees INT,
    office_location VARCHAR(100),
    subsidiary_of VARCHAR(100)
);

CREATE TABLE products (
    products VARCHAR(100) PRIMARY KEY,
    series VARCHAR(100),
    sales_price DECIMAL(10,2)
    );
    
    CREATE TABLE sales_team (
    sales_agent VARCHAR(100) PRIMARY KEY,
    manager VARCHAR(100),
    regional_office VARCHAR(100)
);


CREATE TABLE sales_pipeline (
    opportunity_id VARCHAR(100) PRIMARY KEY,
    sales_agent VARCHAR(100),
    product VARCHAR(100),
    account VARCHAR(100),
    deal_stage VARCHAR(50),
    engage_date DATE,
    close_date DATE,
    close_value DECIMAL(15,2)
);


SELECT COUNT(*) FROM accounts;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM sales_pipeline;
SELECT COUNT(*) FROM sales_team;

SELECT COUNT(*) FROM sales_pipeline
WHERE engage_date IS NULL;

DESCRIBE sales_pipeline;

SELECT COUNT(*) AS null_engage_dates
FROM sales_pipeline
WHERE engage_date IS NULL;


SELECT COUNT(*) AS zero_dates
FROM sales_pipeline
WHERE engage_date = '0000-00-00';

SELECT * 
FROM sales_pipeline
WHERE close_value IS NULL;


-- Finding Deals with no matching Account (Referential Integrity Check)
SELECT 
    p.opportunity_id, 
    p.account AS Missing_Account
FROM sales_pipeline p
LEFT JOIN accounts a ON p.account = a.account
WHERE a.account IS NULL;


-- Price Variance Check
SELECT 
    p.opportunity_id, 
    p.product AS Pipeline_Product, 
    p.close_value AS Actual_Sold_Price, 
    pr.sales_price AS Master_List_Price,
    (p.close_value - pr.sales_price) AS Price_Variance
FROM sales_pipeline p
INNER JOIN products pr 
    ON p.product = pr.product  -- <--- Ensure 'product' exists in BOTH tables
WHERE p.deal_stage = 'Won' 
  AND p.close_value <> pr.sales_price;
    
SELECT COLUMN_NAME, CHARACTER_MAXIMUM_LENGTH 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'products' AND COLUMN_NAME LIKE '%product%';


SELECT 
    COLUMN_NAME, 
    LENGTH(COLUMN_NAME) as NameLength,
    HEX(COLUMN_NAME) as HexValue
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'products';

SELECT 
    p.opportunity_id, 
    p.product AS Pipeline_Item, 
    pr.products AS Master_Item, -- Using the plural name from your check
    p.close_value AS Actual_Sold_Price, 
    pr.sales_price AS Master_List_Price,
    (p.close_value - pr.sales_price) AS Price_Variance
FROM sales_pipeline p
INNER JOIN products pr ON p.product = pr.products 
WHERE p.deal_stage = 'Won' 
  AND p.close_value <> pr.sales_price;
  
  SELECT 
    p.opportunity_id, 
    p.account,
    p.product AS Pipeline_Item, 
    p.close_value AS Actual_Sold_Price, 
    pr.sales_price AS Master_List_Price,
    (p.close_value - pr.sales_price) AS Price_Variance,
    -- Calculate percentage discount for risk assessment
    ROUND(((pr.sales_price - p.close_value) / pr.sales_price) * 100, 2) AS Discount_Percentage
FROM sales_pipeline p
INNER JOIN products pr ON p.product = pr.products 
WHERE p.deal_stage = 'Won' 
  AND (p.close_value - pr.sales_price) < -500 -- Focus on losses greater than $500
ORDER BY Price_Variance ASC; -- Show the biggest losses at the top
  
  -- Step A: Add a Validation Flag column to your staging table
ALTER TABLE sales_pipeline 
ADD COLUMN Migration_Status VARCHAR(50) DEFAULT 'Ready';

-- Disable safe mode temporarily
SET SQL_SAFE_UPDATES = 0;

-- Step B: Flag High-Risk Rows
UPDATE sales_pipeline p
INNER JOIN products pr ON p.product = pr.products
SET p.Migration_Status = 'Review_Required_Price_Gap'
WHERE p.deal_stage = 'Won' 
  AND (p.close_value - pr.sales_price) < -500;

-- Turn safe mode back on for security
SET SQL_SAFE_UPDATES = 1;
  
  SELECT Migration_Status, COUNT(*) as Record_Count
FROM sales_pipeline
GROUP BY Migration_Status;
  
  -- Migration to Production Table (ERP_Final_SalesOrders)
INSERT INTO ERP_Final_SalesOrders (LegacyID, AccountName, ProductName, TotalValue, Status)
SELECT 
    p.opportunity_id,
    UPPER(p.account), -- Standardization
    p.product,
    p.close_value,
    'Ready_to_Invoice' -- Initial ERP status
FROM sales_pipeline p
WHERE p.Migration_Status = 'Ready'; -- The "Quality Filter"
  
  SHOW TABLES;
  
  -
  
  
  
  
DROP TABLE IF EXISTS ERP_Final_SalesOrders;

CREATE TABLE ERP_Final_SalesOrders (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    LegacyID VARCHAR(50),
    AccountName VARCHAR(255),
    ProductName VARCHAR(100),
    TotalValue DECIMAL(18,2),
    Status VARCHAR(50),
    MigrationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO ERP_Final_SalesOrders (LegacyID, AccountName, ProductName, TotalValue, Status)
SELECT 
    p.opportunity_id,
    UPPER(p.account),
    p.product,
    p.close_value,
    'Ready_to_Invoice'
FROM sales_pipeline p
WHERE p.Migration_Status = 'Ready';

-- Final Migration Reconciliation Report
SELECT 
    'Total Legacy Records' AS Metric, COUNT(*) AS Value FROM sales_pipeline
UNION ALL
SELECT 
    'Records Flagged for Review', COUNT(*) FROM sales_pipeline WHERE Migration_Status <> 'Ready'
UNION ALL
SELECT 
    'Successfully Migrated (Target)', COUNT(*) FROM ERP_Final_SalesOrders
UNION ALL
SELECT 
    'Financial Tie-back (Legacy Total Value)', SUM(close_value) FROM sales_pipeline WHERE Migration_Status = 'Ready'
UNION ALL
SELECT 
    'Financial Tie-back (ERP Total Value)', SUM(TotalValue) FROM ERP_Final_SalesOrders;
    
SELECT 
    SUM(pr.sales_price - p.close_value) AS Total_Revenue_Leakage
FROM sales_pipeline p
INNER JOIN products pr ON p.product = pr.products
WHERE p.Migration_Status = 'Review_Required_Price_Gap';


-- Consultant Query: Analyzing Dynamic Credit Risk based on Customer Revenue
SELECT 
    a.account,
    a.sector,
    a.revenue AS Annual_Revenue,
    SUM(p.close_value) AS Current_Pipeline_Exposure,
    -- Rule: Credit Limit is set at 5% of their reported Annual Revenue
    (a.revenue * 0.05) AS Calculated_Credit_Limit,
    CASE 
        WHEN SUM(p.close_value) > (a.revenue * 0.05) THEN 'CREDIT_HOLD: Exposure High'
        ELSE 'PASS: Within Limit'
    END AS Credit_Status
FROM sales_pipeline p
JOIN accounts a ON p.account = a.account
WHERE p.deal_stage = 'Won'
GROUP BY a.account, a.sector, a.revenue
HAVING SUM(p.close_value) > (a.revenue * 0.05);


-- Adding the Credit Status column to your ERP Production table
ALTER TABLE ERP_Final_SalesOrders 
ADD COLUMN Credit_Status VARCHAR(50) DEFAULT 'Approved';

-- Flagging the high-risk accounts we found in the stress test
SET SQL_SAFE_UPDATES = 0;

UPDATE ERP_Final_SalesOrders
SET Credit_Status = 'CREDIT_HOLD'
WHERE AccountName IN ('OPENTECH', 'PLUSSTRIP', 'ISELECTRICS', 'SUNNAMPLEX');

SET SQL_SAFE_UPDATES = 1;


-- Project Gamma: Total Revenue Leakage & Variance Analysis
SELECT 
    'Gross Potential (Legacy)' AS Category, 
    SUM(close_value) AS Amount 
FROM sales_pipeline 
WHERE deal_stage = 'Won'

UNION ALL

-- Pricing Leakage (The 147 records from Alpha)
SELECT 
    'Pricing Leakage (Quarantined)', 
    SUM(close_value) 
FROM sales_pipeline 
WHERE Migration_Status = 'Review_Required_Price_Gap'

UNION ALL

-- Credit Risk Leakage (The 236 records from Beta)
SELECT 
    'Credit Risk Leakage (Blocked)', 
    SUM(TotalValue) 
FROM ERP_Final_SalesOrders 
WHERE Credit_Status = 'CREDIT_HOLD'

UNION ALL

-- Net Realizable Revenue (The Clean "Ready" orders)
SELECT 
    'Net Realizable Revenue (Clean)', 
    SUM(TotalValue) 
FROM ERP_Final_SalesOrders 
WHERE Status = 'Ready_to_Invoice' 
  AND Credit_Status = 'Approved';