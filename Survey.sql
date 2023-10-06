
--This dataset looks at survey scores for mobile and online surveys, the aim is to clean up the data, explore summaries and finally look at how users will be categorised based on which platform they favour

--Review the mobile results first 
SELECT TOP (20)
    Customer_ID,
    Mobile_App_Ease_of_Use,
    Mobile_App_Ease_of_Access,
    Mobile_App_Navigation,
    Mobile_App_Likelihood_to_Recommend,
    Mobile_App_Overall_Rating
 FROM Survey

 --Lets create a new table that adds a column for mobile or online, streamline the survey results and drops the overall rankings
 CREATE TABLE Survey_Updated(
    Customer_ID INT,
    Mobile_Or_Online VARCHAR,
    Ease_Of_Use INT,
    Ease_Of_Access INT,
    App_Navigation INT,
    Likelihood_To_Recommend INT,
 )

--Lets enter the mobile details first for the 4 survey results. We dont need overall, and we will update Survey Type later
INSERT INTO Survey_Updated (Customer_ID, Ease_Of_Use, Ease_Of_Access, App_Navigation, Likelihood_To_Recommend)
SELECT  
    Customer_ID,
    Mobile_App_Ease_of_Use,
    Mobile_App_Ease_of_Access,
    Mobile_App_Navigation,
    Mobile_App_Likelihood_to_Recommend
 FROM Survey

--Update the Survey type to M for mobile
UPDATE Survey_Updated
SET Mobile_Or_Online = 'M'
WHERE Mobile_Or_Online IS NULL;

--Now we enter the online survey results
INSERT INTO Survey_Updated (Customer_ID, Ease_Of_Use, Ease_Of_Access, App_Navigation, Likelihood_To_Recommend)
SELECT  
    Customer_ID,
    Online_Interface_Ease_of_Use,
    Online_Interface_Ease_of_Access,
    Online_Interface_Navigation,
    Online_Interface_Likelihood_to_Recommend
 FROM Survey

--then set the remaining survey type to O for online
UPDATE Survey_Updated
SET Mobile_Or_Online = 'O'
WHERE Mobile_Or_Online IS NULL;

--averages of both online and mobile scores, as union
SELECT
    'M' AS Mobile_Or_Online,
    AVG(Ease_Of_Use*1.0) AS Ease_Of_Use,
    AVG(Ease_Of_Access*1.0) AS Ease_Of_Access,
    AVG(App_Navigation*1.0) AS App_Navigation,
    AVG(Likelihood_To_Recommend*1.0) AS Likelihood_To_Recommend
FROM Survey_Updated
WHERE Mobile_Or_Online = 'M'
GROUP BY Mobile_Or_Online

UNION

SELECT
    'O' AS Mobile_Or_Online,
    AVG(Ease_Of_Use*1.0) AS Ease_Of_Use,
    AVG(Ease_Of_Access*1.0) AS Ease_Of_Access,
    AVG(App_Navigation*1.0) AS App_Navigation,
    AVG(Likelihood_To_Recommend*1.0) AS Likelihood_To_Recommend
FROM Survey_Updated
WHERE Mobile_Or_Online = 'O'
GROUP BY Mobile_Or_Online;

--create a table to store these values
CREATE TABLE Survey_Summary (
    Mobile_Or_Online VARCHAR,
    Ease_Of_Use DECIMAL (4,2),
    Ease_Of_Access DECIMAL (4,2),
    App_Navigation DECIMAL (4,2),
    Likelihood_To_Recommend DECIMAL (4,2)    
)

--update the table with the average score results for mobile
INSERT INTO Survey_Summary (Ease_Of_Use, Ease_Of_Access, App_Navigation, Likelihood_To_Recommend)
SELECT 
    AVG(Ease_Of_Use*1.0),
    AVG(Ease_Of_Access*1.0),
    AVG(App_Navigation*1.0),
    AVG(Likelihood_To_Recommend*1.0)
FROM Survey_Updated
WHERE Mobile_Or_Online = 'M';

--update the table with the avergae scores for online
INSERT INTO Survey_Summary (Ease_Of_Use, Ease_Of_Access, App_Navigation, Likelihood_To_Recommend)
SELECT 
    AVG(Ease_Of_Use*1.0),
    AVG(Ease_Of_Access*1.0),
    AVG(App_Navigation*1.0),
    AVG(Likelihood_To_Recommend*1.0)
FROM Survey_Updated
WHERE Mobile_Or_Online = 'O';
 
--update the mobile column
UPDATE Survey_Summary
SET Mobile_Or_Online = 'M';

--Update the online column
UPDATE Survey_Summary
SET Mobile_Or_Online = 'O'
WHERE Mobile_Or_Online IS NULL;

--this finds the difference between columns, LAG allows us to calculate the difference between a value and what came before it
SELECT  
  Ease_Of_Use - LAG(Ease_Of_Use) OVER(ORDER BY Mobile_Or_Online) AS Ease_Of_Use,
  Ease_Of_Access - LAG(Ease_Of_Access) OVER(ORDER BY Mobile_Or_Online) AS Ease_Of_Access,
  App_Navigation - LAG(App_Navigation) OVER(ORDER BY Mobile_Or_Online) AS App_Navigation,
  Likelihood_To_Recommend - LAG(Likelihood_To_Recommend) OVER(ORDER BY Mobile_Or_Online) AS Likelihood_To_Recommend
