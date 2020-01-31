/***** THIS CREATES THE PRIMARY INVOICE TABLE *****/

USE [SONGS]
GO

DROP TABLE dbo.Invoices_Notes;
DROP TABLE dbo.Invoices_LineItems;
DROP TABLE dbo.Invoices_OM_Summary;
DROP TABLE dbo.Invoices;

CREATE TABLE dbo.Invoices
	(
	Invoice_Key CHAR(6) NOT NULL
		REFERENCES dbo.idxINV_Keys(Invoice_Key),
	InvoiceID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	PlanCategoryID VARCHAR(3) NOT NULL
		REFERENCES dbo.idxPlanCategories(PlanCategoryID),
	PlanCategory_ComponentID VARCHAR(3) NOT NULL
		REFERENCES dbo.idxPlanCategories_Components(PlanCategory_ComponentID),
	DateReceived DATETIME NULL,
	InvoiceNumber VARCHAR(25) UNIQUE NULL,
	TotalAmount MONEY NOT NULL DEFAULT 0,
	Labor_NormalTime MONEY NOT NULL DEFAULT 0,
	Labor_Overtime MONEY NOT NULL DEFAULT 0,
	Labor_DoubleTime MONEY NOT NULL DEFAULT 0,
	Labor_Embedded MONEY NOT NULL DEFAULT 0,
	Labor_DPBReport MONEY NOT NULL DEFAULT 0,
	OverheadRate_Labor_PayrollTax DECIMAL(9,8) NOT NULL DEFAULT 0.00000000,
	OverheadRate_Labor_Benefits DECIMAL(9,8) NOT NULL DEFAULT 0.00000000,
	OverheadRate_Labor_Administration DECIMAL(9,8) NOT NULL DEFAULT 0.00000000,
	OverheadRate_NonLabor_Administration DECIMAL(9,8) NOT NULL DEFAULT 0.00000000,
	OverheadRate_SCEPremiumTime DECIMAL(9,8) NOT NULL DEFAULT 0.00000000,
	Created_User VARCHAR(8) NULL,
	Created_Date DATETIME NULL DEFAULT GETDATE(),
	LastUpdate_User VARCHAR(8) NULL,
	LastUpdate_Date DATETIME NULL,
	Reviewed_User VARCHAR(8) NULL,
	Reviewed_Date VARCHAR(8) NULL,
	Approved_User VARCHAR(8) NULL,
	Approved_Date VARCHAR(8) NULL,
	LOCKED BIT NOT NULL DEFAULT 0,
	InvoicePacket_FilePath VARCHAR(MAX) NULL, /***THIS FIELD IS NOT LOCEKD***/
);

CREATE TABLE  dbo.Invoices_OM_Summary
	(
	InvoiceID INT NOT NULL
		REFERENCES dbo.Invoices(InvoiceID),
	Invoices_OM_SummaryKey INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	PlanCategory_Component_LocationID VARCHAR(3) NOT NULL
		REFERENCES dbo.idxPlanCategories_Components_Locations(PlanCategory_Component_LocationID),
	ActualCosts BIT NOT NULL DEFAULT 1, /***AS OPPOSED TO ESTIMATE***/
	FERCAccount CHAR(3) NULL
		REFERENCES dbo.idxFERCAccounts(FERCAccount),
	SCEFunction_Start CHAR(4) NULL,
	SCEFunction_End CHAR(4) NULL,
	SCECostObject VARCHAR(9) NULL,
	Labor MONEY NOT NULL DEFAULT 0,
	Total MONEY NOT NULL DEFAULT 0,
);

CREATE TABLE dbo.Invoices_LineItems
	(
	InvoiceID INT NOT NULL
		REFERENCES dbo.Invoices(InvoiceID),
	PlanCategory_ComponentID VARCHAR(3) NOT NULL
		REFERENCES dbo.idxPlanCategories_Components(PlanCategory_ComponentID),
	Invoice_LineItemID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	Invoice_LineItemNumber TINYINT NULL,
	Invoice_LineItem_Key VARCHAR(20) NULL
		REFERENCES dbo.idxINV_LineItems_Keys(LineItem_Key),
	Invoice_LineItemInformation VARCHAR(MAX) NULL,
	Invoice_LineItem_Amount MONEY NOT NULL DEFAULT 0,
	Created_User VARCHAR(8) NULL,
	Created_Date DATETIME NULL DEFAULT GETDATE(),
	LOCKED BIT NOT NULL DEFAULT 0,
);

CREATE TABLE dbo.Invoices_Notes
	(
	Invoice_Key CHAR(6) NOT NULL
		REFERENCES dbo.idxINV_Keys(Invoice_Key),
	InvoiceID INT NOT NULL
		REFERENCES dbo.Invoices(InvoiceID),
	Invoice_NoteID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	Invoice_Note VARCHAR(MAX) NULL,
	Invoice_Note_User VARCHAR(8) NULL,
	Invoice_Note_Date DATETIME NULL DEFAULT GETDATE(),
);

GO


