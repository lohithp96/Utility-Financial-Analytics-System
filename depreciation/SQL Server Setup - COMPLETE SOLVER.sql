USE SONGS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Matthew C. Vanderbilt /00562
-- Create date: 06/02/2017 10:48
-- Description:	Runs Solver Model
-- =============================================
IF OBJECT_ID ( 'Depr.runSolver_Model_RateCase','P') IS NOT NULL
    DROP PROCEDURE Depr.runSolver_Model_RateCase;
GO
IF OBJECT_ID ( 'Depr.runSolver_Model_PowerPlan','P') IS NOT NULL
    DROP PROCEDURE Depr.runSolver_Model_PowerPlan;
GO
IF OBJECT_ID ( 'Depr.setSolver_Model_Master','P') IS NOT NULL
    DROP PROCEDURE Depr.setSolver_Model_Master;
GO
IF OBJECT_ID ( 'Depr.setSolver_Model','P') IS NOT NULL
    DROP PROCEDURE Depr.setSolver_Model;
GO
IF OBJECT_ID ( 'Depr.setSolver_Model_FitCurve','P') IS NOT NULL
    DROP PROCEDURE Depr.setSolver_Model_FitCurve;
GO
IF OBJECT_ID ( 'Depr.runSolver_Model_Loop','P') IS NOT NULL
    DROP PROCEDURE Depr.runSolver_Model_Loop;
GO
IF OBJECT_ID ( 'Depr.runSolver_Model_LoadCurve','P') IS NOT NULL
    DROP PROCEDURE Depr.runSolver_Model_LoadCurve;
GO
IF OBJECT_ID ( 'Depr.delSolver_Results','P') IS NOT NULL
    DROP PROCEDURE Depr.delSolver_Results
GO
IF OBJECT_ID ( 'Depr.Solver_Model','U') IS NOT NULL
    DROP TABLE Depr.Solver_Model;
GO
IF OBJECT_ID ( 'Depr.Solver_Model_Master','U') IS NOT NULL
    DROP TABLE Depr.Solver_Model_Master;
