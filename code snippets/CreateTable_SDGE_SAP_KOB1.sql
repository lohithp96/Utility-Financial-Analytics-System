/***** THIS CREATES SDG&E SAP TABLES *****/

USE [SONGS]
GO

DROP TABLE dbo.idxSDGE_SAP_DocumentTypes;
DROP TABLE dbo.idxSDGE_SAP_CostCenters;
DROP TABLE dbo.SDGE_SAP_KOB1;

CREATE TABLE dbo.idxSDGE_SAP_DocumentTypes
	(
	DocumentType CHAR(2) PRIMARY KEY NOT NULL,
	DocumentType_Name VARCHAR(35) NULL,
);

CREATE TABLE dbo.idxSDGE_SAP_CostCenters
	(
	CostCenter CHAR(9) PRIMARY KEY NOT NULL,
	CostCenterName_Long VARCHAR(40) NULL,
	CostCenterName_Short VARCHAR(20) NULL,
	Manager_EmployeeID CHAR(5) NULL,
	Valid_From DATETIME NULL,
	Valid_To DATETIME NULL,
	Department VARCHAR(6) NULL,
	HierarchyArea VARCHAR(10) NULL,
	SharedServiceIndicator CHAR(3) NULL,
	CostingSheet CHAR(6) NULL,
	Category CHAR(1) NULL,
	Actual_PrimaryCosts BIT NULL,
	Actual_SecondaryCosts BIT NULL,
	SONGSCostCenter BIT NULL,
	SONGSCostCenterUse VARCHAR(30) NULL,
	SONGSCostCenterNotes VARCHAR(MAX) NULL,
);

CREATE TABLE dbo.SDGE_SAP_KOB1
	(
	TransactionID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	DocumentNumber VARCHAR(10) NULL,
	CostCenter CHAR(9) NULL,
	CostElement CHAR(7) NULL,
	OffsetAccount VARCHAR(10) NULL,
	Details VARCHAR(50) NULL,
	VendorID VARCHAR(10) NULL,
	MaterialID VARCHAR(10) NULL,
	OrderNumber VARCHAR(12) NULL,
	Amount MONEY NULL,
	Quantity DECIMAL(13,3) NULL,
	Units VARCHAR(3) NULL,
	Date_Posting DATETIME NULL,
	Date_Document DATETIME NULL,
	TransactionType CHAR(4) NULL,
	DrCr CHAR(1) NULL,
	PurchasingDocument VARCHAR(10) NULL,
	ReferenceDocument VARCHAR(10) NULL,
	PartnerObject VARCHAR(12) NULL,
	DocumentType CHAR(2) NULL,
	UserName VARCHAR(9) NULL,
);