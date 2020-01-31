USE [SONGS]
GO

IF OBJECT_ID ( 'Depr.Solver_Model','U') IS NOT NULL
    DROP TABLE Depr.Solver_Model;
GO
IF OBJECT_ID ( 'Depr.Solver_Model_Master','U') IS NOT NULL
    DROP TABLE PowerPlan.Solver_Model_Master;
GO
IF OBJECT_ID ( 'Depr.Solver_Results','U') IS NOT NULL
    DROP TABLE PowerPlan.Solver_Results;
GO
IF OBJECT_ID ( 'Depr.Solver_Source','U') IS NOT NULL
    DROP TABLE Depr.Solver_Source;
GO

PRINT '--Depr.Solver_Source';
CREATE TABLE Depr.Solver_Source
(
    [Solver_Source_ID]          CHAR(2)         NOT NULL
    ,[Solver_Source]            NVARCHAR(35)    NOT NULL
    ,[CreatedBy]                NVARCHAR(50)    NOT NULL    CONSTRAINT DK_Depr_SolverSource_CreatedBy                       DEFAULT USER_NAME()
    ,[CreatedDate]              DATETIME2(2)    NOT NULL    CONSTRAINT DK_Depr_SolverSource_CreatedDate                     DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy]            NVARCHAR(256)       NULL
    ,[LastUpdatedDate]          DATETIME2(2)        NULL
    ,[rowguid] UNIQUEIDENTIFIER ROWGUIDCOL      NOT NULL    CONSTRAINT DK_Depr_SolverSource_rowguid                         DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber]            ROWVERSION
    ,[ValidFrom]                DATETIME2(2)    NOT NULL    CONSTRAINT DK_Depr_SolverSource_ValidFrom                       DEFAULT SYSUTCDATETIME()
    ,[ValidTo]                  DATETIME2(2)    NOT NULL    CONSTRAINT DK_Depr_SolverSource_ValidTo                         DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
    ,CONSTRAINT PK_Depr_SolverSource PRIMARY KEY ([Solver_Source_ID])
);
GO

PRINT '-- LOAD Depr.Solver_Source';
GO	
INSERT INTO Depr.Solver_Source (Solver_Source_ID,Solver_Source)
			VALUES ('DB','Solver Model'),
				   ('RC','Rate Case Parameters'),
				   ('PP','PowerPlan Analysis');
GO

PRINT '--Depr.Solver_Results';
CREATE TABLE Depr.Solver_Results
(
    [Trial_ID]                  INT             NOT NULL    IDENTITY(1,1)
    ,[Analysis_Account_ID]      INT                 NULL    CONSTRAINT  FK_Depr_SolverResults_AnalysisAccount_AnalysisAccountID
                                                            FOREIGN KEY (Analysis_Account_ID)
                                                            REFERENCES  PowerPlan.Analysis_Account(Analysis_Account_ID)
    ,[Analysis_Version_ID]      INT                 NULL    CONSTRAINT  FK_Depr_SolverResults_AnalysisVersion_AnalysisVersionID
                                                            FOREIGN KEY (Analysis_Version_ID)
                                                            REFERENCES  PowerPlan.Analysis_Version(Analysis_Version_ID)    
    ,[Average_Life]             NUMERIC(22,8)   NOT NULL    CONSTRAINT  DK_Depr_SolverResults_AverageLife                   DEFAULT 0
    ,[Direct_Difference]        NUMERIC(22,8)   NOT NULL    CONSTRAINT  DK_Depr_SolverResults_DirectDifference              DEFAULT 0
    ,[Absolute_Difference]      NUMERIC(22,8)   NOT NULL    CONSTRAINT  DK_Depr_SolverResults_AbsoluteDifference            DEFAULT 0
    ,[Squared_Difference]       NUMERIC(22,8)   NOT NULL    CONSTRAINT  DK_Depr_SolverResults_SquaredDifference             DEFAULT 0
    ,[Wtd_Squared_Difference]   NUMERIC(22,8)   NOT NULL    CONSTRAINT  DK_SolverResults_WtdSquaredDifference               DEFAULT 0
    ,[Solver_Source_ID]         CHAR(2)             NULL
    ,[CreatedBy]                NVARCHAR(50)    NOT NULL    CONSTRAINT  DK_Depr_SolverResults_CreatedBy                     DEFAULT USER_NAME()
    ,[CreatedDate]              DATETIME2(2)    NOT NULL    CONSTRAINT  DK_Depr_SolverResults_CreatedDate                   DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy]            NVARCHAR(256)       NULL
    ,[LastUpdatedDate]          DATETIME2(2)        NULL
    ,[rowguid] UNIQUEIDENTIFIER ROWGUIDCOL      NOT NULL    CONSTRAINT  DK_Depr_SolverResults_rowguid                       DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber]            ROWVERSION
    ,[ValidFrom]                DATETIME2(2)    NOT NULL    CONSTRAINT  DK_Depr_SolverResults_ValidFrom                     DEFAULT SYSUTCDATETIME()
    ,[ValidTo]                  DATETIME2(2)    NOT NULL    CONSTRAINT  DK_Depr_SolverResults_ValidTo                       DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
    ,CONSTRAINT PK_Depr_SolverResults PRIMARY KEY ([Trial_ID])
);
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Solver Results is filled in when running actuarial life analysis within the Depreciation System.  The system processes all selected curves for each selected model based on the fitting algorithm.',
    @level0type=N'SCHEMA', @level0name=N'Depr',
    @level1type=N'TABLE',  @level1name=N'Solver_Results';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) System-assigned trial number.',
    @level0type=N'SCHEMA',  @level0name=N'Depr',
    @level1type=N'TABLE',   @level1name=N'Solver_Results',
    @level2type=N'COLUMN',  @level2name=N'Trial_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) The current depreciation study account selected by the user.',
    @level0type=N'SCHEMA',  @level0name=N'Depr',
    @level1type=N'TABLE',   @level1name=N'Solver_Results',
    @level2type=N'COLUMN',  @level2name=N'Analysis_Account_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) The current depreciation study case.',
    @level0type=N'SCHEMA',  @level0name=N'Depr',
    @level1type=N'TABLE',   @level1name=N'Solver_Results',
    @level2type=N'COLUMN',  @level2name=N'Analysis_Version_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'The best fitting average life calculated based on designed algorithm.',
    @level0type=N'SCHEMA',  @level0name=N'Depr',
    @level1type=N'TABLE',   @level1name=N'Solver_Results',
    @level2type=N'COLUMN',  @level2name=N'Average_Life';
