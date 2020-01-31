USE [SONGS]
GO

IF OBJECT_ID ( 'PowerPlan.Report_Asset1036A','U') IS NOT NULL
    DROP TABLE PowerPlan.Report_Asset1036A;
GO

PRINT '-- PowerPlan.Report_Asset1036A';
CREATE TABLE PowerPlan.Report_Asset1036A
(
    [Company_ID] [int] NOT NULL             CONSTRAINT DK_PowerPlan_ReportAsset1036A_CompanyID       DEFAULT 2100
    ,[Depr_Group_ID] [INT] NOT NULL         CONSTRAINT FK_PowerPlan_ReportAsset1036A_DeprGroup_DEPRGROUPID
                                            FOREIGN KEY (Depr_Group_ID)
                                            REFERENCES PowerPlan.Depr_Group(Depr_Group_ID)
    ,[GL_Account] NVARCHAR(35) NOT NULL
    ,[Utility_Account_ID] [int] NULL
    ,[Vintage] [int] NOT NULL
    ,[Effective_Date] date NOT NULL
    ,[Accumulated_Cost] numeric(22,2) NOT NULL  CONSTRAINT DK_PowerPlan_ReportAsset1036_AccumulatedCost DEFAULT 0
    ,[Allocated_Reserve] numeric(22,2) NOT NULL CONSTRAINT DK_PowerPlan_ReportAsset1036_AllocatedReserve DEFAULT 0
    ,[Net_Value] AS [Accumulated_Cost] - [Allocated_Reserve]
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_ReportAsset1036A_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_ReportAsset1036A_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_ReportAsset1036A_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_ReportAsset1036A_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_ReportAsset1036A_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
    ,CONSTRAINT PK_PowerPlan_ReportAsset1036A PRIMARY KEY (Company_ID, Depr_Group_ID, Vintage, Effective_Date)
);
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Net Value Report by Depr Group/ GL acct/Util Acct / Vintage',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Report_Asset1036A';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of the company to which the method applies.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Report_Asset1036A',
    @level2type=N'COLUMN',  @level2name=N'Company_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a particular depreciation group.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Report_Asset1036A',
    @level2type=N'COLUMN',  @level2name=N'Depr_Group_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) User-designated identifier of a unique plant account.  It can be a FERC utility plant account such as 314 or the Companys own account number structure.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Report_Asset1036A', 
    @level2type=N'COLUMN', @level2name=N'Utility_Account_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(Engineering) in-service year of plant addition. (4 digits)',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Report_Asset1036A',
    @level2type=N'COLUMN',  @level2name=N'Vintage';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Effective date of the transaction.  Provides month of activity if necessary.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Report_Asset1036A',
    @level2type=N'COLUMN',  @level2name=N'Effective_Date';
GO