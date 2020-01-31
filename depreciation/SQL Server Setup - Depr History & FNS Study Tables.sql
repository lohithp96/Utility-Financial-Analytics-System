/***************************************************************************************
Name      : Depreciation Accounting - Depr. Study / Salvage Data Table Setup #1
License   : Copyright (C) 2017 San Diego Gas & Electric company
            All Rights Reserved
Created   : 05/10/2017 12:10 Matthew C. Vanderbilt /00562 (START)
            05/10/2017 14:57  Matthew C. Vanderbilt /00562 (END)
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

IF OBJECT_ID ( 'Depr.Salvage_History','U') IS NOT NULL
    DROP TABLE Depr.Salvage_History;
GO
IF OBJECT_ID ( 'Powerplan.DS_Acct_Dataset_Map','U') IS NOT NULL
    DROP TABLE PowerPlan.DS_Acct_Dataset_Map;
GO
IF OBJECT_ID ( 'PowerPlan.DS_DG_Dataset_Map','U') IS NOT NULL
    DROP TABLE PowerPlan.DS_DG_Dataset_Map;
GO
IF OBJECT_ID ( 'PowerPlan.DS_Dataset_External_Trans','U') IS NOT NULL
    DROP TABLE PowerPlan.DS_Dataset_External_Trans;
GO
IF OBJECT_ID ( 'PowerPlan.Transaction_Input_Type','U') IS NOT NULL
    DROP TABLE PowerPlan.Transaction_Input_Type;
GO
IF OBJECT_ID ( 'PowerPlan.Analysis_Transaction_Code','U') IS NOT NULL
    DROP TABLE PowerPlan.Analysis_Transaction_Code;
GO
IF OBJECT_ID ( 'PowerPlan.Summary_Transaction_Code','U') IS NOT NULL
    DROP TABLE PowerPlan.Summary_Transaction_Code;
GO
IF OBJECT_ID ( 'PowerPlan.DS_Data_Account_Depr_Group','U') IS NOT NULL
    DROP TABLE PowerPlan.DS_Data_Account_Depr_Group;
GO
IF OBJECT_ID ( 'PowerPlan.Analysis_Account_Depr_Group','U') IS NOT NULL
    DROP TABLE PowerPlan.Analysis_Account_Depr_Group;
GO
IF OBJECT_ID ( 'PowerPlan.Salvage_Analysis','U') IS NOT NULL
    DROP TABLE PowerPlan.Salvage_Analysis;
GO
IF OBJECT_ID ( 'PowerPlan.Analysis_Version','U') IS NOT NULL
    DROP TABLE PowerPlan.Analysis_Version;
GO
IF OBJECT_ID ( 'PowerPlan.Analysis_Depr_Group','U') IS NOT NULL
    DROP TABLE PowerPlan.Analysis_Depr_Group;
GO
IF OBJECT_ID ( 'PowerPlan.DS_Data_Account','U') IS NOT NULL
    DROP TABLE PowerPlan.DS_Data_Account;
GO
IF OBJECT_ID ( 'PowerPlan.Analysis_Account','U') IS NOT NULL
    DROP TABLE PowerPlan.Analysis_Account;
GO
IF OBJECT_ID ( 'PowerPlan.DS_Analysis_Dataset','U') IS NOT NULL
    DROP TABLE PowerPlan.DS_Analysis_Dataset;
GO
IF OBJECT_ID ( 'PowerPlan.Analysis_Account_Class','U') IS NOT NULL
    DROP TABLE PowerPlan.Analysis_Account_Class;
GO

PRINT '-- Delete Schemas';
GO
PRINT '-- -- Depr';
IF SCHEMA_ID('Depr') IS NOT NULL
	DROP SCHEMA Depr;
GO

/*  CREATE SCHEMAS ********************************************************************/
PRINT '** Create Schemas';
GO
CREATE SCHEMA Depr;
GO
EXEC sys.sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'Depreciation Study and Analysis Tables.', 
	 @level0type=N'SCHEMA',
	 @level0name=N'Depr';
GO

/*  CREATE TABLES *********************************************************************/
PRINT '** Create Tables';
GO

PRINT '-- PowerPlan.Analysis_Account_Class';
CREATE TABLE PowerPlan.Analysis_Account_Class
(
    [Analysis_Account_Class_ID] [int] NOT NULL
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Analysis_Account_Class] [nvarchar](35) NOT NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_AnalysisAccountClass_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_AnalysisAccountClass_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_AnalysisAccountClass_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_AnalysisAccountClass_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_AnalysisAccountClass_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
    ,CONSTRAINT PK_PowerPlan_AnalysisAccountClass PRIMARY KEY ([Analysis_Account_Class_ID])
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(S) [05] This table contains a roll-up of analysis accounts used in depreciation studies.  It is used for reporting and query.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Account_Class';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) System-assigned identifier of a particular analysis account class.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Account_Class',
    @level2type=N'COLUMN', @level2name=N'Analysis_Account_Class_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Account_Class',
    @level2type=N'COLUMN', @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Account_Class',
    @level2type=N'COLUMN', @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records a short description of the analysis account class.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Account_Class',
    @level2type=N'COLUMN', @level2name=N'Analysis_Account_Class';
GO

