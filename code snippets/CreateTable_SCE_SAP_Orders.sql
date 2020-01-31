USE [SONGS]
GO

--DOES NOT DELETE EXISTING TABLES
--MAY ONLY BE USED ON CLEAN DATABASE

CREATE TABLE dbo.idxSCE_SAP_Orders_Projects_Notes
(
    SCEProjectID VARCHAR(10) NOT NULL,
	ProjectNoteID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	ProjectNoteDate DATE,
	ProjectNoteAuthor VARCHAR(8),
	ProjectNote VARCHAR(MAX),
);

CREATE TABLE dbo.idxSCE_SAP_Orders_SONGS_ProjectManagers
(
	SONGSProjectManagerID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	SONGSProjectManager VARCHAR(50),
);

CREATE TABLE dbo.idxSCE_SAP_Orders_SONGS_ImplementationTypes
(
	SONGSImplementationCode INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	SONGSImplementationType VARCHAR(20),
);

CREATE TABLE dbo.idxSCE_SAP_Orders_SONGS_OutageCycles
(
	SONGSOutageCycleID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	SONGSOutageCycle VARCHAR(20),
);

CREATE TABLE dbo.idxSCE_SAP_Orders_SONGS_ProjectGroups
(
	SONGSProjectGroupID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	SONGSProjectGroup VARCHAR(50),
);

CREATE TABLE dbo.idxSCE_SAP_Orders_SONGS_CostEngineers
(
	SONGSCostEngineerID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	SONGSCostEngineer VARCHAR(50),
);

CREATE TABLE dbo.idxSCE_SAP_Orders_MasterOrders
(
	SCEProjectID VARCHAR(10) NOT NULL,
	SCEMasterOrder VARCHAR(9) PRIMARY KEY NOT NULL,
	SCECORRate DECIMAL(5,4),
	SDGEOrder_Default VARCHAR(12),
	SDGEOrder_Default_COR VARCHAR(12),
	SDGEOrder_Default_WOA VARCHAR(MAX),
	SCEForm62C VARCHAR(MAX),
	Notes VARCHAR(MAX),
);

CREATE TABLE dbo.idxSCE_CARS_Locations
(
	SCELocation CHAR(4) PRIMARY KEY NOT NULL,
	SCELocationName VARCHAR(50),
	SCELocationDescription VARCHAR(MAX),
);

CREATE TABLE dbo.idxSCE_SAP_Orders
(
	SCEProjectID VARCHAR(10) NOT NULL,
	SCEMasterOrder VARCHAR(9),
	SCEOrder VARCHAR(9) PRIMARY KEY NOT NULL,
	SCEWBSElement VARCHAR(25),
	SCELocation CHAR(4),
	SCEWorkOrder VARCHAR(9),
	SCEOrderDescription VARCHAR(MAX),
	SCEOrderType VARCHAR(4),
	SCESystemStatus VARCHAR(75),
	SCEUserStatus VARCHAR(75),
	SCECORRate DECIMAL(5,4),
	SDGEOrder VARCHAR(12),
	SDGEOrder_COR VARCHAR(12),
	SCE_ECD DATE,
	SCE_ENGZD DATE,
	SCE_TECO DATE,
	SONGS_Status CHAR(5),
	Added_User VARCHAR(8),
	Added_Date DATETIME,
);

GO