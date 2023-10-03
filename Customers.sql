--create a new table to incorporate the new values
CREATE TABLE Customers (
    ID INT,
    Joining_Date VARCHAR(20), --Joining date as a string since its a single number, will convert to date later
    Account_Type VARCHAR(20),
    Date_Of_Birth DATE,
    Ethnicity VARCHAR(20),
);

--insert the data elements from April, segmented by ID and joining date into Customers table. Note the distinct to avoid dupplicates.
INSERT INTO Customers (ID, Joining_Date, Account_Type, Date_of_birth, Ethnicity)
SELECT DISTINCT
    a.id, a.[Joining Day],
    MAX(CASE WHEN a.demographic = 'Account Type' THEN a.Value END) AS Account_Type,
    MAX(CASE WHEN a.demographic = 'Date of Birth' THEN a.Value END) AS Date_Of_Birth,
    MAX(CASE WHEN a.demographic = 'Ethnicity' THEN a.Value END) AS Ethnicity
FROM December$ a
GROUP BY a.id, a.[Joining Day];



--Concate the single number into a string date, will convert to date later
--UPDATE Customers
--SET Joining_Date = CONCAT('4/', Joining_Date, '/2023')
--FROM Customers;

--this function will convert the joining date to a string date, only if the number is numeric
UPDATE Customers
SET Joining_Date = CASE
    WHEN ISNUMERIC(Joining_Date) = 1 THEN CONCAT('12/', Joining_Date, '/2023')
    ELSE Joining_Date
END;
--This completes the conversion for Jan, the first table. Now we update the Customers with the next month data

--The August table has incorrect title headers, specifically the Demographic spelling
SELECT TOP(5) * FROM August$;

--update the column name
sp_rename 'August$.Demographic', 'August$.Demographic', 'COLUMN';

--add a column
ALTER TABLE August$
ADD Demographic VARCHAR(50);

--input the new column into Demographic
UPDATE August$
SET Demographic = [August$.Demographic]
WHERE Demographic IS NULL;

--drop the duplicated table
ALTER TABLE August$
DROP COLUMN [August$.Demographic]

--The October table has incorrect title headers, specifically the Demographic spelling
SELECT * FROM October$;

--Add a column
ALTER TABLE October$
ADD Demographic VARCHAR(50);

--Update demographic(correct) data from demagraphic(incorrect)
UPDATE October$
SET Demographic = Demagraphic
WHERE Demographic IS NULL;

--drop the duplicated table
ALTER TABLE October$
DROP COLUMN Demagraphic;
 
--Convert the Joined Date column, which is a string into date format.
Update Customers
SET Joining_Date =  CAST(Joining_date AS DATE) 
FROM Customers; 