PRINT '-- PowerPlan.DS_Analysis_Dataset';
CREATE TABLE PowerPlan.DS_Analysis_Dataset
(
    [DS_Analysis_Dataset_ID] [int] NOT NULL
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[DS_Analysis_Dataset] [nvarchar](35) NOT NULL
    ,[Long_Description] [nvarchar](255) NULL
    ,[Begin_Date] datetime2 NULL
    ,[End_Date] datetime2 NULL
    ,[All_Date_Flag] numeric(1,0) NOT NULL  CONSTRAINT DK_PowerPlan_DSAnalysisDataset_AllDateFlag   DEFAULT (1)
    ,[Last_Transaction_Update] datetime2 NULL
    ,[Set_of_Books_ID] [int] NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_DSAnalysisDataset_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_DSAnalysisDataset_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_DSAnalysisDataset_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_DSAnalysisDataset_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_DSAnalysisDataset_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
    ,CONSTRAINT PK_PowerPlan_DSAnalysisDataset PRIMARY KEY ([DS_Analysis_Dataset_ID])
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(O)  [05] The DS Analysis Dataset table lists all sets of data used for depreciation study analysis.  Every analysis scenario created will be based on information from a single analysis dataset.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Analysis_Dataset';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) System-assigned identifier of a particular depr study analysis dataset.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Analysis_Dataset',
    @level2type=N'COLUMN', @level2name=N'DS_Analysis_Dataset_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Analysis_Dataset',
    @level2type=N'COLUMN', @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Analysis_Dataset',
    @level2type=N'COLUMN', @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records a short description of the analysis dataset.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Analysis_Dataset',
    @level2type=N'COLUMN', @level2name=N'DS_Analysis_Dataset';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records a more detailed description of the analysis dataset.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Analysis_Dataset',
    @level2type=N'COLUMN', @level2name=N'Long_Description';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Required if all_date_flag = 0 to set first month of data transactions to include.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Analysis_Dataset',
    @level2type=N'COLUMN', @level2name=N'Begin_Date';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Required if all_date_flag = 0 to set last month of data transactions to include.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Analysis_Dataset',
    @level2type=N'COLUMN', @level2name=N'End_Date';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Flag indicating if the dataset should include all dates (=1) or have user entered begin and end dates (=0).  Default is 1.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Analysis_Dataset',
    @level2type=N'COLUMN', @level2name=N'All_Date_Flag';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Stores the Date/Time from the last refresh of data transactions to dataset transactions.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Analysis_Dataset',
    @level2type=N'COLUMN', @level2name=N'Last_Transaction_Update';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'System-assigned identifier of a particular set of books.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Analysis_Dataset',
    @level2type=N'COLUMN', @level2name=N'Set_of_Books_ID';
GO

PRINT '-- PowerPlan.Analysis_Depr_Group';
CREATE TABLE PowerPlan.Analysis_Depr_Group
(
    [Analysis_Depr_Group_ID] [int] NOT NULL
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Company_ID] [int] NULL
    ,[Analysis_Depr_Group] [nvarchar](35) NOT NULL
    ,[DS_Analysis_Dataset_ID] [int] NOT NULL    CONSTRAINT FK_PowerPlan_AnalysisDeprGroup_DSAnalysisDataset_DSAnalysisDatasetID
                                                FOREIGN KEY (DS_Analysis_Dataset_ID)
                                                REFERENCES PowerPlan.DS_Analysis_Dataset(DS_Analysis_Dataset_ID)
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_AnalysisDeprGroup_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_AnalysisDeprGroup_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_AnalysisDeprGroup_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_AnalysisDeprGroup_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_AnalysisDeprGroup_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
    ,CONSTRAINT PK_PowerPlan_AnalysisDeprGroup PRIMARY KEY ([Analysis_Depr_Group_ID])
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(O) [05] Analysis Depr Group is defined as part of an analysis dataset and is included in all scenarios (versions) for that analysis dataset.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Depr_Group';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) System-assigned identifier of a particular analysis depreciation group.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Depr_Group',
    @level2type=N'COLUMN', @level2name=N'Analysis_Depr_Group_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Depr_Group',
    @level2type=N'COLUMN', @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Depr_Group',
    @level2type=N'COLUMN', @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a particular company.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Depr_Group',
    @level2type=N'COLUMN', @level2name=N'Company_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records a short description of the depreciation group to be used by the user.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Depr_Group',
    @level2type=N'COLUMN', @level2name=N'Analysis_Depr_Group';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a particular depr study analysis dataset.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Depr_Group',
    @level2type=N'COLUMN', @level2name=N'DS_Analysis_Dataset_ID';
GO

PRINT '-- PowerPlan.Analysis_Account';
CREATE TABLE PowerPlan.Analysis_Account
(
    [Analysis_Account_ID] [int] NOT NULL
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Analysis_Account] [nvarchar](35) NOT NULL
    ,[Company_ID] [int] NULL
    ,[Depr_Account_Class_ID] [int] NULL     CONSTRAINT FK_PowerPlan_AnalysisAccount_AnalysisAccountClass_AnalysisAccountID
                                            FOREIGN KEY (Depr_Account_Class_ID)
                                            REFERENCES PowerPlan.Analysis_Account_Class(Analysis_Account_Class_ID)
    ,[Long_Description] [nvarchar](255) NULL
    ,[DS_Analysis_Dataset_ID] [int] NULL    CONSTRAINT FK_PowerPlan_AnalysisAccount_DSAnalysisDataset_DSAnalysisDatasetID
                                            FOREIGN KEY (DS_Analysis_Dataset_ID)
                                            REFERENCES PowerPlan.DS_Analysis_Dataset(DS_Analysis_Dataset_ID)
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_AnalysisAccount_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_AnalysisAccount_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_AnalysisAccount_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_AnalysisAccount_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_AnalysisAccount_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
    ,CONSTRAINT PK_PowerPlan_AnalysisAccount PRIMARY KEY ([Analysis_Account_ID])
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(O) [05] The Analysis Account table lists all "accounts" used for depreciation study purposes.  The analysis accounts are defined as a part of an analysis dataset and are included in all scenarios (versions) for that analysis dataset.  These accounts can be equivalent to the depreciation groups or another rollup of utility account, location, etc. defined on analysis account control.  The accounts include those needed for all versions or cases.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Account';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) System-assigned identifier of a particular analysis account.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Account',
    @level2type=N'COLUMN', @level2name=N'Analysis_Account_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Account',
    @level2type=N'COLUMN', @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Account',
    @level2type=N'COLUMN', @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records a short description of the analysis account, for example, 312 station XX or Distribution, or 397.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Account',
    @level2type=N'COLUMN', @level2name=N'Analysis_Account';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a particular company.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Account',
    @level2type=N'COLUMN', @level2name=N'Company_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a depreciation account class used for reporting.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Account',
    @level2type=N'COLUMN', @level2name=N'Depr_Account_Class_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records a more detailed description of the analysis account.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Account',
    @level2type=N'COLUMN', @level2name=N'Long_Description';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'System-assigned identifier of the analysis dataset.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Account',
    @level2type=N'COLUMN', @level2name=N'DS_Analysis_Dataset_ID';
GO

PRINT '-- PowerPlan.Analysis_Account_Depr_Group';
CREATE TABLE PowerPlan.Analysis_Account_Depr_Group
(
    [Analysis_Account_ID] [int] NOT NULL        CONSTRAINT FK_PowerPlan_AnalysisAccountDeprGroup_AnalysisAccount_AnalysisAccountID
                                                FOREIGN KEY (Analysis_Account_ID)
                                                REFERENCES PowerPlan.Analysis_Account(Analysis_Account_ID)
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Analysis_Depr_Group_ID] [int] NOT NULL    CONSTRAINT FK_PowerPlan_AnalysisAccountDeprGroup_AnalysisDeprGroup_AnalysisDeprGroupID
                                                FOREIGN KEY (Analysis_Depr_Group_ID)
                                                REFERENCES PowerPlan.Analysis_Depr_Group(Analysis_Depr_Group_ID)
    ,[DS_Analysis_Dataset_ID] [int] NOT NULL    CONSTRAINT FK_PowerPlan_AnalysisAccountDeprGroup_DSAnalysisDataset_DSAnalysisDatasetID
                                                FOREIGN KEY (DS_Analysis_Dataset_ID)
                                                REFERENCES PowerPlan.DS_Analysis_Dataset(DS_Analysis_Dataset_ID)
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_AnalysisAccountDeprGroup_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_AnalysisAccountDeprGroup_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_AnalysisAccountDeprGroup_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_AnalysisAccountDeprGroup_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_AnalysisAccountDeprGroup_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
    ,CONSTRAINT PK_PowerPlan_AnalysisAccountDeprGroup PRIMARY KEY ([Analysis_Account_ID])
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(C) [05] The Analysis Account Depreciation Group table links the analysis accounts and depreciation groups created for an analysis dataset in the depreciation studies module.  This relationship is created automatically when a dataset is created. Note that only those analysis accounts that are using the direct method are on this table.  (The program will validate that the company definitions on analysis account and depreciation group are consistent.)',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Account_Depr_Group';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK)(fk) System-assigned identifier of a depreciation study analysis account.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Account_Depr_Group',
    @level2type=N'COLUMN', @level2name=N'Analysis_Account_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Account_Depr_Group',
    @level2type=N'COLUMN', @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Account_Depr_Group',
    @level2type=N'COLUMN', @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a depreciation study analysis account.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Account_Depr_Group',
    @level2type=N'COLUMN', @level2name=N'Analysis_Depr_Group_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of an analysis dataset.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Account_Depr_Group',
    @level2type=N'COLUMN', @level2name=N'DS_Analysis_Dataset_ID';
