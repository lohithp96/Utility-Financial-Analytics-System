USE [SONGS];
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

/***** ERROR HANDLING - FROM AdventureWorks2012 ******/
IF OBJECT_ID ( 'dbo.GetErrorInfo', 'P' ) IS NOT NULL
	DROP PROCEDURE dbo.GetErrorInfo;
GO
CREATE PROCEDURE dbo.GetErrorInfo
AS
SELECT
    ERROR_NUMBER() AS ErrorNumber
    ,ERROR_SEVERITY() AS ErrorSeverity
    ,ERROR_STATE() AS ErrorState
    ,ERROR_PROCEDURE() AS ErrorProcedure
    ,ERROR_LINE() AS ErrorLine
    ,ERROR_MESSAGE() AS ErrorMessage;
GO

-- uspPrintError prints error information about the error that caused 
-- execution to jump to the CATCH block of a TRY...CATCH construct. 
-- Should be executed from within the scope of a CATCH block otherwise 
-- it will return without printing any error information.
IF OBJECT_ID ( 'dbo.PrintError', 'P' ) IS NOT NULL
	DROP PROCEDURE dbo.PrintError;
GO
CREATE PROCEDURE dbo.PrintError
AS
BEGIN
    SET NOCOUNT ON;

    -- Print error information. 
    PRINT 'Error ' + CONVERT(varchar(50), ERROR_NUMBER()) +
          ', Severity ' + CONVERT(varchar(5), ERROR_SEVERITY()) +
          ', State ' + CONVERT(varchar(5), ERROR_STATE()) + 
          ', Procedure ' + ISNULL(ERROR_PROCEDURE(), '-') + 
          ', Line ' + CONVERT(varchar(5), ERROR_LINE());
    PRINT ERROR_MESSAGE();
END;
GO

-- uspLogError logs error information in the ErrorLog table about the 
-- error that caused execution to jump to the CATCH block of a 
-- TRY...CATCH construct. This should be executed from within the scope 
-- of a CATCH block otherwise it will return without inserting error 
-- information. 
IF OBJECT_ID ( 'dbo.LogError', 'P' ) IS NOT NULL
	DROP PROCEDURE dbo.LogError;
GO
CREATE PROCEDURE dbo.LogError
	(
		@ErrorLogID [int] = 0 OUTPUT	-- contains the ErrorLogID of the row inserted
	)									-- by uspLogError in the ErrorLog table
AS
BEGIN
    SET NOCOUNT ON;

    -- Output parameter value of 0 indicates that error 
    -- information was not logged
    SET @ErrorLogID = 0;

    BEGIN TRY
        -- Return if there is no error information to log
        IF ERROR_NUMBER() IS NULL
            RETURN;

        -- Return if inside an uncommittable transaction.
        -- Data insertion/modification is not allowed when 
        -- a transaction is in an uncommittable state.
        IF XACT_STATE() = -1
        BEGIN
            PRINT 'Cannot log error since the current transaction is in an uncommittable state. ' 
                + 'Rollback the transaction before executing uspLogError in order to successfully log error information.';
            RETURN;
        END

        INSERT [dbo].[ErrorLog] 
            (
            [UserName], 
            [ErrorNumber], 
            [ErrorSeverity], 
            [ErrorState], 
            [ErrorProcedure], 
            [ErrorLine], 
            [ErrorMessage]
            ) 
        VALUES 
            (
            CONVERT(sysname, CURRENT_USER), 
            ERROR_NUMBER(),
            ERROR_SEVERITY(),
            ERROR_STATE(),
            ERROR_PROCEDURE(),
            ERROR_LINE(),
            ERROR_MESSAGE()
            );

        -- Pass back the ErrorLogID of the row inserted
        SET @ErrorLogID = @@IDENTITY;
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred in stored procedure uspLogError: ';
        EXECUTE [dbo].[PrintError];
        RETURN -1;
    END CATCH
END;
GO


/***** DELETE EXISTING OBJECTS ******/
PRINT '/***** DELETE EXISTING OBJECTS ******/';
GO
BEGIN TRY 
	EXEC sp_dropextendedproperty 
		 @name=N'MS_Description',
		 @level0type=N'SCHEMA',
		 @level0name=N'dbo';
END TRY
BEGIN CATCH
	EXECUTE usp_GetErrorInfo;
END CATCH
GO

-- DELETE PROCEDURES
IF OBJECT_ID ( 'WOA.getGlobalConstants', 'P' ) IS NOT NULL
	DROP PROCEDURE WOA.getGlobalConstants;
GO
IF OBJECT_ID ( 'WOA.getParentOrders', 'P' ) IS NOT NULL
	DROP PROCEDURE WOA.getParentOrders;
GO
IF OBJECT_ID ( 'WOA.getParentOrderPrefixes', 'P' ) IS NOT NULL
	DROP PROCEDURE WOA.getParentOrderProjects;
GO
IF OBJECT_ID ( 'Common.getIProtectClassification', 'P' ) IS NOT NULL
	DROP PROCEDURE Common.getIProtectClassification;
GO
IF OBJECT_ID ( 'Common.getServerProperties', 'P' ) IS NOT NULL
	DROP PROCEDURE Common.getServerProperties;
GO
IF OBJECT_ID ( 'Common.getTableRows', 'P' ) IS NOT NULL
	DROP PROCEDURE Common.getTableRows;
GO
IF OBJECT_ID ( 'Common.getSysColumns', 'P' ) IS NOT NULL
	DROP PROCEDURE Common.getSysColumns;
GO
IF OBJECT_ID ( 'Common.getSysObjectTypes', 'P' ) IS NOT NULL
	DROP PROCEDURE Common.getSysObjectTypes;
GO
IF OBJECT_ID ( 'Common.getSysObjects', 'P' ) IS NOT NULL
	DROP PROCEDURE Common.getSysObjects;
GO
IF OBJECT_ID ( 'Common.getSchemas', 'P' ) IS NOT NULL
	DROP PROCEDURE Common.getSchemas;
GO
IF OBJECT_ID ( 'Common.getExtendedProperty_Description', 'P' ) IS NOT NULL
	DROP PROCEDURE Common.getExtendedProperty_Description;
GO
IF OBJECT_ID ( 'Common.getSQLUserName', 'P' ) IS NOT NULL
	DROP PROCEDURE Common.getSQLUserName;
GO	
IF OBJECT_ID ( 'SAP.getOrderType', 'P' ) IS NOT NULL
	DROP PROCEDURE SAP.getOrderType;
GO
IF OBJECT_ID ( 'SAP.getCostCenterCategory', 'P' ) IS NOT NULL
	DROP PROCEDURE SAP.getCostCenterCategory;
GO
IF OBJECT_ID ( 'SAP.getCostCenter', 'P' ) IS NOT NULL
	DROP PROCEDURE SAP.getCostCenter;
GO
IF OBJECT_ID ( 'SAP.getCompanyCode', 'P' ) IS NOT NULL
	DROP PROCEDURE SAP.getCompanyCode;
GO
IF OBJECT_ID ( 'SAP.getPlannedCategoryDetails', 'P' ) IS NOT NULL
	DROP PROCEDURE SAP.getPlannedCategoryDetails;
GO
IF OBJECT_ID ( 'SAP.getPlannedCategories', 'P' ) IS NOT NULL
	DROP PROCEDURE SAP.getPlannedCategories;
GO
IF OBJECT_ID ( 'SAP.getCostingSheet', 'P' ) IS NOT NULL
	DROP PROCEDURE SAP.getCostingSheet;
GO
IF OBJECT_ID ( 'SAP.getOverheadKey', 'P' ) IS NOT NULL
	DROP PROCEDURE SAP.getOverheadKey;
GO
IF OBJECT_ID ( 'SAP.getInterestProfile', 'P' ) IS NOT NULL
	DROP PROCEDURE SAP.getInterestProfile;
GO
IF OBJECT_ID ( 'WOA.mergeWorkOrder', 'P' ) IS NOT NULL
	DROP PROCEDURE WOA.mergeWorkOrder;
GO
IF OBJECT_ID ( 'WOA.getStoredProcedure', 'P' ) IS NOT NULL
	DROP PROCEDURE WOA.getStoredProcedure;
GO
IF OBJECT_ID ( 'SAP.getUserStatus', 'P' ) IS NOT NULL
	DROP PROCEDURE SAP.getUserStatus;
GO
IF OBJECT_ID ( 'Common.getBillingCodes', 'P' ) IS NOT NULL
	DROP PROCEDURE Common.getBillingCodes;
GO
IF OBJECT_ID ( 'Common.getCounties', 'P' ) IS NOT NULL
	DROP PROCEDURE Common.getCounties;
GO
IF OBJECT_ID ( 'SAP.getEmployee', 'P' ) IS NOT NULL
	DROP PROCEDURE SAP.getEmployee;
GO
IF OBJECT_ID ( 'SAP.getAnalyzedIndicators', 'P' ) IS NOT NULL
	DROP PROCEDURE SAP.getAnalyzedIndicators;
GO
IF OBJECT_ID ( 'SAP.getBillingTypes', 'P' ) IS NOT NULL
	DROP PROCEDURE SAP.getBillingTypes;
GO
IF OBJECT_ID ( 'SAP.getCities', 'P' ) IS NOT NULL
	DROP PROCEDURE SAP.getCities;
GO
IF OBJECT_ID ( 'SAP.getDistrictCodes', 'P' ) IS NOT NULL
	DROP PROCEDURE SAP.getDistrictCodes;
GO
IF OBJECT_ID ( 'SAP.getEmployees', 'P' ) IS NOT NULL
	DROP PROCEDURE SAP.getEmployees;
GO
IF OBJECT_ID ( 'SAP.getPlants', 'P' ) IS NOT NULL
	DROP PROCEDURE SAP.getPlants;
GO
IF OBJECT_ID ( 'SAP.getPowerPlanOverrides', 'P' ) IS NOT NULL
	DROP PROCEDURE SAP.getPowerPlanOverrides;
GO
IF OBJECT_ID ( 'SAP.getRegionCodes', 'P' ) IS NOT NULL
	DROP PROCEDURE SAP.getRegionCodes;
GO

-- DELETE TABLES
IF OBJECT_ID('dbo.ErrorLog','U') IS NOT NULL
	DROP TABLE dbo.ErrorLog;
GO
IF OBJECT_ID('WOA.GlobalConstant','U') IS NOT NULL
	DROP TABLE WOA.GlobalConstant;
GO
IF OBJECT_ID('WOA.InternalOrder','U') IS NOT NULL
	DROP TABLE WOA.InternalOrder;
GO
IF OBJECT_ID('WOA.InternalOrder','U') IS NOT NULL
	DROP TABLE WOA.InternalOrder_History;
GO
IF OBJECT_ID('WOA.ParentOrderProject') IS NOT NULL
	DROP TABLE WOA.ParentOrderProject;
GO
IF OBJECT_ID('WOA.WorkOrder','U') IS NOT NULL
	DROP TABLE WOA.WorkOrder;
GO
IF OBJECT_ID('WOA.WorkOrder_History','U') IS NOT NULL
	DROP TABLE WOA.WorkOrder_History;
GO
IF OBJECT_ID('SAP.City','U') IS NOT NULL
	DROP TABLE SAP.City;
GO
IF OBJECT_ID('Common.County','U') IS NOT NULL
	DROP TABLE Common.County;
GO
IF OBJECT_ID('SAP.KOK3','U') IS NOT NULL
	DROP TABLE SAP.KOK3;
GO
IF OBJECT_ID('Common.IProtectClassification','U') IS NOT NULL
	DROP TABLE Common.IProtectClassification;
GO
IF OBJECT_ID('Common.BillingCode','U') IS NOT NULL
	DROP TABLE Common.BillingCode;
GO
IF OBJECT_ID('SAP.OrderType','U') IS NOT NULL
	DROP TABLE SAP.OrderType;
GO
IF OBJECT_ID('SAP.EmployeeAuthorization') IS NOT NULL
	DROP TABLE SAP.EmployeeAuthorization;
GO
IF OBJECT_ID('SAP.Employee') IS NOT NULL
	DROP TABLE SAP.Employee;
GO
IF OBJECT_ID('SAP.CostCenter','U') IS NOT NULL
	DROP TABLE SAP.CostCenter;
GO
IF OBJECT_ID('SAP.CostCenterCategory','U') IS NOT NULL
	DROP TABLE SAP.CostCenterCategory;
GO
IF OBJECT_ID('SAP.PlannedCategoryDetail','U') IS NOT NULL
	DROP TABLE SAP.PlannedCategoryDetail;
GO
IF OBJECT_ID('SAP.PlannedCategory','U') IS NOT NULL
	DROP TABLE SAP.PlannedCategory;
GO
IF OBJECT_ID('SAP.CostingSheet','U') IS NOT NULL
	DROP TABLE SAP.CostingSheet;
GO
IF OBJECT_ID('SAP.OverheadKey','U') IS NOT NULL
	DROP TABLE SAP.OverheadKey;
GO
IF OBJECT_ID('SAP.InterestProfile','U') IS NOT NULL
	DROP TABLE SAP.InterestProfile;
GO
IF OBJECT_ID('SAP.AnalyzedIndicator','U') IS NOT NULL
	DROP TABLE SAP.AnalyzedIndicator;
GO
IF OBJECT_ID('SAP.PowerPlanOverride','U') IS NOT NULL
	DROP TABLE SAP.PowerPlanOverride;
GO
IF OBJECT_ID('SAP.DistrictCode','U') IS NOT NULL
	DROP TABLE SAP.DistrictCode;
GO
IF OBJECT_ID('SAP.RegionCode','U') IS NOT NULL
	DROP TABLE SAP.RegionCode;
GO
IF OBJECT_ID('SAP.BillingType','U') IS NOT NULL
	DROP TABLE SAP.BillingType;
GO
IF OBJECT_ID('SAP.Plant','U') IS NOT NULL
	DROP TABLE SAP.Plant;
GO
IF OBJECT_ID('DPSS.COType','U') IS NOT NULL
	DROP TABLE DPSS.COType;
GO
IF OBJECT_ID('Common.BillingCode','U') IS NOT NULL
	DROP TABLE Common.BillingCode;
GO
IF OBJECT_ID('SAP.CompanyCode','U') IS NOT NULL
	DROP TABLE SAP.CompanyCode;
GO
IF OBJECT_ID('WOA.StoredProcedure','U') IS NOT NULL
	DROP TABLE WOA.StoredProcedure;
GO
IF OBJECT_ID('SAP.UserStatus','U') IS NOT NULL
	DROP TABLE SAP.UserStatus;
GO


-- DELETE USER TYPES
IF TYPE_ID('dbo.Name') IS NOT NULL
	DROP TYPE [dbo].[Name];
GO
IF TYPE_ID('dbo.Description') IS NOT NULL
	DROP TYPE [dbo].[Description];
GO

-- DELETE SCHEMAS
IF SCHEMA_ID('Common') IS NOT NULL	
	DROP SCHEMA Common;
GO
IF SCHEMA_ID('DPSS') IS NOT NULL	
	DROP SCHEMA DPSS;
GO
IF SCHEMA_ID('PowerPlan') IS NOT NULL
	DROP SCHEMA PowerPlan;
GO
IF SCHEMA_ID('SAP') IS NOT NULL
	DROP SCHEMA SAP;
GO
IF SCHEMA_ID('WOA') IS NOT NULL
	DROP SCHEMA WOA;
GO


/****** Table Storage Schemas ******/
PRINT '/****** Table Storage Schemas ******/';
GO
EXEC sys.sp_addextendedproperty
	 @name=N'MS_Description',
	 @value=N'Generic [dbo] database SCHEMA.',
	 @level0type=N'SCHEMA',
	 @level0name=N'dbo';
GO

CREATE SCHEMA Common;
GO
EXEC sys.sp_addextendedproperty
	 @name=N'MS_Description', 
	 @value=N'Contains common objects shared across applications.', 
	 @level0type=N'SCHEMA',
	 @level0name=N'Common';
GO

CREATE SCHEMA DPSS;
GO
EXEC sys.sp_addextendedproperty
	 @name=N'MS_Description', 
	 @value=N'Contains DPSS objects leveraged across applications.', 
	 @level0type=N'SCHEMA',
	 @level0name=N'DPSS';
GO

CREATE SCHEMA PowerPlan;
GO
EXEC sys.sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'Contains PowerPlan objects leveraged across applications.', 
	 @level0type=N'SCHEMA',
	 @level0name=N'PowerPlan';
GO

CREATE SCHEMA SAP;
GO
EXEC sys.sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'Contains SAP objects leveraged across applications.', 
	 @level0type=N'SCHEMA',
	 @level0name=N'SAP';
GO

CREATE SCHEMA WOA;
GO
EXEC sys.sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'Work Order Authorization (WOA) Objects', 
	 @level0type=N'SCHEMA',
	 @level0name=N'WOA';
GO


/****** User-Defined Data Types ******/
PRINT '/****** User-Defined Data Types ******/';
GO
CREATE TYPE dbo.Name FROM [nvarchar](50) NULL;
CREATE TYPE dbo.Description FROM [nvarchar](MAX) NULL;
GO