FROM Survey_Summary

--enter the above into the summary table
INSERT INTO Survey_Summary (Ease_Of_Use, Ease_Of_Access, App_Navigation, Likelihood_To_Recommend)
SELECT
  Ease_Of_Use - LAG(Ease_Of_Use) OVER(ORDER BY Mobile_Or_Online) AS Ease_Of_Use,
  Ease_Of_Access - LAG(Ease_Of_Access) OVER(ORDER BY Mobile_Or_Online) AS Ease_Of_Access,
  App_Navigation - LAG(App_Navigation) OVER(ORDER BY Mobile_Or_Online) AS App_Navigation,
  Likelihood_To_Recommend - LAG(Likelihood_To_Recommend) OVER(ORDER BY Mobile_Or_Online) AS Likelihood_To_Recommend
FROM Survey_Summary

--Here we will add a D to denote difference between Mobile or Online
UPDATE Survey_Summary
SET Mobile_Or_Online = 'D'
WHERE Ease_Of_Use = 0.06;

--lets remove the null row, the null row is a byproduct of using lag calculations
DELETE FROM Survey_Summary
WHERE Mobile_Or_Online IS NULL;

--This completes our Survey Summary table, it will host average ratings for online and mobile and the difference between us

--Now we need to understand the difference between overall scores as an average, first mobile
SELECT
    Customer_ID,
    (AVG(Ease_Of_Use*1.0)+AVG(Ease_Of_Access*1.0)+AVG(App_Navigation*1.0)+AVG(Likelihood_To_Recommend*1.0)) / 4.00 AS Mobile_Overall
FROM Survey_Updated
WHERE Mobile_Or_Online = 'M'
GROUP BY Customer_ID;

--Then Online
SELECT
    Customer_ID,
    (AVG(Ease_Of_Use*1.0)+AVG(Ease_Of_Access*1.0)+AVG(App_Navigation*1.0)+AVG(Likelihood_To_Recommend*1.0)) / 4.00 AS Online_Overall
FROM Survey_Updated
WHERE Mobile_Or_Online = 'O'
GROUP BY Customer_ID;


--Lets add these findings to the Survey Updated table as its own column
ALTER TABLE Survey_Updated
ADD Rating_Overall NUMERIC (4,2);

--Update the four 4 scores into a new overall column, note that we do not consider online or mobile or customer scores.
UPDATE Survey_Updated
SET Rating_Overall = (Ease_Of_Use + Ease_Of_Access + App_Navigation + Likelihood_To_Recommend) / 4.00;
 
--Now we can find the difference in the Rating_Overall score between Mobile and Overall
SELECT
  Customer_ID,
  MAX(CASE WHEN Mobile_Or_Online = 'M' THEN Rating_Overall END) - MAX(CASE WHEN Mobile_Or_Online = 'O' THEN Rating_Overall END) AS Difference
FROM Survey_Updated
GROUP BY Customer_ID; 

--we can now classify these differences into categories
WITH DifferenceCTE AS (
  SELECT
    Customer_ID,
    MAX(CASE WHEN Mobile_Or_Online = 'M' THEN Rating_Overall END) - MAX(CASE WHEN Mobile_Or_Online = 'O' THEN Rating_Overall END) AS Difference
  FROM Survey_Updated
  GROUP BY Customer_ID
)

SELECT
  Customer_ID,
  Difference,
  CASE
    WHEN Difference <= -2 THEN 'Online Superfan'
    WHEN Difference > -2 AND Difference < -1 THEN 'Online Fan'
    WHEN Difference >= -1 AND Difference <= 1 THEN 'Neutral'
    WHEN Difference > 1 AND Difference <= 2 THEN 'Mobile Fan'
    WHEN Difference > 2 THEN 'Mobile Superfan'
  END AS Difference_Group
FROM DifferenceCTE;

--With the differences categorised, we can now look at the count of each group. Establish a Common Table Expression Difference
--then count 5 categories before converting into a %
WITH DifferenceCTE AS (
  SELECT
    Customer_ID,
    MAX(CASE WHEN Mobile_Or_Online = 'M' THEN Rating_Overall END) - MAX(CASE WHEN Mobile_Or_Online = 'O' THEN Rating_Overall END) AS Difference
  FROM Survey_Updated
  GROUP BY Customer_ID
)

SELECT
  Difference_Group,
  (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM DifferenceCTE)) AS Percentage
FROM (
  SELECT
    Customer_ID,
    CASE
      WHEN Difference <= -2 THEN 'Online Superfan'
      WHEN Difference > -2 AND Difference < -1 THEN 'Online Fan'
      WHEN Difference >= -1 AND Difference <= 1 THEN 'Neutral'
      WHEN Difference > 1 AND Difference <= 2 THEN 'Mobile Fan'
      WHEN Difference > 2 THEN 'Mobile Superfan'
    END AS Difference_Group
  FROM DifferenceCTE
) AS Subquery
GROUP BY Difference_Group
ORDER BY Difference_Group;


