USE [SONGS]
GO

IF OBJECT_ID ( 'PowerPlan.Report_Study7060','U') IS NOT NULL
    DROP TABLE PowerPlan.Report_Study7060;
GO

PRINT '-- PowerPlan.Report_Study7060';
CREATE TABLE PowerPlan.Report_Study7060
(
    [Analysis_Account_ID] [int] NOT NULL        CONSTRAINT FK_PowerPlan_ReportStudy7060_AnalysisAccount_AnalysisAccountID
                                                FOREIGN KEY (Analysis_Account_ID)
                                                REFERENCES PowerPlan.Analysis_Account(Analysis_Account_ID)
    ,[Analysis_Version_ID] [int] NOT NULL       CONSTRAINT FK_PowerPlan_ReportStudy7060_AnalysisVersion_AnalysisVersionID
                                                FOREIGN KEY (Analysis_Version_ID)
                                                REFERENCES PowerPlan.Analysis_Version(Analysis_Version_ID)   
    ,[Exposures] numeric(22,2) NULL
    ,[Retires] numeric(22,2) NULL
    ,[Abs_Age] [int] NOT NULL                   CONSTRAINT DK_PowerPlan_ReportStudy7060_AbsAge DEFAULT 0
    ,[Beg_Age] NUMERIC(22,2) NULL
    ,[Retire_Ratio] float NULL
    ,[Surv_Ratio] float NULL
    ,[pexposures] numeric(22,2) NULL
    ,[pretires] numeric(22,2) NULL
    ,[pabsolute_age] [int] NULL
    ,[page] NUMERIC(22,2) NULL
    ,[pretire_ratio] float NULL
    ,[psurv_ratio] float NULL
    ,[start_month] datetime2 NULL
    ,[end_month] datetime2 NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_ReportStudy7060_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_ReportStudy7060_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_ReportStudy7060_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_ReportStudy7060_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_ReportStudy7060_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
    ,CONSTRAINT PK_PowerPlan_ReportStudy7060 PRIMARY KEY (Analysis_Version_ID,Analysis_Account_ID,Abs_Age)
);
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Observed Life Report',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Report_Study7060';
GO