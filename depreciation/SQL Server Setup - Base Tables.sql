/***************************************************************************************
Name      : Depreciation Accounting - SQL Base Table Setup
License   : Copyright (C) 2017 San Diego Gas & Electric company
            All Rights Reserved
Created   : 05/04/2017 08:02 Matthew C. Vanderbilt /00562 (START)
            05/09/2017 10:31 Matthew C. Vanderbilt /00562 (END)
****************************************************************************************
ATTRIBUTIONS:
- none
****************************************************************************************
DESCRIPTION / NOTES:
- Creates base tables required for depreciation-study integrated system
****************************************************************************************
PREREQUISITES:
- none
****************************************************************************************
CHANGE LOG:
- 05/09/2017 12:26 Removed from PowerPlan.Mortality_Curve_Source /00562
    ,CONSTRAINT PK_PowerPlan_MortalityCurveSource PRIMARY KEY(Data_Point, Mortality_Curve)
- 
***************************************************************************************/

/*  GENERAL CONFIGURATION AND SETUP ***************************************************/
PRINT '** General Configuration & Setup';
/*  Change database context to the specified database in SQL Server. 
    https://docs.microsoft.com/en-us/sql/t-sql/language-elements/use-transact-sql */
USE [SONGS];
GO

/*  Specify ISO compliant behavior of the Equals (=) and Not Equal To (<>) comparison
    operators when they are used with null values.
    https://docs.microsoft.com/en-us/sql/t-sql/statements/set-ansi-nulls-transact-sql
    -   When SET ANSI_NULLS is ON, a SELECT statement that uses WHERE column_name = NULL 
        returns zero rows even if there are null values in column_name. A SELECT 
        statement that uses WHERE column_name <> NULL returns zero rows even if there 
        are nonnull values in column_name. 
    -   When SET ANSI_NULLS is OFF, the Equals (=) and Not Equal To (<>) comparison 
        operators do not follow the ISO standard. A SELECT statement that uses WHERE 
        column_name = NULL returns the rows that have null values in column_name. A 
        SELECT statement that uses WHERE column_name <> NULL returns the rows that 
        have nonnull values in the column. Also, a SELECT statement that uses WHERE 
        column_name <> XYZ_value returns all rows that are not XYZ_value and that are 
        not NULL. */
SET ANSI_NULLS ON;
GO

/*  Causes SQL Server to follow  ISO rules regarding quotation mark identifiers &
    literal strings.
    https://docs.microsoft.com/en-us/sql/t-sql/statements/set-quoted-identifier-transact-sql
    -   When SET QUOTED_IDENTIFIER is ON, identifiers can be delimited by double 
        quotation marks, and literals must be delimited by single quotation marks. When 
        SET QUOTED_IDENTIFIER is OFF, identifiers cannot be quoted and must follow all 
        Transact-SQL rules for identifiers. */
SET QUOTED_IDENTIFIER ON;
GO

/*  SETUP ERROR HANDLING (from AdventureWorks2012) ************************************/
PRINT '** Setup Error Handling';
GO

PRINT '-- dbo.GetErrorInfo';
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
PRINT '-- dbo.PrintError';
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
PRINT '-- dbo.LogError'; 
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

/*  DELETE EXISTING OBJECTS ***********************************************************/
PRINT '** Delete Existing Objects';
GO

PRINT '-- Delete Tables';
GO
IF OBJECT_ID ( 'PowerPlan.Asset_Location','U') IS NOT NULL
    DROP TABLE PowerPlan.Asset_Location;
GO
IF OBJECT_ID ( 'PowerPlan.Depr_Group','U') IS NOT NULL
    DROP TABLE PowerPlan.Depr_Group;
GO
IF OBJECT_ID ( 'PowerPlan.Depr_Method_Rates','U') IS NOT NULL
    DROP TABLE PowerPlan.Depr_Method_Rates;
GO
IF OBJECT_ID ( 'PowerPlan.Mortality_Curve_Points','U') IS NOT NULL
    DROP TABLE PowerPlan.Mortality_Curve_Points;
GO
IF OBJECT_ID ( 'PowerPlan.Mortality_Curve_Source','U') IS NOT NULL
    DROP TABLE PowerPlan.Mortality_Curve_Source;
GO
IF OBJECT_ID ( 'PowerPlan.Property_Unit_Default_Life','U') IS NOT NULL
    DROP TABLE PowerPlan.Property_Unit_Default_Life;
GO
IF OBJECT_ID ( 'PowerPlan.Retirement_Unit','U') IS NOT NULL
    DROP TABLE PowerPlan.Retirement_Unit;
GO
IF OBJECT_ID ( 'PowerPlan.Property_Unit','U') IS NOT NULL
    DROP TABLE PowerPlan.Property_Unit;
GO
IF OBJECT_ID ( 'PowerPlan.Utility_Account','U') IS NOT NULL
    DROP TABLE PowerPlan.Utility_Account;
GO
IF OBJECT_ID ( 'PowerPlan.Asset_Acct_Method','U') IS NOT NULL
    DROP TABLE PowerPlan.Asset_Acct_Method;
GO
IF OBJECT_ID ( 'PowerPlan.Business_Segment','U') IS NOT NULL
    DROP TABLE PowerPlan.Business_Segment;
GO
IF OBJECT_ID ( 'PowerPlan.CPR_Equip_Type','U') IS NOT NULL
    DROP TABLE PowerPlan.CPR_Equip_Type;
GO
IF OBJECT_ID ( 'PowerPlan.Depr_Mid_Period_Method','U') IS NOT NULL
    DROP TABLE PowerPlan.Depr_Mid_Period_Method;
GO
IF OBJECT_ID ( 'PowerPlan.Depr_Summary','U') IS NOT NULL
    DROP TABLE PowerPlan.Depr_Summary;
GO
IF OBJECT_ID ( 'PowerPlan.Depr_Summary2','U') IS NOT NULL
    DROP TABLE PowerPlan.Depr_Summary2;
GO
IF OBJECT_ID ( 'PowerPlan.Depreciation_Method','U') IS NOT NULL
    DROP TABLE PowerPlan.Depreciation_Method;
GO
IF OBJECT_ID ( 'PowerPlan.FERC_Plant_Account','U') IS NOT NULL
    DROP TABLE PowerPlan.FERC_Plant_Account;
GO
IF OBJECT_ID ( 'PowerPlan.Func_Class', 'U') IS NOT NULL
    DROP TABLE PowerPlan.Func_Class;
GO
IF OBJECT_ID ( 'PowerPlan.Major_Location','U') IS NOT NULL
    DROP TABLE PowerPlan.Major_Location;
GO
IF OBJECT_ID ( 'PowerPlan.Mortality_Curve','U') IS NOT NULL
    DROP TABLE PowerPlan.Mortality_Curve;
GO
IF OBJECT_ID ( 'PowerPlan.Retire_Method','U') IS NOT NULL
    DROP TABLE PowerPlan.Retire_Method;
GO
IF OBJECT_ID ( 'PowerPlan.Unit_of_Measure','U') IS NOT NULL
    DROP TABLE PowerPlan.Unit_of_Measure;
GO
IF OBJECT_ID ( 'PowerPlan.Status_Code','U') IS NOT NULL
    DROP TABLE PowerPlan.Status_Code;
GO

PRINT '-- Delete Schemas';
GO
PRINT '-- -- PowerPlan';
IF SCHEMA_ID('PowerPlan') IS NOT NULL
	DROP SCHEMA PowerPlan;
GO

/*  CREATE SCHEMAS ********************************************************************/
PRINT '** Create Schemas';
GO
CREATE SCHEMA PowerPlan;
GO
EXEC sys.sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'Contains PowerPlan objects leveraged across applications.', 
	 @level0type=N'SCHEMA',
	 @level0name=N'PowerPlan';
GO

/*  CREATE TABLES *********************************************************************/
PRINT '** Create Tables';
GO

PRINT '-- PowerPlan.Status_Code';
CREATE TABLE PowerPlan.Status_Code
(
    [Status_Code_ID] [int] NOT NULL PRIMARY KEY
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Status_Code] [nvarchar](35) NOT NULL
    ,[Long_Description] [nvarchar](254) NULL
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(F)  [11] The Status Code data table records the active or inactive status that is associated with items, such as utility account, which are a part of the CPR record.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Status_Code';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) Status code id identifies a unique status applied to an entity: 0. Active 1. Inactive.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Status_Code',
    @level2type=N'COLUMN', @level2name=N'Status_Code_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard System-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Status_Code',
    @level2type=N'COLUMN', @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard System-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Status_Code',
    @level2type=N'COLUMN', @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records a short description of the status.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Status_Code',
    @level2type=N'COLUMN', @level2name=N'Status_Code';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(Not currently used)',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Status_Code',
    @level2type=N'COLUMN', @level2name=N'Long_Description';
GO

PRINT '-- PowerPlan.Asset_Acct_Method';
CREATE TABLE PowerPlan.Asset_Acct_Method
(
    [Asset_Acct_Meth_ID] [INT] NOT NULL PRIMARY KEY
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Asset_Acct_Meth] [varchar](35) NOT NULL
    ,[Long_Description] [varchar](254) NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_AssetAcctMethod_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_AssetAcctMethod_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_AssetAcctMethod_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_AssetAcctMethod_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_AssetAcctMethod_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(F) [01][12] The Asset Acccounting Method data table lists, using key words, the methods in which assets can be added to the CPR Ledger.  Examples of such methods include specific additions, in which each asset becomes a single ledger entry on the CPR Ledger; and mass additions, where the asset is recorded in an existing vintage year ledger entry, thus being subsequently priced at average vintage cost.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Asset_Acct_Method';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(PK) System-assigned identifier of a particular asset accounting method.  There are three methods defined within the sytsem: MASS, SPECIFIC, and SPECIFIC HIGH LEVEL.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Asset_Acct_Method', 
    @level2type=N'COLUMN', @level2name=N'Asset_Acct_Meth_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Standard system-assigned timestamp used for audit purposes.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Asset_Acct_Method', 
    @level2type=N'COLUMN', @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Standard system-assigned user id used for audit purposes.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Asset_Acct_Method', 
    @level2type=N'COLUMN', @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(description) Records a short description of the Asset Accounting Method.  There are three methods: SPECIFIC, MASS, SPECIFIC HIGH LEVEL.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Asset_Acct_Method', 
    @level2type=N'COLUMN', @level2name=N'Asset_Acct_Meth';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Records a more detailed description of the Asset Accounting Method.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Asset_Acct_Method', 
    @level2type=N'COLUMN', @level2name=N'Long_Description';
GO