GO

PRINT '-- PowerPlan.Analysis_Version';
CREATE TABLE PowerPlan.Analysis_Version
(
    [Analysis_Version_ID] [int] NOT NULL
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Analysis_Version] [nvarchar](35) NOT NULL
    ,[Long_Description] [nvarchar](255) NULL
    ,[Company_ID] [int] NULL
    ,[DS_Analysis_Dataset_ID] [int] NOT NULL    CONSTRAINT FK_PowerPlan_AnalysisVersion_DSAnalysisDataset_DSAnalysisDatasetID
                                                FOREIGN KEY (DS_Analysis_Dataset_ID)
                                                REFERENCES PowerPlan.DS_Analysis_Dataset(DS_Analysis_Dataset_ID)
    ,[Version_Status] [int] NOT NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_AnalysisVersion_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_AnalysisVersion_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_AnalysisVersion_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_AnalysisVersion_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_AnalysisVersion_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
    ,CONSTRAINT PK_PowerPlan_AnalysisVersion PRIMARY KEY ([Analysis_Version_ID])
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(O) [05] The Analysis Version table lists the versions of depreciation life studies or technical updates.  (A scenario, or version, gets associated with a particular analysis dataset.)',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Version';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) System-assigned identifier',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Version',
    @level2type=N'COLUMN', @level2name=N'Analysis_Version_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Version',
    @level2type=N'COLUMN', @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Version',
    @level2type=N'COLUMN', @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records a short description used in pull downs.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Version',
    @level2type=N'COLUMN', @level2name=N'Analysis_Version';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records a more detailed description of the version, including for example, methods, purpose, etc.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Version',
    @level2type=N'COLUMN', @level2name=N'Long_Description';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a particular company.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Version',
    @level2type=N'COLUMN', @level2name=N'Company_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a particular depr study analysis dataset.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Version',
    @level2type=N'COLUMN', @level2name=N'DS_Analysis_Dataset_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Indicates the current status of the analysis scenario: 0 = Unlocked (Default), 1 = Locked.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Version',
    @level2type=N'COLUMN', @level2name=N'Version_Status';