GO
/*****ENABLE THIS SECTION FOR TOTAL RESET **
IF OBJECT_ID ( 'Depr.Solver_Results','U') IS NOT NULL
    DROP TABLE Depr.Solver_Results;
GO*/
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
    ,[Analysis_Version_ID]      INT                 NULL    CONSTRAINT  FK_Depr_SolverResults_AnalysisVersion_AnalysisVersionID
                                                            FOREIGN KEY (Analysis_Version_ID)
                                                            REFERENCES  PowerPlan.Analysis_Version(Analysis_Version_ID)
    ,[Analysis_Account_ID]      INT                 NULL    CONSTRAINT  FK_Depr_SolverResults_AnalysisAccount_AnalysisAccountID
                                                            FOREIGN KEY (Analysis_Account_ID)
                                                            REFERENCES  PowerPlan.Analysis_Account(Analysis_Account_ID)
    ,[Mortality_Curve_ID]       INT                 NULL    CONSTRAINT  FK_PowerPlan_SolverResults_MortalityCurveID
                                                            FOREIGN KEY (Mortality_Curve_ID)
                                                            REFERENCES  PowerPlan.Mortality_Curve(Mortality_Curve_ID)    
    ,[Average_Life]             NUMERIC(22,8)   NOT NULL    CONSTRAINT  DK_Depr_SolverResults_AverageLife                   DEFAULT 0
    ,[Solver_Source_ID]         CHAR(2)             NULL    CONSTRAINT  FK_Depr_SolverResults_SolverSourceID
                                                            FOREIGN KEY (Solver_Source_ID)
                                                            REFERENCES  Depr.Solver_Source(Solver_Source_ID)
    ,[Trial_Counter]            NVARCHAR(35)        NULL    
    ,[Direct_Difference]        NUMERIC(22,8)   NOT NULL    CONSTRAINT  DK_Depr_SolverResults_DirectDifference              DEFAULT 0
    ,[Absolute_Difference]      NUMERIC(22,8)   NOT NULL    CONSTRAINT  DK_Depr_SolverResults_AbsoluteDifference            DEFAULT 0
    ,[Squared_Difference]       NUMERIC(22,8)   NOT NULL    CONSTRAINT  DK_Depr_SolverResults_SquaredDifference             DEFAULT 0
    ,[Wtd_Squared_Difference]   NUMERIC(22,8)   NOT NULL    CONSTRAINT  DK_SolverResults_WtdSquaredDifference               DEFAULT 0
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
    [Age]                       NUMERIC(22,8)   NOT NULL
    ,[Exposures]                NUMERIC(22,2)   NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModelMaster_Exposures            DEFAULT 0
    ,[Retires]                  NUMERIC(22,2)   NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModelMaster_Retires              DEFAULT 0
    ,[Surv_Ratio]               FLOAT           NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModelMaster_SurvRatio            DEFAULT 0
    ,[Retire_Ratio]             FLOAT           NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModelMaster_RetireRatio          DEFAULT 0
    ,[Surv_Pct]                 FLOAT           NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModelMaster_SurvPct              DEFAULT 0
    ,[Retire_Pct]               FLOAT           NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModelMaster_RetirePct            DEFAULT 0
    ,[Mortality_Curve_ID]       INT                 NULL    CONSTRAINT  FK_PowerPlan_SolverModelMaster_MortalityCurveID
                                                            FOREIGN KEY (Mortality_Curve_ID)
                                                            REFERENCES  PowerPlan.Mortality_Curve(Mortality_Curve_ID)
    ,[Model_Average_Life]       NUMERIC(22,8)   NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModelMaster_ExpectedAverageLife  DEFAULT 0
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
    ,[Analysis_Version_ID]      INT                 NULL    CONSTRAINT  FK_Depr_SolverModel_AnalysisVersion_AnalysisVersionID
                                                            FOREIGN KEY (Analysis_Version_ID)
                                                            REFERENCES  PowerPlan.Analysis_Version(Analysis_Version_ID)
    ,[Analysis_Account_ID]      INT                 NULL    CONSTRAINT  FK_Depr_SolverModel_AnalysisAccount_AnalysisAccountID
                                                            FOREIGN KEY (Analysis_Account_ID)
                                                            REFERENCES  PowerPlan.Analysis_Account(Analysis_Account_ID)
    ,[Mortality_Curve_ID]       INT                 NULL    CONSTRAINT  FK_PowerPlan_SolverModel_MortalityCurveID
                                                            FOREIGN KEY (Mortality_Curve_ID)
                                                            REFERENCES  PowerPlan.Mortality_Curve(Mortality_Curve_ID)
    ,[Solver_Source_ID]         CHAR(2)             NULL    CONSTRAINT  FK_Depr_SolverModel_SolverSourceID
                                                            FOREIGN KEY (Solver_Source_ID)
                                                            REFERENCES  Depr.Solver_Source(Solver_Source_ID)
    ,[Trial_Counter]            NVARCHAR(35)        NULL    
    ,[Model_Average_Life]       NUMERIC(22,8)   NOT NULL    CONSTRAINT  DK_PowerPlan_SolverModel_ExpectedAverageLife  DEFAULT 0
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

CREATE PROCEDURE	[Depr].[delSolver_Results] 
                    (
                        @Analysis_Account_ID INT = -1,
                        @Analysis_Version_ID INT = -1
                    )
					AS
					BEGIN
						-- SET NOCOUNT ON added to prevent extra result sets from
						-- interfering with SELECT statements.
						SET NOCOUNT ON;
						DELETE FROM Solver_Results WHERE Solver_Results.Analysis_Account_ID=@Analysis_Account_ID AND Solver_Results.Analysis_Version_ID=@Analysis_Version_ID
					END
					GO

CREATE PROCEDURE	Depr.setSolver_Model_Master 
                    (
                        @Age_Max NUMERIC(22,2) = 500.5
                    )
					AS
					BEGIN
						-- SET NOCOUNT ON added to prevent extra result sets from
						-- interfering with SELECT statements.
						SET NOCOUNT ON;
                        DECLARE @Age NUMERIC(22,2);
                        SET @Age = 0;
                        DELETE FROM Depr.Solver_Model_Master;
						WHILE @Age <= @Age_Max
                            BEGIN
                                INSERT INTO Depr.Solver_Model_Master(AGE) VALUES(@Age);
                                IF @Age=0
                                    SET @Age = 0.5;
                                ELSE
                                    SET @Age = @Age+1;
                            END;
					END
					GO

