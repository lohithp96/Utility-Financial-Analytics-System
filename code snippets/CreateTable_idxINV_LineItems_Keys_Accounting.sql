/***** THIS CREATES THE DATABASE ACCESS TABLES *****/

USE [SONGS]
GO

DROP TABLE dbo.idxINV_LineItems_Keys_Accounting;

CREATE TABLE dbo.idxINV_LineItems_Keys_Accounting
	(
	RecordNumber INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	LineItem_Key VARCHAR(20) NOT NULL
		REFERENCES dbo.idxINV_LineItems_Keys(LineItem_Key),
	PlanCategory_ComponentID varchar(3) NOT NULL
		REFERENCES dbo.idxPlanCategories_Components(PlanCategory_ComponentID),
	Account char(7) NULL,
	OrderNumber varchar(12) NULL,
	CostCenter char(9) NULL,
	Active BIT NOT NULL DEFAULT(1),
);

GO