GO

PRINT '-- PowerPlan.Salvage_Analysis';
CREATE TABLE PowerPlan.Salvage_Analysis
(
    [Salvage_Analysis_ID] [int] NOT NULL
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Analysis_Account_ID] [int] NOT NULL   CONSTRAINT FK_PowerPlan_SavlageAnalysis_AnalysisAccount_AnalysisAccountID
                                            FOREIGN KEY (Analysis_Account_ID)
                                            REFERENCES PowerPlan.Analysis_Account(Analysis_Account_ID)
    ,[Analysis_Version_ID] [int] NOT NULL   CONSTRAINT FK_PowerPlan_SalvageAnalysis_AnalysisVersion_AnalysisVersionID
                                            FOREIGN KEY (Analysis_Version_ID)
                                            REFERENCES PowerPlan.Analysis_Version(Analysis_Version_ID)
    ,[Band_Width] [int] NOT NULL
    ,[Activity_Year] [smallint] NOT NULL
    ,[Vintage] [smallint] NULL
    ,[Retirements] NUMERIC(22,2) NULL
    ,[Salvage_Amt] NUMERIC(22,2) NULL
    ,[Salvage_Pct] NUMERIC(22,8) NULL
    ,[Salvage_Avg] NUMERIC(22,4) NULL
    ,[Cost_of_Removal_Amt] NUMERIC(22,2) NULL
    ,[Cost_of_Removal_Pct] NUMERIC(22,8) NULL
    ,[Cost_of_Removal_Avg] NUMERIC(22,4) NULL
    ,[Net_Salvage_Amt] NUMERIC(22,2) NULL
    ,[Net_Salvage_Pct] NUMERIC(22,8) NULL
    ,[Net_Salvage_Avg] NUMERIC(22,4) NULL
    ,[Salvage_Returns_Amt] NUMERIC(22,2) NULL
    ,[Salvage_Returns_Pct] NUMERIC(22,8) NULL
    ,[Salvage_Returns_Avg] NUMERIC(22,4) NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_SalvageAnalysis_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_SalvageAnalysis_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_SalvageAnalysis_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_SalvageAnalysis_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_SalvageAnalysis_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
    ,CONSTRAINT PK_PowerPlan_SalvageAnalysis PRIMARY KEY ([Salvage_Analysis_ID])
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(C) [05] The salvage analysis table contains the resutls of depreciation studies salvage analysis.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Salvage_Analysis';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) Unique key identifying salvage for a given account, version, activity_year and vintage.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Salvage_Analysis',
    @level2type=N'COLUMN', @level2name=N'Salvage_Analysis_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard System-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Salvage_Analysis',
    @level2type=N'COLUMN', @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard System-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Salvage_Analysis',
    @level2type=N'COLUMN', @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of the current depreciation study account selected by the user.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Salvage_Analysis',
    @level2type=N'COLUMN', @level2name=N'Analysis_Account_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of the current depreciation study case selected by the user.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Salvage_Analysis',
    @level2type=N'COLUMN', @level2name=N'Analysis_Version_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Determines the number of years to be used in the calculation of average net salvage rates.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Salvage_Analysis',
    @level2type=N'COLUMN', @level2name=N'Band_Width';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Year of the retirement activity.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Salvage_Analysis',
    @level2type=N'COLUMN', @level2name=N'Activity_Year';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Year plant was placed in-service.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Salvage_Analysis',
    @level2type=N'COLUMN', @level2name=N'Vintage';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Dollar amount of retirement for an activity year.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Salvage_Analysis',
    @level2type=N'COLUMN', @level2name=N'Retirements';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Salvage dollars of the plant retired.  (Not including salvage retunrs see below).',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Salvage_Analysis',
    @level2type=N'COLUMN', @level2name=N'Salvage_Amt';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Salvage_amt divided by retirements.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Salvage_Analysis',
    @level2type=N'COLUMN', @level2name=N'Salvage_Pct';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Average salvage rate over a period of years specified by the band_width.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Salvage_Analysis',
    @level2type=N'COLUMN', @level2name=N'Salvage_Avg';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Cost of removal dollars of the plant retired.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Salvage_Analysis',
    @level2type=N'COLUMN', @level2name=N'Cost_of_Removal_Amt';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Cost_of_Removal_Amt divided by retirements.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Salvage_Analysis',
    @level2type=N'COLUMN', @level2name=N'Cost_of_Removal_Pct';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Average Cost_of_Removal rate over a period of years specified by the band_width.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Salvage_Analysis',
    @level2type=N'COLUMN', @level2name=N'Cost_of_Removal_Avg';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Salvage_Amt minus Cost_of_Removal_Amt.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Salvage_Analysis',
    @level2type=N'COLUMN', @level2name=N'Net_Salvage_Amt';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Net_Salvage_Amt divided by retirements.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Salvage_Analysis',
    @level2type=N'COLUMN', @level2name=N'Net_Salvage_Pct';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'The average Net_Salvage rate over a period of years specified by the band_width.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Salvage_Analysis',
    @level2type=N'COLUMN', @level2name=N'Net_Salvage_Avg';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Salvage returns for the plant retired, in dollars.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Salvage_Analysis',
    @level2type=N'COLUMN', @level2name=N'Salvage_Returns_Amt';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Salvage returns amount divided by retirements.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Salvage_Analysis',
    @level2type=N'COLUMN', @level2name=N'Salvage_Returns_Pct';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Average salvage retunrs rate over a period of years specified by the band_width.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Salvage_Analysis',
    @level2type=N'COLUMN', @level2name=N'Salvage_Returns_Avg';