/****** CREATE TABLES ******/
PRINT '/****** CREATE TABLES ******/';
GO
-- dbo.ErrorLog
PRINT '-- dbo.ErrorLog'
GO
CREATE TABLE dbo.ErrorLog
(
	ErrorLogID [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	ErrorTime datetime NOT NULL DEFAULT getdate(),
	UserName [sysname] NOT NULL,
	ErrorNumber [int] NOT NULL,
	ErrorSeverity [int] NULL,
	ErrorState [int] NULL,
	ErrorProcedure [nvarchar](126) NULL,
	ErrorLine [int] NULL,
	ErrorMessage [nvarchar](4000) NOT NULL
);
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary key for ErrorLog records.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ErrorLog', @level2type=N'COLUMN',@level2name=N'ErrorLogID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The date and time at which the error occurred.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ErrorLog', @level2type=N'COLUMN',@level2name=N'ErrorTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The user who executed the batch in which the error occurred.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ErrorLog', @level2type=N'COLUMN',@level2name=N'UserName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The error number of the error that occurred.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ErrorLog', @level2type=N'COLUMN',@level2name=N'ErrorNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The severity of the error that occurred.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ErrorLog', @level2type=N'COLUMN',@level2name=N'ErrorSeverity'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The state number of the error that occurred.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ErrorLog', @level2type=N'COLUMN',@level2name=N'ErrorState'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the stored procedure or trigger where the error occurred.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ErrorLog', @level2type=N'COLUMN',@level2name=N'ErrorProcedure'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The line number at which the error occurred.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ErrorLog', @level2type=N'COLUMN',@level2name=N'ErrorLine'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The message text of the error that occurred.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ErrorLog', @level2type=N'COLUMN',@level2name=N'ErrorMessage'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Audit table tracking errors in the the AdventureWorks database that are caught by the CATCH block of a TRY...CATCH construct. Data is inserted by stored procedure dbo.uspLogError when it is executed from inside the CATCH block of a TRY...CATCH construct.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ErrorLog'
GO

-- WOA.StoredProcedure
PRINT '-- WOA.StoredProcedure';
GO
CREATE TABLE WOA.StoredProcedure
(
	StoredProcedureID [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	SchemaName [nvarchar](128) NULL,
	Name [dbo].[name] NULL,
	Description [dbo].[Description] NULL,
	InputParameterList [nvarchar](MAX) NULL,
	OutputParameterList [nvarchar](MAX) NULL,
	ReturnsRecords [bit] NOT NULL DEFAULT 1,
	CommandTypeProperty [int] NOT NULL DEFAULT 4, -- {-1 = adCmdUnspecified; 1 = adCmdText; 2 = adCmdTable; 4 = adCmdStoredProc; 8 = adCmdUnknown}
	IntendedUsage [int] NOT NULL DEFAULT 1, -- {1 = Index; 2 = Query; 3 = Action}
	CreatedBy [nvarchar](50) NOT NULL DEFAULT USER_NAME(),
	CreatedDate [datetime2](2) NOT NULL DEFAULT SYSUTCDATETIME(),
	LastUpdatedBy [nvarchar](256) NULL,
	LastUpdatedDate datetime2(2) NULL,
	rowguid [uniqueidentifier] ROWGUIDCOL NOT NULL DEFAULT NEWSEQUENTIALID (),
	versionnumber rowversion,
	ValidFrom datetime2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
	ValidTo datetime2(2) NOT NULL DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);

-- Common.IProtectClassification
PRINT '-- Common.IProtectClassification';
GO
CREATE TABLE Common.IProtectClassification
(
	IProtectClassificationID [tinyint] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	Name [dbo].[Name] NOT NULL,
	Description [dbo].[Description] NULL,
	CreatedBy [nvarchar](50) NOT NULL DEFAULT USER_NAME(),
	CreatedDate [datetime2](2) NOT NULL DEFAULT SYSUTCDATETIME(),
	LastUpdatedBy [nvarchar](256) NULL,
	LastUpdatedDate datetime2(2) NULL,
	rowguid [uniqueidentifier] ROWGUIDCOL NOT NULL DEFAULT NEWSEQUENTIALID (),
	versionnumber rowversion,
	ValidFrom datetime2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
	ValidTo datetime2(2) NOT NULL DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'Sempra Energy Information Protection Classifications and Descriptions', 
	 @level0type=N'SCHEMA', @level0name=N'Common', 
	 @level1type=N'TABLE',  @level1name=N'IProtectClassification';
GO
EXEC sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'Primary key for Information Protection.', 
	 @level0type=N'SCHEMA', @level0name=N'Common', 
	 @level1type=N'TABLE',  @level1name=N'IProtectClassification', 
	 @level2type=N'COLUMN', @level2name=N'IProtectClassificationID';
GO

-- SAP.County
PRINT '-- Common.County';
GO
CREATE TABLE Common.County
(
	CountyID [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	StateID [nchar](2) NULL DEFAULT 'CA',
	Name [dbo].[Name] NULL,
	FIPS [tinyint] NULL,
	Seat [nvarchar](20) NULL,
	Established [smallint] NULL,
	CreatedBy [nvarchar](50) NOT NULL DEFAULT USER_NAME(),
	CreatedDate [datetime2](2) NOT NULL DEFAULT SYSUTCDATETIME(),
	LastUpdatedBy [nvarchar](256) NULL,
	LastUpdatedDate datetime2(2) NULL,
	rowguid [uniqueidentifier] ROWGUIDCOL NOT NULL DEFAULT NEWSEQUENTIALID (),
	versionnumber rowversion,
	ValidFrom datetime2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
	ValidTo datetime2(2) NOT NULL DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);

-- SAP.City
PRINT '-- SAP.City';
GO
CREATE TABLE SAP.City
(
	CountyID [int] NULL	CONSTRAINT FK_SAPCity_CountyID_County
						FOREIGN KEY (CountyID)
						REFERENCES Common.County(CountyID),
	CityID [nchar](2) NOT NULL PRIMARY KEY,
	Name [dbo].[Name],
	CreatedBy [nvarchar](50) NOT NULL DEFAULT USER_NAME(),
	CreatedDate [datetime2](2) NOT NULL DEFAULT SYSUTCDATETIME(),
	LastUpdatedBy [nvarchar](256) NULL,
	LastUpdatedDate datetime2(2) NULL,
	rowguid [uniqueidentifier] ROWGUIDCOL NOT NULL DEFAULT NEWSEQUENTIALID (),
	versionnumber rowversion,
	ValidFrom datetime2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
	ValidTo datetime2(2) NOT NULL DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);

-- SAP.OrderType
PRINT '-- SAP.OrderType';
GO
CREATE TABLE SAP.OrderType
(
	OrderTypeID [nchar](4) NOT NULL PRIMARY KEY,
	Name [dbo].[Name] NOT NULL,
	Description [dbo].[Description] NULL,
	CreatedBy [nvarchar](50) NOT NULL DEFAULT USER_NAME(),
	CreatedDate [datetime2](2) NOT NULL DEFAULT SYSUTCDATETIME(),
	LastUpdatedBy [nvarchar](256) NULL,
	LastUpdatedDate datetime2(2) NULL,
	rowguid [uniqueidentifier] ROWGUIDCOL NOT NULL DEFAULT NEWSEQUENTIALID (),
	versionnumber rowversion,
	ValidFrom datetime2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
	ValidTo datetime2(2) NOT NULL DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'SAP Order Type - Key that differentiates orders according to their purpose.', 
	 @level0type=N'SCHEMA', @level0name=N'SAP', 
	 @level1type=N'TABLE',  @level1name=N'OrderType';
GO
EXEC sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'Primary key for Order Type - Key that differentiates orders according to their purpose.', 
	 @level0type=N'SCHEMA', @level0name=N'SAP', 
	 @level1type=N'TABLE',  @level1name=N'OrderType', 
	 @level2type=N'COLUMN', @level2name=N'OrderTypeID';
GO

-- SAP.RegionCode
PRINT '-- SAP.RegionCode';
GO
CREATE TABLE SAP.RegionCode
(
	RegionCodeID [nchar](2) NOT NULL PRIMARY KEY,
	Name [dbo].[Name] NOT NULL,
	Description [dbo].[Description] NULL,
	CreatedBy [nvarchar](50) NOT NULL DEFAULT USER_NAME(),
	CreatedDate [datetime2](2) NOT NULL DEFAULT SYSUTCDATETIME(),
	LastUpdatedBy [nvarchar](256) NULL,
	LastUpdatedDate datetime2(2) NULL,
	rowguid [uniqueidentifier] ROWGUIDCOL NOT NULL DEFAULT NEWSEQUENTIALID (),
	versionnumber rowversion,
	ValidFrom datetime2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
	ValidTo datetime2(2) NOT NULL DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'SAP Two-Digit Region Code', 
	 @level0type=N'SCHEMA', @level0name=N'SAP', 
	 @level1type=N'TABLE',  @level1name=N'RegionCode';
GO

-- SAP.CostingSheet
PRINT '-- SAP.CostingSheet';
GO
CREATE TABLE SAP.CostingSheet
(
	CostingSheetID [nchar](6) NOT NULL PRIMARY KEY,
	Name [dbo].[Name] NULL,
	CreatedBy [nvarchar](50) NOT NULL DEFAULT USER_NAME(),
	CreatedDate [datetime2](2) NOT NULL DEFAULT SYSUTCDATETIME(),
	LastUpdatedBy [nvarchar](256) NULL,
	LastUpdatedDate datetime2(2) NULL,
	rowguid [uniqueidentifier] ROWGUIDCOL NOT NULL DEFAULT NEWSEQUENTIALID (),
	versionnumber rowversion,
	ValidFrom datetime2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
	ValidTo datetime2(2) NOT NULL DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'SAP Costing Sheet - Controls the calculation of overhead.', 
	 @level0type=N'SCHEMA', @level0name=N'SAP', 
	 @level1type=N'TABLE',  @level1name=N'CostingSheet';
GO
EXEC sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'Primary key for Costing Sheet - SAP Controller for the calculation of overhead.', 
	 @level0type=N'SCHEMA', @level0name=N'SAP', 
	 @level1type=N'TABLE',  @level1name=N'CostingSheet', 
	 @level2type=N'COLUMN', @level2name=N'CostingSheetID';
GO

-- SAP.OverheadKey
PRINT '-- SAP.OverheadKey';
GO
CREATE TABLE SAP.OverheadKey
(
	OverheadKeyID [nvarchar](6) NOT NULL PRIMARY KEY,
	Name [dbo].[Name] NULL,
	CreatedBy [nvarchar](50) NOT NULL DEFAULT USER_NAME(),
	CreatedDate [datetime2](2) NOT NULL DEFAULT SYSUTCDATETIME(),
	LastUpdatedBy [nvarchar](256) NULL,
	LastUpdatedDate datetime2(2) NULL,
	rowguid [uniqueidentifier] ROWGUIDCOL NOT NULL DEFAULT NEWSEQUENTIALID (),
	versionnumber rowversion,
	ValidFrom datetime2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
	ValidTo datetime2(2) NOT NULL DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'SAP Costing Sheet - The overhead key is used to determine order-specific or material-related overhead rates.', 
	 @level0type=N'SCHEMA', @level0name=N'SAP', 
	 @level1type=N'TABLE',  @level1name=N'OverheadKey';
GO
EXEC sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'Primary key for Overhead Key - SAP key is used to determine order-specific or material-related overhead rates.', 
	 @level0type=N'SCHEMA', @level0name=N'SAP', 
	 @level1type=N'TABLE',  @level1name=N'OverheadKey', 
	 @level2type=N'COLUMN', @level2name=N'OverheadKeyID';
GO

-- WOA.GlobalConstant
PRINT '-- WOA.GlobalConstant';
GO
CREATE TABLE WOA.GlobalConstant
(
	GlobalConstantID [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	Name [dbo].[Name] NULL,
	ConstantValue [nvarchar](255) NULL,
	CreatedBy [nvarchar](50) NOT NULL DEFAULT USER_NAME(),
	CreatedDate [datetime2](2) NOT NULL DEFAULT SYSUTCDATETIME(),
	LastUpdatedBy [nvarchar](256) NULL,
	LastUpdatedDate datetime2(2) NULL,
	rowguid [uniqueidentifier] ROWGUIDCOL NOT NULL DEFAULT NEWSEQUENTIALID (),
	versionnumber rowversion,
	ValidFrom datetime2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
	ValidTo datetime2(2) NOT NULL DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);

-- SAP.InterestProfile
PRINT '-- SAP.InterestProfile';
GO
CREATE TABLE SAP.InterestProfile
(
	InterestProfileID [nvarchar](7) NOT NULL PRIMARY KEY,
	Name [dbo].[Name] NULL,
	CreatedBy [nvarchar](50) NOT NULL DEFAULT USER_NAME(),
	CreatedDate [datetime2](2) NOT NULL DEFAULT SYSUTCDATETIME(),
	LastUpdatedBy [nvarchar](256) NULL,
	LastUpdatedDate datetime2(2) NULL,
	rowguid [uniqueidentifier] ROWGUIDCOL NOT NULL DEFAULT NEWSEQUENTIALID (),
	versionnumber rowversion,
	ValidFrom datetime2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
	ValidTo datetime2(2) NOT NULL DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'SAP Interest Profile - The interest profile contains the rules governing the interest calculation for projects.', 
	 @level0type=N'SCHEMA', @level0name=N'SAP', 
	 @level1type=N'TABLE',  @level1name=N'InterestProfile';
GO
EXEC sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'Primary key for Interest Profile - SAP key that contains the rules governing the interest calculation for projects.', 
	 @level0type=N'SCHEMA', @level0name=N'SAP', 
	 @level1type=N'TABLE',  @level1name=N'InterestProfile', 
	 @level2type=N'COLUMN', @level2name=N'InterestProfileID';
GO

-- SAP.PlannedCategory
PRINT '-- SAP.PlannedCategory';
GO
CREATE TABLE SAP.PlannedCategory
(
	PlannedCategoryID [nchar](3) NOT NULL PRIMARY KEY,
	Name [dbo].[Name] NULL,
	CreatedBy [nvarchar](50) NOT NULL DEFAULT USER_NAME(),
	CreatedDate [datetime2](2) NOT NULL DEFAULT SYSUTCDATETIME(),
	LastUpdatedBy [nvarchar](256) NULL,
	LastUpdatedDate datetime2(2) NULL,
	rowguid [uniqueidentifier] ROWGUIDCOL NOT NULL DEFAULT NEWSEQUENTIALID (),
	versionnumber rowversion,
	ValidFrom datetime2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
	ValidTo datetime2(2) NOT NULL DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'SAP Planned Category', 
	 @level0type=N'SCHEMA', @level0name=N'SAP', 
	 @level1type=N'TABLE',  @level1name=N'PlannedCategory';
GO

-- SAP.PlannedCategoryDetail
PRINT '-- SAP.PlannedCategoryDetail';
GO
CREATE TABLE SAP.PlannedCategoryDetail
(
	PlannedCategoryDetailID [nchar](3) NOT NULL PRIMARY KEY,
	Name [dbo].[Name] NULL,
	PlannedCategoryID [nchar](3) NOT NULL	CONSTRAINT FK_SAPPlannedCategoryDetail_PlannedCategoryID_PlannedCategory
											FOREIGN KEY (PlannedCategoryID)
											REFERENCES SAP.PlannedCategory(PlannedCategoryID)
											ON DELETE CASCADE
											ON UPDATE CASCADE,
	CostingSheetID [nchar](6) NOT NULL	CONSTRAINT FK_SAPPlannedCategoryDetail_CostingSheetID_CostingSheet
										FOREIGN KEY (CostingSheetID)
										REFERENCES SAP.CostingSheet(CostingSheetID),
	OverheadKeyID [nvarchar](6) NULL	CONSTRAINT FK_SAPPlannedCategoryDetail_OverheadKeyID_OverheadKey
										FOREIGN KEY (OverheadKeyID)
										REFERENCES SAP.OverheadKey(OverheadKeyID),
	CreatedBy [nvarchar](50) NOT NULL DEFAULT USER_NAME(),
	CreatedDate [datetime2](2) NOT NULL DEFAULT SYSUTCDATETIME(),
	LastUpdatedBy [nvarchar](256) NULL,
	LastUpdatedDate datetime2(2) NULL,
	rowguid [uniqueidentifier] ROWGUIDCOL NOT NULL DEFAULT NEWSEQUENTIALID (),
	versionnumber rowversion,
	ValidFrom datetime2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
	ValidTo datetime2(2) NOT NULL DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'SAP Planned Category Detail', 
	 @level0type=N'SCHEMA', @level0name=N'SAP', 
	 @level1type=N'TABLE',  @level1name=N'PlannedCategoryDetail';
GO

-- SAP.UserStatus
PRINT '-- SAP.UserStatus';
GO
CREATE TABLE SAP.UserStatus
(
	UserStatusID [nchar](2) NOT NULL PRIMARY KEY,
	Name [dbo].[name] NOT NULL,
	CreatedBy [nvarchar](50) NOT NULL DEFAULT USER_NAME(),
	CreatedDate [datetime2](2) NOT NULL DEFAULT SYSUTCDATETIME(),
	LastUpdatedBy [nvarchar](256) NULL,
	LastUpdatedDate datetime2(2) NULL,
	rowguid [uniqueidentifier] ROWGUIDCOL NOT NULL DEFAULT NEWSEQUENTIALID (),
	versionnumber rowversion,
	ValidFrom datetime2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
	ValidTo datetime2(2) NOT NULL DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);


-- SAP.AnalyzedIndicator
PRINT '-- SAP.AnalyzedIndicator';
GO
CREATE TABLE SAP.AnalyzedIndicator
(
	AnalyzedIndicatorID [nvarchar](3) NOT NULL PRIMARY KEY,
	Name [dbo].[Name] NULL,
	CreatedBy [nvarchar](50) NOT NULL DEFAULT USER_NAME(),
	CreatedDate [datetime2](2) NOT NULL DEFAULT SYSUTCDATETIME(),
	LastUpdatedBy [nvarchar](256) NULL,
	LastUpdatedDate datetime2(2) NULL,
	rowguid [uniqueidentifier] ROWGUIDCOL NOT NULL DEFAULT NEWSEQUENTIALID (),
	versionnumber rowversion,
	ValidFrom datetime2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
	ValidTo datetime2(2) NOT NULL DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'SAP Analyzed Indicator', 
	 @level0type=N'SCHEMA', @level0name=N'SAP', 
	 @level1type=N'TABLE',  @level1name=N'AnalyzedIndicator';
GO

-- SAP.PowerPlanOverride
PRINT '-- SAP.PowerPlanOverride';
GO
CREATE TABLE SAP.PowerPlanOverride
(
	PowerPlanOverrideID [nchar](2) NOT NULL PRIMARY KEY,
	Name [dbo].[Name] NULL,
	CreatedBy [nvarchar](50) NOT NULL DEFAULT USER_NAME(),
	CreatedDate [datetime2](2) NOT NULL DEFAULT SYSUTCDATETIME(),
	LastUpdatedBy [nvarchar](256) NULL,
	LastUpdatedDate datetime2(2) NULL,
	rowguid [uniqueidentifier] ROWGUIDCOL NOT NULL DEFAULT NEWSEQUENTIALID (),
	versionnumber rowversion,
	ValidFrom datetime2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
	ValidTo datetime2(2) NOT NULL DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'SAP PowerPlan Override - FAM Power Plan Process Type', 
	 @level0type=N'SCHEMA', @level0name=N'SAP', 
	 @level1type=N'TABLE',  @level1name=N'PowerPlanOverride';
GO

-- SAP.BillingType
PRINT '-- SAP.BillingType';
GO
CREATE TABLE SAP.BillingType
(
	BillingTypeID [nchar](2) NOT NULL PRIMARY KEY,
	Name [dbo].[Name] NULL,
	CreatedBy [nvarchar](50) NOT NULL DEFAULT USER_NAME(),
	CreatedDate [datetime2](2) NOT NULL DEFAULT SYSUTCDATETIME(),
	LastUpdatedBy [nvarchar](256) NULL,
	LastUpdatedDate datetime2(2) NULL,
	rowguid [uniqueidentifier] ROWGUIDCOL NOT NULL DEFAULT NEWSEQUENTIALID (),
	versionnumber rowversion,
	ValidFrom datetime2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
	ValidTo datetime2(2) NOT NULL DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);

-- SAP.CompanyCode
PRINT '-- SAP.CompanyCode';
GO
CREATE TABLE SAP.CompanyCode
(
	CompanyCodeID [nchar](4) NOT NULL PRIMARY KEY,
	Name [dbo].[Name] NULL,
	Description [dbo].[Description] NULL,
	CreatedBy [nvarchar](50) NOT NULL DEFAULT USER_NAME(),
	CreatedDate [datetime2](2) NOT NULL DEFAULT SYSUTCDATETIME(),
	LastUpdatedBy [nvarchar](256) NULL,
	LastUpdatedDate datetime2(2) NULL,
	rowguid [uniqueidentifier] ROWGUIDCOL NOT NULL DEFAULT NEWSEQUENTIALID (),
	versionnumber rowversion,
	ValidFrom datetime2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
	ValidTo datetime2(2) NOT NULL DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'SAP Company Code - The company code is an organizational unit within financial accounting.', 
	 @level0type=N'SCHEMA', @level0name=N'SAP', 
	 @level1type=N'TABLE',  @level1name=N'CompanyCode';
GO
EXEC sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'Primary key for Company Code - An organizational unit within financial accounting.', 
	 @level0type=N'SCHEMA', @level0name=N'SAP', 
	 @level1type=N'TABLE',  @level1name=N'CompanyCode', 
	 @level2type=N'COLUMN', @level2name=N'CompanyCodeID';
GO

-- SAP.DistrictCode
PRINT '-- SAP.DistrictCode';
GO
CREATE TABLE SAP.DistrictCode
(
	CompanyCodeID [nchar](4) NOT NULL DEFAULT '2100'	CONSTRAINT FK_SAPDistrictCode_CompanyCodeID_CompanyCode
														FOREIGN KEY (CompanyCodeID)
														REFERENCES SAP.CompanyCode(CompanyCodeID),
	RegionCodeID [nchar](2) NULL	CONSTRAINT FK_SAPDistrictCode_RegionCodeID_RegionCode
									FOREIGN KEY (RegionCodeID)
									REFERENCES SAP.RegionCode(RegionCodeID),
	DistrictCodeID [nvarchar](3) NOT NULL PRIMARY KEY,
	Name [dbo].[Name] NOT NULL,
	Description [dbo].[Description] NULL,
	CreatedBy [nvarchar](50) NOT NULL DEFAULT USER_NAME(),
	CreatedDate [datetime2](2) NOT NULL DEFAULT SYSUTCDATETIME(),
	LastUpdatedBy [nvarchar](256) NULL,
	LastUpdatedDate datetime2(2) NULL,
	rowguid [uniqueidentifier] ROWGUIDCOL NOT NULL DEFAULT NEWSEQUENTIALID (),
	versionnumber rowversion,
	ValidFrom datetime2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
	ValidTo datetime2(2) NOT NULL DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'SAP Three-Digit District Code', 
	 @level0type=N'SCHEMA', @level0name=N'SAP', 
	 @level1type=N'TABLE',  @level1name=N'DistrictCode';
GO

-- SAP.CostCenterCategory
PRINT '-- SAP.CostCenterCategory';
GO
CREATE TABLE SAP.CostCenterCategory
(
	CostCenterCategoryID [nchar](1) NOT NULL PRIMARY KEY,
	Name [dbo].[Name] NULL,
	CreatedBy [nvarchar](50) NOT NULL DEFAULT USER_NAME(),
	CreatedDate [datetime2](2) NOT NULL DEFAULT SYSUTCDATETIME(),
	LastUpdatedBy [nvarchar](256) NULL,
	LastUpdatedDate datetime2(2) NULL,
	rowguid [uniqueidentifier] ROWGUIDCOL NOT NULL DEFAULT NEWSEQUENTIALID (),
	versionnumber rowversion,
	ValidFrom datetime2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
	ValidTo datetime2(2) NOT NULL DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'SAP Cost Center Category - Indicator used to define a cost center category.', 
	 @level0type=N'SCHEMA', @level0name=N'SAP', 
	 @level1type=N'TABLE',  @level1name=N'CostCenterCategory';
GO
EXEC sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'Primary key for Cost Center Category - SAP indicator used to define a cost center category.', 
	 @level0type=N'SCHEMA', @level0name=N'SAP', 
	 @level1type=N'TABLE',  @level1name=N'CostCenterCategory', 
	 @level2type=N'COLUMN', @level2name=N'CostCenterCategoryID';
GO

-- SAP.Plant
PRINT '-- SAP.Plant';
GO
CREATE TABLE SAP.Plant
(
	PlantID [nchar](4) NOT NULL PRIMARY KEY,
	Name [dbo].[Name] NULL,
	CreatedBy [nvarchar](50) NOT NULL DEFAULT USER_NAME(),
	CreatedDate [datetime2](2) NOT NULL DEFAULT SYSUTCDATETIME(),
	LastUpdatedBy [nvarchar](256) NULL,
	LastUpdatedDate datetime2(2) NULL,
	rowguid [uniqueidentifier] ROWGUIDCOL NOT NULL DEFAULT NEWSEQUENTIALID (),
	versionnumber rowversion,
	ValidFrom datetime2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
	ValidTo datetime2(2) NOT NULL DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'SAP Plant - SAP key uniquely identifying a plant.', 
	 @level0type=N'SCHEMA', @level0name=N'SAP', 
	 @level1type=N'TABLE',  @level1name=N'Plant';
GO
EXEC sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'Primary key for Plant - SAP key uniquely identifying a plant.', 
	 @level0type=N'SCHEMA', @level0name=N'SAP', 
	 @level1type=N'TABLE',  @level1name=N'Plant', 
	 @level2type=N'COLUMN', @level2name=N'PlantID';
GO

-- DPSS.COType
PRINT '-- DPSS.COType';
GO
CREATE TABLE DPSS.COType
(
	COTypeID [nchar](2) NOT NULL PRIMARY KEY,
	Name [dbo].[Name] NULL,
	CreatedBy [nvarchar](50) NOT NULL DEFAULT USER_NAME(),
	CreatedDate [datetime2](2) NOT NULL DEFAULT SYSUTCDATETIME(),
	LastUpdatedBy [nvarchar](256) NULL,
	LastUpdatedDate datetime2(2) NULL,
	rowguid [uniqueidentifier] ROWGUIDCOL NOT NULL DEFAULT NEWSEQUENTIALID (),
	versionnumber rowversion,
	ValidFrom datetime2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
	ValidTo datetime2(2) NOT NULL DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'DPSS CO Type - Utilized by First Characters of SAP Application Field', 
	 @level0type=N'SCHEMA', @level0name=N'DPSS', 
	 @level1type=N'TABLE',  @level1name=N'COType';
GO

-- Common.BillingCode
PRINT '-- Common.BillingCode';
GO
CREATE TABLE Common.BillingCode
(
	BillingCodeID [nvarchar](3) NOT NULL PRIMARY KEY,
	BillingCodeWOA [nvarchar](3) NULL,
	Name [dbo].[Name] NULL,
	Description [dbo].[Description] NULL,
	CreatedBy [nvarchar](50) NOT NULL DEFAULT USER_NAME(),
	CreatedDate [datetime2](2) NOT NULL DEFAULT SYSUTCDATETIME(),
	LastUpdatedBy [nvarchar](256) NULL,
	LastUpdatedDate datetime2(2) NULL,
	rowguid [uniqueidentifier] ROWGUIDCOL NOT NULL DEFAULT NEWSEQUENTIALID (),
	versionnumber rowversion,
	ValidFrom datetime2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
	ValidTo datetime2(2) NOT NULL DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'Common Billing Codes Defined by SDG&E SOP', 
	 @level0type=N'SCHEMA', @level0name=N'Common', 
	 @level1type=N'TABLE',  @level1name=N'BillingCode';
GO

-- SAP.CostCenter
PRINT '-- SAP.CostCenter';
GO
CREATE TABLE SAP.CostCenter
(
	CostCenterID [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	CostCenter [nchar](9) NOT NULL,
	Description [dbo].[Description] NULL,
	Name [dbo].[Name] NULL,
	Manager_EmployeeID [nchar](5) NULL,
	Department [nchar](6) NULL,
	HierarchyArea [nvarchar](10) NULL,
	SharedServiceIndicator [nchar](3) NULL,
	CostingSheetID [nchar](6) NULL	CONSTRAINT FK_SAPCostCenter_CostingSheetID_CostingSheet
									FOREIGN KEY (CostingSheetID)
									REFERENCES SAP.CostingSheet(CostingSheetID)
									ON DELETE CASCADE
									ON UPDATE CASCADE,
	CostCenterCategoryID [nchar](1)	CONSTRAINT FK_SAPCostCenter_CostCenterCategoryID_CostCenterCategory
									FOREIGN KEY (CostCenterCategoryID)
									REFERENCES SAP.CostCenterCategory(CostCenterCategoryID)
									ON DELETE CASCADE
									ON UPDATE CASCADE,
	Actual_PrimaryCosts [bit] NOT NULL DEFAULT 1,
	Actual_SecondaryCosts [bit] NOT NULL DEFAULT 1,
	CreatedBy [nvarchar](50) NOT NULL DEFAULT USER_NAME(),
	CreatedDate [datetime2](2) NOT NULL DEFAULT SYSUTCDATETIME(),
	LastUpdatedBy [nvarchar](256) NULL,
	LastUpdatedDate datetime2(2) NULL,
	rowguid [uniqueidentifier] ROWGUIDCOL NOT NULL DEFAULT NEWSEQUENTIALID (),
	versionnumber rowversion,
	ValidFrom datetime2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
	ValidTo datetime2(2) NOT NULL DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'SAP Cost Center - Organizational unit within a controlling area that represents a defined location of cost incurrence.', 
	 @level0type=N'SCHEMA', @level0name=N'SAP', 
	 @level1type=N'TABLE',  @level1name=N'CostCenter';
GO
EXEC sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'Primary key for Cost Center - Organizational unit within a controlling area that represents a defined location of cost incurrence.', 
	 @level0type=N'SCHEMA', @level0name=N'SAP', 
	 @level1type=N'TABLE',  @level1name=N'CostCenter', 
	 @level2type=N'COLUMN', @level2name=N'CostCenterID';
GO

/** --	SAP.Employee
		{MUST BE AFTER SAP.CostCenter}
		{MUST BE BEFORE WOA.WorkOrder}**/
PRINT '-- SAP.Employee';
GO
CREATE TABLE SAP.Employee
(
	EmployeeID [int] NOT NULL PRIMARY KEY,
	EmployeeIDString AS (FORMAT(EmployeeID,'00000')),
	SAPUserName [nvarchar](15) NULL,
	WINUserName [nvarchar](15) NULL,
	SQLUserName [nvarchar](50) NULL,
	OrganizationNode [hierarchyid] NULL,
	OrganizationLevel AS (OrganizationNode.GetLevel()),
	ManagerID [int] NULL,
	CostCenterID [int] NULL,
	JobTitle [nvarchar](50) NULL,
	EmployeeName_First [nvarchar](50) NULL,
	EmployeeName_Last [nvarchar](50) NULL,
	EmailAddress [nvarchar](100) NULL,
	PhoneNumber [nchar](10) NULL,
	Accountant [bit] NOT NULL DEFAULT 0,
	Administrator [bit] NOT NULL DEFAULT 0,
	CreatedBy [nvarchar](50) NOT NULL DEFAULT USER_NAME(),
	CreatedDate [datetime2](2) NOT NULL DEFAULT SYSUTCDATETIME(),
	LastUpdatedBy [nvarchar](256) NULL,
	LastUpdatedDate datetime2(2) NULL,
	rowguid [uniqueidentifier] ROWGUIDCOL NOT NULL DEFAULT NEWSEQUENTIALID (),
	versionnumber rowversion,
	ValidFrom datetime2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
	ValidTo datetime2(2) NOT NULL DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
GO

/** --	SAP.EmployeeAuthorization
		{MUST BE AFTER SAP.Employee}**/
PRINT '-- SAP.EmployeeAuthorization';
GO
CREATE TABLE SAP.EmployeeAuthorization
(
	EmployeeAuthorizationID [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	EmployeeID [int] NOT NULL	CONSTRAINT FK_SAPEmployeeAuthorization_EmployeeID_Employee
								FOREIGN KEY (EmployeeID)
								REFERENCES SAP.Employee(EmployeeID),
	ApprovalLevelID [nvarchar](2) NULL,
	DelegatingManagerID [int] NULL	CONSTRAINT FK_SAPEmployeeAuthorization_DelegatingManagerID_Employee
										FOREIGN KEY (DelegatingManagerID)
										REFERENCES SAP.Employee(EmployeeID),
	Delegated_Category_1 [money] NOT NULL DEFAULT 0,
	Delegated_Category_2 [money] NOT NULL DEFAULT 0,
	Delegated_Category_3_PurchReq [money] NOT NULL DEFAULT 0,
	Delegated_Category_4A_POInv [money] NOT NULL DEFAULT 0,
	Delegated_Category_4B_NonPOInv [money] NOT NULL DEFAULT 0,
	Delegated_Category_5_EmpReimb [money] NOT NULL DEFAULT 0,
	Delegated_Category_6_ProCard [money] NOT NULL DEFAULT 0,
	CreatedBy [nvarchar](50) NOT NULL DEFAULT USER_NAME(),
	CreatedDate [datetime2](2) NOT NULL DEFAULT SYSUTCDATETIME(),
	LastUpdatedBy [nvarchar](256) NULL,
	LastUpdatedDate datetime2(2) NULL,
	rowguid [uniqueidentifier] ROWGUIDCOL NOT NULL DEFAULT NEWSEQUENTIALID (),
	versionnumber rowversion,
	ValidFrom datetime2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
	ValidTo datetime2(2) NOT NULL DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
GO

-- SAP.KOK3
PRINT '-- SAP.KOK3';
GO
CREATE TABLE SAP.KOK3
(
	ExternalOrderNumber [nvarchar](20),
	DPSSNumber [nvarchar](10) NULL,
	OrderNumber [nvarchar](12) NULL,
	Description [nvarchar](40) NULL,
	BudgetCategoryCode [nvarchar](4) NULL,
	InterestProfileID [nvarchar](7) NULL,
	OrderTypeID [nchar](4) NULL,
	OverheadKeyID [nvarchar](6) NULL,
	CostingSheetID [nchar](6) NULL,
	SystemStatus [nvarchar](20) NULL,
	CostEstimate [money] NOT NULL DEFAULT 0,
	ReauthorizationAmount [money] NOT NULL DEFAULT 0,
	ReleaseDate [datetime] NULL,
	EstimatedCompletionDate [datetime] NULL,
	WorkEndDate [datetime] NULL,
	TechnicalCompletion [datetime] NULL,
	CloseDate [datetime] NULL,
	CompanyCode [nvarchar](4) NULL,
	CostCenter [nchar](9) NULL,
	PersonResponsible [nvarchar](20) NULL,
	RegionCodeID [nchar](2) NULL,
	DistrictCodeID [nvarchar](3) NULL,
	CreatedBy [nvarchar](50) NOT NULL DEFAULT USER_NAME(),
	CreatedDate [datetime2](2) NOT NULL DEFAULT SYSUTCDATETIME(),
	LastUpdatedBy [nvarchar](256) NULL,
	LastUpdatedDate datetime2(2) NULL,
	rowguid [uniqueidentifier] ROWGUIDCOL NOT NULL DEFAULT NEWSEQUENTIALID (),
	versionnumber rowversion,
	ValidFrom datetime2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
	ValidTo datetime2(2) NOT NULL DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
GO

-- WOA.ParentOrderProject
PRINT '-- WOA.ParentOrderProject';
GO
CREATE TABLE WOA.ParentOrderProject
(
	ParentOrderProjectID [nvarchar](2) NOT NULL PRIMARY KEY,
	Name [dbo].[Name] NULL,
	Description [dbo].[Description] NULL,
	CreatedBy [nvarchar](256) NOT NULL DEFAULT USER_NAME(),
	CreatedDate datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),
	rowguid [uniqueidentifier] ROWGUIDCOL NOT NULL DEFAULT NEWSEQUENTIALID (),
	versionnumber rowversion,
	ValidFrom datetime2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
	ValidTo datetime2(2) NOT NULL DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);


-- WOA.WorkOrder
PRINT '-- WOA.WorkOrder';
GO
CREATE TABLE WOA.WorkOrder
(
	WorkOrderID [bigint] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	WorkOrderNode [hierarchyid] NULL CONSTRAINT UK_WOAWorkOrder_WorkOrderNode UNIQUE,
	WorkOrder [nchar](7) NULL,
	OrderTypeID [nchar](4) NOT NULL DEFAULT 'S010' 	CONSTRAINT FK_WOAWorkOrder_OrderTypeID_SAPOrderType
													FOREIGN KEY (OrderTypeID)
													REFERENCES SAP.OrderType(OrderTypeID),
	IProtectClassificationID [tinyint] NOT NULL DEFAULT 2	CONSTRAINT FK_WOAWorkOrder_IProtectClassificationID_CommonIProtectClassification
															FOREIGN KEY(IProtectClassificationID)
															REFERENCES Common.IProtectClassification(IProtectClassificationID),
	ShortText [nvarchar](28) NULL,
	CompanyCodeID [nchar](4) NOT NULL DEFAULT '2100'	CONSTRAINT FK_WOAWorkOrder_CompanyCodeID_CompanyCode
														FOREIGN KEY (CompanyCodeID)
														REFERENCES SAP.CompanyCode(CompanyCodeID),
	PlantID nchar(4) NULL	CONSTRAINT FK_WOAWorkOrder_PlantID_Plant
							FOREIGN KEY (PlantID)
							REFERENCES SAP.Plant(PlantID),
	BusinessAreaID [nchar](4) NULL,
	CostCenterID [int] NULL	CONSTRAINT FK_WOAWorkOrder_CostCenterID_CostCenter
								FOREIGN KEY (CostCenterID)
								REFERENCES SAP.CostCenter(CostCenterID),
	CostingSheetID [nchar](6) NULL	CONSTRAINT FK_WOAWorkOrder_CostingSheetID_CostingSheet
									FOREIGN KEY (CostingSheetID)
									REFERENCES SAP.CostingSheet(CostingSheetID),
	OverheadKeyID [nvarchar](6) NULL	CONSTRAINT FK_WOAWorkOrder_OverheadKeyID_OverheadKey
										FOREIGN KEY (OverheadKeyID)
										REFERENCES SAP.OverheadKey(OverheadKeyID),
	InterestProfileID [nvarchar](7) NULL	CONSTRAINT FK_WOAWorkOrder_InterestProfileID_InterestProfile
											FOREIGN KEY (InterestProfileID)
											REFERENCES SAP.InterestProfile(InterestProfileID),
	COTypeID [nchar](2) NULL	CONSTRAINT FK_WOAWorkOrder_COTypeID_COType
								FOREIGN KEY (COTypeID)
								REFERENCES DPSS.COType(COTypeID),
	BillingCodeID [nvarchar](3) NULL	CONSTRAINT FK_WOAWorkOrder_BillingCodeID_BillingCode
										FOREIGN KEY (BillingCodeID)
										REFERENCES Common.BillingCode(BillingCodeID),
	Applicant [nvarchar](20) NULL,
	FERCIndicator [nvarchar](20) NULL,
	WorkStartDate [datetime] NOT NULL DEFAULT CAST(SYSUTCDATETIME() AS datetime),
	WorkEndDate [datetime] NULL,
	CostEstimate [money] NOT NULL DEFAULT 0,
	RegionCodeID [nchar](2) NULL	CONSTRAINT FK_WOAWorkOrder_RegionCodeID_RegionCode
									FOREIGN KEY (RegionCodeID)
									REFERENCES SAP.RegionCode(RegionCodeID),
	DistrictCodeID [nvarchar](3) NULL	CONSTRAINT FK_WOAWorkOrder_DistrictCodeID_DistrictCode
										FOREIGN KEY (DistrictCodeID)
										REFERENCES SAP.DistrictCode(DistrictCodeID),
	CollectiblePercentage DECIMAL(6,2) NOT NULL DEFAULT 0.00,
	CityID [nchar](2) NULL	CONSTRAINT FK_WOAWorkOrder_CityID_City
							FOREIGN KEY (CityID)
							REFERENCES SAP.City(CityID),
	ReauthorizationAmount [money] NOT NULL DEFAULT 0,
	ReauthorizationDate [datetime] NULL,
	ProjectManagerID [int] NULL	CONSTRAINT FK_WOAWorkOrder_ProjectManagerID_Employee
								FOREIGN KEY (ProjectManagerID)
								REFERENCES SAP.Employee(EmployeeID),
	UserStatusID [nchar](2) NOT NULL DEFAULT '10'	CONSTRAINT FK_WOAWorkOrder_UserStatusID_UserStatus
													FOREIGN KEY (UserStatusID)
													REFERENCES SAP.UserStatus(UserStatusID),
	EstimatedCompletionDate [datetime] NULL,
	DPSSNumber [nvarchar](10) NULL,
	BillingTypeID [nchar](2) NULL	CONSTRAINT FK_WOAWorkOrder_BillingTypeID_BillingType
									FOREIGN KEY (BillingTypeID)
									REFERENCES SAP.BillingType(BillingTypeID),
	PlannedCategoryID [nchar](3) NULL	CONSTRAINT FK_WOAWorkOrder_PlannedCategoryID_PlannedCategory
										FOREIGN KEY (PlannedCategoryID)
										REFERENCES SAP.PlannedCategory(PlannedCategoryID),
	PlannedCategoryDetailID [nchar](3) NULL	CONSTRAINT FK_WOAWorkOrder_PlannedCategoryDetailID_PlannedCategoryDetail
											FOREIGN KEY (PlannedCategoryDetailID)
											REFERENCES SAP.PlannedCategoryDetail(PlannedCategoryDetailID),
	AnalyzedIndicatorID [nvarchar](3) NULL	CONSTRAINT FK_WOAWorkOrder_AnalyzedIndicatorID_AnalyzedIndicator
											FOREIGN KEY (AnalyzedIndicatorID)
											REFERENCES SAP.AnalyzedIndicator(AnalyzedIndicatorID),
	AnalyzedIndicatorDate [datetime] NULL,
	PowerPlanOverrideID [nchar](2) NOT NULL	DEFAULT '  '
											CONSTRAINT FK_WOAWorkOrder_PowerPlanOverrideID_PowerPlanOverride
											FOREIGN KEY (PowerPlanOverrideID)
											REFERENCES SAP.PowerPlanOverride(PowerPlanOverrideID),
	ParentOrder [bit] NOT NULL DEFAULT 0,
	Revision [tinyint] NOT NULL DEFAULT 0,
	CreatedBy [nvarchar](256) NOT NULL DEFAULT USER_NAME(),
	CreatedDate datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),
	rowguid [uniqueidentifier] ROWGUIDCOL NOT NULL DEFAULT NEWSEQUENTIALID (),
	versionnumber rowversion,
	ValidFrom datetime2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
	ValidTo datetime2(2) NOT NULL DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'SDG&E Work Order Header Details', 
	 @level0type=N'SCHEMA', @level0name=N'WOA', 
	 @level1type=N'TABLE',  @level1name=N'WorkOrder';
GO
EXEC sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'Primary key for Work Order.', 
	 @level0type=N'SCHEMA', @level0name=N'WOA', 
	 @level1type=N'TABLE',  @level1name=N'WorkOrder', 
	 @level2type=N'COLUMN', @level2name=N'WorkOrderID';
GO
EXEC sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'SAP Order Type - Key that differentiates orders according to their purpose.', 
	 @level0type=N'SCHEMA', @level0name=N'WOA', 
	 @level1type=N'TABLE',  @level1name=N'WorkOrder', 
	 @level2type=N'COLUMN', @level2name=N'OrderTypeID';
GO
EXEC sp_addextendedproperty
	 @name=N'MS_Description',
	 @value=N'Sempra Energy Information Protection Classification',
	 @level0type=N'SCHEMA', @level0name=N'WOA',
	 @level1type=N'TABLE',  @level1name=N'WorkOrder', 
	 @level2type=N'COLUMN', @level2name=N'IProtectClassificationID';
GO
EXEC sp_addextendedproperty
	 @name=N'MS_Description',
	 @value=N'SAP Short description of the order (language-independent)',
	 @level0type=N'SCHEMA', @level0name=N'WOA',
	 @level1type=N'TABLE',  @level1name=N'WorkOrder', 
	 @level2type=N'COLUMN', @level2name=N'ShortText';
EXEC sp_addextendedproperty
	 @name=N'MS_Description',
	 @value=N'SAP Informational Field - Expected Start of Work Date',
	 @level0type=N'SCHEMA', @level0name=N'WOA',
	 @level1type=N'TABLE',  @level1name=N'WorkOrder', 
	 @level2type=N'COLUMN', @level2name=N'WorkStartDate';
EXEC sp_addextendedproperty
	 @name=N'MS_Description',
	 @value=N'SAP Informational Field - End of Work Date',
	 @level0type=N'SCHEMA', @level0name=N'WOA',
	 @level1type=N'TABLE',  @level1name=N'WorkOrder', 
	 @level2type=N'COLUMN', @level2name=N'WorkEndDate';
GO
EXEC sp_addextendedproperty
	 @name=N'MS_Description',
	 @value=N'SAP key uniquely identifying plant that the order is assigned to for organizational purposes.',
	 @level0type=N'SCHEMA', @level0name=N'WOA',
	 @level1type=N'TABLE',  @level1name=N'WorkOrder', 
	 @level2type=N'COLUMN', @level2name=N'PlantID';
GO


-- WOA.WorkOrder_History
PRINT '-- WOA.WorkOrder_History';
GO
CREATE TABLE WOA.WorkOrder_History
(
	WorkOrderHistoryID [bigint] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	WorkOrderID [bigint] NULL,
	WorkOrderNode [hierarchyid] NULL,
	WorkOrder [nchar](7) NULL,
	OrderTypeID [nchar](4) NULL,
	IProtectClassificationID [tinyint] NULL,
	ShortText [nvarchar](28) NULL,
	CompanyCodeID [nchar](4) NULL,
	PlantID nchar(4) NULL,
	BusinessAreaID [nchar](4) NULL,
	CostCenterID [int] NULL,
	CostingSheetID [nchar](6) NULL,
	OverheadKeyID [nvarchar](6) NULL,
	InterestProfileID [nvarchar](7) NULL,
	COTypeID [nchar](2) NULL,
	BillingCodeID [nvarchar](3) NULL,
	Applicant [nvarchar](20) NULL,
	FERCIndicator [nvarchar](20) NULL,
	WorkStartDate [datetime] NULL,
	WorkEndDate [datetime] NULL,
	CostEstimate [money] NOT NULL DEFAULT 0,
	RegionCodeID [nchar](2) NULL,
	DistrictCodeID [nvarchar](3) NULL,
	CollectiblePercentage DECIMAL(6,2) NOT NULL DEFAULT 0.00,
	CityID [nchar](2) NULL,
	ReauthorizationAmount [money] NOT NULL DEFAULT 0,
	ReauthorizationDate [datetime] NULL,
	ProjectManagerID [int] NULL,
	UserStatusID [nchar](2) NULL,
	EstimatedCompletionDate [datetime] NULL,
	DPSSNumber [nvarchar](10) NULL,
	BillingTypeID [nchar](2) NULL,
	PlannedCategoryID [nchar](3) NULL,
	PlannedCategoryDetailID [nchar](3) NULL,
	AnalyzedIndicatorID [nvarchar](3) NULL,
	AnalyzedIndicatorDate [datetime] NULL,
	PowerPlanOverrideID [nchar](2) NULL,
	ParentOrder [bit] NULL,
	Revision [tinyint] NOT NULL DEFAULT 0,
	CreatedBy [nvarchar](256) NULL,
	CreatedDate datetime2 NULL,
	rowguid [uniqueidentifier] ROWGUIDCOL NOT NULL DEFAULT NEWSEQUENTIALID (),
	versionnumber rowversion,
	ValidFrom datetime2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
	ValidTo datetime2(2) NOT NULL DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);


-- WOA.InternalOrder
PRINT '-- WOA.InternalOrder';
GO
CREATE TABLE WOA.InternalOrder
(
	InternalOrderID [bigint] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	WorkOrderID [bigint] NOT NULL 	CONSTRAINT FK_WOAInternalOrder_WorkOrderID_WOAWorkOrder
									FOREIGN KEY (WorkOrderID)
									REFERENCES WOA.WorkOrder(WorkOrderID)
									ON DELETE CASCADE
									ON UPDATE CASCADE,
	WorkOrderNode [hierarchyid] NOT NULL CONSTRAINT FK_WOAInternalOrder_WorkOrderNode_WOAWorkOrder
										 FOREIGN KEY (WorkOrderNode)
										 REFERENCES WOA.WorkOrder(WorkOrderNode),
	OrderNumber [nvarchar](12),
	ExternalOrderNumber [nvarchar](20),
	CostingSheetID [nchar](6) NULL	CONSTRAINT FK_WOAInternalOrder_CostingSheetID_CostingSheet
									FOREIGN KEY (CostingSheetID)
									REFERENCES SAP.CostingSheet(CostingSheetID),
	OverheadKeyID [nvarchar](6) NULL	CONSTRAINT FK_WOAInternalOrder_OverheadKeyID_OverheadKey
										FOREIGN KEY (OverheadKeyID)
										REFERENCES SAP.OverheadKey(OverheadKeyID),
	InterestProfileID [nvarchar](7) NULL	CONSTRAINT FK_WOAInternalOrder_InterestProfileID_InterestProfile
											FOREIGN KEY (InterestProfileID)
											REFERENCES SAP.InterestProfile(InterestProfileID),
	CreatedBy [nvarchar](50) NOT NULL DEFAULT USER_NAME(),
	CreatedDate [datetime2](2) NOT NULL DEFAULT SYSUTCDATETIME(),
	LastUpdatedBy [nvarchar](256) NULL,
	LastUpdatedDate datetime2(2) NULL,
	rowguid [uniqueidentifier] ROWGUIDCOL NOT NULL DEFAULT NEWSEQUENTIALID (),
	versionnumber rowversion,
	ValidFrom datetime2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
	ValidTo datetime2(2) NOT NULL DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'SDG&E Internal Order Details', 
	 @level0type=N'SCHEMA', @level0name=N'WOA', 
	 @level1type=N'TABLE',  @level1name=N'InternalOrder';
GO
EXEC sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'Primary key for Internal Order.', 
	 @level0type=N'SCHEMA', @level0name=N'WOA', 
	 @level1type=N'TABLE',  @level1name=N'InternalOrder', 
	 @level2type=N'COLUMN', @level2name=N'InternalOrderID';
GO
EXEC sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'Foreign Key to WOA.WorkOrder.WorkOrderID.', 
	 @level0type=N'SCHEMA', @level0name=N'WOA', 
	 @level1type=N'TABLE',  @level1name=N'InternalOrder', 
	 @level2type=N'COLUMN', @level2name=N'WorkOrderID';
GO
EXEC sp_addextendedproperty
	 @name=N'MS_Description',
	 @value=N'SAP Number which identifies an order within a client.',
	 @level0type=N'SCHEMA', @level0name=N'WOA', 
	 @level1type=N'TABLE',  @level1name=N'InternalOrder', 
	 @level2type=N'COLUMN', @level2name=N'OrderNumber';
EXEC sp_addextendedproperty
	 @name=N'MS_Description',
	 @value=N'Collection of key order information.',
	 @level0type=N'SCHEMA', @level0name=N'WOA', 
	 @level1type=N'TABLE',  @level1name=N'InternalOrder', 
	 @level2type=N'COLUMN', @level2name=N'ExternalOrderNumber';

/****** STORED PROCEDURES ******/
PRINT '/****** STORED PROCEDURES ******/';
GO

PRINT '-- Common.getSQLUserName';
GO
CREATE PROCEDURE	Common.getSQLUserName
					(
						@SQLUserName [nvarchar](256) OUTPUT
					)
					AS
					BEGIN
						SET @SQLUserName = USER_NAME();
					END;
GO

PRINT '-- WOA.mergeWorkOrder';
GO
CREATE PROCEDURE WOA.mergeWorkOrder
				(
					@WorkOrderID [bigint] = 0,
					@WorkOrderNode [hierarchyid],
					@WorkOrder [nchar](7),
					@OrderTypeID [nchar](4) = 'S010',
					@IProtectClassificationID [tinyint] = 2,
					@ShortText [nvarchar](28),
					@CompanyCodeID [nchar](4) = '2100',
					@PlantID [nchar](4),
					@BusinessAreaID [nchar](4),
					@CostCenterID [int],
					@CostingSheetID [nchar](6),
					@OverheadKeyID [nvarchar](6),
					@InterestProfileID [nvarchar](7),
					@COTypeID [nchar](2),
					@BillingCodeID [nvarchar](3),
					@Applicant [nvarchar](20),
					@WorkStartDate [datetime] = NULL,
					@WorkEndDate [datetime],
					@CostEstimate [money] = 0,
					@RegionCodeID [nchar](2),
					@DistrictCodeID [nvarchar](3),
					@CollectiblePercentage DECIMAL(6,2) = 0.00,
					@CityID [nchar](2),
					@ReauthorizationAmount [money] = 0,
					@ReauthorizationDate [datetime],
					@ProjectManagerID [int],
					@UserStatusID [nchar](2) = '10',
					@EstimatedCompletionDate [datetime],
					@DPSSNumber [nvarchar](10),
					@BillingTypeID [nchar](2),
					@PlannedCategoryID [nchar](3),
					@PlannedCategoryDetailID [nchar](3),
					@AnalyzedIndicatorID [nvarchar](3),
					@AnalyzedIndicatorDate [datetime],
					@PowerPlanOverrideID [nchar](2) = '  ',
					@ParentOrder [bit] = 0,
					@Revision [tinyint] = 0,
					@CommonTimeStamp [datetime2] = NULL,
					@MergeWorkOrderID [bigint] OUTPUT
				)
				AS
				BEGIN
					SET NOCOUNT ON;
					SET @Applicant = ISNULL(@COTypeID,'  ') + '-' + ISNULL(@BillingCodeID,'')
					IF (@WorkStartDate IS NULL)
						SET @WorkStartDate = CAST(SYSUTCDATETIME() AS datetime);
					SET @CommonTimeStamp = SYSUTCDATETIME();
				END
				BEGIN
					SET NOCOUNT ON;
					IF EXISTS(SELECT WorkOrderID FROM WOA.mergeWorkOrder WHERE WorkOrderID = @WorKOrderID)
						INSERT INTO WOA.WorkOrder_History
									(	WorKorderID, 
										WorkOrderNode, 
										WorkOrder, 
										OrderTypeID, 
										IProtectClassificationID, 
										ShortText,
										CompanyCodeID,
										PlantID,
										BusinessAreaID,
										CostCenterID,
										CostingSheetID,
										OverheadKeyID,
										InterestProfileID,
										COTypeID,
										BillingCodeID,
										Applicant,
										WorkStartDate,
										WorkEndDate,
										CostEstimate,
										RegionCodeID,
										DistrictCodeID,
										CollectiblePercentage,
										CityID,
										ReauthorizationAmount,
										ReauthorizationDate,
										ProjectManagerID,
										UserStatusID,
										EstimatedCompletionDate,
										DPSSNumber,
										BillingTypeID,
										PlannedCategoryID,
										PlannedCategoryDetailID,
										AnalyzedIndicatorID,
										AnalyzedIndicatorDate,
										PowerPlanOverrideID,
										ParentOrder,
										Revision,
										CreatedBy,
										CreatedDate,
										ValidFrom,
										ValidTo)
									SELECT	WorKorderID, 
											WorkOrderNode, 
											WorkOrder, 
											OrderTypeID, 
											IProtectClassificationID, 
											ShortText,
											CompanyCodeID,
											PlantID,
											BusinessAreaID,
											CostCenterID,
											CostingSheetID,
											OverheadKeyID,
											InterestProfileID,
											COTypeID,
											BillingCodeID,
											Applicant,
											WorkStartDate,
											WorkEndDate,
											CostEstimate,
											RegionCodeID,
											DistrictCodeID,
											CollectiblePercentage,
											CityID,
											ReauthorizationAmount,
											ReauthorizationDate,
											ProjectManagerID,
											UserStatusID,
											EstimatedCompletionDate,
											DPSSNumber,
											BillingTypeID,
											PlannedCategoryID,
											PlannedCategoryDetailID,
											AnalyzedIndicatorID,
											AnalyzedIndicatorDate,
											PowerPlanOverrideID,
											ParentOrder,
											Revision,
											CreatedBy,
											CreatedDate,
											ValidFrom,
											@CommonTimeStamp AS tmpValidTo
									FROM WOA.WorkOrder;
				END
				BEGIN
					MERGE WOA.WorkOrder WITH (HOLDLOCK) AS m
					USING (Select	@WorkOrderID AS WorkOrderID,
									@WorkOrderNode AS WorkOrderNode,
									@WorkOrder AS WorkOrder,
									@OrderTypeID AS OrderTypeID,
									@IProtectClassificationID AS IProtectClassificationID,
									@ShortText AS ShortText,
									@CompanyCodeID AS CompanyCodeID,
									@PlantID AS PlantID,
									@BusinessAreaID AS BusinessAreaID,
									@CostCenterID AS CostCenterID,
									@CostingSheetID AS CostingSheetID,
									@OverheadKeyID AS OverheadKeyID,
									@InterestProfileID AS InterestProfileID,
									@COTypeID AS COTypeID,
									@BillingCodeID AS BillingCodeID,
									@Applicant AS Applicant,
									@WorkStartDate AS WorkStartDate,
									@WorkEndDate AS WorkEndDate,
									@CostEstimate AS CostEstimate,
									@RegionCodeID AS RegionCodeID,
									@DistrictCodeID AS DistrictCodeID,
									@CollectiblePercentage AS CollectiblePercentage,
									@CityID AS CityID,
									@ReauthorizationAmount AS ReauthorizationAmount,
									@ReauthorizationDate AS ReauthorizationDate,
									@ProjectManagerID AS ProjectManagerID,
									@UserStatusID AS UserStatusID,
									@EstimatedCompletionDate AS EstimatedCompletionDate,
									@DPSSNumber AS DPSSNumber,
									@BillingTypeID AS BillingTypeID,
									@PlannedCategoryID AS PlannedCategoryID,
									@PlannedCategoryDetailID AS PlannedCategoryDetailID,
									@AnalyzedIndicatorID AS AnalyzedIndicatorID,
									@AnalyzedIndicatorDate AS AnalyzedIndicatorDate,
									@PowerPlanOverrideID AS PowerPlanOverrideID,
									@ParentOrder AS ParentOrder,
									@Revision AS Revision
						  ) AS s ON m.WorkOrderID = s.WorkOrderID
					WHEN MATCHED THEN
						UPDATE 
						SET	WorkOrderNode = @WorkOrderNode,
							WorkOrder = @WorkOrder, 
							OrderTypeID = @OrderTypeID, 
							IProtectClassificationID = @IProtectClassificationID, 
							ShortText = @ShortText,
							CompanyCodeID = @CompanyCodeID,
							PlantID = @PlantID,
							BusinessAreaID = @BusinessAreaID,
							CostCenterID = @CostCenterID,
							CostingSheetID = @CostingSheetID,
							OverheadKeyID = @OverheadKeyID,
							InterestProfileID = @InterestProfileID,
							COTypeID = @COTypeID,
							BillingCodeID = @BillingCodeID,
							Applicant = @Applicant,
							WorkStartDate = @WorkStartDate,
							WorkEndDate = @WorkEndDate,
							CostEstimate = @CostEstimate,
							RegionCodeID = @RegionCodeID,
							DistrictCodeID = @DistrictCodeID,
							CollectiblePercentage = @CollectiblePercentage,
							CityID = @CityID,
							ReauthorizationAmount = @ReauthorizationAmount,
							ReauthorizationDate = @ReauthorizationDate,
							ProjectManagerID = @ProjectManagerID,
							UserStatusID = @UserStatusID,
							EstimatedCompletionDate = @EstimatedCompletionDate,
							DPSSNumber = @DPSSNumber,
							BillingTypeID = @BillingTypeID,
							PlannedCategoryID = @PlannedCategoryID,
							PlannedCategoryDetailID = @PlannedCategoryDetailID,
							AnalyzedIndicatorID = @AnalyzedIndicatorID,
							AnalyzedIndicatorDate = @AnalyzedIndicatorDate,
							PowerPlanOverrideID = @PowerPlanOverrideID,
							ParentOrder = @ParentOrder,
							Revision = @Revision,
							CreatedBy = USER_NAME(),
							CreatedDate = SYSUTCDATETIME(),
							ValidFrom = @CommonTimeStamp
					WHEN NOT MATCHED THEN
						INSERT 
						(	WorkOrderNode, 
							WorkOrder, 
							OrderTypeID, 
							IProtectClassificationID, 
							ShortText,
							CompanyCodeID,
							PlantID,
							BusinessAreaID,
							CostCenterID,
							CostingSheetID,
							OverheadKeyID,
							InterestProfileID,
							COTypeID,
							BillingCodeID,
							Applicant,
							WorkStartDate,
							WorkEndDate,
							CostEstimate,
							RegionCodeID,
							DistrictCodeID,
							CollectiblePercentage,
							CityID,
							ReauthorizationAmount,
							ReauthorizationDate,
							ProjectManagerID,
							UserStatusID,
							EstimatedCompletionDate,
							DPSSNumber,
							BillingTypeID,
							PlannedCategoryID,
							PlannedCategoryDetailID,
							AnalyzedIndicatorID,
							AnalyzedIndicatorDate,
							PowerPlanOverrideID,
							ParentOrder,
							Revision,
							ValidFrom
						)
						VALUES
						(	@WorKOrderNode,
							@WorkOrder,
							@OrderTypeID,
							@IProtectClassificationID,
							@ShortText,
							@CompanyCodeID,
							@PlantID,
							@BusinessAreaID,
							@CostCenterID,
							@CostingSheetID,
							@OverheadKeyID,
							@InterestProfileID,
							@COTypeID,
							@BillingCodeID,
							@Applicant,
							@WorkStartDate,
							@WorkEndDate,
							@CostEstimate,
							@RegionCodeID,
							@DistrictCodeID,
							@CollectiblePercentage,
							@CityID,
							@ReauthorizationAmount,
							@ReauthorizationDate,
							@ProjectManagerID,
							@UserStatusID,
							@EstimatedCompletionDate,
							@DPSSNumber,
							@BillingTypeID,
							@PlannedCategoryID,
							@PlannedCategoryDetailID,
							@AnalyzedIndicatorID,
							@AnalyzedIndicatorDate,
							@PowerPlanOverrideID,
							@ParentOrder,
							@Revision,
							@CommonTimeStamp
						);
					SELECT SCOPE_IDENTITY();
				END
GO

PRINT '-- Common.getServerProperties';
GO
CREATE PROCEDURE Common.getServerProperties
				AS
				SET NOCOUNT ON
				SELECT	'ServerNameFunction' AS [PropertyName],
						@@SERVERNAME AS [PropertyValue]
				UNION
				SELECT	'VersionFunction' AS [PropertyName],
						@@VERSION AS [PropertyValue]
				UNION	
				SELECT	'BuildCLRVersion' AS [PropertyName],
						SERVERPROPERTY('BuildCLRVersion') AS [PropertyValue]
				UNION	
				SELECT	'Collation' AS [PropertyName],
						SERVERPROPERTY('Collation') AS [PropertyValue]
				UNION	
				SELECT	'CollationID' AS [PropertyName],
						SERVERPROPERTY('CollationID') AS [PropertyValue]
				UNION	
				SELECT	'ComparisonStyle' AS [PropertyName],
						SERVERPROPERTY('ComparisonStyle') AS [PropertyValue]
				UNION	
				SELECT	'ComputerNamePhysicalNetBIOS' AS [PropertyName],
						SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS [PropertyValue]
				UNION	
				SELECT	'Edition' AS [PropertyName],
						SERVERPROPERTY('Edition') AS [PropertyValue]
				UNION	
				SELECT	'EditionID' AS [PropertyName],
						SERVERPROPERTY('EditionID') AS [PropertyValue]
				UNION	
				SELECT	'EngineEdition' AS [PropertyName],
						SERVERPROPERTY('EngineEdition') AS [PropertyValue]
				UNION
				SELECT	'HadrManagerStatus' AS [PropertyName],
						SERVERPROPERTY('HadrManagerStatus') AS [PropertyValue]
				UNION	
				SELECT	'InstanceDefaultDataPath' AS [PropertyName],
						SERVERPROPERTY('InstanceDefaultDataPath') AS [PropertyValue]
				UNION	
				SELECT	'InstanceDefaultLogPath' AS [PropertyName],
						SERVERPROPERTY('InstanceDefaultLogPath') AS [PropertyValue]
				UNION	
				SELECT	'InstanceName' AS [PropertyName],
						SERVERPROPERTY('InstanceName') AS [PropertyValue]
				UNION	
				SELECT	'IsAdvancedAnalyticsInstalled' AS [PropertyName],
						SERVERPROPERTY('IsAdvancedAnalyticsInstalled') AS [PropertyValue]
				UNION	
				SELECT	'IsClustered' AS [PropertyName],
						SERVERPROPERTY('IsClustered') AS [PropertyValue]
				UNION	
				SELECT	'IsFullTextInstalled' AS [PropertyName],
						SERVERPROPERTY('IsFullTextInstalled') AS [PropertyValue]
				UNION	
				SELECT	'IsHadrEnabled' AS [PropertyName],
						SERVERPROPERTY('IsHadrEnabled') AS [PropertyValue]
				UNION	
				SELECT	'IsIntegratedSecurityOnly' AS [PropertyName],
						SERVERPROPERTY('IsIntegratedSecurityOnly') AS [PropertyValue]
				UNION	
				SELECT	'IsLocalDB' AS [PropertyName],
						SERVERPROPERTY('IsLocalDB') AS [PropertyValue]
				UNION	
				SELECT	'IsPolybaseInstalled' AS [PropertyName],
						SERVERPROPERTY('IsPolybaseInstalled') AS [PropertyValue]
				UNION	
				SELECT	'IsSingleUser' AS [PropertyName],
						SERVERPROPERTY('IsSingleUser') AS [PropertyValue]
				UNION	
				SELECT	'IsXTPSupported' AS [PropertyName],
						SERVERPROPERTY('IsXTPSupported') AS [PropertyValue]
				UNION	
				SELECT	'LCID' AS [PropertyName],
						SERVERPROPERTY('LCID') AS [PropertyValue]
				UNION	
				SELECT	'LicenseType' AS [PropertyName],
						SERVERPROPERTY('LicenseType') AS [PropertyValue]
				UNION	
				SELECT	'MachineName' AS [PropertyName],
						SERVERPROPERTY('MachineName') AS [PropertyValue]
				UNION
				SELECT	'NumLicenses' AS [PropertyName],
						SERVERPROPERTY('NumLicenses') AS [PropertyValue]
				UNION	
				SELECT	'ProcessID' AS [PropertyName],
						SERVERPROPERTY('ProcessID') AS [PropertyValue]
				UNION	
				SELECT	'ProductBuild' AS [PropertyName],
						SERVERPROPERTY('ProductBuild') AS [PropertyValue]
				UNION	
				SELECT	'ProductBuildType ' AS [PropertyName],
						SERVERPROPERTY('ProductBuildType ') AS [PropertyValue]
				UNION	
				SELECT	'ProductLevel' AS [PropertyName],
						SERVERPROPERTY('ProductLevel') AS [PropertyValue]
				UNION	
				SELECT	'ProductMajorVersion' AS [PropertyName],
						SERVERPROPERTY('ProductMajorVersion') AS [PropertyValue]
				UNION	
				SELECT	'ProductMinorVersion' AS [PropertyName],
						SERVERPROPERTY('ProductMinorVersion') AS [PropertyValue]
				UNION	
				SELECT	'ProductUpdateLevel' AS [PropertyName],
						SERVERPROPERTY('ProductUpdateLevel') AS [PropertyValue]
				UNION	
				SELECT	'ProductUpdateReference' AS [PropertyName],
						SERVERPROPERTY('ProductUpdateReference') AS [PropertyValue]
				UNION	
				SELECT	'ProductVersion' AS [PropertyName],
						SERVERPROPERTY('ProductVersion') AS [PropertyValue]
				UNION	
				SELECT	'ResourceLastUpdateDateTime' AS [PropertyName],
						SERVERPROPERTY('ResourceLastUpdateDateTime') AS [PropertyValue]
				UNION	
				SELECT	'ResourceVersion' AS [PropertyName],
						SERVERPROPERTY('ResourceVersion') AS [PropertyValue]
				UNION	
				SELECT	'ServerName' AS [PropertyName],
						SERVERPROPERTY('ServerName') AS [PropertyValue]
				UNION	
				SELECT	'SqlCharSet' AS [PropertyName],
						SERVERPROPERTY('SqlCharSet') AS [PropertyValue]
				UNION	
				SELECT	'SqlCharSetName' AS [PropertyName],
						SERVERPROPERTY('SqlCharSetName') AS [PropertyValue]
				UNION	
				SELECT	'SqlSortOrder' AS [PropertyName],
						SERVERPROPERTY('SqlSortOrder') AS [PropertyValue]
				UNION
				SELECT	'SqlSortOrderName' AS [PropertyName],
						SERVERPROPERTY('SqlSortOrderName') AS [PropertyValue]
				UNION	
				SELECT	'FilestreamShareName' AS [PropertyName],
						SERVERPROPERTY('FilestreamShareName') AS [PropertyValue]
				UNION	
				SELECT	'FilestreamConfiguredLevel' AS [PropertyName],
						SERVERPROPERTY('FilestreamConfiguredLevel') AS [PropertyValue]
				UNION	
				SELECT	'FilestreamEffectiveLevel' AS [PropertyName],
						SERVERPROPERTY('FilestreamEffectiveLevel') AS [PropertyValue];
				GO
GO

PRINT '-- Common.getSchemas';
GO
CREATE PROCEDURE Common.getSchemas
				(
					@filterSchemaName [varchar](128) = '%'
				)
				AS
				SET NOCOUNT ON
				SELECT *
				FROM sys.schemas
				WHERE sys.schemas.name LIKE @filterSchemaName
				ORDER BY sys.schemas.name;
GO

PRINT '-- Common.getTableRows';
GO
CREATE PROCEDURE Common.getTableRows
				(
					@filterSchemaName [varchar](128) = '%',
					@filterTableName [varchar](128) = '%',
					@procedureSQL [varchar](MAX) = ''
				)
				AS
				SET NOCOUNT ON
				SET @procedureSQL = 'SELECT * ' +
									'FROM ' + @filterSchemaName + '.' + @filterTableName
				EXEC(@procedureSQL);
GO

PRINT '-- Common.getExtendedProperty_Description';
GO
CREATE PROCEDURE Common.getExtendedProperty_Description
				 -- https://msdn.microsoft.com/en-us/library/ms177541.aspx?f=255&MSPPError=-2147217396
				 (
					@filterClass [tinyint] = 1,
					@filterSchemaName [varchar](128) = '%',
					@filterTableName [varchar](128) = '%',
					@filterColumnName [varchar](128) = '%',
					@returnVariant [sql_variant] OUTPUT
				 )
				 AS
				 SET NOCOUNT ON
				 SELECT CASE @filterClass
					-- Object or Column
					WHEN 1 THEN
						CASE @filterColumnName
							WHEN '%' THEN (
								SELECT	ep.value AS [Extended Property]
								FROM	sys.extended_properties AS ep INNER JOIN
										sys.tables AS t ON ep.major_id = t.object_id LEFT OUTER JOIN
										sys.schemas AS s ON t.schema_id = s.schema_id
								WHERE	ep.name = 'MS_Description' AND 
										ep.minor_id = 0 AND
										s.name LIKE @filterSchemaName AND 
										t.name LIKE @filterTableName)
							ELSE (
								SELECT	ep.value AS [Extended Property]
								FROM	sys.extended_properties AS ep INNER JOIN
										sys.tables AS t ON ep.major_id = t.object_id INNER JOIN
										sys.columns AS c ON ep.major_id = c.object_id AND ep.minor_id = c.column_id LEFT OUTER JOIN
										sys.schemas AS s ON t.schema_id = s.schema_id
								WHERE	ep.name = 'MS_Description' AND 
										s.name LIKE @filterSchemaName AND 
										t.name LIKE @filterTableName AND 
										c.name LIKE @filterColumnName)
						END
					-- Schema
					WHEN 3 THEN (
						SELECT	ep.value
						FROM	sys.extended_properties AS ep INNER JOIN
								sys.schemas AS s ON ep.major_id = s.schema_id
						WHERE	ep.class = @filterClass AND ep.name = 'MS_Description' AND s.name LIKE @filterSchemaName )
					-- Type
					WHEN 6 THEN 'INVALID RETURN'
					-- Index
					WHEN 7 THEN 'INVALID RETURN'
					-- Unused
					ELSE 'INVALID RETURN'
				 END;
				 RETURN
GO

PRINT '-- Common.getSysObjectTypes';
GO
CREATE PROCEDURE Common.getSysObjectTypes
				 AS
				 SET NOCOUNT ON
				 SELECT TOP (100) PERCENT	type,
											type_desc
				 FROM						sys.objects
				 GROUP BY					type,
											type_desc
				 ORDER BY					type;
GO

PRINT '-- Common.getSysObjects';
GO
CREATE PROCEDURE Common.getSysObjects
				 (
					@filterSchemaName [varchar](128) = '%',
					@filterName [varchar](128) = '%',
					@filterType [varchar](2) = '%',
					@filterType_Desc [varchar](128) = '%'
				 )
				 AS
				 SET NOCOUNT ON
				 SELECT	SCHEMA_Name(sys.objects.schema_id) AS SchemaName, 
						sys.objects.*,
						(SELECT COUNT(*) FROM information_schema.columns WHERE table_name = sys.objects.name) AS ColumnCount
				 FROM	sys.objects
				 WHERE	SCHEMA_Name(sys.objects.schema_id) LIKE '%' + @filterSchemaName + '%' AND
						sys.objects.name LIKE '%' + @filterName + '%' AND 
						sys.objects.type LIKE '%' + @filterType + '%' AND
						sys.objects.type_desc LIKE '%' + @filterType_Desc + '%'
				 ORDER BY	sys.objects.name;
GO

PRINT '-- Common.getSysColumns';
GO
CREATE PROCEDURE Common.getSysColumns
				 (
					@filterSchemaName [varchar](128) = '%',
					@filterTableName [varchar](128) = '%'
				 )
				 AS
				 SET NOCOUNT ON
				 SELECT		s.name AS [Schema], t.name AS [table], c.* 
				 FROM		sys.tables AS t INNER JOIN
							sys.schemas AS s ON t.schema_id = s.schema_id INNER JOIN
							sys.columns AS c ON t.object_id = c.object_id
				 WHERE s.name LIKE '%' + @filterSchemaName AND t.name LIKE @filterTableName
				 ORDER BY c.column_id;
GO

PRINT '-- Common.getIProtectClassification';
GO
CREATE PROCEDURE Common.getIProtectClassification 
				 (
					@flagVerbose bit = 0,
					@flagShowExpired bit = 0
				 )
				 AS
				 SET NOCOUNT ON
				 IF @flagVerbose = 1
					SELECT TOP (100) PERCENT *
					FROM Common.IProtectClassification 
					ORDER BY Common.IProtectClassification.IProtectClassificationID
				 ELSE IF @flagVerbose = 0 AND @flagShowExpired = 0
					SELECT IProtectClassificationID,
					       Name
					FROM Common.IProtectClassification 
					WHERE Common.IProtectClassification.ValidTo > SYSUTCDATETIME()
					ORDER BY Common.IProtectClassification.IProtectClassificationID
				 ELSE
					SELECT IProtectClassificationID,
					       Name + (CASE WHEN ValidTo > SYSUTCDATETIME() THEN '' ELSE ' {EXPIRED}' END) AS Display,
						   (CASE WHEN ValidTo > SYSUTCDATETIME() THEN '1' ELSE '2' END) + CAST(IProtectClassificationID AS nvarchar(1)) + Name AS SortOrder
					FROM Common.IProtectClassification
					ORDER BY SortOrder;
GO	

PRINT '-- SAP.getOrderType';
GO
CREATE PROCEDURE SAP.getOrderType
				 (
					@flagVerbose bit = 0,
					@flagShowExpired bit = 0
				 )
				 AS
				 SET NOCOUNT ON
				 IF @flagVerbose = 1
					SELECT TOP (100) PERCENT *
					FROM SAP.OrderType 
					ORDER BY SAP.OrderType.OrderTypeID
				 ELSE IF @flagVerbose = 0 AND @flagShowExpired = 0
					SELECT OrderTypeID,
					       Name
					FROM SAP.OrderType 
					WHERE SAP.OrderType.ValidTo > SYSUTCDATETIME()
					ORDER BY SAP.OrderType.OrderTypeID
				 ELSE
					SELECT OrderTypeID,
					       Name + (CASE WHEN ValidTo > SYSUTCDATETIME() THEN '' ELSE ' {EXPIRED}' END) AS Display,
						   (CASE WHEN ValidTo > SYSUTCDATETIME() THEN '1' ELSE '2' END) + OrderTypeID + Name AS SortOrder
					FROM SAP.OrderType
					ORDER BY SortOrder;
GO			

PRINT '-- SAP.getCompanyCode';
GO
CREATE PROCEDURE SAP.getCompanyCode
				 (
					@flagVerbose bit = 0,
					@flagShowExpired bit = 0
				 )
				 AS
				 SET NOCOUNT ON
				 IF @flagVerbose = 1
					SELECT TOP (100) PERCENT *
					FROM SAP.CompanyCode 
					ORDER BY SAP.CompanyCode.CompanyCodeID
				 ELSE IF @flagVerbose = 0 AND @flagShowExpired = 0
					SELECT CompanyCodeID,
					       Name,
						   Description
					FROM SAP.CompanyCode 
					WHERE SAP.CompanyCode.ValidTo > SYSUTCDATETIME()
					ORDER BY SAP.CompanyCode.CompanyCodeID
				 ELSE
					SELECT CompanyCodeID,
					       Name + (CASE WHEN ValidTo > SYSUTCDATETIME() THEN '' ELSE ' {EXPIRED}' END) AS Display,
						   Description,
						   (CASE WHEN ValidTo > SYSUTCDATETIME() THEN '1' ELSE '2' END) + CompanyCodeID + Name AS SortOrder
					FROM SAP.CompanyCode
					ORDER BY SortOrder;
GO		

PRINT '-- SAP.getEmployee';
GO
CREATE Procedure	SAP.getEmployee
					(
						@InputWINUserName [nvarchar](15) = '',
						@InputEmployeeIDString [nvarchar](5) = '',
						@EmployeeID [int] OUTPUT,
						@EmployeeIDString [nchar](5) OUTPUT,
						@SAPUserName [nvarchar](15) OUTPUT,
						@WINUserName [nvarchar](15) OUTPUT,
						@SQLUserName [nvarchar](50) Output,
						@ManagerID [int] OUTPUT,
						@CostCenterID [int] OUTPUT,
						@JobTitle [nvarchar](50) OUTPUT,
						@EmployeeName_First [nvarchar](50) OUTPUT,
						@EmployeeName_Last [nvarchar](50) OUTPUT,
						@EmailAddress [nvarchar](100) OUTPUT,
						@PhoneNumber [nchar](10) OUTPUT,
						@Accountant [bit] OUTPUT,
						@Administrator [bit] OUTPUT
					)
					AS
					BEGIN
						SET NOCOUNT ON
						SELECT	TOP 1 
								@EmployeeID = EmployeeID,
								@EmployeeIDString = EmployeeIDString,
								@SAPUserName = SAPUserName,
								@WINUserName = WINUserName,
								@SQLUserName = SQLUserName,
								@ManagerID = ManagerID,
								@CostCenterID = CostCenterID,
								@JobTitle = JobTitle,
								@EmployeeName_First = EmployeeName_First,
								@EmployeeName_Last = EmployeeName_Last,
								@EmailAddress = EmailAddress,
								@PhoneNumber = PhoneNumber,
								@Accountant = Accountant,
								@Administrator = Administrator
						FROM	SAP.Employee
						WHERE	SAP.Employee.WINUserName = @InputWINUserName OR 
								SAP.Employee.EmployeeIDString = @InputEmployeeIDString
					END;
GO


PRINT '-- SAP.getCostCenter';
GO	
CREATE PROCEDURE SAP.getCostCenter
				 (
					@flagVerbose bit = 0,
					@flagShowExpired bit = 0
				 )
				 AS
				 SET NOCOUNT ON
				 IF @flagVerbose = 1
					SELECT TOP (100) PERCENT *
					FROM SAP.CostCenter 
					ORDER BY SAP.CostCenter.CostCenterID
				 ELSE IF @flagVerbose = 0 AND @flagShowExpired = 0
					SELECT CostCenterID,
					       CostCenter,
						   Name,
						   Description
					FROM SAP.CostCenter 
					WHERE SAP.CostCenter.ValidTo > SYSUTCDATETIME()
					ORDER BY SAP.CostCenter.CostCenterID
				 ELSE
					SELECT CostCenterID,
						   CostCenter,
					       Name + (CASE WHEN ValidTo > SYSUTCDATETIME() THEN '' ELSE ' {EXPIRED}' END) AS Display,
						   Description,
						   (CASE WHEN ValidTo > SYSUTCDATETIME() THEN '1' ELSE '2' END) + CostCenterID + CostCenter AS SortOrder
					FROM SAP.CostCenter
					ORDER BY SortOrder;
GO		

PRINT '-- SAP.getCostCenterCategory';
GO	
CREATE PROCEDURE SAP.getCostCenterCategory
				 (
					@flagVerbose bit = 0,
					@flagShowExpired bit = 0
				 )
				 AS
				 SET NOCOUNT ON
				 IF @flagVerbose = 1
					SELECT TOP (100) PERCENT *
					FROM SAP.CostCenterCategory 
					ORDER BY SAP.CostCenterCategory.CostCenterCategoryID
				 ELSE IF @flagVerbose = 0 AND @flagShowExpired = 0
					SELECT CostCenterCategoryID,
					       Name
					FROM SAP.CostCenterCategory 
					WHERE SAP.CostCenterCategory.ValidTo > SYSUTCDATETIME()
					ORDER BY SAP.CostCenterCategory.CostCenterCategoryID
				 ELSE
					SELECT CostCenterCategoryID,
					       Name + (CASE WHEN ValidTo > SYSUTCDATETIME() THEN '' ELSE ' {EXPIRED}' END) AS Display,
						   (CASE WHEN ValidTo > SYSUTCDATETIME() THEN '1' ELSE '2' END) + CostCenterCategoryID + Name AS SortOrder
					FROM SAP.CostCenterCategory
					ORDER BY SortOrder;
GO	

PRINT '-- SAP.getCostingSheet';
GO	
CREATE PROCEDURE SAP.getCostingSheet
				 (
					@flagVerbose bit = 0,
					@flagShowExpired bit = 0
				 )
				 AS
				 SET NOCOUNT ON
				 IF @flagVerbose = 1
					SELECT TOP (100) PERCENT *
					FROM SAP.CostingSheet 
					ORDER BY SAP.CostingSheet.CostingSheetID
				 ELSE IF @flagVerbose = 0 AND @flagShowExpired = 0
					SELECT CostingSheetID,
					       Name
					FROM SAP.CostingSheet 
					WHERE SAP.CostingSheet.ValidTo > SYSUTCDATETIME()
					ORDER BY SAP.CostingSheet.CostingSheetID
				 ELSE
					SELECT CostingSheetID,
					       Name + (CASE WHEN ValidTo > SYSUTCDATETIME() THEN '' ELSE ' {EXPIRED}' END) AS Display,
						   (CASE WHEN ValidTo > SYSUTCDATETIME() THEN '1' ELSE '2' END) + CostingSheetID + Name AS SortOrder
					FROM SAP.CostingSheet
					ORDER BY SortOrder;
GO	

PRINT '-- SAP.getOverheadKey';
GO	
CREATE PROCEDURE SAP.getOverheadKey
				 (
					@flagVerbose bit = 0,
					@flagShowExpired bit = 0
				 )
				 AS
				 SET NOCOUNT ON
				 IF @flagVerbose = 1
					SELECT TOP (100) PERCENT *
					FROM SAP.OverheadKey 
					ORDER BY SAP.OverheadKey.OverheadKeyID
				 ELSE IF @flagVerbose = 0 AND @flagShowExpired = 0
					SELECT OverheadKeyID,
					       Name
					FROM SAP.OverheadKey 
					WHERE SAP.OverheadKey.ValidTo > SYSUTCDATETIME()
					ORDER BY SAP.OverheadKey.OverheadKeyID
				 ELSE
					SELECT OverheadKeyID,
					       Name + (CASE WHEN ValidTo > SYSUTCDATETIME() THEN '' ELSE ' {EXPIRED}' END) AS Display,
						   (CASE WHEN ValidTo > SYSUTCDATETIME() THEN '1' ELSE '2' END) + Name + OverheadKeyID AS SortOrder
					FROM SAP.OverheadKey
					ORDER BY SortOrder;
GO	

PRINT '-- SAP.getInterestProfile';
GO	
CREATE PROCEDURE SAP.getInterestProfile
				 (
					@flagVerbose bit = 0,
					@flagShowExpired bit = 0
				 )
				 AS
				 SET NOCOUNT ON
				 IF @flagVerbose = 1
					SELECT TOP (100) PERCENT *
					FROM SAP.InterestProfile 
					ORDER BY SAP.InterestProfile.InterestProfileID
				 ELSE IF @flagVerbose = 0 AND @flagShowExpired = 0
					SELECT InterestProfileID,
					       Name
					FROM SAP.InterestProfile 
					WHERE SAP.InterestProfile.ValidTo > SYSUTCDATETIME()
					ORDER BY SAP.InterestProfile.InterestProfileID
				 ELSE
					SELECT InterestProfileID,
					       Name + (CASE WHEN ValidTo > SYSUTCDATETIME() THEN '' ELSE ' {EXPIRED}' END) AS Display,
						   (CASE WHEN ValidTo > SYSUTCDATETIME() THEN '1' ELSE '2' END) + Name + InterestProfileID AS SortOrder
					FROM SAP.InterestProfile
					ORDER BY SortOrder;
GO	

PRINT '-- WOA.getStoredProcedure';
GO	
CREATE PROCEDURE WOA.getStoredProcedure
				 (
					@flagVerbose bit = 0,
					@flagShowExpired bit = 0
				 )
				 AS
				 SET NOCOUNT ON
				 IF @flagVerbose = 1 AND @flagShowExpired = 1
					SELECT TOP (100) PERCENT *
					FROM WOA.StoredProcedure 
					ORDER BY WOA.StoredProcedure.StoredProcedureID
				 ELSE IF @flagVerbose = 1 AND @flagShowExpired = 0
					SELECT TOP (100) PERCENT *
					FROM WOA.StoredProcedure
					WHERE WOA.StoredProcedure.ValidTo > SYSUTCDATETIME()
					ORDER BY WOA.StoredProcedure.StoredProcedureID
				 ELSE IF @flagVerbose = 0 AND @flagShowExpired = 0
					SELECT StoredProcedureID,
					       Name
					FROM WOA.StoredProcedure 
					WHERE WOA.StoredProcedure.ValidTo > SYSUTCDATETIME()
					ORDER BY WOA.StoredProcedure.StoredProcedureID
				 ELSE
					SELECT StoredProcedureID,
					       Name + (CASE WHEN ValidTo > SYSUTCDATETIME() THEN '' ELSE ' {EXPIRED}' END) AS Display,
						   (CASE WHEN ValidTo > SYSUTCDATETIME() THEN '1' ELSE '2' END) + Name + StoredProcedureID AS SortOrder
					FROM WOA.StoredProcedure
					ORDER BY SortOrder;
GO	

PRINT '-- SAP.getUserStatus';
GO
CREATE PROCEDURE	SAP.getUserStatus
					(
						@flagVerbose bit = 0,
						@flagShowExpired bit = 0
					)
					AS
					SET NOCOUNT ON
					IF @flagVerbose = 1 AND @flagShowExpired = 1
						SELECT TOP (100) PERCENT	UserStatusID,
													Name,
													UserStatusID + ' (' + Name + ')' AS Display
						FROM SAP.UserStatus
						ORDER BY SAP.UserStatus.UserStatusID
					ELSE IF @flagVerbose = 1 and @flagShowExpired = 0
						SELECT TOP (100) PERCENT	UserStatusID,
													Name,
													UserStatusID + ' (' + Name + ')' AS Display
						FROM SAP.UserStatus
						WHERE SAP.UserStatus.ValidTo > SYSUTCDATETIME()
						ORDER BY SAP.UserStatus.UserStatusID
					ELSE IF @flagVerbose = 0 AND @flagShowExpired = 0
						SELECT	UserStatusID,
								Name,
								UserStatusID + ' (' + Name + ')' AS Display
						FROM SAP.UserStatus
						WHERE SAP.UserStatus.ValidTo > SYSUTCDATETIME()
						ORDER BY SAP.UserStatus.UserStatusID
					ELSE
						SELECT	UserStatusID,
								Name + (CASE WHEN ValidTo > SYSUTCDATETIME() THEN '' ELSE ' {EXPIRED}' END) AS Display,
								(CASE WHEN ValidTo > SYSUTCDATETIME() THEN '1' ELSE '2' END) + Name + UserStatusID AS SortOrder
						FROM SAP.UserStatus
						ORDER BY SortOrder;
GO

PRINT '-- WOA.getGlobalConstants';
GO
CREATE PROCEDURE	WOA.getGlobalConstants
					(
						@flagVerbose bit = 0,
						@flagShowExpired bit = 0
					)
					AS
					SET NOCOUNT ON
					IF @flagShowExpired = 1
						SELECT	GlobalConstantID,
								Name,
								ConstantValue
						FROM WOA.GlobalConstant
						WHERE WOA.GlobalConstant.ValidTo > SYSUTCDATETIME()
						ORDER BY WOA.GlobalConstant.Name
					ELSE
						SELECT	GlobalConstantID,
								Name,
								ConstantValue,
								Name + (CASE WHEN ValidTo > SYSUTCDATETIME() THEN '' ELSE ' {EXPIRED}' END) AS Display,
								(CASE WHEN ValidTo > SYSUTCDATETIME() THEN '1' ELSE '2' END) + Name AS SortOrder
						FROM WOA.GlobalConstant
						ORDER BY WOA.GlobalConstant.GlobalConstantID;
GO

PRINT '-- Common.getBillingCode';
GO
CREATE PROCEDURE	Common.getBillingCodes
					(
						@flagVerbose bit = 0,
						@flagShowExpired bit = 0
					)
					AS
					SET NOCOUNT ON
					IF @flagVerbose = 1 AND @flagShowExpired = 1
						SELECT *
						FROM Common.BillingCode
						ORDER BY Common.BillingCode.BillingCOdeID
					ELSE IF @flagVerbose = 1 and @flagShowExpired = 0
						SELECT *
						FROM Common.BillingCode
						WHERE Common.BillingCode.ValidTo > SYSUTCDATETIME()
					ELSE IF @flagVerbose = 0 AND @flagShowExpired = 0
						SELECT	BillingCodeID,
								BillingCodeWOA,
								Name,
								BillingCodeID + ' - ' + Name AS Display
						FROM Common.BillingCode
						WHERE Common.BillingCode.ValidTo > SYSUTCDATETIME()
						ORDER BY Common.BillingCode.BillingCodeID	
					ELSE
						SELECT	BillingCodeID,
								BillingCodeWOA,
								Name,
								BillingCodeID + ' - ' + Name + (CASE WHEN ValidTo > SYSUTCDATETIME() THEN '' ELSE ' {EXPIRED}' END) AS Display,
								(CASE WHEN ValidTo > SYSUTCDATETIME() THEN '1' ELSE '2' END) + BillingCodeID + ' - ' + Name AS SortOrder
						FROM Common.BillingCode
						ORDER BY SortOrder;
GO

PRINT '-- Common.getCounties';
GO
CREATE PROCEDURE	Common.getCounties
					(
						@flagVerbose bit = 0,
						@flagShowExpired bit = 0,
						@filterStateID [nchar](2) = 'CA'
					)
					AS
					BEGIN
						DECLARE @sqlString AS [VARCHAR](MAX)
						BEGIN TRY
							SET NOCOUNT ON
						
							IF (@flagVerbose = 1)
								SET @sqlString = 'SELECT *, '
							ELSE
								SET @sqlString = 'SELECT	 CountyID, ' +
															'Name, ' +
															'StateID, '
							SET @sqlString = @sqlString +  'Name + (CASE WHEN ValidTo > SYSUTCDATETIME() THEN ' + CHAR(39) + CHAR(39) + ' ELSE ' + CHAR(39) + ' {EXPIRED}' + CHAR(39) + ' END) AS Display, ' +
															'(CASE WHEN ValidTo > SYSUTCDATETIME() THEN ' + char(39) + '1' + CHAR(39) + ' ELSE ' + CHAR(39) + '2' + CHAR(39) + ' END) + Name AS SortOrder '
							SET @sqlString = @sqlString + 'FROM Common.County '
							SET @sqlString = @sqlString + 'WHERE 1=1 '
							SET @sqlString = @sqlString + ' AND Common.County.StateID = ' + CHAR(39) + @filterStateID + CHAR(39) + ' '
							IF @flagShowExpired = 0
								SET @sqlString = @sqlString + ' AND Common.County.ValidTo > SYSUTCDATETIME() '
							SET @sqlString = @sqlString + 'ORDER BY SortOrder'
							EXEC(@sqlString)
						END TRY
						BEGIN CATCH
							PRINT @sqlString
						END CATCH
					END;
GO

PRINT '-- SAP.getAnalyzedIndicators';
GO
CREATE PROCEDURE	SAP.getAnalyzedIndicators
					(
						@flagVerbose bit = 0,
						@flagShowExpired bit = 0
					)
					AS
					SET NOCOUNT ON
					IF @flagVerbose = 1 AND @flagShowExpired = 1
						SELECT *
						FROM SAP.AnalyzedIndicator
						ORDER BY SAP.AnalyzedIndicator.AnalyzedIndicatorID
					ELSE IF @flagVerbose = 1 and @flagShowExpired = 0
						SELECT *
						FROM SAP.AnalyzedIndicator
						WHERE SAP.AnalyzedIndicator.ValidTo > SYSUTCDATETIME()
					ELSE IF @flagVerbose = 0 AND @flagShowExpired = 0
						SELECT	AnalyzedIndicatorID,
								Name,
								AnalyzedIndicatorID + ' - ' + Name AS Display
						FROM SAP.AnalyzedIndicator
						WHERE SAP.AnalyzedIndicator.ValidTo > SYSUTCDATETIME()
						ORDER BY SAP.AnalyzedIndicator.AnalyzedIndicatorID	
					ELSE
						SELECT	AnalyzedIndicatorID,
								Name,
								AnalyzedIndicatorID + ' - ' + Name + (CASE WHEN ValidTo > SYSUTCDATETIME() THEN '' ELSE ' {EXPIRED}' END) AS Display,
								(CASE WHEN ValidTo > SYSUTCDATETIME() THEN '1' ELSE '2' END) + AnalyzedIndicatorID + ' - ' + Name AS SortOrder
						FROM SAP.AnalyzedIndicator
						ORDER BY SortOrder;
GO

PRINT '-- SAP.getBillingTypes';
GO
CREATE PROCEDURE	SAP.getBillingTypes
					(
						@flagVerbose bit = 0,
						@flagShowExpired bit = 0
					)
					AS
					SET NOCOUNT ON
					IF @flagVerbose = 1 AND @flagShowExpired = 1
						SELECT *
						FROM SAP.BillingType
						ORDER BY SAP.BillingType.BillingTypeID
					ELSE IF @flagVerbose = 1 and @flagShowExpired = 0
						SELECT *
						FROM SAP.BillingType
						WHERE SAP.BillingType.ValidTo > SYSUTCDATETIME()
					ELSE IF @flagVerbose = 0 AND @flagShowExpired = 0
						SELECT	BillingTypeID,
								Name,
								BillingTypeID + ' - ' + Name AS Display
						FROM SAP.BillingType
						WHERE SAP.BillingType.ValidTo > SYSUTCDATETIME()
						ORDER BY SAP.BillingType.BillingTypeID	
					ELSE
						SELECT	BillingTypeID,
								Name,
								BillingTypeID + ' - ' + Name + (CASE WHEN ValidTo > SYSUTCDATETIME() THEN '' ELSE ' {EXPIRED}' END) AS Display,
								(CASE WHEN ValidTo > SYSUTCDATETIME() THEN '1' ELSE '2' END) + BillingTypeID + ' - ' + Name AS SortOrder
						FROM SAP.BillingType
						ORDER BY SortOrder;
GO

PRINT '-- SAP.getCities';
GO
CREATE PROCEDURE	SAP.getCities
					(
						@flagVerbose bit = 0,
						@flagShowExpired bit = 0,
						@filterCountyID int = 0
					)
					AS
					BEGIN
						DECLARE @sqlString AS [VARCHAR](MAX)
						BEGIN TRY
							SET NOCOUNT ON
						
							IF (@flagVerbose = 1)
								SET @sqlString = 'SELECT * '
							ELSE
								SET @sqlString = 'SELECT	 CityID, ' +
															'Name, ' +
															'CountyID, ' +
															'Name + (CASE WHEN ValidTo > SYSUTCDATETIME() THEN ' + CHAR(39) + CHAR(39) + ' ELSE ' + CHAR(39) + ' {EXPIRED}' + CHAR(39) + ' END) AS Display, ' +
															'(CASE WHEN ValidTo > SYSUTCDATETIME() THEN ' + char(39) + '1' + CHAR(39) + ' ELSE ' + CHAR(39) + '2' + CHAR(39) + ' END) + Name AS SortOrder '
							SET @sqlString = @sqlString + 'FROM SAP.City '
							SET @sqlString = @sqlString + 'WHERE 1=1 '
							IF @flagShowExpired = 0
								SET @sqlString = @sqlString + ' AND SAP.City.ValidTo > SYSUTCDATETIME() '
							IF @filterCountyID <> 0
								SET @sqlString = @sqlString + ' AND SAP.City.CountyID = ' + CAST(@filterCountyID AS [NVARCHAR](MAX)) + ' '
							IF @flagVerbose = 1
								SET @sqlString = @sqlString + 'ORDER BY SAP.City.Name'
							ELSE
								SET @sqlString = @sqlString + 'ORDER BY SortOrder'
							EXEC(@sqlString)
						END TRY
						BEGIN CATCH
							PRINT @sqlString
						END CATCH
					END;
GO

PRINT '-- SAP.getDistrictCodes';
GO
CREATE PROCEDURE	SAP.getDistrictCodes
					(
						@flagVerbose bit = 0,
						@flagShowExpired bit = 0,
						@filterCompanyCodeID [nchar](4) = '2100',
						@filterRegionCodeID [nchar](2) = '%'
					)
					AS
					BEGIN
						DECLARE @sqlString AS [VARCHAR](MAX)
						BEGIN TRY
							SET NOCOUNT ON
						
							IF (@flagVerbose = 1)
								SET @sqlString = 'SELECT *, '
							ELSE
								SET @sqlString = 'SELECT	 DistrictCodeID, ' +
															'Name, ' +
															'RegionCodeID, ' +
															'CompanyCodeID, '
							SET @sqlString = @sqlString +  'Name + (CASE WHEN ValidTo > SYSUTCDATETIME() THEN ' + CHAR(39) + CHAR(39) + ' ELSE ' + CHAR(39) + ' {EXPIRED}' + CHAR(39) + ' END) AS Display, ' +
															'(CASE WHEN ValidTo > SYSUTCDATETIME() THEN ' + char(39) + '1' + CHAR(39) + ' ELSE ' + CHAR(39) + '2' + CHAR(39) + ' END) + Name AS SortOrder '
							SET @sqlString = @sqlString + 'FROM SAP.DistrictCode '
							SET @sqlString = @sqlString + 'WHERE 1=1 '
							SET @sqlString = @sqlString + ' AND SAP.DistrictCode.CompanyCodeID = ' + CHAR(39) + @filterCompanyCodeID + CHAR(39) + ' '
							IF @filterRegionCodeID <> '%'
								SET @sqlString = @sqlString + ' AND SAP.DistrictCode.RegionCodeID = ' + CHAR(39) + @filterRegionCodeID + CHAR(39) + ' '
							IF @flagShowExpired = 0
								SET @sqlString = @sqlString + ' AND SAP.DistrictCode.ValidTo > SYSUTCDATETIME() '
							SET @sqlString = @sqlString + 'ORDER BY SortOrder'
							EXEC(@sqlString)
						END TRY
						BEGIN CATCH
							PRINT @sqlString
						END CATCH
					END;
GO

PRINT '-- SAP.getPlannedCategories';
GO
CREATE PROCEDURE	SAP.getPlannedCategories
					(
						@flagVerbose bit = 0,
						@flagShowExpired bit = 0
					)
					AS
					BEGIN
						DECLARE @sqlString AS [VARCHAR](MAX)
						BEGIN TRY
							SET NOCOUNT ON
						
							IF (@flagVerbose = 1)
								SET @sqlString = 'SELECT *, '
							ELSE
								SET @sqlString = 'SELECT	 PlannedCategoryID, ' +
															'Name, '
							SET @sqlString = @sqlString +  'Name +' + CHAR(39) + ' - ' + CHAR(39) + '+ PlannedCategoryID + (CASE WHEN ValidTo > SYSUTCDATETIME() THEN ' + CHAR(39) + CHAR(39) + ' ELSE ' + CHAR(39) + ' {EXPIRED}' + CHAR(39) + ' END) AS Display, ' +
															'(CASE WHEN ValidTo > SYSUTCDATETIME() THEN ' + char(39) + '1' + CHAR(39) + ' ELSE ' + CHAR(39) + '2' + CHAR(39) + ' END) + Name +' + CHAR(39) + ' - ' + CHAR(39) + '+ PlannedCategoryID AS SortOrder '
							SET @sqlString = @sqlString + 'FROM SAP.PlannedCategory '
							SET @sqlString = @sqlString + 'WHERE 1=1 '
							IF @flagShowExpired = 0
								SET @sqlString = @sqlString + ' AND SAP.PlannedCategory.ValidTo > SYSUTCDATETIME() '
							SET @sqlString = @sqlString + 'ORDER BY SortOrder'
							EXEC(@sqlString)
						END TRY
						BEGIN CATCH
							PRINT @sqlString
						END CATCH
					END;
GO

PRINT '-- SAP.getPlannedCategoryDetails';
GO
CREATE PROCEDURE	SAP.getPlannedCategoryDetails
					(
						@flagVerbose bit = 0,
						@flagShowExpired bit = 0,
						@filterPlannedCategoryID [nchar](3) = '%%%'
					)
					AS
					BEGIN
						DECLARE @sqlString AS [VARCHAR](MAX)
						BEGIN TRY
							SET NOCOUNT ON
							IF (@flagVerbose = 1)
								SET @sqlString = 'SELECT *, '
							ELSE
								SET @sqlString = 'SELECT	 PlannedCategoryDetailID, ' +
															'Name, ' +
															'PlannedCategoryID, ' +
															'CostingSheetID, ' +
															'OverheadKeyID, '
							SET @sqlString = @sqlString +  'Name +' + CHAR(39) + ' - ' + CHAR(39) + '+ PlannedCategoryDetailID + (CASE WHEN ValidTo > SYSUTCDATETIME() THEN ' + CHAR(39) + CHAR(39) + ' ELSE ' + CHAR(39) + ' {EXPIRED}' + CHAR(39) + ' END) AS Display, ' +
															'(CASE WHEN ValidTo > SYSUTCDATETIME() THEN ' + char(39) + '1' + CHAR(39) + ' ELSE ' + CHAR(39) + '2' + CHAR(39) + ' END) + Name +' + CHAR(39) + ' - ' + CHAR(39) + '+ PlannedCategoryDetailID AS SortOrder '
							SET @sqlString = @sqlString + 'FROM SAP.PlannedCategoryDetail '
							SET @sqlString = @sqlString + 'WHERE 1=1 '
							IF @filterPlannedCategoryID <> '%%%'
								SET @sqlString = @sqlString + ' AND SAP.PlannedCategoryDetail.PlannedCategoryID = ' + CHAR(39) + @filterPlannedCategoryID + CHAR(39) + ' '
							IF @flagShowExpired = 0
								SET @sqlString = @sqlString + ' AND SAP.PlannedCategoryDetail.ValidTo > SYSUTCDATETIME() '
							SET @sqlString = @sqlString + 'ORDER BY SortOrder'
							EXEC(@sqlString)
						END TRY
						BEGIN CATCH
							PRINT @sqlString
						END CATCH
					END;
GO

PRINT '-- SAP.getPlants';
GO
CREATE PROCEDURE	SAP.getPlants
					(
						@flagVerbose bit = 0,
						@flagShowExpired bit = 0
					)
					AS
					BEGIN
						DECLARE @sqlString AS [VARCHAR](MAX)
						BEGIN TRY
							SET NOCOUNT ON
						
							IF (@flagVerbose = 1)
								SET @sqlString = 'SELECT *, '
							ELSE
								SET @sqlString = 'SELECT	 PlantID, ' +
															'Name, '
							SET @sqlString = @sqlString +  'Name +' + CHAR(39) + ' - ' + CHAR(39) + '+ PlantID + (CASE WHEN ValidTo > SYSUTCDATETIME() THEN ' + CHAR(39) + CHAR(39) + ' ELSE ' + CHAR(39) + ' {EXPIRED}' + CHAR(39) + ' END) AS Display, ' +
															'(CASE WHEN ValidTo > SYSUTCDATETIME() THEN ' + char(39) + '1' + CHAR(39) + ' ELSE ' + CHAR(39) + '2' + CHAR(39) + ' END) + Name AS SortOrder '
							SET @sqlString = @sqlString + 'FROM SAP.Plant '
							SET @sqlString = @sqlString + 'WHERE 1=1 '
							IF @flagShowExpired = 0
								SET @sqlString = @sqlString + ' AND SAP.Plant.ValidTo > SYSUTCDATETIME() '
							SET @sqlString = @sqlString + 'ORDER BY SortOrder'
							EXEC(@sqlString)
						END TRY
						BEGIN CATCH
							PRINT @sqlString
						END CATCH
					END;
GO

PRINT '-- SAP.getPowerPlanOverrides';
GO
CREATE PROCEDURE	SAP.getPowerPlanOverrides
					(
						@flagVerbose bit = 0,
						@flagShowExpired bit = 0
					)
					AS
					BEGIN
						DECLARE @sqlString AS [VARCHAR](MAX)
						BEGIN TRY
							SET NOCOUNT ON
						
							IF (@flagVerbose = 1)
								SET @sqlString = 'SELECT *, '
							ELSE
								SET @sqlString = 'SELECT	 PowerPlanOverrideID, ' +
															'Name, '
							SET @sqlString = @sqlString +  'Name +' + CHAR(39) + ' - ' + CHAR(39) + '+ PowerPlanOverrideID + (CASE WHEN ValidTo > SYSUTCDATETIME() THEN ' + CHAR(39) + CHAR(39) + ' ELSE ' + CHAR(39) + ' {EXPIRED}' + CHAR(39) + ' END) AS Display, ' +
															'(CASE WHEN ValidTo > SYSUTCDATETIME() THEN ' + char(39) + '1' + CHAR(39) + ' ELSE ' + CHAR(39) + '2' + CHAR(39) + ' END) + Name AS SortOrder '
							SET @sqlString = @sqlString + 'FROM SAP.PowerPlanOverride '
							SET @sqlString = @sqlString + 'WHERE 1=1 '
							IF @flagShowExpired = 0
								SET @sqlString = @sqlString + ' AND SAP.PowerPlanOverride.ValidTo > SYSUTCDATETIME() '
							SET @sqlString = @sqlString + 'ORDER BY SortOrder'
							EXEC(@sqlString)
						END TRY
						BEGIN CATCH
							PRINT @sqlString
						END CATCH
					END;
GO

PRINT '-- SAP.getRegionCodes';
GO
CREATE PROCEDURE	SAP.getRegionCodes
					(
						@flagVerbose bit = 0,
						@flagShowExpired bit = 0
					)
					AS
					BEGIN
						DECLARE @sqlString AS [VARCHAR](MAX)
						BEGIN TRY
							SET NOCOUNT ON
						
							IF (@flagVerbose = 1)
								SET @sqlString = 'SELECT *, '
							ELSE
								SET @sqlString = 'SELECT	 RegionCodeID, ' +
															'Name, '
							SET @sqlString = @sqlString +  'Name +' + CHAR(39) + ' - ' + CHAR(39) + '+ RegionCodeID + (CASE WHEN ValidTo > SYSUTCDATETIME() THEN ' + CHAR(39) + CHAR(39) + ' ELSE ' + CHAR(39) + ' {EXPIRED}' + CHAR(39) + ' END) AS Display, ' +
															'(CASE WHEN ValidTo > SYSUTCDATETIME() THEN ' + char(39) + '1' + CHAR(39) + ' ELSE ' + CHAR(39) + '2' + CHAR(39) + ' END) + Name AS SortOrder '
							SET @sqlString = @sqlString + 'FROM SAP.RegionCode '
							SET @sqlString = @sqlString + 'WHERE 1=1 '
							IF @flagShowExpired = 0
								SET @sqlString = @sqlString + ' AND SAP.RegionCode.ValidTo > SYSUTCDATETIME() '
							SET @sqlString = @sqlString + 'ORDER BY SortOrder'
							EXEC(@sqlString)
						END TRY
						BEGIN CATCH
							PRINT @sqlString
						END CATCH
					END;
GO


/***** POPULATE DEFAULT DATA ******/
PRINT '/****** POPULATE DEFAULT DATA ******/';
GO

PRINT '-- Common.IProtectClassification';
GO	
INSERT INTO Common.IProtectClassification (Name)
			VALUES ('Public'),
				   ('Internal'),
				   ('Confidential'),
				   ('Restricted');

GO

PRINT '-- SAP.OrderType';
GO	
INSERT INTO SAP.OrderType (OrderTypeID, Name)
			VALUES	('0201','SE O&M Order'),
					('0202','SE Capital Order'),
					('0203','SE Permanent Order'),
					('0204','SE Balance Sheet Order'),
					('0205','SE Asset Alloc Order'),
					('0206','SE Cost Pool Order'),
					('0207','SE Statistical O&M Order'),
					('0208','SE Planning Order'),
					('0210','SE Capital Order'),
					('0901','SEGE Operating Orders'),
					('0902','SEGE Capital Orders'),
					('0903','SEGE IT Billing Order'),
					('0904','SEGE Cost Pool Orders'),
					('1003','El Dorado Real Orders'),
					('1004','El Dorado Statistical Orders'),
					('1101','SEI Operating Orders'),
					('1102','SEI Capital Orders'),
					('1103','SEI Asset Acquisition Orders'),
					('1104','SEI Cost Pool Orders'),
					('1301','SER Operating Orders'),
					('1302','SER Capital Orders'),
					('1303','SER Asset Acquisition Orders'),
					('1304','SER Cost Pool Orders'),
					('1401','SEIS Operating Orders'),
					('1402','SEIS Capital Orders'),
					('1403','SEIS Asset Acquisition Orders'),
					('1404','SEIS Cost Pool Orders'),
					('1501','SEE Operating Orders'),
					('1601','SEF Operating Orders'),
					('1701','SEC Operating Orders'),
					('1702','SEC Capital Orders with IM'),
					('1703','SEC Asset Acquisition Orders'),
					('1704','SEC Cost Pool Orders'),
					('1801','PE/NOVA Operating Orders'),
					('1803','PE/NOVA Asset Acquisition Orders'),
					('1901','SEMM Operating Orders'),
					('1902','SEMM Capital Orders'),
					('1903','SEMM Asset Acquisition Orders'),
					('1904','SEMM Cost Pool Orders'),
					('2001','SV Operating Orders'),
					('2002','SV Capital Orders'),
					('2003','SV Asset Acquisition Orders'),
					('5533','Mesquite Order'),
					('5572','Twin Oaks Order'),
					('5610','Elk Hills Order'),
					('S010','SDGE Capital Order'),
					('S011','SDGE Project Order'),
					('S020','SDGE Manual Capital Order'),
					('S030','OBSOLETE SDGE Billing Order'),
					('S035','SDGE Allocated/Direct O&M Billing'),
					('S036','SDGE Directly Req.-Capital'),
					('S037','SDGE Directly Req.Serv.-Affiliates'),
					('S038','SDGE NSS Directly Req.Serv-AFF CAP'),
					('S039','SDGE Inter-Comp Receiving Billing Order'),
					('S040','SDGE O&M Order'),
					('S050','SDGE Manual O&M Order'),
					('S055','SDGE O&M Reporting Exclusions Order'),
					('S060','SDGE Statistical FERC Order'),
					('S070','SDGE Perm. Order for Cap. Stock Mat.'),
					('S080','SDGE Permanent Order - Others'),
					('S085','SDGE Manual Permanent Order - Others'),
					('S090','SDGE Balance Sheet Order'),
					('S091','SDGE Split Orders, Settle before OH Load'),
					('S095','SDGE Manual Balance Sheet Order'),
					('S100','SDGE Planning Order'),
					('S110','OBSOLETE SDGE ISU-FERC Clearing Order'),
					('S120','SDGE Cost Pools/Credit Objects'),
					('S130','SDGE Clearing Order for 184, 163'),
					('S140','OBSOLETE SDGE Shop Order'),
					('S150','SDGE Statistical O&M Order'),
					('S160','OBSOLETE SDGE Asset Alloc Order'),
					('S170','SDGE OH Clearing Order'),
					('S900','Poles, Towers & Fixtures'),
					('S901','Overhead Conductors & Devices'),
					('S902','Underground Conduit'),
					('S903','Underground Conductors & Devices'),
					('S904','Protective Devices & Capacitors'),
					('S905','Services Overhead'),
					('S906','Services Underground'),
					('S907','Meter Installations'),
					('S908','Electronic Meter Installations'),
					('S909','Installations on Customers Premises'),
					('S910','Street Lighting & Signal Systems'),
					('S911','Telecom'),
					('S920','Mains'),
					('S921','Services'),
					('S922','Meter and Regulator Installations'),
					('S923','Meters/Regs./Modules Installations'),
					('S924','Gas Regulation Station'),
					('S925','Mains - Transmission'),
					('S926','Compressor Station Equipment'),
					('S927','Measuring and Regulating Equipment'),
					('S930','SDE CPD (Cap) - RMR - Electric'),
					('S931','SDG CPD (Cap) - RMR - Gas'),
					('S940','SDE CPD (O&M) - CCtr - Electric'),
					('S941','SDG CPD (O&M) - CCtr - Gas'),
					('S950','SDE CPD (Cap) - G/L - Electric'),
					('S951','SDG CPD (Cap) - G/L - Gas'),
					('S960','SDE CPD (Cap) - I/O - Electric'),
					('S961','SDG CPD (Cap) - I/O - Gas'),
					('S990','SDGE CPD - Default OAA'),
					('SG05','SCG Capital Order'),
					('SG10','SCG O&M Order'),
					('SG15','SCG Statistical FERC Order'),
					('SG20','SCG Perm. Order for Cap. Stock Mat.'),
					('SG22','SCG Perm. Order for Cap. Stock Mat. AMI'),
					('SG25','SCG Planning Order'),
					('SG30','OBSOLETE SCG ISU-FERC Clearing Order'),
					('SG35','SCG Cost Pools/Credit Objects'),
					('SG40','SCG Allocated/Direct O&M Billing'),
					('SG41','SCG Inter-Comp Receiving Billing Order'),
					('SG45','SCG Statistical O&M Order'),
					('SG50','SCG Directly Req.-Capital'),
					('SG90','SCG CPD (Cap) - 107/101'),
					('SG91','SCG CPD (Cap) - 108'),
					('SG92','SCG CPD (O&M) - CCtr'),
					('SG93','SCG CPD (Cap) - 184 BalSh'),
					('SG94','SCG CPD (Cap) - I/O'),
					('SG99','SCG CPD Default OAA');
GO

PRINT '-- SAP.CostingSheet';
GO	
INSERT INTO SAP.CostingSheet(CostingSheetID,Name)
			VALUES	('110001','SEMPRA Costing Sheet'),
					('210001','SDGE AFFILIATE Costing Sheet'),
					('210002','SDGE - Old Capital (2004)'),
					('210003','SDGE - Labor Only (2004)'),
					('553201','El Dorado Costing Sheet'),
					('A00000','Standard'),
					('A00001','Standard/Surcharge key'),
					('A00002','Standard/Plant'),
					('A00003','Standard/Company Code'),
					('A00004','Standard/Business Area'),
					('A00005','Standard/Order Type'),
					('A00006','Standard/Order Category'),
					('PP-PC1','PP-PC Standard'),
					('PP-PC2','PP-PC Surch.on CostOfGoodsManu'),
					('SCG001','SoCalGas Costing Sheet'),
					('SCG002','SCG Costing Sheet (Affiliate)'),
					('SCG003','SCG Costing Sheet (Pools,CSM)'),
					('SCG004','SCG CostingS (Shared Services)'),
					('SCG101','SCG - Cost Centers & O&M'),
					('SCG102','SCG - Affiliate Billing'),
					('SCG103','SCG - Shared Services'),
					('SCG104','SCG - CSM'),
					('SCG105','SCG - Ratable Alloc'),
					('SCG106','SCG - Warehouse'),
					('SCG107','SCG - Purchasing Only'),
					('SCG108','SCG - New Capital'),
					('SCG109','SCG - BLANK COSTING SHEET'),
					('SCG110','SCG - Labor Only w/o PLPD'),
					('SCG111','SCG - AMI - No Purch or WH'),
					('SDG101','SDGE - O&M'),
					('SDG102','SDGE - Billing'),
					('SDG103','SDGE - Damage Claims'),
					('SDG104','SDGE - Non-Valued'),
					('SDG105','SDGE - Labor Only'),
					('SDG106','SDGE - Warehouse'),
					('SDG107','SDGE - Purchasing Only'),
					('SDG108','SDGE - New Capital'),
					('SDG109','SDGE - Old Capital'),
					('SDG110','SDGE - Labor Only w/o PLPD'),
					('SEMP01','SEMPRA Costing Sheet'),
					('Z00002','SCG102-200502'),
					('Z00003','SCG103-200502'),
					('Z00004','SCG104-200502'),
					('Z00005','SCG105-200502'),
					('Z00006','SCG108-200502'),
					('Z00007','SDG101-200502'),
					('Z00008','SDG102-200502'),
					('Z00009','SDG103-200502'),
					('Z00010','SDG104-200502'),
					('Z00011','SDG105-200502'),
					('Z00012','SDG108-200502'),
					('Z00013','SDG109-200502'),
					('Z00014','SCG101-200503'),
					('Z00015','SCG102-200503'),
					('Z00016','SCG103-200503'),
					('Z00017','SCG104-200503'),
					('Z00018','SCG105-200503'),
					('Z00019','SCG108-200503'),
					('Z00020','SDG101-200503'),
					('Z00021','SDG102-200503'),
					('Z00022','SDG103-200503'),
					('Z00023','SDG104-200503'),
					('Z00024','SDG105-200503'),
					('Z00025','SDG108-200503'),
					('Z00026','SDG109-200503'),
					('Z00027','SDG105-200504'),
					('Z00028','SCG101-200505'),
					('Z00029','SCG102-200505'),
					('Z00030','SCG108-200505'),
					('Z00031','SCG105-200509'),
					('Z00032','SCG106-200509'),
					('Z00033','SDG106-200509'),
					('Z00034','SDG103-200609'),
					('Z00035','SCG101-200801'),
					('Z00036','SCG102-200801'),
					('Z00037','SCG103-200801'),
					('Z00038','SCG104-200801'),
					('Z00039','SCG105-200801'),
					('Z00040','SCG108-200801'),
					('Z00041','SCG110-200801'),
					('Z00042','SDG101-200801'),
					('Z00043','SDG102-200801'),
					('Z00044','SDG103-200801'),
					('Z00045','SDG104-200801'),
					('Z00046','SDG105-200801'),
					('Z00047','SDG108-200801'),
					('Z00048','SDG109-200801'),
					('Z00049','SDG110-200801'),
					('Z00050','110001-200801'),
					('Z00051','SEMP01-200801'),
					('Z00052','210002-200801'),
					('Z00053','SCG103-200802'),
					('Z00054','SCG104-200802'),
					('Z00055','SCG105-200802'),
					('Z00056','SCG108-200802'),
					('Z00057','SCG110-200802'),
					('Z00058','SDG101-200802'),
					('Z00059','SDG102-200802'),
					('Z00060','SDG103-200802'),
					('Z00061','SDG104-200802'),
					('Z00062','SDG105-200802'),
					('Z00063','SDG108-200802'),
					('Z00064','SDG109-200802'),
					('Z00065','SDG110-200802'),
					('Z00066','SCG101-200802'),
					('Z00067','SCG102-200802'),
					('Z00068','SCG101-201001'),
					('Z00069','SCG102-201001'),
					('Z00070','SCG103-201001'),
					('Z00071','SCG104-201001'),
					('Z00072','SCG108-201001'),
					('Z00073','SDG102-201001'),
					('Z00074','SDG103-201001'),
					('Z00075','SDG104-201001'),
					('Z00076','SDG108-201001'),
					('Z00077','SDG109-201001'),
					('Z00078','SCG111-201009'),
					('Z00079','SCG111-201008'),
					('Z00080','SDG108-201011'),
					('Z00081','SDG109-201011'),
					('Z00087','Z00083-201201'),
					('Z00088','Z00085-201201'),
					('Z00089','Z00086-201201'),
					('Z00090','SDG102-201201'),
					('Z00091','SCG101-201306'),
					('Z00092','SCG102-201306'),
					('Z00093','SCG103-201306'),
					('Z00094','SCG104-201306'),
					('Z00095','SCG108-201306'),
					('Z00096','SDG101-201306'),
					('Z00097','SDG102-201306'),
					('Z00098','SDG103-201306'),
					('Z00099','SDG108-201306'),
					('Z00100','SDG109-201306'),
					('Z00101','SCG101-201407'),
					('Z00102','SDG101-201407'),
					('Z00103','SCG108-201407'),
					('Z00104','SDG102-201407'),
					('Z00105','SDG103-201407'),
					('Z00106','SDG104-201407'),
					('Z00107','SDG108-201407'),
					('Z00108','SDG109-201407'),
					('Z00109','SCG107-201407'),
					('Z00110','SCG101-201501'),
					('Z00111','SCG102-201501'),
					('Z00112','SCG103-201501'),
					('Z00113','SCG104-201501'),
					('Z00114','SCG105-201501'),
					('Z00115','SCG108-201501'),
					('Z00116','SCG110-201501'),
					('Z00117','SCG111-201501'),
					('Z00118','SDG101-201501'),
					('Z00119','SDG102-201501'),
					('Z00120','SDG103-201501'),
					('Z00121','SDG104-201501'),
					('Z00122','SDG105-201501'),
					('Z00123','SDG108-201501'),
					('Z00124','SDG109-201501'),
					('Z00125','SDG110-201501');
GO

PRINT '-- SAP.OverheadKey';
GO	
INSERT INTO SAP.OverheadKey(OverheadKeyID,Name)
			VALUES	('210000','Electric Substation'),
					('210001','Electric Transmission (1)'),
					('210002','Electric Distribution (2)'),
					('210003','Gas Transmission (4)'),
					('210004','Gas Distribution (5)'),
					('210005','Common (Elec & Gas)'),
					('210006','Affiliates Regulated'),
					('210007','Affiliates Unregulated'),
					('210008','Damage Claims (Electric)'),
					('210009','Damage Claims (Gas)'),
					('210010','C&J - Excl. LE/Small Tools'),
					('210011','C&J - Electric Substation'),
					('210012','C&J - Electric Transmission'),
					('210013','C&J - Electric Distribution'),
					('210014','C&J - Gas Transmission'),
					('210015','C&J - Gas Distribution'),
					('210016','C&J - Electric'),
					('210017','C&J - Gas'),
					('210018','Electric Government Turnkey'),
					('210019','Military/Government Accts'),
					('210020','Unregulated-Non-Energy Affilia'),
					('210021','Software projects'),
					('210022','Electric Substation'),
					('210023','Electric Transmission (1)'),
					('210024','Generation'),
					('210101','Electric (cost centers only)'),
					('210102','Gas (cost centers only)'),
					('210103','Common (cost centers only)'),
					('220000','SCG Building Project - CS'),
					('220001','SCG IT Project - CS'),
					('220002','SCG Pipeline Project - CS'),
					('220003','SCG O&M Project - CS'),
					('220004','SCG Building Project - DISTR'),
					('220005','SCG IT Project - DISTR'),
					('220006','SCG Pipeline Project - DISTR'),
					('220007','SCG O&M Project - DISTR'),
					('220008','SCG Building Project - TRANS'),
					('220009','SCG IT Project - TRANS'),
					('220010','SCG Wells Project - TRANS'),
					('220011','SCG Pipeline Project - TRANS'),
					('220012','SCG O&M Project - TRANS'),
					('220013','SCG Building Project - OTHER'),
					('220014','SCG IT Project - OTHER'),
					('220015','SCG Pipeline Project - OTHER'),
					('220016','SCG Wells Project - OTHER'),
					('220017','SCG Utility - CS (Affiliate)'),
					('220018','SCG Utility - DIST (Affiliate)'),
					('220019','SCG Utility - TRAN (Affiliate)'),
					('220020','SCG Utility - OTHR (Affiliate)'),
					('220021','SCG NonUtil - CS (Affiliate)'),
					('220022','SCG NonUtil - DIST (Affiliate)'),
					('220023','SCG NonUtil - TRAN (Affiliate)'),
					('220024','SCG NonUtil - OTHR (Affiliate)'),
					('220025','SCG Meter Connect Cost'),
					('220026','SCG O&M Sundry - CS'),
					('220027','SCG O&M Sundry - DIST'),
					('220028','SCG O&M Sundry - TR'),
					('220029','SCG O&M Sundry - OTHER'),
					('220030','SCG Overhead Key No Rates'),
					('220031','Parent Only-Customer Service'),
					('220032','Parent Only-Distribution'),
					('220033','Parent Only-Transmission'),
					('220034','Parent Only-Other'),
					('220035','EDS Pipe & Other-New Business'),
					('220036','EDS Pipe & Other-Replacement'),
					('220037','CSM I/O (Meters)'),
					('220038','Third-Party Rate'),
					('220039','NPT for Region Planners'),
					('220050','SCG Refundable/Sundry'),
					('220051','SCG Damage Claim'),
					('220052','SCG 3rd. Party Trans.'),
					('220053','SCG SS - Parent/Non En/En CSS'),
					('220054','SCG Shared Services - SD'),
					('220055','SCG Storage'),
					('220056','SCG Advanced Meter'),
					('220057','SCG LbrOHs-Purch-Shop-Tool-Cap'),
					('220058','PSEP projects'),
					('220059','SCG CST/BCS Tariff'),
					('SAP1','Overhead key 1'),
					('SAP2','Overhead key 2');
GO

PRINT '-- SAP.Plant';
GO	
INSERT INTO SAP.Plant (PlantID,Name)
			VALUES	('1001','Central/Miramar'),
					('1003','Shops'),
					('1006','Encina'),
					('1007','South Bay Power Plant'),
					('1008','Gas Turbines'),
					('1010','Carlsbad Oper & Maint'),
					('1017','Ramona'),
					('1019','Compressor Stations'),
					('1020','Escondido Oper & Maint'),
					('1022','Foretravel'),
					('1030','Pacific Beach Oper & Maint'),
					('1040','Contractor North'),
					('1045','Contractor South'),
					('1050','Metro Construction Stores'),
					('1057','South Bay Garage'),
					('1060','El Cajon Oper & Maint'),
					('1070','Kearny Elec Const & Maint'),
					('1080','San Clemente Oper & Maint'),
					('1093','Telecommunications'),
					('1094','Skills Training Center'),
					('1096','Pine Valley'),
					('1098','SDGE Mission Control Center'),
					('1099','AGILE SOURCING'),
					('1101','Palomar Energy Center'),
					('1102','Miramar Energy Facility'),
					('1103','Cuyamaca Peak Energy Plant'),
					('1201','Desert Star Energy Center'),
					('1301','Sbstn Transm Surplus Material'),
					('1995','SDG&E  PSEP Operations'),
					('ENVL','Environmental Analysis Lab'),
					('KERN','Kern County - SDG&E'),
					('KING','King County - SDG&E'),
					('LALA','LA & LA County - SDG&E'),
					('MNPF','Monterey Park HQ'),
					('ORNG','Orange County - SDG&E'),
					('RIVR','Riverside County - SDG&E'),
					('SDED','SDGE Electric Distribution'),
					('SDET','SDGE Electric Transmission'),
					('SDGD','SDGE Gas Distribution'),
					('SDGE','San Diego Gas & Electric Hdqtr'),
					('VENT','Ventura County - SDG&E');
GO

PRINT '-- SAP.InterestProfile';
GO	
INSERT INTO SAP.InterestProfile (InterestProfileID,Name)
			VALUES	('0000001','Standard profile'),
					('A1','Affiliate Standard Profile'),
					('A2','Frontier Energy Profile'),
					('A3','Bangor Gas Profile'),
					('A4','Affiliate Interest Terminated'),
					('A5','Affiliate External Financing'),
					('C1','(DO NOT USE) SoCal-Tech Comp. Orders (07/99)'),
					('F1','SCG FAM AFUDC'),
					('F2','SDGE FAM AFUDC'),
					('S0','No Interest Profile'),
					('S1','SoCal-Standard Profile'),
					('S2','SoCal-Interest Terminated'),
					('S3','SDGE-Standard Profile'),
					('S4','Sempra-Standard Profile'),
					('S5','SDGE-Interest is N/A'),
					('S6','SDGE-ElectricTransmission'),
					('S7','Sempra-Line Items'),
					('SG','SoCal-Native Gas'),
					('T1','SCG Ad Valorem'),
					('T3','SDGE Ad Valorem');
GO

PRINT '-- SAP.CompanyCode';
GO	
INSERT INTO SAP.CompanyCode (CompanyCodeID,Name,Description)
			VALUES ('1100','HQ','Sempra Energy'),
				   ('2100','SDG&E','San Diego Gas & Electric'),
				   ('2200','SCG','Southern California Gas Co.');
GO

PRINT '-- SAP.CostCenterCategory';
GO	
INSERT INTO SAP.CostCenterCategory (CostCenterCategoryID,Name)
			VALUES	('A','Customer Svc (SCG)'),
					('B','Distribution (SCG)'),
					('C','Common'),
					('D','Transmission (SCG)'),
					('E','Electric'),
					('F','FERC Plan Setlt'),
					('G','Gas'),
					('H','O&M'),
					('O','Other'),
					('S','Sempra Corporate');
GO

PRINT '-- SAP.PlannedCategory';
GO	
INSERT INTO SAP.PlannedCategory (PlannedCategoryID,Name)
			VALUES	('CAP','Capital'),
					('CLR','Clearing'),
					('O&M','O&M'),
					('REF','Refundable'),
					('SPB','100% 3rd Party Billable');
GO

PRINT '-- SAP.PlannedCategoryDetail - 1/2';
GO	
INSERT INTO SAP.PlannedCategoryDetail (PlannedCategoryDetailID, PlannedCategoryID, Name, CostingSheetID, OverheadKeyID)
			VALUES	('EAF','SPB','Affiliate - Energy - Sempra','SDG102','210007'),
					('GOV','SPB','Government Turnkey','SDG102','210018'),
					('MIL','SPB','Military Accounts','SDG102','210019'),
					('NEA','SPB','Affiliate - Non-Energy','SDG102','210020'),
					('SCG','SPB','Affiliate - Energy - SCG','SDG102','210006');
GO

PRINT '-- SAP.PlannedCategoryDetail - 2/2';
GO	
INSERT INTO SAP.PlannedCategoryDetail (PlannedCategoryDetailID, PlannedCategoryID, Name, CostingSheetID)
			VALUES	('3RD','SPB','All Other','SDG102'),
					('DMG','SPB','Damage Claims','SDG103'),
					('GEN','CAP','General / All Other','SDG108'),
					('NVI','CAP','Non-Value Inventory','SDG104'),
					('O&M','O&M','O&M','SDG101'),
					('RFS','CAP','Removal','SDG108'),
					('SFT','CAP','SOP98 Software Projects','SDG110');
GO

PRINT '-- SAP.AnalyzedIndicator';
GO	
INSERT INTO SAP.AnalyzedIndicator (AnalyzedIndicatorID,Name)
			VALUES	('A','Analyzed'),
					('UA','Unitization & Analyzed'),
					('UCT','Unitization Complete TECO Only'),
					('UCF','Unitization Complete Final Only'),
					('TFC','Temp Facility Current'),
					('TFP','Temp Facility Permanent'),
					('TFR','Temp Facility Removed'),
					('X','Exclude from Power Plan');
GO

PRINT '-- SAP.PowerPlanOverride';
GO	
INSERT INTO SAP.PowerPlanOverride (PowerPlanOverrideID,Name)
			VALUES	('  ','Automated Process'),
					('NQ','Non-Qualified Order'),
					('MP','Manually Process to Power Plan'),
					('EX','Exclude from Power Plan Processing');
GO

PRINT '-- SAP.BillingType';
GO	
INSERT INTO SAP.BillingType (BillingTypeID,Name)
			VALUES	('B1','100% 3rd Party Billable'),
					('B2','SS Direct Project'),
					('B3','SS CC Percent Billed'),
					('B4','SS Direct Non-Project'),
					('B5','SS CorpCtr Payments by SDGE');
GO

PRINT '-- DPSS.COType';
GO
INSERT INTO DPSS.COType (COTypeID,Name)
				VALUES	('10','Tranmission Job'),
						('11','Blanket Order'),
						('87','Specific Budget'),
						('91','Operating Order / O&M');
GO
	
PRINT '-- Common.BillingCode';
GO	
INSERT INTO Common.BillingCode (BillingCodeID,BillingCodeWOA,Name,Description)
			VALUES	('_',' ','FERC Statistical Order',null),
					('A','A','Non-Billable / No CIAC Billing or Capitalization',null),
					('B1','B','Cust. Conv. Work','Direct Payment to Customer for SDG&E Convenience Work Done by Customer'),
					('B2','B','Miscellaneous Non-CIAC Payments',null),
					('B3','B','Refundable (CAC) Billing Only',null),
					('B4','B','R/W Fees Only (No CIAC or CAC Payments)',null),
					('B5','B','No Payment - Capitalization Only',null),
					('B6','B','Rule 2 Lump Sum Payment',null),
					('C1','C','Collectible',null),
					('C2','C','Actual Cost Billing - Cal Trans',null),
					('F','F','Service Upgrade for EV Facilities',null),
					('G','G','Actual Cost Billing - Customer',null),
					('M','M','Metropolitan Transit (MTS, SANDAG)',null),
					('N/A','N/A','Affiliate Billing',null),
					('NC','NC','Non-Collectible',null),
					('Q','Q','San Diego Surcharge Conversions',null),
					('R','R','Actual Cost Billing - Franchise',null),
					('V1','V','Competitive Bid',null),
					('V2','V','Applicant Installation',null),
					('X','X','Net Contract Price Billing','Net Contract Price Billing (CIAC Payment or Discount Option)'),
					('Z','Z','Unknown',null);
GO

PRINT '-- SAP.RegionCode';
GO	
INSERT INTO SAP.RegionCode (RegionCodeID,Name)
			VALUES	('39','SCG HEADQUARTERS'),
					('41','SCG INLAND EMPIRE - GD'),
					('42','SCG ORANGE COAST - GD'),
					('43','SCG PACIFIC  - GD'),
					('44','SCG NORTHERN - GD'),
					('45','SCG REGION 45'),
					('50','SCG STORAGE OPERATIONS - UG'),
					('51','SCG DESERT AREA  - GT'),
					('52','SCG SOUTHERN AREA - GT'),
					('53','SCG NORTHERN AREA - GT'),
					('SE','SDGE EAST - GD, ED, ET & SS'),
					('SG','SDGE  - GT'),
					('SS','SDGE SOUTH - GD, ED, ET & SS'),
					('XX','NOT APPLICABLE - ALL OTHERS');
GO

PRINT '-- SAP.DistrictCode';
GO	
INSERT INTO SAP.DistrictCode(CompanyCodeID,RegionCodeID,DistrictCodeID,Name)
			VALUES	('1100','SS','Z01','BEACH CITIES C&O'),
					('1100','SS','Z02','METRO C&O'),
					('1100','SS','Z03','EASTERN C&O'),
					('1100','SS','Z04','MOUNTAIN EMPIRE C&O'),
					('1100','SS','Z05','NORTH COAST C&O'),
					('1100','SS','Z06','NORTHEAST C&O'),
					('1100','SS','Z07','METRO STREET REPAIR'),
					('1100','SS','Z08','NORTHEAST STREET REPAIR'),
					('1100','SS','Z09','BEACH CITIES C&O'),
					('1100','SS','Z10','METRO C&O'),
					('1100','SS','Z11','EASTERN C&O'),
					('1100','SS','Z12','MOUNTAIN EMPIRE C&O'),
					('1100','SS','Z13','NORTH COAST C&O'),
					('1100','SS','Z14','NORTHEAST C&O'),
					('1100','SS','Z15','RAMONA C&O'),
					('1100','SS','Z16','RAMONA C&O'),
					('1100','SS','Z17','ORANGE COUNTY C&O'),
					('1100','SS','Z18','ORANGE COUNTY C&O'),
					('2100','XX','55','FEASIBILITY STUDY'),
					('2100','XX','86','NORC'),
					('2100','XX','99','TRAINING/DEMO'),
					('2100','SS','BC','BEACH CITIES C&O'),
					('2100','SS','CM','METRO C&O'),
					('2100','SS','CN','NORTHEAST C&O'),
					('2100','SS','EA','EASTERN C&O'),
					('2100','XX','ES','EASTERN SOT TEAM'),
					('2100','XX','GI','GAS INSTRUMENT SHOP'),
					('2100','XX','GM','GAS METER SHOP'),
					('2100','XX','GO','GAS OPERATIONS'),
					('2100','XX','KM','KEARNY MAINTENANCE'),
					('2100','SS','ME','MOUNTAIN EMPIRE C&O'),
					('2100','XX','MM','METRO METER SVCS'),
					('2100','SS','MR','MIRAMAR - OPEX ONLY'),
					('2100','SS','NC','NORTH COAST C&O'),
					('2100','SS','NE','NORTHEAST C&O'),
					('2100','XX','NM','NORTHERN METER SVC'),
					('2100','SS','OC','ORANGE COUNTY C&O'),
					('2100','XX','OM','OPERATIONS & METERING'),
					('2100','XX','PE','ENCINA POWER PLANT'),
					('2100','XX','PM','JOB WITH ORIGINATOR'),
					('2100','XX','PS','SOUTH BAY POWER PLANT'),
					('2100','SS','RA','RAMONA C&O'),
					('2100','SS','SB','METRO C&O'),
					('2100','XX','SG','SOUTH BAY GAS SERV'),
					('2100','XX','ST','SORT'),
					('2100','SS','XB','CNTR BEACH CITIES'),
					('2100','SS','XC','CNTR NORTH COAST'),
					('2100','SE','XE','CNTR EASTERN'),
					('2100','SS','XM','CNTR METRO'),
					('2100','SS','XN','CNTR NORTHEAST'),
					('2100','SS','XO','CNTR ORANGE COUNTY'),
					('2100','XX','XX','NOT APPLICABLE'),
					('2200','43','182','182ND STREET'),
					('2200','51','ADL','ADELANTO'),
					('2200','50','ALC','ALISO CANYON'),
					('2200','45','ALH','ALHAMBRA'),
					('2200','42','ANH','ANAHEIM'),
					('2200','45','AZS','AZUSA'),
					('2200','41','BEA','BEAUMONT'),
					('2200','44','BKR','BAKERSFIELD'),
					('2200','43','BLV','BELVEDERE'),
					('2200','51','BLY','BLYTE'),
					('2200','51','BMT','BEAUMONT'),
					('2200','52','BRE','BREA'),
					('2200','45','BRN','BRANFORD'),
					('2200','51','CAC','CACTUS CITY'),
					('2200','41','CHN','CHINO'),
					('2200','XX','CHT','CHATSWORTH'),
					('2200','43','CMP','COMPTON'),
					('2200','44','CNP','CANOGA PARK'),
					('2200','41','COR','CORONA'),
					('2200','43','CRN','CRENSHAW'),
					('2200','51','DES','DESERT CENTER'),
					('2200','42','DWN','DOWNEY'),
					('2200','41','ELC','EL CENTRO'),
					('2200','41','FNT','FONTANA'),
					('2200','39','GCT','GCT'),
					('2200','45','GLN','GLENDALE'),
					('2200','50','GOL','GOLETA'),
					('2200','42','GRG','GARDEN GROVE'),
					('2200','41','HAN','HANFORD'),
					('2200','39','HDQ','HEADQUARTERS'),
					('2200','43','HLY','HOLLYWOOD'),
					('2200','50','HRN','HONOR RANCHO'),
					('2200','43','HTP','HUNTINGTON PARK'),
					('2200','45','IND','INDUSTRY'),
					('2200','43','JNT','JUANITA'),
					('2200','51','KEL','KELSO'),
					('2200','42','LAJ','LA JOLLA'),
					('2200','44','LNC','LANCASTER'),
					('2200','52','MMR','MIRAMAR'),
					('2200','42','MNV','ALISO VIEJO'),
					('2200','41','MOJ','MOJAVE'),
					('2200','50','MTB','MONTEBELLO'),
					('2200','41','MUR','MURRIETA'),
					('2200','51','NBY','NEWBERRY'),
					('2200','51','NDL','NEEDLES'),
					('2200','51','NND','NORTH NEEDLES'),
					('2200','52','OLY','OLYMPIC'),
					('2200','44','OXN','OXNARD'),
					('2200','45','PAS','PASADENA'),
					('2200','50','PDR','PLAYA DEL REY'),
					('2200',NULL,'PIR','PICO RIVERA'),
					('2200','41','PMD','PALM DESERT'),
					('2200','41','POR','PORTERVILLE'),
					('2200','XX','RED','REDLANDS'),
					('2200','41','RMF','RIM FOREST'),
					('2200','41','RMN','RAMONA'),
					('2200','41','RVR','RIVERSIDE'),
					('2200','44','SAT','SATICOY'),
					('2200','44','SBR','SANTA BARBARA'),
					('2200','44','SLO','SAN LUIS OBISPO'),
					('2200','44','SMR','SANTA MARIA'),
					('2200','44','SMV','SIMI VALLEY'),
					('2200','42','SNA','SANTA ANA'),
					('2200','41','SNB','SAN BERNARDINO'),
					('2200','41','SND','SOUTH NEEDLES'),
					('2200','43','SNM','SANTA MONICA'),
					('2200','43','SNP','SAN PEDRO'),
					('2200','52','SST','SPENCE ST'),
					('2200','53','SYL','SYLMAR'),
					('2200','53','TAF','TAFT'),
					('2200','41','TEM','TEMPLETON'),
					('2200','53','VEN','VENTURA'),
					('2200','51','VIC','VICTORVILLE'),
					('2200','45','VLN','VALENCIA'),
					('2200','44','VSL','VISALIA'),
					('2200','53','WHR','WHEELER RIDGE'),
					('2200','42','WHT','WHITTIER'),
					('2200','XX','XXX','NOT APPLICABLE'),
					('2200','43','YKN','YUKON'),
					('2200','41','YUC','YUCCA VALLEY');
GO

PRINT '-- Common.County';
GO	
INSERT INTO Common.County(Name,FIPS,Seat,Established)
			VALUES	('Alameda',1,'Oakland',1853),
					('Alpine',3,'Markleeville',1864),
					('Amador',5,'Jackson',1854),
					('Butte',7,'Oroville',1850),
					('Calaveras',9,'San Andreas',1850),
					('San Francisco',75,'San Francisco',1850),
					('Colusa',11,'Colusa',1850),
					('Contra Costa',13,'Martinez',1850),
					('Del Norte',15,'Crescent City',1857),
					('El Dorado',17,'Placerville',1850),
					('Fresno',19,'Fresno',1856),
					('Glenn',21,'Willows',1891),
					('Humboldt',23,'Eureka',1853),
					('Imperial',25,'El Centro',1907),
					('Inyo',27,'Independence',1866),
					('Kern',29,'Bakersfield',1866),
					('Kings',31,'Hanford',1893),
					('Lake',33,'Lakeport',1861),
					('Lassen',35,'Susanville',1864),
					('Los Angeles',37,'Los Angeles',1850),
					('Madera',39,'Madera',1893),
					('Marin',41,'San Rafael',1850),
					('Mariposa',43,'Mariposa',1850),
					('Mendocino',45,'Ukiah',1850),
					('Merced',47,'Merced',1855),
					('Modoc',49,'Alturas',1874),
					('Mono',51,'Bridgeport',1861),
					('Monterey',53,'Salinas',1850),
					('Napa',55,'Napa',1850),
					('Nevada',57,'Nevada City',1851),
					('Orange',59,'Santa Ana',1889),
					('Placer',61,'Auburn',1851),
					('Plumas',63,'Quincy',1854),
					('Riverside',65,'Riverside',1893),
					('Sacramento',67,'Sacramento',1850),
					('San Benito',69,'Hollister',1874),
					('San Bernardino',71,'San Bernardino',1853),
					('San Diego',73,'San Diego',1850),
					('San Joaquin',77,'Stockton',1850),
					('San Luis Obispo',79,'San Luis Obispo',1850),
					('San Mateo',81,'Redwood City',1856),
					('Santa Barbara',83,'Santa Barbara',1850),
					('Santa Clara',85,'San Jose',1850),
					('Santa Cruz',87,'Santa Cruz',1850),
					('Shasta',89,'Redding',1850),
					('Sierra',91,'Downieville',1852),
					('Siskiyou',93,'Yreka',1852),
					('Solano',95,'Fairfield',1850),
					('Sonoma',97,'Santa Rosa',1850),
					('Stanislaus',99,'Modesto',1854),
					('Sutter',101,'Yuba City',1850),
					('Tehama',103,'Red Bluff',1856),
					('Trinity',105,'Weaverville',1850),
					('Tulare',107,'Visalia',1852),
					('Tuolumne',109,'Sonora',1850),
					('Ventura',111,'Ventura',1872),
					('Yolo',113,'Woodland',1850),
					('Yuba',115,'Marysville',1850);
GO

PRINT '-- SAP.City';
GO	
INSERT INTO SAP.City(CountyID,CityID,Name)
			VALUES	(34,'AG','Aguanga'),
					(38,'AP','Alpine'),
					(31,'AV','Aliso Viejo'),
					(14,'BD','Bard'),
					(38,'BL','Boulevard'),
					(38,'BO','Bonita'),
					(38,'BR','Borrego Springs'),
					(38,'BS','Bonsall'),
					(38,'CA','Campo'),
					(38,'CB','Carlsbad'),
					(31,'CC','Coto de Caza'),
					(38,'CD','Cardiff-by-the-Sea'),
					(38,'CO','Coronado'),
					(31,'CP','Capistrano Beach'),
					(38,'CV','Chula Vista'),
					(14,'CX','Calexico'),
					(38,'DE','Descanso'),
					(38,'DM','Del Mar'),
					(31,'DP','Dana Point'),
					(38,'DZ','Dulzure'),
					(38,'EC','El Cajon'),
					(14,'EL','El Centro'),
					(38,'EN','Encinitas'),
					(38,'ES','Escondido'),
					(38,'FB','Fallbrook'),
					(38,'GY','Guatay'),
					(38,'IB','Imperial Beach'),
					(14,'IC','Imperial County (IC)'),
					(38,'JA','Jamul'),
					(38,'JC','Jacumba'),
					(38,'JU','Julian'),
					(38,'LA','Lincoln Acres'),
					(31,'LF','Las Flores'),
					(38,'LG','Lemon Grove'),
					(31,'LH','Laguna Hills'),
					(38,'LJ','La Jolla'),
					(38,'LK','Lakeside'),
					(38,'LM','La Mesa'),
					(31,'LN','Laguna Nigel'),
					(31,'LR','Ladera Ranch'),
					(38,'LU','Leucadia'),
					(31,'MB','Monarch Beach'),
					(38,'ML','Mount Laguna'),
					(31,'MV','Mission Viejo'),
					(38,'NC','National City'),
					(38,'NE','Nestor'),
					(38,'OC','Oceanside'),
					(38,'OL','Olivenhain'),
					(38,'PA','Pala'),
					(38,'PM','Palomar Mountain'),
					(38,'PT','Potrero'),
					(38,'PV','Pauma Valley'),
					(38,'PW','Poway'),
					(38,'PY','Pine Valley'),
					(14,'QI','Imperial County (QI)'),
					(31,'QO','Orange County'),
					(34,'QR','Riverside County'),
					(38,'QS','San Diego County'),
					(38,'RA','Ramona'),
					(38,'RH','Ranchita'),
					(38,'RL','Rancho La Costa'),
					(31,'RM','Rancho Santa Margarita'),
					(38,'RS','Rancho Santa Fe'),
					(31,'RV','Rancho Mission Viejo'),
					(38,'SB','Solana Beach'),
					(31,'SC','San Clemente'),
					(38,'SD','San Diego'),
					(38,'SI','Santa Ysabel'),
					(31,'SJ','San Juan Capistrano'),
					(31,'SL','South Laguna'),
					(38,'SM','San Marcos'),
					(38,'SR','San Luis Rey'),
					(38,'SS','Sunnyside'),
					(38,'ST','Santee'),
					(38,'SV','Spring Valley'),
					(38,'SY','San Ysidro'),
					(38,'TC','Tecate'),
					(38,'VC','Valley Center'),
					(38,'VS','Vista'),
					(38,'WA','Warner Springs');
GO

PRINT '-- WOA.StoredProcedure';
GO	
INSERT INTO WOA.StoredProcedure(SchemaName,Name, Description, InputParameterList, OutputParameterList, ReturnsRecords, CommandTypeProperty, IntendedUsage)
			/**CommandTypeProperty: {-1 = adCmdUnspecified; 1 = adCmdText; 2 = adCmdTable; 4 = adCmdStoredProc; 8 = adCmdUnknown}
			   IntendedUsage: {1 = Index; 2 = Query; 3 = Action} **/
			VALUES	('WOA','getGlobalConstants','Returns System Constants','@flagVerbose|@flagShowExpired',null,1,4,1),
					('Common','getSQLUserName','Returns USER_NAME() from SQL Server',null,null,1,4,2),
					('WOA','mergeWorkOrder','Adds/Modifies WOA Details',null,'@MergeWorkOrderID',1,4,3),
					('Common','getServerProperties','Returns list of server properties',null,null,1,4,1),
					('Common','getSchemas','Returns list of database schemas','@filterSchemaName',null,1,4,1),
					('Common','getTableRows','Returns records from selected table.','@filterSchemaName|@filterTableName',null,1,4,2),
					('Common','getExtendedProperty_Description','Returns table/field notes','@filterClass|@filterSchemaName|@filterTableName|@filterColumnName','@returnVariant',1,4,2),
					('Common','getSysObjectTypes','Returns list of system object types',null,null,1,4,1),
					('Common','getSysObjects','Returns list of sytsem objects','@filterSchemaName|@filterName|@filterType|@filterType_Desc',null,1,4,1),
					('Common','getSysColumns','Returns list of table fields','@filterSchemaName|@filterTableName',null,1,4,1),
					('Common','getIProtectClassification','Returns list of IProtectClassifications','@flagVerbose|@flagShowExpired',null,1,4,1),
					('SAP','getOrderType','Returns Order Type Index','@flagVerbose|@flagShowExpired',null,1,4,1),
					('SAP','getCompanyCode','Returns Company Code Index','@flagVerbose|@flagShowExpired',null,1,4,1),
					('SAP','getCostCenter','Returns Cost Center Index','@flagVerbose|@flagShowExpired',null,1,4,1),
					('SAP','getCostCenterCategory','Returns Cost Center Category Index','@flagVerbose|@flagShowExpired',null,1,4,1),
					('SAP','getCostingSheet','Returns Costing Sheet Index','@flagVerbose|@flagShowExpired',null,1,4,1),
					('SAP','getOverheadKey','Returns Overhead Key Index','@flagVerbose|@flagShowExpired',null,1,4,1),
					('SAP','getInterestProfile','Returns Interest Profile Index','@flagVerbose|@flagShowExpired',null,1,4,1),
					('SAP','getUserStatus','Returns User Status Index','@flagVerbose|@flagShowExpired',null,1,4,1),
					('Common','getBillingCodes','Returns Billing Code Status Index','@flagVerbose|@flagShowExpired',null,1,4,1),
					('Common','getCounties','Returns County Index (Default California)','@flagVerbose|@flagShowExpired|@filterStateID',null,1,4,1),
					('SAP','getAnalyzedIndicators','Returns Analyzed Indicator Index','@flagVerbose|@flagShowExpired',null,1,4,1),
					('SAP','getBillingTypes','Returns Billing Type Index','@flagVerbose|@flagShowExpired',null,1,4,1),
					('SAP','getCities','Returns City Index','@flagVerbose|@flagShowExpired|@filterCountyID',null,1,4,1),
					('SAP','getDistrictCodes','Returns District Code Index','@flagVerbose|@flagShowExpired|@filterRegionCodeID|@filterCompanyCodeID',null,1,4,1),
					('SAP','getPlannedCategories','Returns Planned Category Index','@flagVerbose|@flagShowExpired',null,1,4,1),
					('SAP','getPlannedCategoryDetails','Returns Planned Category Details Index','@flagVerbose|@flagShowExpired|@filterPlannedCategoryID',null,1,4,1),
					('SAP','getPlants','Returns Plant Index','@flagVerbose|@flagShowExpired',null,1,4,1),
					('SAP','getPowerPlanOverrides','Returns PowerPlan Override Index','@flagVerbose|@flagShowExpired',null,1,4,1),
					('SAP','getRegionCodes','Returns Region Code Index','@flagVerbose|@flagShowExpired',null,1,4,1);
GO

PRINT '-- SAP.UserStatus';
GO
INSERT INTO SAP.UserStatus (UserStatusID, Name)
			VALUES	('10','NOST'),
					('30','NFEC'),
					('40','ZPLN'),
					('50','Z001'),
					('60','BILL'),
					('70','ASET'),
					('80','KAMV');
GO

PRINT '-- WOA.ParentOrderProject';
GO
INSERT INTO WOA.ParentOrderProject (ParentOrderProjectID,Name,Description)
			VALUES	('AD','ADMS Project','Advanced Distribution Management System'),
					('AE','Easy Enrollment','My Account Easy Enrollment'),
					('AG','AGFD Project','Advanced Grid Fault Detection'),
					('AP','Avian Protection','Avian Protection Plan'),
					('BM','BPMG Project','Balboa Park Microgrid Project'),
					('BS','BSMG Project','Borrego Springs Microgrid 2.0 Project'),
					('BT','Battery Replacement','SDG&E Battery Replacement & Re-engineering Program'),
					('CA','Catastrophe','Catastrophic Event'),
					('CB','CBM GCB','CBM GCB Monitoring'),
					('CC','CCM Release','CCM Release'),
					('CE','Customer Energy','Customer Energy'),
					('CI','CAISO Initiatives','California ISO Initiatives'),
					('CM','CMG Project','Civita Microgrid Project'),
					('CP','CPD Enhancements','SDG&E CPD Enhancements'),
					('CS','CBM','CBM'),
					('DE','DERMS','District Energy RSRC MGMT SOL DRM'),
					('DI','DIIS','DIIS'),
					('DL','DLR Project','Dynamic Line Ratings Project'),
					('DP','DPP','DPP'),
					('EC','EC','Env. Post Construction'),
					('EP','EPS Project','Energy Procurement System'),
					('ES','AES Project','Advanced Energy Storage Proejct'),
					('ET','ET','ET'),
					('EV','LCFS','LCFS'),
					('FI','Wireless Fault Indicators','Wireless Fault Indicators'),
					('FM','FIRM Project','FIRM SO80 Shared Cost'),
					('FP','FHPMA Proejct','EDM Fire Hazard Prevention'),
					('FR','Facilities','Facilities Resource Management'),
					('GC','GCP','GCP'),
					('GD','GD',null),
					('GI','GI',null),
					('GT','GT',null),
					('IT','IT',null),
					('IV','IV',null),
					('LA','LA',null),
					('LR','LR',null),
					('MA','MA',null),
					('MG','MG',null),
					('MH','MH',null),
					('MM','MM',null),
					('MO','MO',null),
					('NE','NE',null),
					('NM','NM',null),
					('NP','NP',null),
					('OL','OL',null),
					('OP','OP',null),
					('P5','Jacumba Solar','Jacumba Solar PTO Interconnection'),
					('PD','DSEC Purchase','Desert Star Energy Center Purchase'),
					('PE','PE',null),
					('PG','PG',null),
					('PI','PI',null),
					('PO','PO',null),
					('PR','PR',null),
					('PS','PS',null),
					('S0','S0',null),
					('SA','SA',null),
					('SC','SC',null),
					('SE','SE',null),
					('SG','SG',null),
					('SI','SI',null),
					('SL','SL',null),
					('SM','SM',null),
					('SP','SP',null),
					('SR','SR',null),
					('SS','SS',null),
					('ST','ST',null),
					('SU','SU',null),
					('T1','T1',null),
					('TE','TE',null),
					('TF','TF',null),
					('TH','TH',null),
					('TI','TIMP','TIMP'),
					('TO','TO',null),
					('TS','TS',null),
					('VG','VG',null),
					('WC','WC',null),
					('WN','WAN Rebuild','WAN Rebuild'),
					('WP','IT W7U','W7U Legacy PC/Printer Replacement'),
					('WR','Powerworkz','Powerworkz TC / Vegetation Management'),
					('WW','PLWW Project','Point Loma Waste Water Projects'),
					('Z0','SONGS','San Onofre Nuclear Generating Station Projects');
					
GO

PRINT '-- WOA.GlobalConstant';
GO
INSERT INTO WOA.GlobalConstant (Name, ConstantValue)
			VALUES	('ApplicationIcon','Assets\FlameBoy.ico'),
					('ApplicationName','Work Order Authorization System'),
					('AssetsPath','\\nas-rb2a\corpdata$\SDGE Cost Acct\Capital Asset Mgmt\Software\WOASystem\Assets\'),
					('BackEndDatabase','\\nas-rb2a\corpdata$\SDGE Cost Acct\Capital Asset Mgmt\Software\WOASystem\DATA\WOASystem_DATA.accdb'),
					('CodeLibrary','\\nas-rb2a\corpdata$\SDGE Cost Acct\Capital Asset Mgmt\Software\CodeLibrary\VanderbiltCodeLibrary.accde'),
					('ErrorLogPath','\\nas-rb2a\corpdata$\SDGE Cost Acct\Capital Asset Mgmt\Software\WOASystem\ErrorLog.txt'),
					('ODBCDatabase','SONGS'),
					('ODBCDriver','SQL Server'),
					('ODBCServer','SQ-ENT12-D01'),
					('SecurityCode','4AD&&SrYt8V5&&xV6AD9hYZT'),
					('UserGuide_Web','https://sps.sdge.com/so/acct/SSL_WOAProcess/SitePages/Home.aspx');

GO

/***** POPULATE DEFAULT DATA UPDATES ******/
PRINT '/***** POPULATE DEFAULT DATA UPDATES ******/';
GO
PRINT '-- SAP.DistrictCode';
GO
UPDATE SAP.DistrictCode
SET ValidTo = SYSUTCDATETIME()
FROM SAP.DistrictCode
WHERE SAP.DistrictCode.CompanyCodeID NOT IN ('2100');
GO

PRINT '-- SAP.RegionCode';
GO
UPDATE SAP.RegionCode
SET ValidTo = SYSUTCDATETIME()
FROM SAP.RegionCode
WHERE SAP.RegionCode.RegionCodeID NOT IN ('SE','SS','XX');
GO

PRINT '-- SAP.OrderType';
GO
UPDATE SAP.OrderType
SET ValidTo = SYSUTCDATETIME()
FROM SAP.OrderType
WHERE SAP.OrderType.OrderTypeID NOT IN('S010','S040','S050','S055','S060','S070','S080','S090','S091','S095','S150');
GO	

PRINT '-- SAP.CostingSheet';
GO
UPDATE SAP.CostingSheet
SET ValidTo = SYSUTCDATETIME()
FROM SAP.CostingSheet
WHERE SAP.CostingSheet.CostingSheetID NOT IN('SDG101','SDG102','SDG103','SDG104','SDG105','SDG108','SDG110');
GO	

PRINT '-- SAP.OverheadKey';
GO
UPDATE SAP.OverheadKey
SET ValidTo = SYSUTCDATETIME()
FROM SAP.OverheadKey
WHERE SAP.OverheadKey.OverheadKeyID NOT IN('210000','210001','210002','210003','210004','210005','210006','210007','210018','210019','210020','210024');
GO

PRINT '-- SAP.InterestProfile';
GO
UPDATE SAP.InterestProfile
SET ValidTo = SYSUTCDATETIME()
FROM SAP.InterestProfile
WHERE SAP.InterestProfile.InterestProfileID NOT IN('S0','S3','S5','S6');
GO


PRINT '/***** SCRIPT COMPLETED ******/';
GO