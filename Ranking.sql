--view the data set
SELECT *  FROM Ranking;

--create a new column for bank code
ALTER TABLE Ranking
ADD Bank VARCHAR(10);

--input the bank code into the bank column
UPDATE Ranking
SET Bank = SUBSTRING(Transaction_Code, 1, CHARINDEX('-', Transaction_Code) - 1);  --This crops the string before the '-' symbol

--create a column for month
ALTER TABLE Ranking
ADD Month VARCHAR(20);

--convert and enter the month data into the month column
UPDATE Ranking
SET Month = FORMAT(Transaction_Date, 'MMMM')  --This is a month name converstion
FROM Ranking;

-- add a column for ranking
ALTER TABLE Ranking
ADD Bank_Rank_Per_Month INT;

--pivot the data by bank and month, then ranked by month where the bank with the highest value is listed first.  
SELECT 
    [Month],
    Bank, 
    SUM(Value) AS Total  --this is the sum query
FROM Ranking
GROUP BY BANK,[Month]
ORDER BY [Month], Total DESC;

--Assign a rank to the Bank, based on each month.
SELECT 
    [Month],
    Bank, 
    SUM(Value) AS Total,
    DENSE_RANK() OVER (PARTITION BY [Month] ORDER BY SUM(Value) DESC) AS Bank_Rank_Per_Month   --this is the bank ranking query   
 FROM Ranking
GROUP BY [Month], Bank;

--instead of adding these pivoted values to the current table, create and insert into a new table
CREATE TABLE Ranking_Updated(
    Month VARCHAR(20),
    Bank VARCHAR(20),
    Total INT,
    Bank_Rank_Per_Month INT
)

--insert date into new updated table
INSERT INTO Ranking_Updated(Month, Bank, Total, Bank_Rank_Per_Month)
SELECT 
    [Month],
    Bank, 
    SUM(Value) AS Total,
    DENSE_RANK() OVER (PARTITION BY [Month] ORDER BY SUM(Value) DESC) AS Bank_Rank_Per_Month   --this line is the ranking query   
 FROM Ranking
GROUP BY [Month], Bank;

--Add two columns for future calculations. Average Rank per Bank and Average Transcation Value per Rank
ALTER TABLE Ranking_Updated
ADD Average_Rank_Per_Bank DECIMAL(4,2);

ALTER TABLE Ranking_Updated
ADD Average_Transaction_Value_Per_Rank DECIMAL(10,2)

--update Average Rank per Bank column first
WITH AvgRankCTE AS (
    SELECT
        *,
        AVG(Bank_Rank_Per_Month * 1.00) OVER (PARTITION BY Bank) AS NewAverageRank
    FROM Ranking_Updated
)
UPDATE AvgRankCTE
SET Average_Rank_Per_Bank = NewAverageRank;
 
--Update the Average Transaction Value Per Rank
WITH AvgRankCTE AS (
    SELECT
        *,
        AVG(Total*1.00) OVER(PARTITION BY Bank_Rank_Per_Month) AS NewTransactionValue
    FROM Ranking_Updated
)
UPDATE AvgRankCTE
SET Average_Transaction_Value_Per_Rank = NewTransactionValue;
 

--Extra Code for selecting partition data

--this query finds the average rank per bank 
SELECT
    Month,
    Bank,
    Bank_Rank_Per_Month,
    [Average_Rank_Per_Bank] = AVG(Bank_Rank_Per_Month*1.00) OVER(PARTITION BY Bank) 
FROM Ranking_Updated;

--This query is to find the average transaction value per rank
SELECT 
    Month,
    Bank,
    Bank_Rank_Per_Month,
    Total,
    Average_Transaction_Value_Per_Rank = AVG(Total*1.00) OVER(PARTITION BY Bank_Rank_Per_Month)
FROM Ranking_Updated  