GO


PRINT '-- PowerPlan.DS_Data_Account';
CREATE TABLE PowerPlan.DS_Data_Account
(
    [DS_Data_Account_ID] [int] NOT NULL
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[DS_Data_Account] [nvarchar](35) NOT NULL
    ,[Company_ID] [int] NOT NULL
    ,[Data_Account_Class_ID] [int] NULL     CONSTRAINT FK_PowerPlan_DSDataAccount_AnalysisAccountClass_AnalysisAccountID
                                            FOREIGN KEY (Data_Account_Class_ID)
                                            REFERENCES PowerPlan.Analysis_Account_Class(Analysis_Account_Class_ID)
    ,[Long_Description] [nvarchar](255) NULL
    ,[Status_Code_ID] [int] NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_DSDataAccount_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_DSDataAccount_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_DSDataAccount_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_DSDataAccount_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_DSDataAccount_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
    ,CONSTRAINT PK_PowerPlan_DSDataAccount PRIMARY KEY ([DS_Data_Account_ID])
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(O)  [05] The DS Data Account table lists all "accounts" available for depreciation study purposes.  The analysis accounts can be equivalent to the depreciation groups or another rollup of utility account, location, etc. defined on data account control.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Data_Account';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) System-assigned identifier of a particular depr study data account.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Data_Account',
    @level2type=N'COLUMN', @level2name=N'DS_Data_Account_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard System-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Data_Account',
    @level2type=N'COLUMN', @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard System-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Data_Account',
    @level2type=N'COLUMN', @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records a short description of the data account, for example, 312 station XX or Distribution, or 397.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Data_Account',
    @level2type=N'COLUMN', @level2name=N'DS_Data_Account';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a particular company.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Data_Account',
    @level2type=N'COLUMN', @level2name=N'Company_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identiifer of a depreciation study data account class used for reporting.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Data_Account',
    @level2type=N'COLUMN', @level2name=N'Data_Account_Class_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records a more detailed description of the data account.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Data_Account',
    @level2type=N'COLUMN', @level2name=N'Long_Description';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) Valid, invalid account.  Invalid accounts are not to receive activity but are used in the transfer structure.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Data_Account',
    @level2type=N'COLUMN', @level2name=N'Status_Code_ID';
GO

PRINT '-- PowerPlan.DS_Data_Account_Depr_Group';
CREATE TABLE PowerPlan.DS_Data_Account_Depr_Group
(
    [DS_Data_Account_ID] [int] NOT NULL     CONSTRAINT FK_PowerPlan_DSDataAccountDeprGroup_DSDataAccount_DSDataAccountID
                                            FOREIGN KEY (DS_Data_Account_ID)
                                            REFERENCES PowerPlan.DS_Data_Account(DS_Data_Account_ID)
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Depr_Group_ID] [int] NOT NULL         CONSTRAINT FK_PowerPlan_DSDataAccountDeprGroup_DeprGroup_DeprGroupID
                                            FOREIGN KEY (Depr_Group_ID)
                                            References PowerPlan.Depr_Group(Depr_Group_ID)
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_DSDataAccountDeprGroup_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_DSDataAccountDeprGroup_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_DSDataAccountDeprGroup_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_DSDataAccountDeprGroup_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_DSDataAccountDeprGroup_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
    ,CONSTRAINT PK_PowerPlan_DSDataAccountDeprGroup PRIMARY KEY ([DS_Data_Account_ID])
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(O)  [05] The DS Data Account Depr Group table links the data accounts used in the depreciation study directly to depreciation groups on a many-to-1 basis.  A single data account may be linked to a single depreciation group; however, multiple data accounts may be linked to the same depreciation group.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Data_Account_Depr_Group';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK)(fk) System-assigned identifier of a depreciation study data account.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Data_Account_Depr_Group',
    @level2type=N'COLUMN', @level2name=N'DS_Data_Account_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Data_Account_Depr_Group',
    @level2type=N'COLUMN', @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Data_Account_Depr_Group',
    @level2type=N'COLUMN', @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a depreciation group.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Data_Account_Depr_Group',
    @level2type=N'COLUMN', @level2name=N'Depr_Group_ID';
GO
PRINT '-- PowerPlan.DS_Acct_Dataset_Map';
CREATE TABLE PowerPlan.DS_Acct_Dataset_Map
(
    [DS_Analysis_Dataset_ID] [int] NOT NULL CONSTRAINT FK_PowerPlan_DSAcctDatasetMap_DSAnalysisDataset_DSAnalysisDatasetID
                                            FOREIGN KEY (DS_Analysis_Dataset_ID)
                                            REFERENCES PowerPlan.DS_Analysis_Dataset(DS_Analysis_Dataset_ID)    
    ,[DS_Data_Account_ID] [int] NOT NULL    CONSTRAINT FK_PowrePlan_DSAcctDatasetMap_DSDataAccount_DSDataAccountID
                                            FOREIGN KEY (DS_Data_Account_ID)
                                            REFERENCES PowerPlan.DS_Data_Account(DS_Data_Account_ID)
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Analysis_Account_ID] [int] NULL           CONSTRAINT FK_PowerPlan_DSAcctDatasetMap_AnalysisAccount_AnalysisAccountID
                                                FOREIGN KEY (Analysis_Account_ID)
                                                REFERENCES PowerPlan.Analysis_Account(Analysis_Account_ID)
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_DSAcctDatasetMap_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_DSAcctDatasetMap_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_DSAcctDatasetMap_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_DSAcctDatasetMap_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_DSAcctDatasetMap_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
    ,CONSTRAINT PK_PowerPlan_DSDAcctDatasetMap PRIMARY KEY ([DS_Analysis_Dataset_ID], [DS_Data_Account_ID])
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(C)  [05] The Dataset Account Map table stores the relationships between the depreciation study data account, which is the lowest level of detail, and analysis account, which is the level for performing analysis.  Two functions are accomplished via this table.  First, which data accounts to include in the analysis dataset, and second, any rollup or combination of data accounts into analysis accounts.  This is used as criteria for building analysis transactions from the depreciation study data transaction table.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Acct_Dataset_Map';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK)(fk) System-assigned identifier of a particular depr study analysis dataset.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Acct_Dataset_Map',
    @level2type=N'COLUMN', @level2name=N'DS_Analysis_Dataset_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK)(fk) System-assigned identifier of a particular depr study data account.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Acct_Dataset_Map',
    @level2type=N'COLUMN', @level2name=N'DS_Data_Account_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Acct_Dataset_Map',
    @level2type=N'COLUMN', @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Acct_Dataset_Map',
    @level2type=N'COLUMN', @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a particular depr study analysis account.  Can be rollup of data accounts.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Acct_Dataset_Map',
    @level2type=N'COLUMN', @level2name=N'Analysis_Account_ID';
