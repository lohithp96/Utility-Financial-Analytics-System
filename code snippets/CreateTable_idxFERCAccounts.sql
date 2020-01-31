DROP TABLE dbo.idxFERCAccounts_Headings;

DROP TABLE dbo.idxFERCAccounts_Categories;

DROP TABLE dbo.idxFERCAccounts;

CREATE TABLE dbo.idxFERCAccounts
(
    FERCAccounts_CategoryID VARCHAR(3) NOT NULL,
    FERCAccounts_HeaderID VARCHAR(4) NOT NULL,
    FERCAccount CHAR(3) PRIMARY KEY NOT NULL,
    FERCAccount_SCE AS (FERCAccount + 'A') PERSISTED,
    FERCAccount_Name VARCHAR(50) NULL, 
    FERCAccount_Description VARCHAR(MAX) NULL,
);

CREATE TABLE dbo.idxFERCAccounts_Categories
(
    PlanCategoryID VARCHAR(3) NOT NULL,
    FERCAccounts_CategoryID CHAR(1) PRIMARY KEY NOT NULL,
    FERCAccounts_Category VARCHAR(120) NULL,
);

CREATE TABLE dbo.idxFERCAccounts_Headings
 (
	FERCAccounts_HeaderID VARCHAR(4) PRIMARY KEY NOT NULL,
	FERCAccounts_HeaderName VARCHAR(120) NULL,
);