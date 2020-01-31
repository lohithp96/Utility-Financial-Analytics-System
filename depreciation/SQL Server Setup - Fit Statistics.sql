USE [SONGS]
GO

IF OBJECT_ID ( 'PowerPlan.Fit_Statistics','U') IS NOT NULL
    DROP TABLE PowerPlan.Fit_Statistics;
GO
IF OBJECT_ID ( 'PowerPlan.Fit_Stats_All','U') IS NOT NULL
    DROP TABLE PowerPlan.Fit_Stats_All;
GO

PRINT '-- PowerPlan.Fit_Statistics';
CREATE TABLE PowerPlan.Fit_Statistics
(
    [Trial_ID] [INT] NOT NULL
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Analysis_Account_ID] [int] NULL           CONSTRAINT FK_PowerPlan_FitStatistics_AnalysisAccount_AnalysisAccountID
                                                FOREIGN KEY (Analysis_Account_ID)
                                                REFERENCES PowerPlan.Analysis_Account(Analysis_Account_ID)
    ,[Analysis_Version_ID] [int] NULL           CONSTRAINT FK_PowerPlan_FitStatistics_AnalysisVersion_AnalysisVersionID
                                                FOREIGN KEY (Analysis_Version_ID)
                                                REFERENCES PowerPlan.Analysis_Version(Analysis_Version_ID)    
    ,[Observation_Start_Year] [int] NULL
    ,[Observation_End_Year] [int] NULL
    ,[Censoring] numeric(22,2) NULL
    ,[Average_Life_1] numeric(22,2) NULL
    ,[Conformance_Index_1] numeric(22,2) NULL
    ,[Flag_1] char(1) NULL
    ,[Dispersion_1] [int] NULL
    ,[Average_Life_2] numeric(22,2) NULL
    ,[Conformance_Index_2] numeric(22,2) NULL
    ,[Flag_2] char(1) NULL
    ,[Dispersion_2] [int] NULL
    ,[Average_Life_3] numeric(22,2) NULL
    ,[Conformance_Index_3] numeric(22,2) NULL
    ,[Flag_3] char(1) NULL
    ,[Dispersion_3] [int] NULL
    ,[Age] NUMERIC(22,2) NULL
    ,[Error_Sum_Squares] NUMERIC(22,8) NULL
    ,[Best_Fit_Curve] [int] NULL
    ,[Best_Fit_ASL] NUMERIC(22,2) NULL
    ,[Placement_Start_Year] [int] NULL
    ,[Placement_End_Year] [int] NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_FitStatistics_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_FitStatistics_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_FitStatistics_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_FitStatistics_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_FitStatistics_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
    ,CONSTRAINT PK_PowerPlan_FitStatistics PRIMARY KEY ([Trial_ID])
);
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(C)  [05] Fit Statistics is filled in when running actuarial life analysis.  The system automatically processes each curve from the mortality curve table (indicated as USE on that table) by fitting polynomials of 1st, 2nd and 3rd degrees.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Fit_Statistics';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) System-assigned trial number.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Statistics',
    @level2type=N'COLUMN',  @level2name=N'Trial_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Statistics',
    @level2type=N'COLUMN',  @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard System-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Statistics',
    @level2type=N'COLUMN',  @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) The current depreciation study account selected by the user.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Statistics',
    @level2type=N'COLUMN',  @level2name=N'Analysis_Account_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) The current depreciation study case.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Statistics',
    @level2type=N'COLUMN',  @level2name=N'Analysis_Version_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'The beginning year of the current observation band (Activity year).',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Statistics',
    @level2type=N'COLUMN',  @level2name=N'Observation_Start_Year';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'The end year of the current observation band (Activity year).',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Statistics',
    @level2type=N'COLUMN',  @level2name=N'Observation_End_Year';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'The cumulative proportion surviving at the end of the last age interval of the observed life table for each observation band.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Statistics',
    @level2type=N'COLUMN',  @level2name=N'Censoring';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'The best fitting average life calculated for Dispersion 1.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Statistics',
    @level2type=N'COLUMN',  @level2name=N'Average_Life_1';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Measures the goodness of fit for the first degree polynomial.  The CI is the average observed plant balance for the years in test band divided by residual measure.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Statistics',
    @level2type=N'COLUMN',  @level2name=N'Conformance_Index_1';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Indicates if graduated hazard function exhibits negative values over a range of fitted hazard rates.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Statistics',
    @level2type=N'COLUMN',  @level2name=N'Flag_1';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) The ID of the best fitting Iowa curve for the 1st degree polynomial.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Statistics',
    @level2type=N'COLUMN',  @level2name=N'Dispersion_1';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'The ID of the best fitting Iowa Curve for the 2nd degree polynomial.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Statistics',
    @level2type=N'COLUMN',  @level2name=N'Average_Life_2';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Measures the goodness of fit for the second degree polynomial.  Measures CI for 2nd degree polynomial fit.  The CI is the average observed plant balance for the years in test band divided by residual measure.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Statistics',
    @level2type=N'COLUMN',  @level2name=N'Conformance_Index_2';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Flag for 2nd degree polynomial fit.  Flag2 indicates if graduated hazard function exhibits negative values over a range of fitted hazard rates.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Statistics',
    @level2type=N'COLUMN',  @level2name=N'Flag_2';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) The ID of the best fitting Iowa curve for the 2nd degree polynomial.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Statistics',
    @level2type=N'COLUMN',  @level2name=N'Dispersion_2';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'The bets fitting average life calculation for Dispersion 3.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Statistics',
    @level2type=N'COLUMN',  @level2name=N'Average_Life_3';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Measures the goodness of fit for the second degree polynomial.  Measures CI for 3rd degree polynomial fit.  The CI is the average observed plant balance for the years in test band divided by residual measure.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Statistics',
    @level2type=N'COLUMN',  @level2name=N'Conformance_Index_3';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Flag for 3rd degree polynomial fit.  Flag3 indicates if graduated hazard function exhibits negative values over a range of fitted hazard rates.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Statistics',
    @level2type=N'COLUMN',  @level2name=N'Flag_3';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) The ID of the best fitting Iowa curve for the 3rd degree polynomial.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Statistics',
    @level2type=N'COLUMN',  @level2name=N'Dispersion_3';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'The age of the surviving plant for the survivorship function.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Statistics',
    @level2type=N'COLUMN',  @level2name=N'Age';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'The minimum sum of squares used in identifying the best fitting dispersion and average service life under the survivorship function.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Statistics',
    @level2type=N'COLUMN',  @level2name=N'Error_Sum_Squares';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'The best fitting Iowa Curve ID using the survivorship function.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Statistics',
    @level2type=N'COLUMN',  @level2name=N'Best_Fit_Curve';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'The best fitting service life for the survivorship function.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Statistics',
    @level2type=N'COLUMN',  @level2name=N'Best_Fit_ASL';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Beginning of the vintage year band.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Statistics',
    @level2type=N'COLUMN',  @level2name=N'Placement_Start_Year';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'End of the vintage year band.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Statistics',
    @level2type=N'COLUMN',  @level2name=N'Placement_End_Year';