PRINT '-- PowerPlan.Business_Segment';
CREATE TABLE PowerPlan.Business_Segment
(
    [Bus_Segment_ID] [INT] NOT NULL PRIMARY KEY
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Business_Segment] [varchar](35) NOT NULL
    ,[Status_Code_ID] [INT] NOT NULL
    ,[External_Bus_Segment] [char](35) NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_BusinessSegment_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_BusinessSegment_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_BusinessSegment_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_BusinessSegment_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_BusinessSegment_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(S) [11] The Business Segment data table records those types of business in which the utility is involved.  Examples include Gas, Electric, and Common, or Generation and Transmission.  General Ledger and utility (plant) accounts can be associated with a given segment.  A single legal company can have multiple business segments.  Utility plant accounts can vary by business segment.  Debit and credit control and balancing is maintained by business segment.  Informal business units can use a classification code rather than a PowerPlan business segment.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Business_Segment';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(PK) System-assigned identifier of a unique business segment.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Business_Segment', 
    @level2type=N'COLUMN', @level2name=N'Bus_Segment_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Standard system-assigned timestamp used for audit purposes.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Business_Segment', 
    @level2type=N'COLUMN', @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Standard system-assigned user id used for audit purposes.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Business_Segment', 
    @level2type=N'COLUMN', @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(description) Records a short description of the business segment, e.g., Gas, Electric, Generation, or Transmission.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Business_Segment', 
    @level2type=N'COLUMN', @level2name=N'Business_Segment';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(fk) Identifies a unique status: 1 - Active; 0 - Inactive.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Business_Segment', 
    @level2type=N'COLUMN', @level2name=N'Status_Code_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Optional tie to a business segment or unit used in an external system.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Business_Segment', 
    @level2type=N'COLUMN', @level2name=N'External_Bus_Segment';
GO

PRINT '-- PowerPlan.CPR_Equip_Type';
CREATE TABLE PowerPlan.CPR_Equip_Type
(
    [Equip_Type_ID] [int] NOT NULL PRIMARY KEY
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Equip_Type] [nvarchar](35) NOT NULL
    ,[Asset_Relation] [int] NOT NULL
    ,[Asset_Restriction] [int] NOT NULL
    ,[Update_Asset_Quantity] [int] NOT NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_CPREquipType_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_CPREquipType_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_CPREquipType_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_CPREquipType_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_CPREquipType_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(O) [01] The CPR Equip Type table holds the client-defined list of Equipment Record Types.  Equipment Record Type also defines the list of detail attributes to be associated with a particular equipment record through the table Equipment Record Type Attribute.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Equip_Type';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) System-assigned identifier of a particular equipment record type.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Equip_Type', 
    @level2type=N'COLUMN', @level2name=N'Equip_Type_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard System-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Equip_Type', 
    @level2type=N'COLUMN', @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard System-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Equip_Type', 
    @level2type=N'COLUMN', @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(description) Records a brief description of the equipment record type.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Equip_Type', 
    @level2type=N'COLUMN', @level2name=N'Equip_Type';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier that defines the type of relationship to CPR assets: 1-1 asset to many records; 2-1 equipment record to many assets; 3-1 to 1; 4-Uncoupled.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Equip_Type', 
    @level2type=N'COLUMN', @level2name=N'Asset_Relation';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'System-assigned identifier that defines the level of asset activity allowed: 1-Yes: when creating asset-level transactions (retirements, transfers) from the CPR, the user will be forced to select the associated Equipment Records to participate in the transation.  Alternatively, transactions may be intiiated within the Equipment Ledger.  0-No: Asset-level transactions are not restricted.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Equip_Type', 
    @level2type=N'COLUMN', @level2name=N'Asset_Restriction';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'System-assigned identifier that defines how asset-level quantities are treated when an equipment ledger quantity is updated: 1-Yes: Update asset quantity when associated equipment ledger quanitty is updated.  0-No: Do not update asset quanitty when associated equipment ledger quantity is updatedd.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Equip_Type', 
    @level2type=N'COLUMN', @level2name=N'Update_Asset_Quantity';
GO

PRINT '-- PowerPlan.Depr_Mid_Period_Method';
CREATE TABLE PowerPlan.Depr_Mid_Period_Method
(
    [Mid_Period_Method] [nvarchar](35) NOT NULL PRIMARY KEY
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Description] [nvarchar](35) NOT NULL
    ,[Calc_Option] [nvarchar](1) NOT NULL
    ,[Sort_Order] [int] NOT NULL   
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_DeprMidPeriodMethod_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_DeprMidPeriodMethod_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_DeprMidPeriodMethod_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_DeprMidPeriodMethod_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_DeprMidPeriodMethod_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(F) [01] System delivered table containing list of all Mid-Period Methods available for PowerPlan Depreciation Groups.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Depr_Mid_Period_Method';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) System-assigned identifier of the depr mid period method.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Depr_Mid_Period_Method', 
    @level2type=N'COLUMN', @level2name=N'Mid_Period_Method';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard System-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Depr_Mid_Period_Method', 
    @level2type=N'COLUMN', @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard System-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Depr_Mid_Period_Method', 
    @level2type=N'COLUMN', @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records a short description of the mid period method.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Depr_Mid_Period_Method', 
    @level2type=N'COLUMN', @level2name=N'Description';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Indicates if the mid-period method is available for depreciation groups using group methodology (G) or individual asset methodology (I).',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Depr_Mid_Period_Method', 
    @level2type=N'COLUMN', @level2name=N'Calc_Option';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Controls the sort order of mid-period methods when displayed in the system.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Depr_Mid_Period_Method', 
    @level2type=N'COLUMN', @level2name=N'Sort_Order';
GO

PRINT '-- PowerPlan.Depr_Summary';
CREATE TABLE PowerPlan.Depr_Summary
(
    [Depr_Summary_ID] [int] NOT NULL PRIMARY KEY
    ,[Depr_Summary] [NVARCHAR](35) NULL
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Depr_Summary_Rollup] [NVARCHAR](35) NULL
    ,[Summary_Code] [nvarchar](35) NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_DeprSummary_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_DeprSummary_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_DeprSummary_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_DeprSummary_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_DeprSummary_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(S) [01] The Depreciation Summary table contains a classification for rolling up depreciation groups for reporting.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Depr_Summary';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) Depr summary id is the unique System-assigned identifier of a particular depreciation reporting summary level.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Summary',
    @level2type=N'COLUMN',  @level2name=N'Depr_Summary_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(description) Description identified a particular depreciation reporting summary level, rolling up depreciation gropus.  See also depr_summary2.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Summary',
    @level2type=N'COLUMN',  @level2name=N'Depr_Summary';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard sytsem-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Summary',
    @level2type=N'COLUMN',  @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Summary',
    @level2type=N'COLUMN',  @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Freeform rollup up of depr summary for reporting.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Summary',
    @level2type=N'COLUMN',  @level2name=N'Depr_Summary_Rollup';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'External code description.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Summary',
    @level2type=N'COLUMN',  @level2name=N'Summary_Code';
GO

PRINT '-- PowerPlan.Depr_Summary2';
CREATE TABLE PowerPlan.Depr_Summary2
(
    [Depr_Summary2_ID] [int] NOT NULL PRIMARY KEY
    ,[Depr_Summary2] [NVARCHAR](35) NULL
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Depr_Summary2_Rollup] [NVARCHAR](35) NULL
    ,[Summary_Code2] [nvarchar](35) NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_DeprSummary2_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_DeprSummary2_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_DeprSummary2_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_DeprSummary2_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_DeprSummary2_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(S) [01] The Depreciation Summary2 table contains another classification for rolling-up depreciation groups for reporting (see Depr Summary table).',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Depr_Summary2';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) Depr summary id is the unique System-assigned identifier of a particular depreciation reporting summary level.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Summary2',
    @level2type=N'COLUMN',  @level2name=N'Depr_Summary2_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(description) Description identified a particular depreciation reporting summary level, rolling up depreciation gropus.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Summary2',
    @level2type=N'COLUMN',  @level2name=N'Depr_Summary2';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard sytsem-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Summary2',
    @level2type=N'COLUMN',  @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Summary2',
    @level2type=N'COLUMN',  @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Additional freeform rollup up of Depr Summary 2 used in reporting.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Summary2',
    @level2type=N'COLUMN',  @level2name=N'Depr_Summary2_Rollup';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'External code description.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Summary2',
    @level2type=N'COLUMN',  @level2name=N'Summary_Code2';
GO

PRINT '-- PowerPlan.Depreciation_Method';
CREATE TABLE PowerPlan.Depreciation_Method
(
    [Depr_Method_Id] [int] NOT NULL PRIMARY KEY
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Depr_Method] varchar(254) NOT NULL
    ,[Rate_Recalc_Option] [int] NULL
    ,[Exclude_from_RWIP] [int] NULL
    ,[Auto_Retire] [int] NULL
    ,[Company_ID] [int] NOT NULL                CONSTRAINT DK_PowerPlan_DeprMethod_CompanyID       DEFAULT 2100
    ,[Depr_Blending_Type_ID] [int] NULL
    ,[Prospective] [int] NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_DeprMethod_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_DeprMethod_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_DeprMethod_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_DeprMethod_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_DeprMethod_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(S) [01] The Depreciation Method data table records the depreciation method, description, or label used for depreciation groups.  The actual data for the depreciation method is in the Depr Method Rates table.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Depreciation_Method';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) System-assigned identifier of a particular depreciation method.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depreciation_Method',
    @level2type=N'COLUMN',  @level2name=N'Depr_Method_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depreciation_Method',
    @level2type=N'COLUMN',  @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depreciation_Method',
    @level2type=N'COLUMN',  @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(description) Records a short description of the depreciation method, e.g., DISTRIBUTION.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depreciation_Method',
    @level2type=N'COLUMN',  @level2name=N'Depr_Method';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'This is an option that allows the depreciation accrual rate to be automatically reclaculated, assuming the curve and life specified, with or without an end date.  NULL or 0 - do not automatically reclacluate the rate = NOT ALLOWED; 1-12 - recalculate the rate in the respective month; 1 = JANUARY, etc; 13 - recalculate the rate each month, EVERY MONTH; 14 - Allow the user to choose to recalculate the rate in the monthly closing cycle from the CPR Control Window, but do not require it.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depreciation_Method',
    @level2type=N'COLUMN',  @level2name=N'Rate_Recalc_Option';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Switch which will exclude the associated depreciation groups from the CWIP allocation if the allocation is being used: NO = Dont exclude; YES = Exclude.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depreciation_Method',
    @level2type=N'COLUMN',  @level2name=N'Exclude_from_RWIP';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'YES/NO indicator.  YES means apply auto life retires to CPR depreciation assets.  NO means do not apply auto life retires to CPR depreciation assets, even if otherwise indicated.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depreciation_Method',
    @level2type=N'COLUMN',  @level2name=N'Auto_Retire';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of the company to which the method applies.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depreciation_Method',
    @level2type=N'COLUMN',  @level2name=N'Company_ID';
GO