-- runSolver_Model_Loop
CREATE	PROCEDURE	Depr.runSolver_Model_Loop
		AS
		BEGIN
			DECLARE @Surv_Pct FLOAT = 1;
			DECLARE @Retire_Pct FLOAT = 0;
			DECLARE @Surv_Ratio FLOAT;
			DECLARE @Age NUMERIC(22,8);

			DECLARE increment CURSOR LOCAL FOR SELECT TOP (100) PERCENT m.Age, m.Surv_Ratio FROM Depr.Solver_Model m ORDER BY m.Age
			OPEN increment
			FETCH next FROM increment INTO @Age, @Surv_Ratio;
			
			WHILE @@FETCH_STATUS = 0 BEGIN
				UPDATE Depr.Solver_Model SET Depr.Solver_Model.Surv_Pct = @Surv_Pct, Depr.Solver_Model.Retire_Pct = @Retire_Pct WHERE Depr.Solver_Model.Age = @Age;
				SET @Surv_Pct = @Surv_Pct * @Surv_Ratio;
				SET @Retire_Pct = CAST(1 AS FLOAT) - @Surv_Pct;
				FETCH next FROM increment INTO @Age, @Surv_Ratio;
			END

			CLOSE increment
			DEALLOCATE increment
		END;
GO

-- runSolver_Model_LoadCurve
CREATE	PROCEDURE	Depr.runSolver_Model_LoadCurve
		(

			@Analysis_Account_ID INT = -1,
			@Analysis_Version_ID INT = -1,
			@Mortality_Curve_ID INT = -1,
			@Model_Average_Life NUMERIC(22,8)=-1,
            @Solver_Source_ID CHAR(2) = 'DB',
            @counterInsert NVARCHAR(35) = ''
		)
		AS
		BEGIN
			-- Clear Last Run
			UPDATE Depr.Solver_Model SET	Depr.Solver_Model.Analysis_Version_ID = @Analysis_Version_ID,
                                            Depr.Solver_Model.Analysis_Account_ID = @Analysis_Account_ID,
                                            Depr.Solver_Model.Solver_Source_ID = @Solver_Source_ID,
                                            Depr.Solver_Model.Trial_Counter = @counterInsert,
                                            Depr.Solver_Model.Mortality_Curve_ID = NULL,
										 	Depr.Solver_Model.Model_Average_Life = 0,
										 	Depr.Solver_Model.Model_Age = 0,
										 	Depr.Solver_Model.Model_pAgeIndex = 0,
											Depr.SOlver_Model.Model_nAgeIndex = 0,
										 	Depr.Solver_Model.Model_pSurv_Pct = 0,
										 	Depr.Solver_Model.Model_nSurv_Pct = 0,
										 	Depr.Solver_Model.Model_Surv_Pct = 0;
			
			-- Set Model Survivor Curve & ASL
			UPDATE Depr.Solver_Model SET	Depr.Solver_Model.Mortality_Curve_ID = @Mortality_Curve_ID,
										 	Depr.Solver_Model.Model_Average_Life = @Model_Average_Life,
											Depr.Solver_Model.Model_pAgeIndex = CASE ISNULL(@Model_Average_Life,0) WHEN 0 THEN 0 ELSE (CAST(CAST(100 AS NUMERIC(22,8))*CAST(Depr.Solver_Model.Age AS NUMERIC(22,8))/@Model_Average_Life AS INT) +1) END,
											Depr.Solver_Model.Model_nAgeIndex = CASE ISNULL(@Model_Average_Life,0) WHEN 0 THEN 0 ELSE (CAST(CAST(100 AS NUMERIC(22,8))*CAST(Depr.Solver_Model.Age AS NUMERIC(22,8))/@Model_Average_Life AS INT) +2) END;
		
			-- Set Modeled Survivors - Prior
			UPDATE Depr.Solver_Model SET	Model_pSurv_Pct = ISNULL(p.Surviving_Percentage,0)
									 FROM	Depr.Solver_Model AS m	INNER JOIN
									 		PowerPlan.Mortality_Curve_Points AS p ON
											m.Mortality_Curve_ID = p.Mortality_Curve_ID AND
											m.Model_pAgeIndex = p.Data_Point;

			-- Set Modeled Survivors - Next
			UPDATE Depr.Solver_Model SET	Model_nSurv_Pct = ISNULL(p.Surviving_Percentage,0)
									 FROM	Depr.Solver_Model AS m	INNER JOIN
									 		PowerPlan.Mortality_Curve_Points AS p ON
											m.Mortality_Curve_ID = p.Mortality_Curve_ID AND
											m.Model_nAgeIndex = p.Data_Point;

			-- Set Modeled Survivors
			UPDATE Depr.Solver_Model SET	Model_Surv_Pct = (m.Model_pSurv_Pct*(((CASE WHEN m.Model_Average_Life=0 THEN 0 ELSE CAST(m.Age AS NUMERIC(22,8))/m.Model_Average_Life END)-(CAST(CAST((CASE WHEN m.Model_Average_Life=0 THEN 0 ELSE CAST(m.Age AS NUMERIC(22,8))/m.Model_Average_Life END) AS INT) AS NUMERIC(22,8))+1))/((CAST(CAST((CASE WHEN m.Model_Average_Life=0 THEN 0 ELSE CAST(m.Age AS NUMERIC(22,8))/m.Model_Average_Life END) AS INT) AS NUMERIC(22,8))+0)-(CAST(CAST((CASE WHEN m.Model_Average_Life=0 THEN 0 ELSE CAST(m.Age AS NUMERIC(22,8))/m.Model_Average_Life END) AS INT) AS NUMERIC(22,8))+1))))+(m.Model_nSurv_Pct*(((CASE WHEN m.Model_Average_Life=0 THEN 0 ELSE CAST(m.Age AS NUMERIC(22,8))/m.Model_Average_Life END)-(CAST(CAST((CASE WHEN m.Model_Average_Life=0 THEN 0 ELSE CAST(m.Age AS NUMERIC(22,8))/m.Model_Average_Life END) AS INT) AS NUMERIC(22,8))))/((CAST(CAST((CASE WHEN m.Model_Average_Life=0 THEN 0 ELSE CAST(m.Age AS NUMERIC(22,8))/m.Model_Average_Life END) AS INT) AS NUMERIC(22,8))+1)-(CAST(CAST((CASE WHEN m.Model_Average_Life=0 THEN 0 ELSE CAST(m.Age AS NUMERIC(22,8))/m.Model_Average_Life END) AS INT) AS NUMERIC(22,8)))))) 
									 FROM	Depr.Solver_Model AS m;
			
			-- Calculate Squared Difference(s)
			UPDATE Depr.Solver_Model SET	Direct_Diff = m.Surv_Pct - m.Model_Surv_Pct,
											Absolute_Diff = ABS(m.Surv_Pct - m.Model_Surv_Pct),
											Squared_Diff= SQUARE(m.Surv_Pct - m.Model_Surv_Pct),
											Wtd_Squared_Diff = (SQUARE(m.Surv_Pct - m.Model_Surv_Pct)) * CASE	WHEN	m.Surv_Pct>0.8 THEN CAST(2 AS NUMERIC(22,8))
																												WHEN 	m.Surv_Pct>0.5 AND m.Surv_Pct<=0.8 THEN CAST(4 AS NUMERIC(22,8))
																												WHEN	m.Surv_Pct>0.2 AND m.Surv_Pct<=0.5 THEN CAST(3 AS NUMERIC(22,8)) 
																												WHEN	m.Surv_Pct<=0.2 THEN CAST(1 AS NUMERIC(22,8)) END
									 FROM	Depr.Solver_Model AS m;
			-- Save Results of Scenario
			INSERT INTO Depr.Solver_Results (
						Analysis_Version_ID,
                        Analysis_Account_ID,
                        Mortality_Curve_ID,
						Average_Life,
						Solver_Source_ID,
						Trial_Counter,
						Direct_Difference,
						Absolute_Difference,
						Squared_Difference,
						Wtd_Squared_Difference ) 
			SELECT	Analysis_Version_ID,
                    Analysis_Account_ID,
                    Mortality_Curve_ID,
					Model_Average_Life,
                    Solver_Source_ID,
                    Trial_Counter,
					SUM(m.Direct_Diff) AS sumDirectDiff,
					SUM(m.Absolute_Diff) AS sumAbsoluteDiff,
					SUM(m.Squared_Diff) AS sumSquaredDiff,
					SUM(m.Wtd_Squared_Diff) AS sumWtdSquaredDiff
			FROM	Depr.Solver_Model m
            GROUP BY m.Analysis_Version_ID, m.Analysis_Account_ID,  m.Mortality_Curve_ID, m.Model_Average_Life, m.SOlver_Source_ID, m.Trial_Counter; 
		END;