GO

PRINT '--Depr.Solver_Model_Master';
CREATE TABLE Depr.Solver_Model_Master
(
    [Age]                       NUMERIC(22,8)       NULL
    ,[Exposures]                NUMERIC(22,2)   NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModelMaster_Exposures            DEFAULT 0
    ,[Retires]                  NUMERIC(22,2)   NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModelMaster_Retires              DEFAULT 0
    ,[Surv_Ratio]               FLOAT           NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModelMaster_SurvRatio            DEFAULT 0
    ,[Retire_Ratio]             FLOAT           NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModelMaster_RetireRatio          DEFAULT 0
    ,[Surv_Pct]                 FLOAT           NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModelMaster_SurvPct              DEFAULT 0
    ,[Retire_Pct]               FLOAT           NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModelMaster_RetirePct            DEFAULT 0
    ,[Mortality_Curve_ID]       INT                 NULL    CONSTRAINT  FK_PowerPlan_SolverModelMaster_MortalityCurveID
                                                            FOREIGN KEY (Mortality_Curve_ID)
                                                            REFERENCES  PowerPlan.Mortality_Curve(Mortality_Curve_ID)
    ,[Model_Average_Life]       DECIMAL(22,8)   NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModelMaster_ExpectedAverageLife  DEFAULT 0
    ,[Model_Age]                NUMERIC(22,8)   NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModelMaster_ModelAge             DEFAULT 0
    ,[Model_pAgeIndex]          INT             NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModelMaster_ModelPAgeIndex       DEFAULT 0
    ,[Model_nAgeIndex]          INT             NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModelMaster_ModelNAgeIndex       DEFAULT 0
    ,[Model_pSurv_Pct]          FLOAT           NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModelMaster_ModelPSurvPct        DEFAULT 0
    ,[Model_nSurv_Pct]          FLOAT           NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModelMaster_ModelNSurvPct        DEFAULT 0
    ,[Model_Surv_Pct]           FLOAT           NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModelMaster_ModelSurvPct         DEFAULT 0
    ,[Direct_Diff]              FLOAT           NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModelMaster_DirectDiff           DEFAULT 0
    ,[Absolute_Diff]            FLOAT           NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModelMaster_AbsoluteDiff         DEFAULT 0
    ,[Squared_Diff]             FLOAT           NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModelMaster_SquaredDiff          DEFAULT 0
    ,[Wtd_Squared_Diff]         FLOAT           NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModelMaster_StdSquaredDiff       DEFAULT 0
    ,[CreatedBy]                NVARCHAR(50)    NOT NULL    CONSTRAINT  DK_Depr_SolverModelMaster_CreatedBy                 DEFAULT USER_NAME()
    ,[CreatedDate]              DATETIME2(2)    NOT NULL    CONSTRAINT  DK_Depr_SolverModelMaster_CreatedDate               DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy]            NVARCHAR(256)       NULL
    ,[LastUpdatedDate]          DATETIME2(2)        NULL
    ,[rowguid] UNIQUEIDENTIFIER ROWGUIDCOL      NOT NULL    CONSTRAINT DK_Depr_SolverModelMaster_rowguid                    DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber]            ROWVERSION
    ,[ValidFrom]                DATETIME2(2)    NOT NULL    CONSTRAINT  DK_Depr_SolverModelMaster_ValidFrom                 DEFAULT SYSUTCDATETIME()
    ,[ValidTo]                  DATETIME2(2)    NOT NULL    CONSTRAINT  DK_Depr_SolverModelMaster_ValidTo                   DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
    ,CONSTRAINT PK_Depr_SolverModelMaster PRIMARY KEY ([Age])
);
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Solver Model Master holds the core design setup for modeling OLT results.',
    @level0type=N'SCHEMA', @level0name=N'Depr',
    @level1type=N'TABLE',  @level1name=N'Solver_Model_Master';