PRINT '-- PowerPlan.FERC_Plant_Account';
CREATE TABLE PowerPlan.FERC_Plant_Account
(
    [FERC_Plt_Acct_ID] [int] NOT NULL PRIMARY KEY
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[FERC_Plt_Acct] [nvarchar](35) NOT NULL
    ,[Long_Description] [nvarchar](MAX) NULL
    ,[RUS_Line_Number] [int] NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_FERCPlantAccount_CreatedBy       DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_FERCPlantAccount_CreatedDate     DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL CONSTRAINT DK_PowerPlan_FERCPlantAccount_rowguid   DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_FERCPlantAccount_ValidFrom       DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_FERCPlantAccount_ValidTo         DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(S) [11] The FERC Plant Account data table records the FERC-designated list of plant accounts used by the utility, e.g., 310, 311, 312, etc. or standard asset accounts used across the enterprise.  The companies accounts are in the Utility Account table.  Each utility account references a FERC plant account.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'FERC_Plant_Account';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(PK) Identifies a unique FERC plant account (300-series for electric, etc.).' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'FERC_Plant_Account', 
    @level2type=N'COLUMN', @level2name=N'FERC_Plt_Acct_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Standard system-assigned timestamp used for audit purposes.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'FERC_Plant_Account', 
    @level2type=N'COLUMN', @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Standard system-assigned user id used for audit purposes.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'FERC_Plant_Account', 
    @level2type=N'COLUMN', @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(description) Records a short description of the FERC plant account.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'FERC_Plant_Account', 
    @level2type=N'COLUMN', @level2name=N'FERC_Plt_Acct';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Records an optional detailed description of the FERC plant account.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'FERC_Plant_Account', 
    @level2type=N'COLUMN', @level2name=N'Long_Description';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'The line number on the RUS report: FINANCIAL AND OPERATING REPORT ELECTRIC POWER SUPPLY PART H - ANNUAL SUPPLEMENT.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'FERC_Plant_Account', 
    @level2type=N'COLUMN', @level2name=N'RUS_Line_Number';
GO

PRINT '-- PowerPlan.Func_Class';
CREATE TABLE PowerPlan.Func_Class
(
    [Func_Class_ID] [int] NOT NULL PRIMARY KEY
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Func_Class] [nvarchar](35) NOT NULL
    ,[Status_Code_ID] [int] NOT NULL
    ,[Func_Class_Sort_ID] [int] NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_FuncClass_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_FuncClass_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_FuncClass_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_FuncClass_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_FuncClass_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(S) [01][11][12] The Functional Class data table records the functional classes of plant generally as determined by FERC.  Additional functional classes should be added for non-FERC account summarization.  Used by the system mainly for reporting and to support queries.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Func_Class';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) System-assigned identifier for a particular functional class of plant such as Steam Production.  Functional classes should be set up for non-regulated accounts to support the drill-downs into the PowerPlan Ledgers.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Func_Class', 
    @level2type=N'COLUMN', @level2name=N'Func_Class_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned teimstamp used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Func_Class', 
    @level2type=N'COLUMN', @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Func_Class', 
    @level2type=N'COLUMN', @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records a short description of the functional class.  Functional classes should be set up for non-regulated accounts to support the drill downs into the system.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Func_Class', 
    @level2type=N'COLUMN', @level2name=N'Func_Class';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Identifies a unique status: 0 Not used on FERC Reporting; 1 FERC reporting order.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Func_Class', 
    @level2type=N'COLUMN', @level2name=N'Status_Code_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'A sequential number allowing a particular functional class sort.  Certain FERC Reports in the system use this sequence number as the order in which list the functions.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Func_Class', 
    @level2type=N'COLUMN', @level2name=N'Func_Class_Sort_ID';
GO

PRINT '-- PowerPlan.Major_Location';
CREATE TABLE PowerPlan.Major_Location
(
    [Major_Location_ID] [INT] NOT NULL PRIMARY KEY
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Division_ID] [int] NOT NULL
    ,[Municipality_ID] [nvarchar](18) NULL
    ,[State_ID] [nvarchar](18) NOT NULL
    ,[Location_Type_ID] [int] NOT NULL
    ,[External_Location_ID] [nvarchar](35) NULL
    ,[Grid_Coordinate] [int] NULL
    ,[Major_Location] [nvarchar](35) NOT NULL
    ,[Long_Description] [nvarchar](254) NULL
    ,[Address_] [nvarchar](MAX) NULL
    ,[ZIP_Code] [int] NULL
    ,[Location_Report] [nvarchar](35) NULL
    ,[Rate_Area_ID] [int] NULL
    ,[Status_Code_ID] [int] NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_MajorLocation_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_MajorLocation_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_MajorLocation_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_MajorLocation_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_MajorLocation_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(sl*) [01][09][12] The Major Location data table maintains a record of all major locations at which the utility maintains assets.  Major location is a principal locator of an asset.  Major Locations are broken down into detail asset locations (which are distinguished by minor locations, tax districts or line numbers).',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Major_Location';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) System-assigned identifier of a unique major location.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Major_Location', 
    @level2type=N'COLUMN', @level2name=N'Major_Location_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard System-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Major_Location', 
    @level2type=N'COLUMN', @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard System-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Major_Location', 
    @level2type=N'COLUMN', @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a particular division within a given company (departments all roll up to division).',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Major_Location', 
    @level2type=N'COLUMN', @level2name=N'Division_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) Records the name of a particular city within a given state.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Major_Location', 
    @level2type=N'COLUMN', @level2name=N'Municipality_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) Records the name of a particular state within a given country.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Major_Location', 
    @level2type=N'COLUMN', @level2name=N'State_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a particular location type.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Major_Location', 
    @level2type=N'COLUMN', @level2name=N'Location_Type_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Externally generated location number usually derived from the utilitys existing system.  In some cases these external numbers are required to allow cross-referencing between existing systems and PowerPlan.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Major_Location', 
    @level2type=N'COLUMN', @level2name=N'External_Location_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Externally generated location number usually derived from the utilitys exisitng geographic database.  In some cases these external numbers are required to allow cross-referencing between existing systems and PowerPlan.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Major_Location', 
    @level2type=N'COLUMN', @level2name=N'Grid_Coordinate';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(description) Records a short description of the entity.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Major_Location', 
    @level2type=N'COLUMN', @level2name=N'Major_Location';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records an optional detailed description of the entity.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Major_Location', 
    @level2type=N'COLUMN', @level2name=N'Long_Description';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Address maintains the street address of the major location.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Major_Location', 
    @level2type=N'COLUMN', @level2name=N'Address_';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Zip code records the mailing zip code of the major location.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Major_Location', 
    @level2type=N'COLUMN', @level2name=N'ZIP_Code';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'User defined variable that may be used in custom reports.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Major_Location', 
    @level2type=N'COLUMN', @level2name=N'Location_Report';
GO

PRINT '-- PowerPlan.Mortality_Curve';
CREATE TABLE PowerPlan.Mortality_Curve
(
    [Mortality_Curve_ID] [int] NOT NULL PRIMARY KEY
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Mortality_Curve] varchar(35) NOT NULL
    ,[Depr_Study] [bit] NULL                CONSTRAINT DK_PowerPlan_Mortality_Curve_Depr_Study      DEFAULT 0
    ,[Sort_Order] [INT] NULL
    ,[GM_Indicator] [INT] NULL              CONSTRAINT DK_PowerPlan_MortalitY_Curve_GM_Indicator    DEFAULT 0
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_Mortality_Curve_CreatedBy       DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_Mortality_Curve_CreatedDate     DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL CONSTRAINT DK_PowerPlan_Mortality_Curve_rowguid   DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_Mortality_Curve_ValidFrom       DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_Mortality_Curve_ValidTo         DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(S) [01][05][09][11][12] The Mortality Curve data table identifies those mortality curves, such as Iowa Curves, used within the PowerPlan applicaiton for retirement processing, net value computations, and depreciation studies.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Mortality_Curve';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(PK) System-assigned identifier of a unique mortality curve.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Mortality_Curve', 
    @level2type=N'COLUMN', @level2name=N'Mortality_Curve_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'System-assigned identifier of a unique mortality curve.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Mortality_Curve', 
    @level2type=N'COLUMN', @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Standard System-assigned timestamp used for audit purposes.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Mortality_Curve', 
    @level2type=N'COLUMN', @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(description) Records a short description of the curve (e.g., S1).' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Mortality_Curve', 
    @level2type=N'COLUMN', @level2name=N'Mortality_Curve';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'1 or 0; A 1 or USE means that the curve is available in depreciation study, and will be one of the curves that is automatically selected for fitting.  A 0 or IGNORE means do not use or automatically select.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Mortality_Curve', 
    @level2type=N'COLUMN', @level2name=N'Depr_Study';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'An integer indicating the order that the Depreciation Studies Module evaluates and reports results by curve in the Simulated Plant record Processing.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Mortality_Curve', 
    @level2type=N'COLUMN', @level2name=N'Sort_Order';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'An indicator whether a particular curve is a Gompertz Makeham or an Iowa Curve type; 0 = Iowa (Modified - by Ron White 1992), 1 = Gompertz (Makeham), 2 = Iowa (Original); 3 = H Curves.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Mortality_Curve', 
    @level2type=N'COLUMN', @level2name=N'GM_Indicator';
GO

PRINT '-- PowerPlan.Mortality_Curve_Source';
CREATE TABLE PowerPlan.Mortality_Curve_Source
(
    [Mortality_Curve_Type] NVARCHAR(20) NOT NULL    CONSTRAINT DK_PowerPlan_MortalityCurveSource_MortalityCurveType DEFAULT 'UNKNOWN'
    ,[Data_Point] DECIMAL(22,8) NOT NULL
    ,[Mortality_Curve] varchar(35) NOT NULL
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Age_Per_Exp_Life] [int] NOT NULL
    ,[Rem_Life_Percentage] DECIMAL(22,8)
    ,[Surviving_Percentage] DECIMAL(22,8)
    ,[GM_Indicator] [INT] NOT NULL          CONSTRAINT DK_PowerPlan_MortalityCurveSource_GMIndicator DEFAULT 0
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_MortalityCurveSource_CreatedBy      DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_MortalityCurveSource_CreatedDate    DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_MortalityCurveSource_rowguid    DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_MortalityCurveSource_ValidFrom  DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_MortalityCurveSource_ValidTo    DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Mortality Curve Source Data',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Mortality_Curve_Source';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Survivor curve percentage of average service life expressed as a factor of 100 (i.e. divide by 100 for percentage).' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Mortality_Curve_Source', 
    @level2type=N'COLUMN', @level2name=N'Data_Point';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Percentage of average service life remaining express as a factor of 100 (i.e. divide by 100 for percentage).' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Mortality_Curve_Source', 
    @level2type=N'COLUMN', @level2name=N'Rem_Life_Percentage';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Percentage of original units surviving.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Mortality_Curve_Source', 
    @level2type=N'COLUMN', @level2name=N'Surviving_Percentage';
GO

PRINT '-- PowerPlan.Retire_Method';
CREATE TABLE PowerPlan.Retire_Method
(
    [Retire_Method_ID] [int] NOT NULL PRIMARY KEY
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Retire_Method] [varchar](35) NULL    
    ,[Long_Description] NVARCHAR(MAX) NULL
    ,[Posting_Month] [int] NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_RetireMethod_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_RetireMethod_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_RetireMethod_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_RetireMethod_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_RetireMethod_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(S) [01][12] The Retire Method data table records the retirement methods used in PowerPlan  to retire assets from the CPR Ledger.  It is specified at a property unit level.  Retirement methods are: SPECIFIC - An individual asset is identified.  FIFO - A quantity is identified. The vintage and dollars are determined by the system, retiring the oldest vintage first.  RETIRE_CURVE - A quantity is identified.  The vintage is determined using a curve.  LIFE_AUTO - No retirements are identified.  The system automatically retires the assets at the end of their expected lives.  RETIRE CURVE/AUTO - no retirements are identified.  The system automatically retires the assets in conformity with a specified curve.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Retire_Method';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) System-assigned identifier of a particular retirement method.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Retire_Method',
    @level2type=N'COLUMN', @level2name=N'Retire_Method_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Standard System-assigned timestamp used for audit purposes.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Retire_Method', 
    @level2type=N'COLUMN', @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'System-assigned identifier of a unique mortality curve.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Retire_Method', 
    @level2type=N'COLUMN', @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(description) Description determined: Specific, FIFO, Retire Curve, Retire Curve/Auto, and Life/Auto.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Retire_Method',
    @level2type=N'COLUMN', @level2name=N'Retire_Method';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Retirement methods are: 1.) Specific  --An individual asset is identified. 2.) FIFO -- A quantity is identified, the vintage and $ are determined by the system, retiring the oldest vintage. 3.) Retire Curve Auto -- No retirements are identified; the system retires asset dollars in accordance with a mortality curve. 4.) Retire Curve  -- A quantity is identified.  The vintage is determined using a curve. 5.) Life/Auto -- No retirements are identified; the system automatically retires the asset at the end of their lives.  Lives are given by property unit or can be defaulted from company/account, or the depreication group. 6.) HW FIFO -- The system retires the replacement item by calculating the retirement based on the Handy Whitman indices to the oldest vintage(s). 7.) HW Curve  -- The system retires the replacement based on a mortality curve and Handy Whitman indices. 8.) ARO -- This is on the ARC part of the asset.  It is retired with the associated asset from the ARO module. 9.)Specific/Life Auto -- This is like Life_Auto, but the user can make life distinctions by company or business segment/utility account, or indicate that certain company account combinations use specific. Note:  Age is determined by the engineering in-service date.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Retire_Method',
    @level2type=N'COLUMN', @level2name=N'Long_Description';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'No longer used: See Company Set Up (Company).',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Retire_Method',
    @level2type=N'COLUMN', @level2name=N'Posting_Month';