GO

-- setSolver_Model
CREATE	PROCEDURE	Depr.setSolver_Model 
		(
			@Analysis_Account_ID AS INT = -1,
			@Analysis_Version_ID AS INT = -1,
			@Model_Age_Min AS NUMERIC(22,8) = 1,
			@Model_Age_Limit AS NUMERIC(22,8) = 500.5
		)
		AS
		BEGIN
			-- SET NOCOUNT ON added to prevent extra result sets from
			-- interfering with SELECT statements.
			SET NOCOUNT ON;

			-- Declare / Initialize Variables
			DECLARE @MaxAge AS NUMERIC(22,8) = 500.5;
			DECLARE @Model_Age_Max AS NUMERIC(22,8) = 500.5;

			-- Clear Previous Model Run
			DELETE FROM Depr.Solver_Model;

			-- Determine Maximum Age from Observed Life Table Data (Report 7060)
			SELECT TOP (1) @MaxAge = (1+MAX(r.Beg_Age)) 
			FROM PowerPlan.Report_Study7060 r
			WHERE	(r.Analysis_Version_ID = @Analysis_Version_ID 
					AND r.Analysis_Account_ID = @Analysis_Account_ID
					AND ISNULL(r.Exposures,0)<>0);
			
			-- Add New Observed Life Table Data (Report 7060)
			INSERT INTO	Depr.Solver_Model ( 
						Age, 
						Exposures, 
						Retires, 
						Surv_Ratio, 
						Retire_Ratio,
						Model_Age,
						Model_pAgeIndex,
						Model_nAgeIndex )
			SELECT	ISNULL(r.Beg_Age,0), 
					ISNULL(r.Exposures,0), 
					ISNULL(r.Retires,0),
					(1-CASE ISNULL(r.Exposures,0) WHEN 0 THEN 0 ELSE CAST(ISNULL(r.Retires,0) AS FLOAT)/CAST(r.Exposures AS FLOAT) END) AS Observed_LifeRatio_Survivors,
					(CASE ISNULL(r.Exposures,0) WHEN 0 THEN 0 ELSE CAST(ISNULL(r.Retires,0) AS FLOAT)/CAST(r.Exposures AS FLOAT) END) AS Observed_LifeRatio_Retirements,
					(CASE WHEN (r.Beg_Age <= 0.5) THEN 0 ELSE r.Beg_Age-1 END) AS calcModel_Age,
					CAST((CASE WHEN (r.Beg_Age <= 0.5) THEN 0 ELSE r.Beg_Age-1 END) AS INT) AS calcModel_pAgeIndex,
					(CAST((CASE WHEN (r.Beg_Age <= 0.5) THEN 0 ELSE r.Beg_Age-1 END) AS INT)+1) AS calcModel_nAgeIndex
			FROM 	Depr.Solver_Model_Master m LEFT JOIN PowerPlan.Report_Study7060 r ON m.Age = r.Beg_Age
			WHERE	(((m.Age)<=@MaxAge) 
					AND ((r.Analysis_Account_ID)=@Analysis_Account_ID) 
					AND ((r.Analysis_Version_ID)=@Analysis_Version_ID));

			-- Loop Through Dataset to Calculate Observed Percentages
			EXEC Depr.runSolver_Model_Loop;
		END;