GO


PRINT '-- PowerPlan.Summary_Transaction_Code';
CREATE TABLE PowerPlan.Summary_Transaction_Code
(
    [Summary_Trans_ID] [int] NOT NULL
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Summary_Trans] [nvarchar](35) NOT NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_SummaryTransactionCode_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_SummaryTransactionCode_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_SummaryTransactionCode_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_SummaryTransactionCode_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_SummaryTransactionCode_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
    ,CONSTRAINT PK_PowerPlan_SummaryTransactionCode PRIMARY KEY ([Summary_Trans_ID])
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(O) [05] Analysis Depr Group is defined as part of an analysis dataset and is included in all scenarios (versions) for that analysis dataset.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Summary_Transaction_Code';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) ID number of one of four main transaction types: 1. Additions, 2. Retirements, 3. Balances, 4. Net Salvage',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Summary_Transaction_Code',
    @level2type=N'COLUMN', @level2name=N'Summary_Trans_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard System-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Summary_Transaction_Code',
    @level2type=N'COLUMN', @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard System-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Summary_Transaction_Code',
    @level2type=N'COLUMN', @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Description of each Summary Transaction Type.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Summary_Transaction_Code',
    @level2type=N'COLUMN', @level2name=N'Summary_Trans';
GO

PRINT '-- PowerPlan.Analysis_Transaction_Code';
CREATE TABLE PowerPlan.Analysis_Transaction_Code
(
    [Analysis_Trans_ID] [int] NOT NULL
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Analysis_Transaction_Code] [nvarchar](35) NOT NULL
    ,[Summary_Trans_ID] [int] NOT NULL      CONSTRAINT FK_PowerPlan_AnalysisTransactionCode_SummaryTransactionCode_SummaryTransID
                                            FOREIGN KEY (Summary_Trans_ID)
                                            REFERENCES PowerPlan.Summary_Transaction_Code(Summary_Trans_ID)
    ,[Adjustment_Transaction] [int] NULL    CONSTRAINT DK_PowerPlan_AnalysisTransactionCode_AdjustmentTransaction   DEFAULT (0)
    ,[Sum_Factor] [int] NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_AnalysisTransactionCode_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_AnalysisTransactionCode_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_AnalysisTransactionCode_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_AnalysisTransactionCode_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_AnalysisTransactionCode_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
    ,CONSTRAINT PK_PowerPlan_AnalysisTransactionCode PRIMARY KEY ([Analysis_Trans_ID])
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(F) [05] Contains the transaction codes use to identify an account transaction for specified vintage and activity years.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Transaction_Code';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) System-assigned ID number for each plant transaction.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Transaction_Code',
    @level2type=N'COLUMN', @level2name=N'Analysis_Trans_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Transaction_Code',
    @level2type=N'COLUMN', @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Transaction_Code',
    @level2type=N'COLUMN', @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records a short description of each plant transaction (see above).',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Transaction_Code',
    @level2type=N'COLUMN', @level2name=N'Analysis_Transaction_Code';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of the four transaction types.  1 = Additions, 2 = Retirements, 3 = Balances, 4 = Net Salvage.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Transaction_Code',
    @level2type=N'COLUMN', @level2name=N'Summary_Trans_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Indicates if transaction code is used: 0 = normal transactions (default); 1 = adjustment transactions.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Transaction_Code',
    @level2type=N'COLUMN', @level2name=N'Adjustment_Transaction';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Factor (1 or -1) applied to transaction amounts in calculating balances.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Analysis_Transaction_Code',
    @level2type=N'COLUMN', @level2name=N'Sum_Factor';
GO