GO

PRINT '-- PowerPlan.Unit_of_Measure';
CREATE TABLE PowerPlan.Unit_of_Measure
(
    [Unit_of_Measure_ID] [int] NOT NULL PRIMARY KEY
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Unit_of_Measure] [varchar](35) NOT NULL    
    ,[Long_Description] NVARCHAR(254) NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_UnitOfMeasure_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_UnitOfMeasure_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_UnitOfMeasure_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_UnitOfMeasure_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_UnitOfMeasure_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(S) [01][12] The Unit of Measure data table maintains a list of all measurement units used to quantify retirement units as they are recorded on the CPR Ledger.  It is specified at the property unit level.  Examples are FEET, EACH, etc.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Unit_of_Measure';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) System-assigned identifier of a particular unit of measure.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Unit_of_Measure',
    @level2type=N'COLUMN', @level2name=N'Unit_of_Measure_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Standard System-assigned timestamp used for audit purposes.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Unit_of_Measure', 
    @level2type=N'COLUMN', @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'System-assigned identifier of a unique mortality curve.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Unit_of_Measure', 
    @level2type=N'COLUMN', @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(description) Records a short description of the entity, e.g., FEET, INCHES, EACH.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Unit_of_Measure',
    @level2type=N'COLUMN', @level2name=N'Unit_of_Measure';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records an optional detailed description of the unit of measure.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Unit_of_Measure',
    @level2type=N'COLUMN', @level2name=N'Long_Description';
GO

PRINT '-- PowerPlan.Asset_Location';
CREATE TABLE PowerPlan.Asset_Location
(
    [Asset_Location_ID] [INT] NOT NULL PRIMARY KEY
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Tax_Location_ID] [INT] NULL
    ,[Minor_Location_ID] [INT] NULL
    ,[Tax_District_ID] [INT] NULL
    ,[Major_Location_ID] [INT] NOT NULL     CONSTRAINT FK_PowerPlan_AssetLocation_MajorLocation_MajorLocationID
                                            FOREIGN KEY (Major_Location_ID)
                                            REFERENCES PowerPlan.Major_Location(Major_Location_ID)
    ,[Minor_Location_ID2] [INT] NULL
    ,[Line_Number_ID] [INT] NULL
    ,[Ext_Asset_Location] [varchar](35) NULL
    ,[Asset_Location] [varchar](254) NULL
    ,[Status_Code_ID] [INT] NOT NULL        CONSTRAINT DK_PowerPlan_AssetLocation_StatusCodeID  DEFAULT 0
    ,[GRID_COORDINATE] [varchar](35) NULL
    ,[Prop_Tax_Location_ID] [INT] NULL
    ,[Address] [VARCHAR](254) NULL
    ,[ZIP_Code] [int] NULL
    ,[Town_ID] [INT] NULL
    ,[County_ID] [varchar](18) NULL
    ,[State_ID] [varchar](18) NULL
    ,[Charge_Location_ID] [int] NULL
    ,[Grid_Coordinate1] [VARCHAR](35) NULL
    ,[Grid_Coordinate2] [VARCHAR](35) NULL
    ,[Repair_Location_ID] [INT] NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_AssetLocation_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_AssetLocation_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_AssetLocation_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_AssetLocation_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_AssetLocation_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(sl*)  [01] [07] [09] [12] The Asset Location data table records the detailed locations used in the recording of assets on the CPR Ledger.  Asset locations exist as combinations of major locations, minor locations, line/unit numbers, and property tax districts.  The asset location description is automatically generated to uniquely describe this combination.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Asset_Location';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'System-assigned identifier of a particular asset location.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Asset_Location', 
    @level2type=N'COLUMN', @level2name=N'Asset_Location_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Standard system-assigned timestamp for audit purposes', 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Asset_Location', 
    @level2type=N'COLUMN', @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Standard system-assigned user id used for audit purposes' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Asset_Location', 
    @level2type=N'COLUMN', @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(fk) System-assigned identifier for the locations that may be used to distinguish Federal income tax classes in PowerTax.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Asset_Location', 
    @level2type=N'COLUMN', @level2name=N'Tax_Location_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(fk) System-assigned identifier of a particular minor location.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Asset_Location', 
    @level2type=N'COLUMN', @level2name=N'Minor_Location_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'System-assigned identifier of a particular property tax district.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Asset_Location', 
    @level2type=N'COLUMN', @level2name=N'Tax_District_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(fk) System-assigned identifier of a unique major location' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Asset_Location', 
    @level2type=N'COLUMN', @level2name=N'Major_Location_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(fk) System-assigned identifier for a particular transmission line number or generating unit number.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Asset_Location', 
    @level2type=N'COLUMN', @level2name=N'Line_Number_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'May be used as an externally generated location number usually derived from the utilitys exisiting system.  In some cases, these external numbers are required to allow cross-referencing between existing systems and PowerPlan.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Asset_Location', 
    @level2type=N'COLUMN', @level2name=N'Ext_Asset_Location';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(long_description) Records an optional detailed description of the entity.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Asset_Location', 
    @level2type=N'COLUMN', @level2name=N'Asset_Location';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(fk) Identifies a status: 1=Active; 2=Inactive' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Asset_Location', 
    @level2type=N'COLUMN', @level2name=N'Status_Code_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Former grid coordinates.  Now a user field, which is available in the asset location window.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Asset_Location', 
    @level2type=N'COLUMN', @level2name=N'Grid_Coordinate';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(fk) The second minor location can be used if the asset uses a to/from concept; for example, for lines.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Asset_Location', 
    @level2type=N'COLUMN', @level2name=N'Minor_Location_ID2';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(fk) System-assigned identifier of a property tax location (locations that are to be retained on the property tax ledger in addition to tax district, county, and state).' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Asset_Location', 
    @level2type=N'COLUMN', @level2name=N'Prop_Tax_Location_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Maintains the street address of the asset location.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Asset_Location', 
    @level2type=N'COLUMN', @level2name=N'Address';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Records the mailing zip code of the asset location.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Asset_Location', 
    @level2type=N'COLUMN', @level2name=N'ZIP_Code';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(fk) System-assigned identifier to a town or municipality.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Asset_Location', 
    @level2type=N'COLUMN', @level2name=N'Town_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(fk) Records the name of the county/parish of the asset location.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Asset_Location', 
    @level2type=N'COLUMN', @level2name=N'County_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(fk) Records the name of the state within a given country.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Asset_Location', 
    @level2type=N'COLUMN', @level2name=N'State_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(fk) Sytsem identifier of a charge location.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Asset_Location', 
    @level2type=N'COLUMN', @level2name=N'Charge_Location_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Optional x-coordinate of the asset location.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Asset_Location', 
    @level2type=N'COLUMN', @level2name=N'Grid_Coordinate1';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Optional y-coordinate of the asset location.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Asset_Location', 
    @level2type=N'COLUMN', @level2name=N'Grid_Coordinate2';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(fk) References a tax repair location for aggregate tests for PRA and network assets.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Asset_Location', 
    @level2type=N'COLUMN', @level2name=N'Repair_Location_ID';
GO