GO

-- setSolver_Model_FitCurve
CREATE	PROCEDURE Depr.setSolver_Model_FitCurve
		(
			@Analysis_Account_ID AS INT = -1,
			@Analysis_Version_ID AS INT = -1,
			@Model_Age_Min AS NUMERIC(22,8) = 1,
			@Model_Age_Limit AS NUMERIC(22,8) = 500.5,
			@Mortality_Curve_ID AS INT
		)
		AS
		BEGIN
			-- Declare / Initialize Variables
			DECLARE @MaxAge AS NUMERIC(22,8) = 500.5;
			DECLARE @Model_Age_Max AS NUMERIC(22,8) = 500.5;
			DECLARE @localCounter as INT = 1;
			DECLARE @otherCounter AS INT = 0;
			DECLARE @loopMe AS BIT = 1;
			DECLARE @innerLoop as BIT=1
			DECLARE @evaluateArray AS BIT = 0;
			DECLARE @ASL NUMERIC(22,8);
			DECLARE @alternateASL NUMERIC(22,8);
			DECLARE @ASL_Left NUMERIC(22,8);
			DECLARE @ASL_Right NUMERIC(22,8);
			DECLARE @result_Current NUMERIC(22,8) = 0;
			DECLARE @result_Left NUMERIC(22,8) = 0;
			DECLARE @result_Right NUMERIC(22,8) = 0;
			DECLARE @minimumIncrement NUMERIC(22,8);
            DECLARE @counterIndex NVARCHAR(35);
			DECLARE @counterMax INT;
			SET @minimumIncrement = CAST(1 AS NUMERIC(22,8))/CAST(12 AS NUMERIC(22,8));

			-- Determine Maximum Age from Observed Life Table Data (Report 7060)
			SELECT TOP (1) @MaxAge = (1+MAX(r.Beg_Age)) 
			FROM PowerPlan.Report_Study7060 r
			WHERE	(r.Analysis_Version_ID = @Analysis_Version_ID 
					AND r.Analysis_Account_ID = @Analysis_Account_ID
					AND ISNULL(r.Exposures,0)<>0);

			-- Determine Maximum Service Life for Modeling
			SET @Model_Age_Max = 4*(CASE ISNULL(@MaxAge,0) WHEN 0 THEN (@Model_Age_Limit/4) ELSE @MaxAge END);
			IF @Model_Age_Max > @Model_Age_Limit SET @Model_Age_Max = @Model_Age_Limit;
			SET @counterMax = 12*CAST(@Model_Age_Max AS INT)/4;

			-- Loop Protocol
			WHILE ((@loopMe = 1) AND (@localCounter <= @counterMax)) BEGIN
				IF @localCounter <= 2
					BEGIN
						IF @localCounter = 1
							BEGIN
								SET @ASL = CAST(@Model_Age_Min AS NUMERIC(22,8))
								SET @ASL_Left = @ASL
								SET @evaluateArray = 0
							END
						ELSE
							BEGIN
								SET @ASL = CAST(@Model_Age_Max AS NUMERIC(22,8))
								SET @ASL_Right = @ASL
								SET @evaluateArray = 0
							END
					END
				ELSE
					BEGIN
						IF ABS(@ASL_Right - @ASL_Left) <=1
							BEGIN
								SET @ASL = @ASL_Left + @minimumIncrement
								SET @ASL_Left = @ASL
								SET @loopMe = CASE WHEN ABS(@ASL_Right - @ASL) <= @minimumIncrement THEN 0 END
								SET @evaluateArray=0
							END
						ELSE
							BEGIN
								SET @ASL = Common.MROUND((@ASL_Left+@ASL_Right)/CAST(2 AS NUMERIC(22,8)),DEFAULT)
								SET @evaluateArray = 1
							END
					END

				-- Setup Run Data
                SET @counterIndex = 'A' + RIGHT('0000000000'+CAST(@localCounter AS NVARCHAR(35)),10);
				EXEC Depr.runSolver_Model_LoadCurve @Analysis_Account_ID, @Analysis_Version_ID, @Mortality_Curve_ID, @ASL, 'DB', @counterIndex

                -- Increment Counter
				SET @localCounter = @localCounter+1;

				-- GATHER Weighted Squared Difference
				SELECT TOP (1) @result_Current = (SUM(m.Wtd_Squared_Diff))
				FROM Depr.Solver_Model m;

				-- Solver Loop
				IF @evaluateArray=0 CONTINUE;
				IF @localCounter>=@counterMax BREAK;
				SET @evaluateArray=0
				SET @otherCounter = 1;
				SET @innerLoop=1;
				WHILE  @innerLoop = 1 BEGIN

						SET @alternateASL = @ASL - (@minimumIncrement*CAST(@otherCounter AS NUMERIC(22,8)));
						SET @alternateASL = CASE	WHEN @alternateASL < @Model_Age_Min THEN @Model_Age_Min 
																			WHEN @alternateASL > @Model_Age_Max THEN @Model_Age_Max
																			ELSE @alternateASL END
						SET @counterIndex = 'B' + RIGHT('0000000000'+CAST(@localCounter AS NVARCHAR(35)),10) + '.' +CAST(@otherCounter AS NVARCHAR(35));
						EXEC Depr.runSolver_Model_LoadCurve @Analysis_Account_ID, @Analysis_Version_ID, @Mortality_Curve_ID, @alternateASL, 'DB', @counterIndex;
						SELECT TOP (1) @result_Left = (SUM(m.Wtd_Squared_Diff)) FROM Depr.Solver_Model m;
						SET @localCounter = @localCounter + 1;

						SET @alternateASL = @ASL + (@minimumIncrement*CAST(@otherCounter AS NUMERIC(22,8)));
						SET @alternateASL = CASE	WHEN @alternateASL < @Model_Age_Min THEN @Model_Age_Min 
																			WHEN @alternateASL > @Model_Age_Max THEN @Model_Age_Max
																			ELSE @alternateASL END
						SET @counterIndex = 'C' + RIGHT('0000000000'+CAST(@localCounter AS NVARCHAR(35)),10) + '.' + CAST(@otherCounter AS NVARCHAR(35));
						EXEC Depr.runSolver_Model_LoadCurve @Analysis_Account_ID, @Analysis_Version_ID, @Mortality_Curve_ID, @alternateASL, 'DB', @counterIndex;
						SELECT TOP (1) @result_Right = (SUM(m.Wtd_Squared_Diff)) FROM Depr.Solver_Model m;
						SET @localCounter = @localCounter + 1;

						IF @localCounter>=@counterMax BREAK;
						SET @innerLoop = CASE WHEN @ASL_Left<@ASL AND @ASL_Right>@ASL AND ((@result_Left<=@result_Current AND @result_Right<=@result_Current) OR (@result_Left>=@result_Current AND @result_Right>=@result_Current)) THEN 1 ELSE 0 END;

						SET @otherCounter = @otherCounter + 1;
				END

				SET @loopMe = 0
				IF @result_Left <= @result_Current AND @result_Right> @result_Current
					BEGIN
						SET @result_Right = @result_Current
						SET @ASL_Right = @ASL
						SET @loopMe = 1
					END
				IF @result_Left > @result_Current AND @result_Right <= @result_Current
					BEGIN
						SET @result_Left = @result_Current
						SET @ASL_left = @ASL
						SET @loopMe = 1
					END
			END
		END;