PRINT '-- PowerPlan.Transaction_Input_Type';
CREATE TABLE PowerPlan.Transaction_Input_Type
(
    [Transaction_Input_Type_ID] [int] NOT NULL
    ,[User_ID] varchar(18) NULL
    ,[Time_Stamp] datetime2 NULL
    ,[Transaction_Input_Type] [nvarchar](35) NOT NULL
    ,[Edit_Flag] [int] NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_TransactionInputType_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_TransactionInputType_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_TransactionInputType_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_TransactionInputType_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_TransactionInputType_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
    ,CONSTRAINT PK_PowerPlan_TransactionInputType PRIMARY KEY ([Transaction_Input_Type_ID])
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(F)  [05] This table contains the descriptions of the different transaction types found in the aged_transaction table for depreciation studies.  Transaction types are 1) Analyst Input, 2) Plant (PowerPlan), and 3) Derived.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Transaction_Input_Type';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) System-assigned ID of transaction type.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Transaction_Input_Type',
    @level2type=N'COLUMN', @level2name=N'Transaction_Input_Type_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard System-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Transaction_Input_Type',
    @level2type=N'COLUMN', @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard System-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Transaction_Input_Type',
    @level2type=N'COLUMN', @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(description) The description of the transaction input type.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Transaction_Input_Type',
    @level2type=N'COLUMN', @level2name=N'Transaction_Input_Type';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Controls if transactions using this transaction input type can be edited online.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Transaction_Input_Type',
    @level2type=N'COLUMN', @level2name=N'Edit_Flag';
GO

PRINT '-- PowerPlan.DS_Dataset_External_Trans';
CREATE TABLE PowerPlan.DS_Dataset_External_Trans
(
    [DS_Trans_ID] [int] NOT NULL
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[DS_Analysis_Dataset_ID] [int] NOT NULL    CONSTRAINT FK_PowerPlan_DSDatasetExternalTrans_DSAnalysisDataset_DSAnalysisDatasetID
                                                FOREIGN KEY (DS_Analysis_Dataset_ID)
                                                REFERENCES PowerPlan.DS_Analysis_Dataset(DS_Analysis_Dataset_ID)
    ,[Analysis_Account_ID] [int] NULL           CONSTRAINT FK_PowerPlan_DSDatasetExternalTrans_AnalysisAccount_AnalysisAccountID
                                                FOREIGN KEY (Analysis_Account_ID)
                                                REFERENCES PowerPlan.Analysis_Account(Analysis_Account_ID)
    ,[Analysis_Trans_ID] [int] NOT NULL         CONSTRAINT FK_PowerPlan_DSDatasetExternalTrans_AnalysisTransactionCode_AnalysisTransID
                                                FOREIGN KEY (Analysis_Trans_ID)
                                                REFERENCES PowerPlan.Analysis_Transaction_Code(Analysis_Trans_ID)
    ,[Vintage] [smallint] NULL
    ,[Activity_Year] [smallint] NOT NULL
    ,[Adjustment_Year] [smallint] NULL
    ,[Effective_Date] datetime2 NULL
    ,[Amount] NUMERIC(22,2) NULL
    ,[Quantity] NUMERIC(22,2) NULL
    ,[Transaction_Input_Type_ID] [int] NULL     CONSTRAINT DK_PowerPlan_DSDatasetExternalTrans_TransactionInputType_TransactionInputTypeID
                                                FOREIGN KEY (Transaction_Input_Type_ID)
                                                REFERENCES PowerPlan.Transaction_Input_Type(Transaction_Input_Type_ID)
    ,[Description] [nvarchar](254) NULL
    ,[Message] [nvarchar](254) NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_DSDatasetExternalTrans_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_DSDatasetExternalTrans_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_DSDatasetExternalTrans_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_DSDatasetExternalTrans_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_DSDatasetExternalTrans_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
    ,CONSTRAINT PK_PowerPlan_DSDatasetExternalTrans PRIMARY KEY ([DS_Trans_ID], [DS_Analysis_Dataset_ID])
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(O)  [05] The DS Dataset External Trans table is used to stage external plant and reserve accounting records that are being merged with the standard plant and reserve dataset transactions. This table is populated when a user selects a tab delimited text file containing either aged or unaged data to import. Once the data is staged and verified the user has the option to load these transactions into the appropriate dataset transaction table (either DS Dataset Transaction table or  DS Dataset Rsrv Transaction).',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Dataset_External_Trans';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) System-assigned (dumb) key to uniquely identify each transaction.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Dataset_External_Trans',
    @level2type=N'COLUMN', @level2name=N'DS_Trans_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Dataset_External_Trans',
    @level2type=N'COLUMN', @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Dataset_External_Trans',
    @level2type=N'COLUMN', @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK)(fk) System-assigned identifier of a particular depr study analysis dataset.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Dataset_External_Trans',
    @level2type=N'COLUMN', @level2name=N'DS_Analysis_Dataset_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a particular depr study analysis account.  Can be rollup of data accounts.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Dataset_External_Trans',
    @level2type=N'COLUMN', @level2name=N'Analysis_Account_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a particular analysis transaction.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Dataset_External_Trans',
    @level2type=N'COLUMN', @level2name=N'Analysis_Trans_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(Engineering) in-service year of plant addition. (4 digits)',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Dataset_External_Trans',
    @level2type=N'COLUMN', @level2name=N'Vintage';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Year of transaction activity, when posted to the companys books.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Dataset_External_Trans',
    @level2type=N'COLUMN', @level2name=N'Activity_Year';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Adjusting year, when the posting year does not reflect the event year, e.g. a retiremetn of vintage 1955 property, posted in 2004, but out-of-service in 2003.  2003 would be the adjusting year.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Dataset_External_Trans',
    @level2type=N'COLUMN', @level2name=N'Adjustment_Year';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Effective date of the transaction (dependent of the CPR unit of measure).',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Dataset_External_Trans',
    @level2type=N'COLUMN', @level2name=N'Effective_Date';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Dollar amount of the transaction.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Dataset_External_Trans',
    @level2type=N'COLUMN', @level2name=N'Amount';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Physical quantity of the transaction (dependent of the CPR unit of measure).',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Dataset_External_Trans',
    @level2type=N'COLUMN', @level2name=N'Quantity';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of the External transaction input type.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Dataset_External_Trans',
    @level2type=N'COLUMN', @level2name=N'Transaction_Input_Type_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'User editable description about the transaction.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Dataset_External_Trans',
    @level2type=N'COLUMN', @level2name=N'Description';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'System-assigned identifier of load status.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Dataset_External_Trans',
    @level2type=N'COLUMN', @level2name=N'Message';