GO

PRINT '--Depr.Solver_Model';
CREATE TABLE Depr.Solver_Model
(
    [Age]                       NUMERIC(22,8)   NOT NULL
    ,[Exposures]                NUMERIC(22,2)   NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModel_Exposures            DEFAULT 0
    ,[Retires]                  NUMERIC(22,2)   NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModel_Retires              DEFAULT 0
    ,[Surv_Ratio]               FLOAT           NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModel_SurvRatio            DEFAULT 0
    ,[Retire_Ratio]             FLOAT           NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModel_RetireRatio          DEFAULT 0
    ,[Surv_Pct]                 FLOAT           NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModel_SurvPct              DEFAULT 0
    ,[Retire_Pct]               FLOAT           NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModel_RetirePct            DEFAULT 0
    ,[Mortality_Curve_ID]       INT                 NULL    CONSTRAINT  FK_PowerPlan_SolverModel_MortalityCurveID
                                                            FOREIGN KEY (Mortality_Curve_ID)
                                                            REFERENCES  PowerPlan.Mortality_Curve(Mortality_Curve_ID)
    ,[Model_Average_Life]       DECIMAL(22,8)   NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModel_ExpectedAverageLife  DEFAULT 0
    ,[Model_Age]                NUMERIC(22,8)   NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModel_ModelAge             DEFAULT 0
    ,[Model_pAgeIndex]          INT             NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModel_ModelPAgeIndex       DEFAULT 0
    ,[Model_nAgeIndex]          INT             NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModel_ModelNAgeIndex       DEFAULT 0
    ,[Model_pSurv_Pct]          FLOAT           NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModel_ModelPSurvPct        DEFAULT 0
    ,[Model_nSurv_Pct]          FLOAT           NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModel_ModelNSurvPct        DEFAULT 0
    ,[Model_Surv_Pct]           FLOAT           NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModel_ModelSurvPct         DEFAULT 0
    ,[Direct_Diff]              FLOAT           NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModel_DirectDiff           DEFAULT 0
    ,[Absolute_Diff]            FLOAT           NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModel_AbsoluteDiff         DEFAULT 0
    ,[Squared_Diff]             FLOAT           NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModel_SquaredDiff          DEFAULT 0
    ,[Wtd_Squared_Diff]         FLOAT           NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModel_StdSquaredDiff       DEFAULT 0
    ,[CreatedBy]                NVARCHAR(50)    NOT NULL    CONSTRAINT  DK_Depr_SolverModel_CreatedBy                 DEFAULT USER_NAME()
    ,[CreatedDate]              DATETIME2(2)    NOT NULL    CONSTRAINT  DK_Depr_SolverModel_CreatedDate               DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy]            NVARCHAR(256)       NULL
    ,[LastUpdatedDate]          DATETIME2(2)        NULL
    ,[rowguid] uniqueidentifier ROWGUIDCOL      NOT NULL    CONSTRAINT DK_Depr_SolverModel_rowguid                    DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber]            ROWVERSION
    ,[ValidFrom]                DATETIME2(2)    NOT NULL    CONSTRAINT  DK_Depr_SolverModel_ValidFrom                 DEFAULT SYSUTCDATETIME()
    ,[ValidTo]                  DATETIME2(2)    NOT NULL    CONSTRAINT  DK_Depr_SolverModel_ValidTo                   DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
    ,CONSTRAINT PK_Depr_SolverModel PRIMARY KEY ([Age])
);
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Solver Model holds the OLT and modeled OLT results.',
    @level0type=N'SCHEMA', @level0name=N'Depr',
    @level1type=N'TABLE',  @level1name=N'Solver_Model';
GO