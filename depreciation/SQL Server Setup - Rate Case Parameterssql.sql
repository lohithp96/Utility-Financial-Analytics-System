/***************************************************************************************
Name      : Depreciation Accounting - Regulatory Depr. Parameter Tables
License   : Copyright (C) 2017 San Diego Gas & Electric company
            All Rights Reserved
Created   : 05/18/2017 08:43 Matthew C. Vanderbilt /00562 (START)
            05/18/2017 12:32  Matthew C. Vanderbilt /00562 (END)
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
- Delete CONSTRAINT FK_PowerPlan_DSDataAccount_AnalysisAccountClass_AnalysisAccountID
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

/*  DELETE EXISTING OBJECTS ***********************************************************/
PRINT '** Delete Existing Objects';
GO

PRINT '-- Delete Tables';
GO

IF OBJECT_ID ( 'Depr.Rate_Case_Parameter','U') IS NOT NULL
    DROP TABLE Depr.Rate_Case_Parameter;
GO
IF OBJECT_ID ( 'Depr.Rate_Case','U') IS NOT NULL
    DROP TABLE Depr.Rate_Case;
GO

/*  CREATE TABLES *********************************************************************/
PRINT '** Create Tables';
GO

PRINT '-- Depr.Rate_Case';
CREATE TABLE Depr.Rate_Case
(
    [Rate_Case_ID] [nvarchar](7) NOT NULL
    ,[Rate_Case] [nvarchar](35) NULL
    ,[Agency] [char](4) NOT NULL
    ,[Application] [nvarchar](18) NULL
    ,[Decision] [nvarchar](18) NULL
    ,[Start_Date] datetime2 NOT NULL
    ,[End_Date] datetime2 NOT NULL
    ,[Notes] [nvarchar](MAX) NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_Depr_RateCase_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_Depr_RateCase_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_Depr_RateCase_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_Depr_RateCase_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_Depr_RateCase_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
    ,CONSTRAINT PK_Depr_RateCase PRIMARY KEY ([Rate_Case_ID])
);
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'The Rate Case table indexes the various rate cases and their effective periods.',
    @level0type=N'SCHEMA', @level0name=N'Depr',
    @level1type=N'TABLE',  @level1name=N'Rate_Case';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) Unique identifier of a particular rate case.',
    @level0type=N'SCHEMA',  @level0name=N'Depr',
    @level1type=N'TABLE',   @level1name=N'Rate_Case',
    @level2type=N'COLUMN',  @level2name=N'Rate_Case_ID';
GO