PRINT '-- PowerPlan.Depr_Group';
CREATE TABLE PowerPlan.Depr_Group
(
    [Depr_Group_ID] [INT] PRIMARY KEY
    ,[Depr_Summary2_ID] [INT] NULL          CONSTRAINT FK_PowerPlan_DeprGroup_DeprSummary2_DeprSummary2ID
                                            FOREIGN KEY (Depr_Summary2_ID)
                                            REFERENCES PowerPlan.Depr_Summary2(Depr_Summary2_ID)
    ,[Subledger_Type_ID] [INT] NOT NULL
    ,[Depr_Summary_ID] [INT] NULL           CONSTRAINT FK_PowerPlan_DeprGroup_DeprSummary_DeprSummaryID
                                            FOREIGN KEY (Depr_Summary_ID)
                                            REFERENCES PowerPlan.Depr_Summary(Depr_Summary_ID)
    ,[Company_ID] [INT] NULL
    ,[Depr_Method_ID] [INT] NULL            CONSTRAINT FK_PowerPlan_DeprGroup_DepreciationMethod_DeprMethodID
                                            FOREIGN KEY (Depr_Method_ID)
                                            REFERENCES PowerPlan.Depreciation_Method(Depr_Method_ID)
    ,[Reserve_Acct_ID] [INT] NOT NULL
    ,[Expense_Acct_ID] [INT] NOT NULL
    ,[Time_Stamp] datetime2 NULL
    ,[Depr_Group] [nvarchar](35) NOT NULL
    ,[Factor_ID] [INT] NULL
    ,[User_ID] varchar(18) NULL
    ,[Mid_Period_Conv] DECIMAL(22,8) NOT NULL
    ,[Mid_Period_Method] [nvarchar](35) NOT NULL CONSTRAINT FK_PowerPlan_DeprGroup_DeprMidPeriodMethod_MidPeriodMethod 
                                                 FOREIGN KEY (Mid_Period_Method)
                                                 REFERENCES PowerPlan.Depr_Mid_Period_Method(Mid_Period_Method)
    ,[Est_Ann_Net_Adds] DECIMAL(22,8) NULL
    ,[Gain_Acct_ID] [INT] NOT NULL
    ,[Loss_Acct_ID] [INT] NOT NULL
    ,[COR_Treatment] [VARCHAR](5) NULL
    ,[Salvage_Treatment] [VARCHAR](5) NULL
    ,[Net_Salvage_Amort_Life] [INT] NULL
    ,[Gain_Loss_Default] [INT] NULL
    ,[Combined_Depr_Group_ID] [INT] NULL
    ,[Status_ID] [INT] NULL                 CONSTRAINT DK_PowerPlan_DeprGroup_StatusID  DEFAULT 1
    ,[Bus_Segment_ID] [INT] NULL            CONSTRAINT FK_PowerPlan_DeprGroup_BusinessSegment_BusinessSegmentID
                                            FOREIGN KEY (Bus_Segment_ID)
                                            REFERENCES PowerPlan.Business_Segment(Bus_Segment_ID)
    ,[Func_Class_ID] [INT] NULL             CONSTRAINT FK_PowerPlan_DeprGroup_FuncClass_FuncClassID
                                            FOREIGN KEY (Func_Class_ID)
                                            REFERENCES PowerPlan.Func_Class(Func_Class_ID)
    ,[COR_Reserve_Acct_ID] [INT] NOT NULL
    ,[COR_Expense_Acct_ID] [INT] NOT NULL
    ,[True_Up_CPR_Depr] [int] NULL
    ,[External_Depr_Code] [NVARCHAR](254) NULL
    ,[ARO_ID] [INT] NULL
    ,[Salvage_Reserve_Acct_ID] [INT] NOT NULL
    ,[Salvage_Expense_Acct_ID] [INT] NOT NULL
    ,[JE_by_Asset] [INT] NULL               CONSTRAINT DK_PowerPlan_DeprGroup_JEbyAsset   DEFAULT 0
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_DeprGroup_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_DeprGroup_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_DeprGroup_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_DeprGroup_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_DeprGroup_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(O) [01][05] The Depreciation Group data table maintains a list of all depreciation groups a utility uses for the purposes of calcualting depreciation and maintaining the Depreciation Reserve.  Depreciation groups are set up by the user to maintain reserves at the level desired.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Depr_Group';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) System-assigned identifier of a particular depreciation group.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Group',
    @level2type=N'COLUMN',  @level2name=N'Depr_Group_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) Depr summary id is the unique System-assigned identifier of a particular depreciation reporting level.  (See also depr_summary_id and functional_class_id on this same table).  It references the depreciation reporting summary established on the Depr_summary2 table, maintained through standard table maintenance.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Group',
    @level2type=N'COLUMN',  @level2name=N'Depr_Summary2_ID';
GO

EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a particular sub-ledger when applicable to depreciable sub ledgers, lease, CPR depr, and ARO.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Group',
    @level2type=N'COLUMN',  @level2name=N'Subledger_Type_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned idnetifier of a particular depreciation reporting summary level.  It references the user depreciation reporting summary established on the Depr Summary table, maintained through standard table maintenance.  See also depr_summary2_id and functional_class_id on this table.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Group',
    @level2type=N'COLUMN',  @level2name=N'Depr_Summary_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) Sytsem-assigned identifier of a particular company.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Group',
    @level2type=N'COLUMN',  @level2name=N'Company_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a particular depreciation method.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Group',
    @level2type=N'COLUMN',  @level2name=N'Depr_Method_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a unique Genreal Ledger account for posting transactions to the reserve (e.g., 108).  (Note: Salvage and COR can have their own GL accounts.)',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Group',
    @level2type=N'COLUMN',  @level2name=N'Reserve_Acct_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a unique General Ledger account for posting depreciation expense (e.g., 403, 405).  (Note: Salvage and COR can have their own GL accounts.)',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Group',
    @level2type=N'COLUMN',  @level2name=N'Expense_Acct_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Group',
    @level2type=N'COLUMN',  @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(description) Name identifier of the depreciation group to be used by the user.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Group',
    @level2type=N'COLUMN',  @level2name=N'Depr_Group';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) Reference to the monthly spread factors to spread estimated annual depreciation; used when the mid_period_method is curve.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Group',
    @level2type=N'COLUMN',  @level2name=N'Factor_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned user ID used for audit purposes.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Group',
    @level2type=N'COLUMN',  @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'The mid-period convention controls how curren tyear activity impacts the depreciable base.  It works in coordination with the mid_period_method.  It weights the impact of activity on the depreciable base.  For example, if the mid_period_method is MONTHLY, a 0 would mean that activity does not impact the current month depreciable balance; a 0.5 would mean that an average monthly balance would be used.  If the factor were 1, the ending balance for the monthly would be used.  For the YEARLY convention, a 0.5 means a half-year convention is used in the month of the addition.  For CURVE it weights the annual estimated or actual (December) activity.  For CURVE (NO TRUE-UP), it weights the annual estimated activity.  For END DATE, it weights the monthly activity.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Group',
    @level2type=N'COLUMN',  @level2name=N'Mid_Period_Conv';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) The mid-period method defines the depreciable balance methodology.  For depreciation done at the group level, activity impacting the depreciable base can be recognized several ways: YEARLY means that a half-year convention is recognized in the current month only.  The beginning point for the depreciable base is the beginning balance at the start of the year.  MONTHLY means a half-month convention is recognized in the current month only.  The beginning point for the depreciable base is the prior months ending balance.  CURVE means that a half-year convention is recognized over the year based on estimated net additions.  The beginning point for the depreciable base is the balance at the start of the year.  CURVE (NO TRUE-UP) is the same as CURVE (except that there is no substitute of actual net additions for estimate net additions in December).  END OF LIFE means that depreciation is calculated on a net basis over the remaining months, using the end date given in the Depr Mehtod Rates table.  RATE OF END OF LIFE means that depreciation is calculated on the net basis using the input rate.  The End of Life value is used for rate recalculation and reserve allocation.  UNIT OF PROD means that the ratio of monthly units of production to remaining units of production will be applied...{more}',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Group',
    @level2type=N'COLUMN',  @level2name=N'Mid_Period_Method';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'The net estimated annual additions to the depreciation group in dollars.  Needed only i fthe curve method is being used.  Can be updated during the year, th eimpact of the update will be spread to the remaining months.  In December, the estimate is automatically replaced with actual.  Note that this variable does not have associated time; it is for the year in which the last month for which depreciation has not been approved falls.  It can be updated in December before December depreciation is calculated.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Group',
    @level2type=N'COLUMN',  @level2name=N'Est_Ann_Net_Adds';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a unique General Ledger account for posting gains from disposition (e.g., 411.6, 421.1, etc).',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Group',
    @level2type=N'COLUMN',  @level2name=N'Gain_Acct_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a unique General Ledger account for posting a loss from disposition (e.g., 411.7, 421.2).',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Group',
    @level2type=N'COLUMN',  @level2name=N'Loss_Acct_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Not used - see Depr Method Rates.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Group',
    @level2type=N'COLUMN',  @level2name=N'COR_Treatment';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Not Used - see Depr Method Rates.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Group',
    @level2type=N'COLUMN',  @level2name=N'Salvage_Treatment';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Not Used - see Depr Method Rates',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Group',
    @level2type=N'COLUMN',  @level2name=N'Net_Salvage_Amort_Life';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'No longer used - moved to the Depr Method Rates table which is by set of books and depr group.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Group',
    @level2type=N'COLUMN',  @level2name=N'Gain_Loss_Default';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a combined depreciation group.  Combined groups can be used when applying a depreciation rate at a lower level of detail than was used in determining the rate.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Group',
    @level2type=N'COLUMN',  @level2name=N'Combined_Depr_Group_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'1 is valid; 0 is invalid.  The default is valid.  An invalid depreciation group will not allow new dollars to be added to the depreciation group.  It can also be used for dummy groups used for convenience iwth the parent/child depreciation tree structure.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Group',
    @level2type=N'COLUMN',  @level2name=N'Status_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of the business segment associated with this group.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Group',
    @level2type=N'COLUMN',  @level2name=N'Bus_Segment_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of functional class, used for depreciation reporting.  (See also depr_summary_id and depr_summary2_id on this same table.)',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Group',
    @level2type=N'COLUMN',  @level2name=N'Func_Class_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) Sytsem-assigned identifier of the general ledger account which maintains the reserve associated with cost of removal.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Group',
    @level2type=N'COLUMN',  @level2name=N'COR_Reserve_Acct_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) Sytsem-assigned identifier of the general ledger account that is posted for the cost of removal expense provision.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Group',
    @level2type=N'COLUMN',  @level2name=N'COR_Expense_Acct_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'For CPR depreciation (i.e. individual asset), this indicates how late in service, late charges, changes in life should be treated: 0 = No trupe up (the initial add starts depreciation over the stated life whenever it occurs no matter what the in-service date is.  Subsequent changes are always amortized over the remaining life - this option is not appropriate if using 106; 1=Cumulative true up.  The reserve is trued up tot the theoretical every month through the depreciation calculation.  This accomodates late-in-service reporting, late charges (taking back changes in initial or remaining life to initial in-service for the true-up).  2 = Convention weight. The initial addition is true dup with depreciation back to the in-service month.  Later activity gets convention weight in month of activity but no true-up.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Group',
    @level2type=N'COLUMN',  @level2name=N'True_Up_CPR_Depr';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Additional external reference for making journal entries or for connecting to external systems.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Group',
    @level2type=N'COLUMN',  @level2name=N'External_Depr_Code';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of an ARO to which all the assets of the group are associated.  This facilitates reporting of all regulatory assets and liabilities for an ARO.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Group',
    @level2type=N'COLUMN',  @level2name=N'ARO_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of the general ledger account which maintains the reserve associated with salvage.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Group',
    @level2type=N'COLUMN',  @level2name=N'Salvage_Reserve_Acct_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of the general ledger account which is posted for the salvage provision.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Group',
    @level2type=N'COLUMN',  @level2name=N'Salvage_Expense_Acct_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Allows depr expense journal entries to be made by asset; 1=yes, 0=no (default)',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Depr_Group',
    @level2type=N'COLUMN',  @level2name=N'JE_by_Asset';
GO

PRINT '-- PowerPlan.Depr_Method_Rates';
CREATE TABLE PowerPlan.Depr_Method_Rates
(
    [Company_ID] [int] NOT NULL                 CONSTRAINT DK_PowerPlan_DeprMethodRates_CompanyID       DEFAULT 2100
    ,[Depr_Method_Id] [int] NOT NULL            CONSTRAINT FK_PowerPlan_DeprMethodRates_DeprMethodID 
                                                FOREIGN KEY (Depr_Method_ID)
                                                REFERENCES PowerPlan.Depreciation_Method(Depr_Method_ID)
    ,[Set_of_Books_ID] [int] NOT NULL           CONSTRAINT DK_PowerPlan_DeprMethodRates_SetOfBooksID    DEFAULT 1
    ,[Effective_Date] datetime2 NOT NULL
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Rate] DECIMAL(22,8) NOT NULL              CONSTRAINT DK_PowerPlan_DeprMethodRates_Rate            DEFAULT 0
    ,[Net_Gross] [int] NULL
    ,[Over_Depr_Check] [int] NULL
    ,[Net_Salvage_Pct] DECIMAL(22,8) NOT NULL   CONSTRAINT DK_PowerPlan_DeprMethodRates_NetSalvagePct   DEFAULT 0
    ,[Rate_Used_Code] [int] NULL
    ,[End_Of_Life] [int] NULL
    ,[Mortality_Curve_ID] [int] NULL            CONSTRAINT FK_PowerPlan_DeprMethodRates_MortalityCurveID
                                                FOREIGN KEY (Mortality_Curve_ID)
                                                REFERENCES PowerPlan.Mortality_Curve(Mortality_Curve_ID)
    ,[Expected_Average_Life] DECIMAL(22,8) NULL
    ,[Reserve_Ratio_ID] [int] NULL
    ,[Cost_of_Removal_Rate] DECIMAL(22,8) NOT NULL  CONSTRAINT DK_PowerPlan_DeprMethodRates_CostOfRemovalRate   DEFAULT 0
    ,[Cost_of_Removal_Pct] DECIMAL(22,8) NOT NULL   CONSTRAINT DK_PowerPlan_DeprMethodRates_CostOfRemovalPct    DEFAULT 0
    ,[DR_Comment_ID] [int] NULL
    ,[Salvage_Rate] DECIMAL(22,8) NOT NULL  CONSTRAINT DK_PowerPlan_DeprMethodRates_SalvageRate   DEFAULT 0
    ,[Interest_Rate] DECIMAL(22,8) NOT NULL  CONSTRAINT DK_PowerPlan_DeprMethodRates_InterestRate   DEFAULT 0
    ,[Amortizable_Life] [int] NULL
    ,[COR_Treatment] [nvarchar](5) NULL
    ,[Salvage_Treatment] [nvarchar](5) NULL
    ,[Net_Salvage_Amort_Life] [int] NULL
    ,[Mort_Mem_Mort_Curve_ID] [int] NULL
    ,[Mass_Expected_Life] DECIMAL(22,8) NULL
    ,[Allocation_Procedure] [nvarchar](5) NULL
    ,[Gain_Loss_Default] [int] NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_DeprMethodRates_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_DeprMethodRates_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_DeprMethodRates_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_DeprMethodRates_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_DeprMethodRates_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
    ,CONSTRAINT PK_PowerPlan_DeprMethodRates PRIMARY KEY (Depr_Method_ID, Set_of_Books_ID, Effective_Date)
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(O) [01] This table can also be maintained through the Depreciation Group Rate Maintenance window. The Depr Mehtod Rates data table records the multiple rates that a user may define for a depreciation group based on their sets of books.  For example, the depreciation rates a user employs in the BOOK set of books and the GAAP set of books could be different.  Multiple depreciation groups can use the same Depr Method Rate.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Depr_Method_Rates';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(PK)(fk) System-assigned identifier of a particular depreciation method.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Depr_Method_Rates', 
    @level2type=N'COLUMN', @level2name=N'Depr_Method_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(PK)(fk) System-assigned identifier of a unique set of books maintained by the utility in PowerPlan.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Depr_Method_Rates', 
    @level2type=N'COLUMN', @level2name=N'Set_of_Books_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(PK) First accounting month and year when the rate becomes effective.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Depr_Method_Rates', 
    @level2type=N'COLUMN', @level2name=N'Effective_Date';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Standard system-assigned timestamp used for audit purposes.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Depr_Method_Rates', 
    @level2type=N'COLUMN', @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Standard system-assigned user id used for audit purposes.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Depr_Method_Rates', 
    @level2type=N'COLUMN', @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Records the actual depreciation rate to be used in the calculation of depreciation expense.  The rate is an annual rate entered as a decimal.  Note that if cost of removal is broken out in a separate reserve with its own rate in Cost_of_Removal_Rate below, this rate should exlude the cost of removal rate.  Default is 0.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Depr_Method_Rates', 
    @level2type=N'COLUMN', @level2name=N'Rate';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Indicator with values GROSS=2 or NET=1 indicating whether the rate should be applied to a gross balance or at net (of the reserve) balance.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Depr_Method_Rates', 
    @level2type=N'COLUMN', @level2name=N'Net_Gross';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Controls if and how each depreciation group is checked for over-depreciation condition.  For depreciation group sthat are part of a combined depreciation group it is required that they all have the same over-depreciation check settings.  If not, an error will result in the combined group calcualtion and the member groups will be individually checked, as if they are not part of a combined group.  Over-Depreciation Check options are: NO=0: No over-depreciation check is done for either life reserve or COR Reserve; YES/Separate=1: The life reserve an COR reserve are checked as separate balances for over-depreciation condition.  If either fails the check then up to the current month calculated expense will be reversed.  The limit for life reserve is pplant balance x (1 - net salvage %).  The limit for COR reserve is plant balance x COR %.  This is teh default and pre-vision 10 treatment when over-depreciation check = YES.  YES/LIFE ONLY=2: The life rserve is checked alone for over-depreciation conditoin.  If it fails, up to the current month calculated life expense will be reversed.  No check is done on the COR reserve balance and no adjustment made for calcualted COR expense.  The limit for life reserve is plant balance x (1 - net salvage %).  YES/TOTAL=3: The total reserve, life reserve plus COR reseve, is checked for over-depreciation condition.  If it fails, up to the current month claculated expense, life expense plus COF expense, will be reversed.  The amount reversed will be prorated ove rthe original life and COR calcualted expense.  Th elimit for total reserve is plant balance x (1 - net salvage % + COR %).' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Depr_Method_Rates', 
    @level2type=N'COLUMN', @level2name=N'Over_Depr_Check';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'The annual cost of removal depreciation rate entered as a percent.  If entered the system can maintain a COR balance in the reserve.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Depr_Method_Rates', 
    @level2type=N'COLUMN', @level2name=N'Cost_of_Removal_Rate';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'The annual salvage depreciation rate entered as a percent.  If not required to be separate for calculation or journal entry purposes this may be part of the Life Rate.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Depr_Method_Rates', 
    @level2type=N'COLUMN', @level2name=N'Salvage_Rate';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'User-input percentage used i nconjunction with an over depr check = YES.  The rate can be plus (salvage exceeds cost of removal) or minus and is entered as a decimal.  Only in the case of END DAT remaining life depreciation or monthly net the depreciabile balance is also decreased (increased) by this percent.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Depr_Method_Rates', 
    @level2type=N'COLUMN', @level2name=N'Net_Salvage_Pct';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'RECALC on a rate with an effective past date will calculate a depreciation adjustment for that and all subsequent months and post it in the current period.  Note that a recalcalution cannot b emade if there is an effective date entered for that method after the desired recalculation month.  USED means the rate has been used in an apporve dmonth and cannot b erecalcualted.  The USED status is set by the system.  NO RECALC is the normal input for a new rate.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Depr_Method_Rates', 
    @level2type=N'COLUMN', @level2name=N'Rate_Used_Code';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Year and month (yyyymm) for END DATE depreciation.  Depreciation is calcualted on a monthly remaining life against a net basis up to this input month.  This will override any mid-period method on the Depreciation Group Table.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Depr_Method_Rates', 
    @level2type=N'COLUMN', @level2name=N'End_of_Life';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'System-assigned identifier of a mortality (e.g. Iowa) curve associated with the depreciation group.  (This is used for theoretical reserve allocaiton.)' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Depr_Method_Rates', 
    @level2type=N'COLUMN', @level2name=N'Mortality_Curve_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Records the average expected life in years fo the depreciation group (or combination group) from a life study.  (With the mortality curve it is used for theoretical reserve allocaiton.)' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Depr_Method_Rates', 
    @level2type=N'COLUMN', @level2name=N'Expected_Average_Life';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Records the reference to reserve rates table.  It is internally maintained.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Depr_Method_Rates', 
    @level2type=N'COLUMN', @level2name=N'Reserve_Ratio_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'User-input percentage used in conjunction with an over depreciation check when using a separate cost of removal reserve . Expressed as a positive decimal, i.e., this is the percentage that determine sthe total recoverable amount.  (1 + cost_of_removal_pct) (Gross Plant Balance).  Default is 0.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Depr_Method_Rates', 
    @level2type=N'COLUMN', @level2name=N'Cost_of_Removal_Pct';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(fk) System-assigned identifier of a depreciation rates comment id.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Depr_Method_Rates', 
    @level2type=N'COLUMN', @level2name=N'DR_Comment_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'User-input rate used in conjunction with SINKING FUND YEARLY mid-period method, otherwise ignored.  The Interest Rate is multiplied by the beginning of year reserve balance and added ot the traditional expense calcualtion of Depreciation Base * Rate to calculate total monthly depreciaiton provision.  Expressed as a decimal.  Default is 0.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Depr_Method_Rates', 
    @level2type=N'COLUMN', @level2name=N'Interest_Rate';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'For automatic retirements (e.g. amortizable general plant) using the depreciation group otpion this is life in months.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Depr_Method_Rates', 
    @level2type=N'COLUMN', @level2name=N'Amortizable_Life';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'NO is normal - cos tof removal is provided in the depreciation rate over the asset life.  ANNUAL indicates that actual cost of removal is amoritzed over the number of months provided (net_salvage_amort_life below), starting the next January.  MONTHLY indicates that the cost of removal is amortized over the number of months provided beginning in the current month.  Thus 1 month with a monthly option will expense cost of removal in the current month.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Depr_Method_Rates', 
    @level2type=N'COLUMN', @level2name=N'COR_Treatment';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'NO is normal - salvage is provided in the depreciation rate (or reduced base) or an estimated basis over the asset life.  ANNUAL indicates that actual salvage is amorized over the number of months provided (net_salvage_amort_life below), starting the next January.  MONTHLY indicates that the salvage is amortized over the number of months provided beginning in the current month.  Thus 1 month with a monthly option will expense salvage in the current month.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Depr_Method_Rates', 
    @level2type=N'COLUMN', @level2name=N'Salvage_Treatment';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'If salvage proceds or actual cost of removal is amortized apart from the life depreciation provision (see cor_treatment and salvage_treatment above), this is the amortizable life in months.  Note that for the annual option th elife starts in January of the following year.  For the monthly option, the life starts in the current month; thus a life of 1 can expense cost of removal or salvage.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Depr_Method_Rates', 
    @level2type=N'COLUMN', @level2name=N'Net_Salvage_Amort_Life';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(fk) Records the mortality curve used to process retirements (to build mortality memory) if the pp_system control MORTALITY CURVE ACCOUNT LOOKUP option is DEPR METHOD.  If that option is selected and this field is blank, the sytsem will use the mortal_curve_id on this table.  By allowing two curves, and to lives, one can be dollar based, the other quantity based.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Depr_Method_Rates', 
    @level2type=N'COLUMN', @level2name=N'Mort_Mem_Mort_Curve_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Records the average expected life in years . With the mort_mem_mort_curve above it is used to process retirements.  Similar to mort_mem_mort_curve above, if blank, it will default to average_expected_life.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Depr_Method_Rates', 
    @level2type=N'COLUMN', @level2name=N'Mass_Expected_Life';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'BROAD - broadgroup or ELG - equal life group.  The theoretical procedure to be used in the reserve allocation.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Depr_Method_Rates', 
    @level2type=N'COLUMN', @level2name=N'Allocation_Procedure';
GO

PRINT '-- PowerPlan.Mortality_Curve_Points';
CREATE TABLE PowerPlan.Mortality_Curve_Points
(
    [Data_Point] DECIMAL(22,8) NOT NULL
    ,[Mortality_Curve_ID] [int] NOT NULL    CONSTRAINT FK_PowerPlan_MortalityCurvePoints_MortalityCurve_MortalityCurveID 
                                            FOREIGN KEY (Mortality_Curve_ID)
                                            REFERENCES PowerPlan.Mortality_Curve(Mortality_Curve_ID)
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Age_Per_Exp_Life] DECIMAL(22,8) NOT NULL
    ,[Rem_Life_Percentage] DECIMAL(22,8) NOT NULL
    ,[Surviving_Percentage] DECIMAL(22,8) NOT NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_MortalityCurvePoints_CreatedBy      DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_MortalityCurvePoints_CreatedDate    DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_MortalityCurvePoints_rowguid    DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL  CONSTRAINT DK_PowerPlan_MortalityCurvePoints_ValidFrom  DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL    CONSTRAINT DK_PowerPlan_MortalityCurvePoints_ValidTo    DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
    ,CONSTRAINT PK_PowerPlan_MortalityCurvePoints PRIMARY KEY(Data_Point,Mortality_Curve_ID)
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(S) [01][05][11][12] The Mortality Curve Points data table records the data points associated with a particular Mortality or dispersion curve.  The Iowa curves are specified in terms of 1% of average life, the hundredth data point representing the percentage surviving at the average expected life.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Mortality_Curve_Points';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(PK) User-designated data point on the Iowa curve.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Mortality_Curve_Points', 
    @level2type=N'COLUMN', @level2name=N'Data_Point';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(PK)(fk) System-assigned identifier of a unique mortality curve.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Mortality_Curve_Points', 
    @level2type=N'COLUMN', @level2name=N'Mortality_Curve_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Standard System-assigned timestamp used for audit purposes.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Mortality_Curve_Points', 
    @level2type=N'COLUMN', @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Standard System-assigned user id used for audit purposes.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Mortality_Curve_Points', 
    @level2type=N'COLUMN', @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Age per exp life records the expected life in terms of average expected life associated with a particular data point.  (If zero, assumed to be 1% of expected life per point.)' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Mortality_Curve_Points', 
    @level2type=N'COLUMN', @level2name=N'Age_Per_Exp_Life';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Records the remaining life rate associated with a particular data point.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Mortality_Curve_Points', 
    @level2type=N'COLUMN', @level2name=N'Rem_Life_Percentage';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Surviving percentage records the surviving percentage rate associated with a particular data point.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Mortality_Curve_Points', 
    @level2type=N'COLUMN', @level2name=N'Surviving_Percentage';
GO

PRINT '-- PowerPlan.Property_Unit';
CREATE TABLE PowerPlan.Property_Unit
(
    [Property_Unit_ID] [int] NOT NULL PRIMARY KEY
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Asset_Acct_Meth_ID] [int] NOT NULL    CONSTRAINT FK_PowerPlan_PropertyUnit_AssetAcctMethID
                                            FOREIGN KEY (Asset_Acct_Meth_ID)
                                            REFERENCES PowerPlan.Asset_Acct_Method(Asset_Acct_Meth_ID)
    ,[Retire_Method_ID] [int] NOT NULL      CONSTRAINT FK_PowerPlan_PropertyUnit_RetireMethod_RetireMethodID
                                            FOREIGN KEY (Retire_Method_ID)
                                            REFERENCES PowerPlan.Retire_Method(Retire_Method_ID)
    ,[Unit_of_Measure_ID] [int] NOT NULL    CONSTRAINT FK_PowerPlan_PropertyUnit_UnitOfMeasure_UnitOfMeasureID
                                            FOREIGN KEY (Unit_of_Measure_ID)
                                            REFERENCES PowerPlan.Unit_of_Measure(Unit_of_Measure_ID)
    ,[Subledger_Type_ID] [int] NOT NULL
    ,[External_Prop_Unit] [nvarchar](35) NULL
    ,[Default_Life] [int] NULL
    ,[Property_Tax_Indicator] [int] NULL
    ,[PreCapitalized_Indicator] [int] NULL
    ,[Property_Unit] NVARCHAR(35) NULL
    ,[Long_Description] NVARCHAR(MAX) NULL
    ,[Acct_Instruct] [nvarchar](MAX) NULL
    ,[Status_Code_ID] [int] NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_PropertyUnit_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_PropertyUnit_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_PropertyUnit_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_PropertyUnit_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_PropertyUnit_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(sp*)  [01] [12] The Property Unit data table maintains a list of all property units used by the utility in recording assets on the CPR Ledger.  This list can include those property units required by FERC as well as those that are unique to the utility.  Property units can be broken down by type size specifications into retirement units.  It is the retirement unit that is actually maintained on the CPR.  Accounting and process information is maintained at the property unit level.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Property_Unit';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(PK) System-assigned identifier of a particular property unit.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Property_Unit', 
    @level2type=N'COLUMN', @level2name=N'Property_Unit_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Standard system-assigned teimstamp used for audit purposes.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Property_Unit', 
    @level2type=N'COLUMN', @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Standard System-assigned user id used for audit purposes.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Property_Unit', 
    @level2type=N'COLUMN', @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(fk) System-assigned identifier of a particular asset accounting method.  There are two methods defined within the sytsem mass and specific.  MASS is where an asset can be included with other like assets (same location, account, vintage, and retirement unit) and be subsequently priced at average cost.  SPECIFIC is for an asset which forms an individual record on the CPR.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Property_Unit', 
    @level2type=N'COLUMN', @level2name=N'Asset_Acct_Meth_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(fk) System-assigned identifier of a particular retirement method, (e.g. specific, fifo, retire curve, life auto, etc.)  See the Retirement Method Table.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Property_Unit', 
    @level2type=N'COLUMN', @level2name=N'Retire_Method_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(fk) System-assigned identifier of a particular unit of measure, such as EACH, FEET, etc.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Property_Unit', 
    @level2type=N'COLUMN', @level2name=N'Unit_of_Measure_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(fk) System-assigned identifier of a particular Subledger if this property unit is tracked on a Subledger.  Reference NONE if none.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Property_Unit', 
    @level2type=N'COLUMN', @level2name=N'Subledger_Type_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Externally generated property unit number usually derived from the utilitys existing property unit catalog.  In some cases these external numbers are required to allow cross-referencing between existing systems and PowerPlan.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Property_Unit', 
    @level2type=N'COLUMN', @level2name=N'External_Prop_Unit';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Records the estimated depreciable life in months of the property unit.  This default can be used for a depreciable Subledger or the CPR depreciation.  In the Subledger or CPR depreciation, it is used for an amortization or depreciable life.  It is also used for the life in life auto retirements.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Property_Unit', 
    @level2type=N'COLUMN', @level2name=N'Default_Life';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Not used.  See Property Tax Type Data and Property Tax Type Asisgn.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Property_Unit', 
    @level2type=N'COLUMN', @level2name=N'Property_Tax_Indicator';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Not used.  See overhead method.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Property_Unit', 
    @level2type=N'COLUMN', @level2name=N'PreCapitalized_Indicator';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'(description) Records a short description of the property unit.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Property_Unit', 
    @level2type=N'COLUMN', @level2name=N'Property_Unit';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Records an optional detailed description of the property unit.  (There is also an accounting instruction.)' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Property_Unit', 
    @level2type=N'COLUMN', @level2name=N'Long_Description';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Records specific accounting instructions as they relate to teh property unit and the given utiltiy account.  They may include capitalization rules, what costs are included, what costs are excluded and references to other property units.' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Property_Unit', 
    @level2type=N'COLUMN', @level2name=N'Acct_Instruct';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'none' , 
    @level0type=N'SCHEMA', @level0name=N'PowerPlan', 
    @level1type=N'TABLE',  @level1name=N'Property_Unit', 
    @level2type=N'COLUMN', @level2name=N'Status_Code_ID';
GO

PRINT '-- PowerPlan.Utility_Account';
CREATE TABLE PowerPlan.Utility_Account
(
    [Utility_Account_ID] [int] NOT NULL
    ,[Bus_Segment_ID] [int] NOT NULL        CONSTRAINT FK_PowerPlan_UtilityAccount_BusSegment_BusSegmentID
                                            FOREIGN KEY (Bus_Segment_ID)
                                            REFERENCES PowerPlan.Business_Segment(Bus_Segment_ID)
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Mortality_Curve_ID] [int] NULL        CONSTRAINT FK_PowerPlan_UtilityAccount_MortalityCurve_MortalityCurveID
                                            FOREIGN KEY (Mortality_Curve_ID)
                                            REFERENCES PowerPlan.Mortality_Curve(Mortality_Curve_ID)
    ,[HW_Table_ID] [varchar](8) NULL
    ,[HW_Line_No] [int] NULL
    ,[FERC_Plt_Acct_ID] [int] NULL          CONSTRAINT FK_PowerPlan_UtilityAccount_FERCPlantAccount_FERCPltAcctID
                                            FOREIGN KEY (FERC_Plt_Acct_ID)
                                            REFERENCES PowerPlan.FERC_Plant_Account(FERC_Plt_Acct_ID)
    ,[Func_Class_ID] [int] NOT NULL         CONSTRAINT FK_PowerPlan_UtilityAccount_FuncClass_FuncClassID
                                            FOREIGN KEY (Func_Class_ID)
                                            REFERENCES PowerPlan.Func_Class(Func_Class_ID)
    ,[Utility_Account] [varchar](35) NOT NULL
    ,[Long_Description] [varchar](MAX) NULL
    ,[Status_Code_ID] [int] NOT NULL
    ,[External_Account_Code] [varchar](35) NULL
    ,[Expected_Life] [int] NULL
    ,[HW_Table_Line_ID] [int] NULL
    ,[CCNC_Quantity] [int] NULL             CONSTRAINT DK_PowerPlant_UtilityAccount_CCNCQuantity    DEFAULT (0)
    ,[OVH_to_UDG] [int] NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_UtilityAccount_CreatedBy       DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_UtilityAccount_CreatedDate     DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL CONSTRAINT DK_PowerPlan_UtilityAccount_rowguid   DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_UtilityAccount_ValidFrom       DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_UtilityAccount_ValidTo         DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
    ,CONSTRAINT PK_PowerPlan_UtilityAccount PRIMARY KEY(Utility_Account_ID, Bus_Segment_ID)
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(sa*)  [09] [11] The Utility Account data table maintains those plant accounts used by the company to record assets on the CPR Ledger and optionally on the Depreciation Ledger.  For FERC-regulated utilities, these could be the FERC-defined plant accounts.  The company need not use the FERC plant accounts and their numbering scheme, but it must relate them to the FERC (NARUC, STB, etc.) plant accounts for reporting and summarization.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Utility_Account';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'User-designated identifier of a unique plant account.  It can be a FERC utility plant account such as 314 or the Companys own account number structure.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Utility_Account', 
    @level2type=N'COLUMN', @level2name=N'Utility_Account_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK)(fk) System-assigned identifier of a unique business segment.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Utility_Account', 
    @level2type=N'COLUMN', @level2name=N'Bus_Segment_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard System-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Utility_Account', 
    @level2type=N'COLUMN', @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard System-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Utility_Account', 
    @level2type=N'COLUMN', @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a unique mortality curve used to process retirements with a curve.  The curve can be specified at the retirement unit level.  It can also be the default for the entire account using this variable.  The level of entry is determined by MORTALITY CURVE ACCOUNT LOOKUP on the PP System Control Company table.  In either case, the CURVE MINIMUM RETIRE should be specified on the Retirement Unit table.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Utility_Account', 
    @level2type=N'COLUMN', @level2name=N'Mortality_Curve_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Now used as the user field on the Account Window.  The user field label is given in PP System Control Company under UTILITY ACCOUNT USER FIELD LABEL.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Utility_Account', 
    @level2type=N'COLUMN', @level2name=N'HW_Table_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'No longer used.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Utility_Account', 
    @level2type=N'COLUMN', @level2name=N'HW_Line_No';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) Identifies a unique FERC plant account (300-series for electric, etc.).  This could also be a NARUC, STP or even an enterprise wide standard list.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Utility_Account', 
    @level2type=N'COLUMN', @level2name=N'FERC_Plt_Acct_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier for a particular funcational class of plant such as Steam Production.  Functional classes should be set up for non-regulated accounts to support the drill-downs into the PowerPlan Ledgers.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Utility_Account', 
    @level2type=N'COLUMN', @level2name=N'Func_Class_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(description) Records a short description of the plant account.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Utility_Account', 
    @level2type=N'COLUMN', @level2name=N'Utility_Account';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records a detailed description of the account (optional).',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Utility_Account', 
    @level2type=N'COLUMN', @level2name=N'Long_Description';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) Status code id identifies whether the utility account is (1) active or (2) inactive.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Utility_Account', 
    @level2type=N'COLUMN', @level2name=N'Status_Code_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Optional external account code for interfaces.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Utility_Account', 
    @level2type=N'COLUMN', @level2name=N'External_Account_Code';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Average expected life in years used to process the cruve for auto/curve retirements.  It can be set at the retirement unit, but can be defaulted from this variable at the account level.  The level of entry is determined by MORTALITY CURVE ACCOUNT LOOKUP on the PP System Control Company table.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Utility_Account', 
    @level2type=N'COLUMN', @level2name=N'Expected_Life';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a particular Handy Whitman (or other escalator) table and line number.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Utility_Account', 
    @level2type=N'COLUMN', @level2name=N'HW_Table_Line_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'0 = NO default; 1 = YES.  Indicates whether quantities should be posted for the closed but not classified (e.g. 106) transactions.  These quantities either come from the estimates or the actuals depending on the methodology employed.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Utility_Account', 
    @level2type=N'COLUMN', @level2name=N'CCNC_Quantity';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Indiciates whether Overhead/Underground conductor applies to the utility account.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Utility_Account', 
    @level2type=N'COLUMN', @level2name=N'OVH_to_UDG';
