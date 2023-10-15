--all of our 12 tables follow the same format with the table name denoting the different months
select * from Stocks_jan;

--lets create a master table, then we will import the data in from all 12 months
CREATE TABLE Stocks (
    id INT,
    File_Date DATE,
    first_name VARCHAR (50),
    last_name VARCHAR (50),
    Ticker VARCHAR (20),
    Market VARCHAR (20),
    Stock_Name VARCHAR (100),
    Market_Cap VARCHAR (20), --this will be a string for now, but will see if we need numbers later on
    Purchase_Price DECIMAL (10,2)
);

--well insert each table into stocks starting from Jan
INSERT INTO Stocks (id, first_name, last_name, Ticker, Market, Stock_Name, Market_Cap, Purchase_Price)
SELECT
    id,     
    first_name, 
    last_name, 
    Ticker, 
    Market, 
    Stock_Name, 
    Market_Cap, 
    Purchase_Price
FROM Stocks_dec; --change this for each month

--update the empty column to the allocated month
UPDATE Stocks
SET File_Date = '01/12/2023'  --change the middle column 
FROM Stocks
WHERE File_Date IS NULL;

--The market cap column needs cleaning, first we remove any rows with n/a values in the market cap column
DELETE FROM Stocks 
WHERE Market_Cap = 'n/a'
 
select market_cap from stocks
ORDER BY market_cap desc;

--our list of market cap contains b for billions and m for millions. we can use case when to change them into numbers.
SELECT
    CASE
        WHEN RIGHT(market_cap, 1) = 'B' THEN CAST(SUBSTRING(market_cap, 2, LEN(market_cap) - 2) AS DECIMAL(18, 2)) * 1e9
        WHEN RIGHT(market_cap, 1) = 'M' THEN CAST(SUBSTRING(market_cap, 2, LEN(market_cap) - 2) AS DECIMAL(18, 2)) * 1e6
        ELSE NULL
    END AS Market_Cap_Num
FROM stocks;

--as the market_cap column is a string, lets instead create a column for its associated numbers.
ALTER TABLE Stocks
ADD Market_Cap_Num DECIMAL (18,2);

--Now we can enter the above findings into the market_cap_num column
UPDATE Stocks
SET Market_Cap_Num = CASE
    WHEN RIGHT(Market_Cap, 1) = 'B' THEN CAST(SUBSTRING(Market_Cap, 2, LEN(Market_Cap) - 2) AS DECIMAL(18, 2)) * 1e9
    WHEN RIGHT(Market_Cap, 1) = 'M' THEN CAST(SUBSTRING(Market_Cap, 2, LEN(Market_Cap) - 2) AS DECIMAL(18, 2)) * 1e6
    ELSE NULL
END;

--now we need to categorise our purchase price. low, medium, high, very high
SELECT
  Purchase_Price,
  CASE
    WHEN Purchase_Price <= 24999.99 THEN 'Low'
    WHEN Purchase_Price > 25000 AND Purchase_Price <= 49999.99 THEN 'Medium'
    WHEN Purchase_Price > 50000 AND Purchase_Price <= 74999.99 THEN 'High'
    WHEN Purchase_Price > 75000 THEN 'Very High'
  END AS Purchase_Price_Group
FROM Stocks;

--Add a column for this new category
ALTER TABLE Stocks
ADD Purchase_Price_Group VARCHAR(20);

--enter the categories into table
UPDATE Stocks
SET Purchase_Price_Group = CASE
    WHEN Purchase_Price <= 24999.99 THEN 'Low'
    WHEN Purchase_Price > 25000 AND Purchase_Price <= 49999.99 THEN 'Medium'
    WHEN Purchase_Price > 50000 AND Purchase_Price <= 74999.99 THEN 'High'
    WHEN Purchase_Price > 75000 THEN 'Very High'
  END;

--now we need to categorise our Market Cap. Small, Medium, Large, Huge.
SELECT
  Market_Cap_Num,
  CASE
    WHEN Market_Cap_Num <= 100000000 THEN 'Low'
    WHEN Market_Cap_Num > 100000000 AND Market_Cap_Num <= 1000000000 THEN 'Medium'
    WHEN Market_Cap_Num > 1000000000 AND Market_Cap_Num <= 100000000000 THEN 'High'
    WHEN Market_Cap_Num > 100000000000 THEN 'Huge'
  END AS Market_Cap_Num_Group
FROM Stocks;

--Add a column for this new category
ALTER TABLE Stocks
ADD Market_Cap_Num_Group VARCHAR(20);

--
UPDATE Stocks
SET Market_Cap_Num_Group = CASE
    WHEN Market_Cap_Num <= 100000000 THEN 'Low'
    WHEN Market_Cap_Num > 100000000 AND Market_Cap_Num <= 1000000000 THEN 'Medium'
    WHEN Market_Cap_Num > 1000000000 AND Market_Cap_Num <= 100000000000 THEN 'High'
    WHEN Market_Cap_Num > 100000000000 THEN 'Huge'
END;

select * from stocks;

--we need to establish rank by purchase price, where ranks are grouped by 
select top (5)
    Purchase_Price,
    file_date,
    purchase_price_group,
    Market_Cap_Num_Group
FROM stocks
WHERE Purchase_Price_Group = 'Very High' AND Market_cap_num_group = 'High' AND file_date = '01/01/2023'
ORDER BY Purchase_price DESC;
 
--we need to establish rank by purchase price, where ranks are grouped market then purchase price
SELECT  
  Purchase_Price,
  file_date,
  purchase_price_group,
  Market_Cap_Num_Group,
  RANK() OVER (ORDER BY Market_cap_num_group DESC, Purchase_price DESC) AS ranking
FROM Stocks;