GO

-- runSolver_Model_PowerPlan
CREATE	PROCEDURE	Depr.runSolver_Model_PowerPlan
        (
            @Analysis_Account_ID INT = -1,
			@Analysis_Version_ID INT = -1
        )
		AS
		BEGIN
            DECLARE @Mortality_Curve_ID INT = -1;
            DECLARE @Model_Average_Life NUMERIC(22,8) = -1;
            DECLARE @Solver_Source_ID CHAR(2) = 'PP';
            DECLARE @Trial_ID INT = 0;
            DECLARE @localCounter INT = 0;
            DECLARE @counterInsert NVARCHAR(35) = '';

			DECLARE increment CURSOR LOCAL FOR
                SELECT TOP (100) PERCENT    PowerPlan_Fit_Stats_All.Trial_ID,
                                            PowerPlan_Fit_Stats_All.Mortality_Curve_ID, 
                                            PowerPlan_Fit_Stats_All.Fit_ASL
                FROM PowerPlan_Fit_Stats_All 
                    INNER JOIN PowerPlan_Fit_Statistics 
                    ON PowerPlan_Fit_Stats_All.Trial_ID = PowerPlan_Fit_Statistics.Trial_ID
                WHERE   PowerPlan_Fit_Statistics.Analysis_Version_ID=@Analysis_Version_ID AND
                        PowerPlan_Fit_Statistics.Analysis_Account_ID=@Analysis_Account_ID
            OPEN increment
			FETCH next FROM increment INTO @Trial_ID, @Mortality_Curve_ID, @Model_Average_Life;
			
			WHILE @@FETCH_STATUS = 0 BEGIN
                SET @localCounter = @localCounter + 1;
                SET @counterInsert = 'P' + RIGHT('0000000000'+CAST(@Trial_ID AS NVARCHAR(35)),10) + '.' + CAST(@localCounter AS NVARCHAR(35));
				EXEC Depr.runSolver_Model_LoadCurve @Analysis_Account_ID,
                                                    @Analysis_Version_ID,
                                                    @Mortality_Curve_ID,
                                                    @Model_Average_Life,
                                                    @Solver_Source_ID,
                                                    @counterInsert;                                                    

				FETCH next FROM increment INTO @Mortality_Curve_ID, @Model_Average_Life;
			END

			CLOSE increment
			DEALLOCATE increment
		END;