GO

PRINT '-- PowerPlan.Retirement_Unit';
CREATE TABLE PowerPlan.Retirement_Unit
(
    [Retirement_Unit_ID] [int] NOT NULL PRIMARY KEY
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Property_Unit_ID] [int] NOT NULL      CONSTRAINT FK_PowerPlan_RetirementUnit_PropertyUnit_PropertyUnitID
                                            FOREIGN KEY (Property_Unit_ID)
                                            REFERENCES PowerPlan.Property_Unit(Property_Unit_ID)
    ,[External_Retire_Unit] [nvarchar](35) NULL
    ,[Retirement_Unit] [nvarchar](35) NOT NULL
    ,[Long_Description] [nvarchar](254) NULL
    ,[Status_Code_ID] [int] NOT NULL
    ,[Mortality_Curve_ID] [int] NULL        CONSTRAINT FK_PowerPlan_RetirementUnit_MortalityCurve_MortalityCurveID
                                            FOREIGN KEY (MortalitY_Curve_ID)
                                            REFERENCES PowerPlan.Mortality_Curve(Mortality_Curve_ID)
    ,[Expected_Life] DECIMAL(22,2) NULL
    ,[Environmental_Percent] DECIMAL(22,8) NULL
    ,[Curve_Minimum_Retire] DECIMAL(22,2) NULL
    ,[Acct_Instruct] [nvarchar](MAX) NULL
    ,[Memo_Only] [int] NULL
    ,[Link_to_Picture] [nvarchar](254) NULL
    ,[Tax_Destinction_ID] [int] NULL
    ,[Equip_Type_ID] [int] NULL             CONSTRAINT FK_PowerPlan_RetirementUnit_CPREquipType_EquipTypeID
                                            FOREIGN KEY (Equip_Type_ID)
                                            REFERENCES PowerPlan.CPR_Equip_Type(Equip_Type_ID)
    ,[Repair_Qty_Include] [int] NOT NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_RetirementUnit_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_RetirementUnit_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_RetirementUnit_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_RetirementUnit_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_RetirementUnit_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(sp*)  [01] [12] [13] The Retirement Unit data table maintains a list of detailed property units used by the utility to record assets on the CPR Ledger.  Multiple retirement units can be specified for a property unit, generally with different type sizes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Retirement_Unit';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) System-assigned identifier of a particular retiremetn unit.  Installer notes 1-5 are reserved for non-unitized assets, -1 is reserve for non-unitized retirements.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Retirement_Unit', 
    @level2type=N'COLUMN', @level2name=N'Retirement_Unit_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard System-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Retirement_Unit', 
    @level2type=N'COLUMN', @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard System-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Retirement_Unit', 
    @level2type=N'COLUMN', @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a particular property unit.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Retirement_Unit', 
    @level2type=N'COLUMN', @level2name=N'Property_Unit_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Externally generated retirement unit number usually derived from the utilitys existing property unit catalog.  In some cases these external numbers are required to allow cross-referencing between existing systems and PowerPlan.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Retirement_Unit', 
    @level2type=N'COLUMN', @level2name=N'External_Retire_Unit';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(description) Records a short description of the retirement unit.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Retirement_Unit', 
    @level2type=N'COLUMN', @level2name=N'Retirement_Unit';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records an optional detialed description of the retirement unit.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Retirement_Unit', 
    @level2type=N'COLUMN', @level2name=N'Long_Description';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a particular status: 1.) Active 2.) Inactive.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Retirement_Unit', 
    @level2type=N'COLUMN', @level2name=N'Status_Code_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a unique mortality curve used to process retirements with a curve.  It can be entered here or defaulted from utility account.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Retirement_Unit', 
    @level2type=N'COLUMN', @level2name=N'Mortality_Curve_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Average expected life in years used to process curve for auto/life retirementes.  It can be specified here or defaulted from utility account.  This choice is a sytsem-wide choice and is set up in PP System Control Company.  In either case, CURVE_MINIMUM_RETIRE should be entered below.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Retirement_Unit', 
    @level2type=N'COLUMN', @level2name=N'Expected_Life';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Optional field - not used in the code.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Retirement_Unit', 
    @level2type=N'COLUMN', @level2name=N'Environmental_Percent';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Minimum quantity that should be retired with a curve.  For example, if conductor is in feet, the minimum may be set to 100 so that 1 and 2 foot items are not retired from many vintages.  In this case the system tries to retire under 100 ft from a single vinatge; over 100 ft from multiple vintages in groups of 100. (V10.2.1.7 and higher).',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Retirement_Unit', 
    @level2type=N'COLUMN', @level2name=N'Curve_Minimum_Retire';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Accounting instructions for the retirement unit (it is defaulted from the property unit).',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Retirement_Unit', 
    @level2type=N'COLUMN', @level2name=N'Acct_Instruct';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Indicates that unitization is not done at this level, although the capitalization policy is MEMO ONLY retirements units are not recorded with dollar amounts in the CPR but are avilable in list from by quantity.  Normal retirement units are NO.  The defautl is NO.  Note that under each property unit designated SPECIFIC HIGH LEVEL, all the retirement units except one (the one equal to the property unit) should be indicated memo.  For MASS and SPECIFIC proeprty, no retiremetn units should be designated MEMO.  See the Asset Accounting Method table, SPECIFIC HIGH LEVEL method.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Retirement_Unit', 
    @level2type=N'COLUMN', @level2name=N'Memo_Only';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Link to a web-site address.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Retirement_Unit', 
    @level2type=N'COLUMN', @level2name=N'Link_to_Picture';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a federal/state income tax distinction for depreciation purposes, used in addition to account information, etc.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Retirement_Unit', 
    @level2type=N'COLUMN', @level2name=N'Tax_Destinction_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of an equipment type, indicating what type of equipment records will be maintained for this retirement unit.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Retirement_Unit', 
    @level2type=N'COLUMN', @level2name=N'Equip_Type_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Indicates whether the records retirement unit is one that should be included for the repairs test (1) or one related to a minor unit of property that should just be expensed (0).',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Retirement_Unit', 
    @level2type=N'COLUMN', @level2name=N'Repair_Qty_Include';