PRINT '-- Depr.Rate_Case_Parameter';
CREATE TABLE Depr.Rate_Case_Parameter
(
    [Depr_Group_ID] [INT] NOT NULL          CONSTRAINT FK_Depr_RateCaseParameter_DeprGroup_DeprGroupID
                                            FOREIGN KEY (Depr_Group_ID)
                                            REFERENCES PowerPlan.Depr_Group(Depr_Group_ID)
    ,[Depr_Method_Id] [int] NOT NULL        CONSTRAINT FK_Depr_RateCaseParameter_DepreciationMethod_DeprMethodID
                                            FOREIGN KEY (Depr_Method_ID)
                                            REFERENCES PowerPlan.Depreciation_Method(Depr_Method_ID)
    ,[Rate_Case_ID] [nvarchar](7) NOT NULL  CONSTRAINT FK_Depr_RateCaseParameter_RateCase_RateCaseID
                                            FOREIGN KEY (Rate_Case_ID)
                                            REFERENCES Depr.Rate_Case(Rate_Case_ID)
    ,[Mortality_Curve_ID] [int] NULL        CONSTRAINT FK_Depr_RateCaseParameter_MortalityCurve_MortalityCurveID
                                            FOREIGN KEY (Mortality_Curve_ID)
                                            REFERENCES PowerPlan.Mortality_Curve(Mortality_Curve_ID)
    ,[Expected_Average_Life] DECIMAL(22,8) NULL
    ,[End_Of_Life] datetime2 NULL
    ,[Net_Salvage_Pct] DECIMAL(22,8) NOT NULL           CONSTRAINT DK_Depr_RateCaseParameter_NetSalvagePct   DEFAULT 0
    ,[Interim_Retirement_Pct] DECIMAL(22,8) NOT NULL    CONSTRAINT DK_Depr_RateCaseParameter_InterimRetirementPct   DEFAULT 0
    ,[Rate] DECIMAL(22,8) NOT NULL                      CONSTRAINT DK_Depr_RateCaseParameter_Rate   DEFAULT 0
    ,[Cost_of_Removal_Rate] DECIMAL(22,8) NOT NULL      CONSTRAINT DK_Depr_RateCaseParameter_CostOfRemovalRate   DEFAULT 0
    ,[Notes] [nvarchar](MAX) NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL                CONSTRAINT DK_Depr_RateCaseParameter_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL              CONSTRAINT DK_Depr_RateCaseParameter_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_Depr_RateCaseParameter_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL                  CONSTRAINT DK_Depr_RateCaseParameter_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL                    CONSTRAINT DK_Depr_RateCaseParameter_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
    ,CONSTRAINT PK_Depr_RateCaseParameter PRIMARY KEY ([Depr_Group_ID],[Depr_Method_ID],[Rate_Case_ID])
);
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'The Rate Case Parameter table indexes the authorized and/or leveraged depreciation parameters utilized throughout each case period.',
    @level0type=N'SCHEMA', @level0name=N'Depr',
    @level1type=N'TABLE',  @level1name=N'Rate_Case_Parameter';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK)(fk) System-assigned identifier of a particular depreciation group.',
    @level0type=N'SCHEMA',  @level0name=N'Depr',
    @level1type=N'TABLE',   @level1name=N'Rate_Case_Parameter',
    @level2type=N'COLUMN',  @level2name=N'Depr_Group_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a particular depreciation method.',
    @level0type=N'SCHEMA',  @level0name=N'Depr',
    @level1type=N'TABLE',   @level1name=N'Rate_Case_Parameter',
    @level2type=N'COLUMN',  @level2name=N'Depr_Method_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK)(fk) Unique identifier of a particular rate case.',
    @level0type=N'SCHEMA',  @level0name=N'Depr',
    @level1type=N'TABLE',   @level1name=N'Rate_Case_Parameter',
    @level2type=N'COLUMN',  @level2name=N'Rate_Case_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'System-assigned identifier of a mortality (e.g. Iowa) curve associated with the depreciation group.  (This is used for theoretical reserve allocaiton.)' , 
    @level0type=N'SCHEMA', @level0name=N'Depr',
    @level1type=N'TABLE',  @level1name=N'Rate_Case_Parameter',
    @level2type=N'COLUMN', @level2name=N'Mortality_Curve_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Records the average expected life in years fo the depreciation group (or combination group) from a life study.  (With the mortality curve it is used for theoretical reserve allocaiton.)' , 
    @level0type=N'SCHEMA', @level0name=N'Depr',
    @level1type=N'TABLE',  @level1name=N'Rate_Case_Parameter',
    @level2type=N'COLUMN', @level2name=N'Expected_Average_Life';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Year and month (yyyymm) for END DATE depreciation.  Depreciation is calcualted on a monthly remaining life against a net basis up to this input month.  This will override any mid-period method on the Depreciation Group Table.' , 
    @level0type=N'SCHEMA', @level0name=N'Depr',
    @level1type=N'TABLE',  @level1name=N'Rate_Case_Parameter',
    @level2type=N'COLUMN', @level2name=N'End_of_Life';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'User-input percentage used in conjunction with an over depr check = YES.  The rate can be plus (salvage exceeds cost of removal) or minus and is entered as a decimal.  Only in the case of END DATE remaining life depreciation or monthly net the depreciable balance is also decreased (increased) by this percent.' , 
    @level0type=N'SCHEMA', @level0name=N'Depr',
    @level1type=N'TABLE',  @level1name=N'Rate_Case_Parameter',
    @level2type=N'COLUMN', @level2name=N'Net_Salvage_Pct';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'User-input percentage used not mirrored in PowerPlan and deprecated beginning with the 2019 GRC.  This value is utilized to reduce the expectancy of assets.' , 
    @level0type=N'SCHEMA', @level0name=N'Depr',
    @level1type=N'TABLE',  @level1name=N'Rate_Case_Parameter',
    @level2type=N'COLUMN', @level2name=N'Interim_Retirement_Pct';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'Records the actual depreciation rate to be used in the calculation of depreciation expense.  The rate is an annual rate entered as a decimal.  Note that if cost of removal is broken out in a separate reserve with its own rate in Cost_of_Removal_Rate below, this rate should exlude the cost of removal rate.  Default is 0.' , 
    @level0type=N'SCHEMA', @level0name=N'Depr',
    @level1type=N'TABLE',  @level1name=N'Rate_Case_Parameter',
    @level2type=N'COLUMN', @level2name=N'Rate';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description', 
    @value=N'The annual cost of removal depreciation rate entered as a percent.  If entered the system can maintain a COR balance in the reserve.' , 
    @level0type=N'SCHEMA', @level0name=N'Depr',
    @level1type=N'TABLE',  @level1name=N'Rate_Case_Parameter',
    @level2type=N'COLUMN', @level2name=N'Cost_of_Removal_Rate';
GO