GO

PRINT '-- PowerPlan.Fit_Stats_All';
CREATE TABLE PowerPlan.Fit_Stats_All
(
    [Trial_ID] [INT] NOT NULL
    ,[Mortality_Curve_ID] [int] NOT NULL        CONSTRAINT FK_PowerPlan_FitStatsAll_MortalityCurveID
                                                FOREIGN KEY (Mortality_Curve_ID)
                                                REFERENCES PowerPlan.Mortality_Curve(Mortality_Curve_ID)
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Conformance_Index_1] numeric(22,8) NULL
    ,[Sum_Sq_Diff_1] numeric(22,8) NULL
    ,[Conformance_Index_2] numeric(22,8) NULL
    ,[Sum_Sq_Diff_2] numeric(22,8) NULL
    ,[Conformance_Index_3] numeric(22,8) NULL
    ,[Sum_Sq_Diff_3] numeric(22,8) NULL
    ,[Average_Life_1] numeric(22,2) NULL
    ,[Average_Life_2] numeric(22,2) NULL
    ,[Average_Life_3] numeric(22,2) NULL
    ,[Age] numeric(22,2) NULL
    ,[Error_Sum_Squares] NUMERIC(22,8) NULL
    ,[Fit_ASL] NUMERIC(22,2) NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_FitStatsAll_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_FitStatsAll_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_FitStatsAll_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_FitStatsAll_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_FitStatsAll_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
    ,CONSTRAINT PK_PowerPlan_FitStatsAll PRIMARY KEY ([Trial_ID],[Mortality_Curve_ID])
);
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(C)  [05] The Fit Stats All table contains the best fit statistics for each curve, for each of the three polynomial fits.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Fit_Stats_All';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) System-assigned identifier of a particular trial.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Stats_All',
    @level2type=N'COLUMN',  @level2name=N'Trial_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK)(fk) System-assigned identifier of a particular Iowa curve.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Stats_All',
    @level2type=N'COLUMN',  @level2name=N'Mortality_Curve_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Stats_All',
    @level2type=N'COLUMN',  @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Stats_All',
    @level2type=N'COLUMN',  @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Conformance index for the 1st degree polynomial.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Stats_All',
    @level2type=N'COLUMN',  @level2name=N'Conformance_Index_1';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Sum of squared differences for the 1st degree polynomial.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Stats_All',
    @level2type=N'COLUMN',  @level2name=N'Sum_Sq_Diff_1';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Conformance index for the 2nd degree polynomial.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Stats_All',
    @level2type=N'COLUMN',  @level2name=N'Conformance_Index_2';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Sum of squared differences for the 2nd degree polynomial.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Stats_All',
    @level2type=N'COLUMN',  @level2name=N'Sum_Sq_Diff_2';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Conformance index for the 3rd degree polynomial.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Stats_All',
    @level2type=N'COLUMN',  @level2name=N'Conformance_Index_3';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Sum of squared differences for the 3rd degree polynomial.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Stats_All',
    @level2type=N'COLUMN',  @level2name=N'Sum_Sq_Diff_3';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Average life yielding the best fit for this Iowa curve and a 1rst degree polynomial.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Stats_All',
    @level2type=N'COLUMN',  @level2name=N'Average_Life_1';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Average life yielding the best fit for this Iowa curve and a 2nd degree polynomial.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Stats_All',
    @level2type=N'COLUMN',  @level2name=N'Average_Life_2';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Average life yielding the best fit for this Iowa curve and a 3rd degree polynomial.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Stats_All',
    @level2type=N'COLUMN',  @level2name=N'Average_Life_3';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'The maximum age of the life table that was used by the survivorship function fitting routine for this trial.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Stats_All',
    @level2type=N'COLUMN',  @level2name=N'Age';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'The Sum of Squares Difference between the life table and the ASL/Mortality Curve combination identified by the survivorship function.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'Fit_Stats_All',
    @level2type=N'COLUMN',  @level2name=N'Error_Sum_Squares';
GO