GO

PRINT '-- PowerPlan.Property_Unit_Default_Life';
CREATE TABLE PowerPlan.Property_Unit_Default_Life
(
    [Company_ID] [int] NOT NULL                 CONSTRAINT DK_PowerPlan_PropertyUnitDefaultLife_CompanyID       DEFAULT 2100
    ,[Utility_Account_ID] [int] NOT NULL
    ,[Bus_Segment_ID] [INT] NOT NULL            CONSTRAINT FK_PowerPlan_PropertyUnitDefaultLife_BusSegmentID
                                                FOREIGN KEY (Bus_Segment_ID)
                                                REFERENCES PowerPlan.Business_Segment(Bus_Segment_ID)
    ,[Property_Unit_ID] [int] NOT NULL          CONSTRAINT FK_PowerPlan_PropertyUnitDefaultLife_PropertyUnitID
                                                FOREIGN KEY (Property_Unit_ID)
                                                REFERENCES PowerPlan.Property_Unit(Property_Unit_ID)
    ,[Default_Life] [int] NOT NULL
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Retire_Method_ID] [int] NULL      CONSTRAINT DK_PowerPlan_PropertyUnitDefaultLife_RetireMethod_RetireMethodID
                                        FOREIGN KEY (Retire_Method_ID)
                                        REFERENCES PowerPlan.Retire_Method(Retire_Method_ID)
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_PropertyUnitDefaultLife_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_PropertyUnitDefaultLife_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_PropertyUnitDefaultLife_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_PropertyUnitDefaultLife_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_PropertyUnitDefaultLife_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
    ,CONSTRAINT PK_PowerPlan_PropertyUnitDefaultLife PRIMARY KEY(Company_ID, Utility_Account_ID, Bus_Segment_ID, Property_Unit_ID)
    ,CONSTRAINT FK_PowerPlan_PropertyUnitDefaultLife_UtilityAccount_UtilityAccountID FOREIGN KEY(Utility_Account_ID, Bus_Segment_ID) REFERENCES PowerPlan.Utility_Account(Utility_Account_ID,Bus_Segment_ID)
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(O) [01] The Property Unit Default Life table allows the user to specify a retirement method default life (if the retirement method is life auto) or for the property unit, by company and utility account (/business segment) and property unit, instead of just property unit.  The life is used in auto life retirements.  It is also used as the depreciable life for sub-ledgers and (optionally) for CPR depreciation.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Property_Unit_Default_Life';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) System-assigned identifier of a particular company.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Property_Unit_Default_Life', 
    @level2type=N'COLUMN', @level2name=N'Company_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK)(fk) System-assigned identifier of a particular utility account.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Property_Unit_Default_Life', 
    @level2type=N'COLUMN', @level2name=N'Utility_Account_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK)(fk) System-assigned identifier of a particular business segment.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Property_Unit_Default_Life', 
    @level2type=N'COLUMN', @level2name=N'Bus_Segment_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK)(fk) System-assigned identifier of a particular property unit.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Property_Unit_Default_Life', 
    @level2type=N'COLUMN', @level2name=N'Property_Unit_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Default life of the property unit in months.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Property_Unit_Default_Life', 
    @level2type=N'COLUMN', @level2name=N'Default_Life';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard System-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Property_Unit_Default_Life', 
    @level2type=N'COLUMN', @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard System-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Property_Unit_Default_Life', 
    @level2type=N'COLUMN', @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) Retirement method for this company, business segment, utility account, and property unit overriding the retirement method set just by property unit.  Note that if a curve method is specified the life and curve are determined in accordance with PP_system_control.mortality_curve_account_lookup.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Property_Unit_Default_Life', 
    @level2type=N'COLUMN', @level2name=N'Retire_Method_ID';
GO