GO

PRINT '-- PowerPlan.DS_DG_Dataset_Map';
CREATE TABLE PowerPlan.DS_DG_Dataset_Map
(
    [DS_Analysis_Dataset_ID] [int] NOT NULL     CONSTRAINT FK_PowerPlan_DSDGDatasetMap_DSAnalysisDataset_DSAnalysisDatasetID
                                                FOREIGN KEY (DS_Analysis_Dataset_ID)
                                                REFERENCES PowerPlan.DS_Analysis_Dataset(DS_Analysis_Dataset_ID)   
    ,[Depr_Group_ID] [int] NOT NULL             CONSTRAINT FK_PowerPlan_DSDGDatasetMap_DeprGroup_DeprGroupID
                                                FOREIGN KEY (Depr_Group_ID)
                                                References PowerPlan.Depr_Group(Depr_Group_ID)
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Analysis_Depr_Group_ID] [int] NOT NULL    CONSTRAINT FK_PowerPlan_DSDGDatasetMap_AnalysisDeprGroup_AnalysisDeprGroupID
                                                FOREIGN KEY (Analysis_Depr_Group_ID)
                                                REFERENCES PowerPlan.Analysis_Depr_Group(Analysis_Depr_Group_ID)
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_DSDGDatasetMap_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_DSDGDatasetMap_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_DSDGDatasetMap_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_DSDGDatasetMap_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_DSDGDatasetMap_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
    ,CONSTRAINT PK_PowerPlan_DSDGDatasetMap PRIMARY KEY ([DS_Analysis_Dataset_ID], [Depr_Group_ID])
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(C)  [05] The Dataset Depreciation Group Map table stores the relationships between the PowerPlan depreciation group, which is the lowest level of detail, and analysis depreciation group, which is the level at which performing analysis.  Two functions are accomplished via this table.  First, which depreciation groups to include in the analysis dataset, and second, any rollup or combination of depreciation groups into analysis depreciation groups.  This is used as criteria for building analysis dataset depreciation ledger and dataset reserve transaction tables from the base depreciation ledger and reserve transaction tables.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_DG_Dataset_Map';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK)(fk) System-assigned identifier of a particular depr study analysis dataset.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_DG_Dataset_Map',
    @level2type=N'COLUMN', @level2name=N'DS_Analysis_Dataset_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK)(fk) System-assigned identifier of a particular depreciation group.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_DG_Dataset_Map',
    @level2type=N'COLUMN', @level2name=N'Depr_Group_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_DG_Dataset_Map',
    @level2type=N'COLUMN', @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_DG_Dataset_Map',
    @level2type=N'COLUMN', @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a particular depr study analysis depreciation group.  Can be rollup of base depreciation groups.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_DG_Dataset_Map',
    @level2type=N'COLUMN', @level2name=N'Analysis_Depr_Group_ID';
GO


PRINT '-- Depr.Salvage_History';
CREATE TABLE Depr.Salvage_History
(
    [Salvage_History_ID] [int] NOT NULL IDENTITY(1,1)
    ,[Analysis_Account_ID] [int] NULL       CONSTRAINT FK_PowerPlan_SavlageAnalysis_AnalysisAccount_AnalysisAccountID
                                            FOREIGN KEY (Analysis_Account_ID)
                                            REFERENCES PowerPlan.Analysis_Account(Analysis_Account_ID)
    ,[Analysis_Version_ID] [int] NULL       CONSTRAINT FK_PowerPlan_SalvageAnalysis_AnalysisVersion_AnalysisVersionID
                                            FOREIGN KEY (Analysis_Version_ID)
                                            REFERENCES PowerPlan.Analysis_Version(Analysis_Version_ID)
    ,[Band_Width] [int] NULL
    ,[Activity_Year] [smallint] NOT NULL
    ,[Vintage] [smallint] NULL
    ,[Retirements] NUMERIC(22,2) NULL
    ,[Salvage_Amt] NUMERIC(22,2) NULL
    ,[Salvage_Pct] NUMERIC(22,8) NULL
    ,[Salvage_Avg] NUMERIC(22,4) NULL
    ,[Cost_of_Removal_Amt] NUMERIC(22,2) NULL
    ,[Cost_of_Removal_Pct] NUMERIC(22,8) NULL
    ,[Cost_of_Removal_Avg] NUMERIC(22,4) NULL
    ,[Net_Salvage_Amt] NUMERIC(22,2) NULL
    ,[Net_Salvage_Pct] NUMERIC(22,8) NULL
    ,[Net_Salvage_Avg] NUMERIC(22,4) NULL
    ,[Salvage_Returns_Amt] NUMERIC(22,2) NULL
    ,[Salvage_Returns_Pct] NUMERIC(22,8) NULL
    ,[Salvage_Returns_Avg] NUMERIC(22,4) NULL
    ,[Depr_Group] [nvarchar](35) NULL
    ,[Source] [nvarchar](3) NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_SalvageHistory_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_SalvageHistory_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_SalvageHistory_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_SalvageHistory_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_SalvageHistory_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
    ,CONSTRAINT PK_Depr_SalvageHistory      PRIMARY KEY ([Salvage_History_ID])
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Dataset of Historical Net Salvage',
    @level0type=N'SCHEMA', @level0name=N'Depr',
    @level1type=N'TABLE',  @level1name=N'Salvage_History';
GO