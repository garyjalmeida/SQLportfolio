 select * from Fraud_Account_Information

--check for NULL values in Account Holder ID
SELECT *
FROM Fraud_Account_Information
WHERE Account_Holder_ID = ',';

--There are some account holders with more than one value. First we will find these accounts
 SELECT
  Account_Number,
  Account_Type,
  SUBSTRING(Account_Holder_ID, CHARINDEX(',', Account_Holder_ID) + 1, LEN(Account_Holder_ID)) AS Account_Holders_After_Comma,
  Balance_Date,
  Balance
FROM Fraud_Account_Information
WHERE CHARINDEX(',', Account_Holder_ID) > 0;

--Lets insert these extra accounts into the table, we will clean them up after
INSERT INTO Fraud_Account_Information(Account_Number, Account_Type, Account_Holder_ID, Balance_Date, Balance)
SELECT 
  Account_Number,
  Account_Type,
  SUBSTRING(Account_Holder_ID, CHARINDEX(',', Account_Holder_ID) + 1, LEN(Account_Holder_ID)),
  Balance_Date,
  Balance  
 FROM Fraud_Account_Information
WHERE CHARINDEX(',', Account_Holder_ID) > 0;

--now we can remove the secondary account holders listed
UPDATE Fraud_Account_Information
SET Account_Holder_ID = LEFT(Account_Holder_ID, CHARINDEX(',', Account_Holder_ID) - 1)
WHERE CHARINDEX(',', Account_Holder_ID) > 0

select * from Fraud_Account_Holders;

--client requested a 0 to be in front of the contact numbner (ie 07 instead of 7)
UPDATE Fraud_Account_Holders
SET Contact_Number = '0'+ Contact_Number;


select * from Fraud_Account_Holders;
select * from Fraud_Account_Information;

--Bring the  tables together
SELECT
  f1.Account_Holder_ID,
  f1.Name,
  f1.Date_of_Birth,
  f1.Contact_Number,
  f2.Account_Number,
  f2.Balance_Date,
  f2.Balance  
FROM Fraud_Account_Holders AS f1
JOIN Fraud_Account_Information AS f2
  ON f1.Account_Holder_ID = f2.Account_Holder_ID;
  
--
SELECT TOP (500) *
FROM Fraud_Transaction_Detail

SELECT TOP (500) *
FROM Fraud_Transaction_Path;


--triple join tables
SELECT
  f1.Account_Holder_ID,
  f2.Name,
  f2.Date_of_Birth,
  f2.Contact_Number,
  f1.Account_Number,
  f1.Balance_Date,
  f1.Balance,
  f3.Account_From,
  f3.Account_To,
  f3.Transaction_ID

FROM Fraud_Account_Information AS f1
JOIN Fraud_Account_Holders AS f2 ON f1.Account_Holder_ID = f2.Account_Holder_ID
LEFT JOIN Fraud_Transaction_Path as f3 ON f3.Account_To = f1.Account_Number;


--quad join table
 SELECT
  f1.Account_Holder_ID,
  f2.Name,
  f2.Date_of_Birth,
  f2.Contact_Number,
  f1.Account_Number,
  f1.Balance_Date,
  f1.Balance,
  f3.Account_From,
  f3.Account_To,
  f3.Transaction_ID,
  f4.Transaction_Date,
  f4.Value,
  f4.Cancelled

FROM Fraud_Account_Information AS f1
JOIN Fraud_Account_Holders AS f2 ON f1.Account_Holder_ID = f2.Account_Holder_ID
LEFT JOIN Fraud_Transaction_Path AS f3 ON f3.Account_To = f1.Account_Number
JOIN Fraud_Transaction_Detail AS f4 ON f4.Transaction_ID = f3.Transaction_ID;