GO

-- runSolver_Model_RateCase
CREATE	PROCEDURE	Depr.runSolver_Model_RateCase
        (
            @Analysis_Account_ID INT = -1,
			@Analysis_Version_ID INT = -1
        )
		AS
		BEGIN
            DECLARE @Mortality_Curve_ID INT = -1;
            DECLARE @Model_Average_Life NUMERIC(22,8) = -1;
            DECLARE @Solver_Source_ID CHAR(2) = 'RC';
            DECLARE @localCounter INT = 0;
            DECLARE @counterInsert NVARCHAR(35) = '';

			DECLARE increment CURSOR LOCAL FOR
                SELECT TOP (100) PERCENT    Depr_Rate_Case_Parameter.Rate_Case_ID, 
                                            Depr_Rate_Case_Parameter.Mortality_Curve_ID, 
                                            Depr_Rate_Case_Parameter.Expected_Average_Life
                FROM PowerPlan_Analysis_Version INNER JOIN (PowerPlan_DS_Acct_Dataset_Map 
                                                INNER JOIN (PowerPlan_DS_Data_Account_Depr_Group 
                                                INNER JOIN Depr_Rate_Case_Parameter 
                                                ON PowerPlan_DS_Data_Account_Depr_Group.Depr_Group_ID = Depr_Rate_Case_Parameter.Depr_Group_ID) 
                                                ON PowerPlan_DS_Acct_Dataset_Map.DS_Data_Account_ID = PowerPlan_DS_Data_Account_Depr_Group.DS_Data_Account_ID) 
                                                ON PowerPlan_Analysis_Version.DS_Analysis_Dataset_ID = PowerPlan_DS_Acct_Dataset_Map.DS_Analysis_Dataset_ID;

            OPEN increment
			FETCH next FROM increment INTO @counterInsert, @Mortality_Curve_ID, @Model_Average_Life;
			
			WHILE @@FETCH_STATUS = 0 BEGIN
                SET @localCounter = @localCounter + 1;
                SET @counterInsert = 'R' + RIGHT('0000000000'+@counterInsert,10) + '.' + CAST(@localCounter AS NVARCHAR(35));
				EXEC Depr.runSolver_Model_LoadCurve @Analysis_Account_ID,
                                                    @Analysis_Version_ID,
                                                    @Mortality_Curve_ID,
                                                    @Model_Average_Life,
                                                    @Solver_Source_ID,
                                                    @counterInsert;                                                    

				FETCH next FROM increment INTO @Mortality_Curve_ID, @Model_Average_Life;
			END

			CLOSE increment
			DEALLOCATE increment
		END;
GO