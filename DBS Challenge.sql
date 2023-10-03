-- change 1/2s to Online and in-person
UPDATE Details
SET Online_or_in_person =
    CASE
        WHEN Online_or_in_person = 1 THEN 'Online'
        WHEN Online_or_in_person = 2 THEN 'In Person'
    END; --


-- Add a column for bank, as char
ALTER TABLE Details
ADD Bank VARCHAR(10);

--retrieve the text before the -delimiter into the bank column
UPDATE Details
SET Bank = SUBSTRING(Transaction_Code, 1, CHARINDEX('-', Transaction_Code) - 1);

--view the bank column
Select BANK from Details;

--find the dates as quarter
SELECT DATEPART(QUARTER, Transaction_Date) AS Quarter, Transaction_Date
FROM Details;

--create a column for quarters
ALTER TABLE Details
ADD Quarter INT;

--enter the quarter dates into the quarter columns
UPDATE Details
SET Quarter = DATEPART(QUARTER, Transaction_Date);

--group the sum of values by quarter and transcation type
SELECT Online_or_In_Person, Sum(Value) AS Total_Values, Bank, Quarter
FROM Details
WHERE Bank = 'DSB'
GROUP BY Online_or_In_Person, Bank, Quarter
ORDER BY Online_or_In_Person;

-- Transpose or Pivot the data from columns into rows
SELECT Online_or_In_Person, Quarter, Amount
FROM Targets
UNPIVOT (
  Amount
  FOR Quarter IN (Q1, Q2, Q3, Q4)
) AS UnpivotedData;

--create a new temp table to enter the transpose date
CREATE TABLE TempTarget (
    Transaction_Code VARCHAR (20),
    Quarter VARCHAR (20),
    Amount VARCHAR (20), 
);

--enter the transpose date into the temp target table
 INSERT INTO TempTarget (Transaction_code, Quarter, Amount)
VALUES
    ('Online', 'q1', 72500),
    ('Online', 'q2', 70000),
    ('Online', 'q3', 60000),
    ('Online', 'q4', 60000),
    ('In-Person', 'q1', 75000),
    ('In-Person', 'q2', 70000),
    ('In-Person', 'q3', 70000),
    ('In-Person', 'q4', 60000);

--remove the q from the quarter table
UPDATE TempTarget
SET [Quarter] = TRIM(LEADING 'q' FROM Quarter);

--change the quarter to int data type
ALTER TABLE TempTarget
ALTER COLUMN Quarter INT; 

--update the tempt target to In Person, to match the details table
UPDATE TempTarget
SET Transaction_Code = 'In Person'
WHERE Transaction_Code = 'In-Person'

--add a column to details for the target values
ALTER TABLE Details
ADD Target INT;
 
--update the new target column to match the quarter and transaction code from temptarget
UPDATE Details 
SET Details.Target = TempTarget.Amount
FROM TempTarget 
LEFT JOIN Details ON Details.Online_or_In_Person = TempTarget.Transaction_code
                  AND Details.Quarter = TempTarget.Quarter;

--Add a column for Variance between the target and values
ALTER TABLE Details
ADD Variance INT;

--view table with targets and variance to target
SELECT
    Online_or_In_Person,
    Quarter,
    SUM(Value) AS Value,
    Target AS Quarterly_Targets,
    (SUM(Value) - Target) AS Variance_To_Target
FROM Details
WHERE Bank = 'DSB'
GROUP BY Online_or_In_Person, Bank, Quarter, Target
ORDER BY Online_or_In_Person;

 