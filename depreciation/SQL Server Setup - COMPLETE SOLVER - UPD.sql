USE SONGS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Matthew C. Vanderbilt /00562
-- Create date: 06/02/2017 10:48
-- Description:	Updates Solver Model
-- =============================================
IF OBJECT_ID ( 'Depr.runSolver_Model_RateCase','P') IS NOT NULL
    DROP PROCEDURE Depr.runSolver_Model_RateCase;
GO
IF OBJECT_ID ( 'Depr.runSolver_Model_PowerPlan','P') IS NOT NULL
    DROP PROCEDURE Depr.runSolver_Model_PowerPlan;
GO
IF OBJECT_ID ( 'Depr.delSolver_Results','P') IS NOT NULL
    DROP PROCEDURE Depr.delSolver_Results
GO
-- delSolver_Results
CREATE PROCEDURE	[Depr].[delSolver_Results] 
                    (
                        @Analysis_Account_ID INT = -1,
                        @Analysis_Version_ID INT = -1,
                        @Solver_Source_ID CHAR(2) = '-1'
                    )
					AS
					BEGIN
						-- SET NOCOUNT ON added to prevent extra result sets from
						-- interfering with SELECT statements.
						SET NOCOUNT ON;
						DELETE FROM Solver_Results WHERE Solver_Results.Analysis_Account_ID=@Analysis_Account_ID 
                                                     AND Solver_Results.Analysis_Version_ID=@Analysis_Version_ID
                                                     AND Solver_Results.Solver_Source_ID=@Solver_Source_ID
					END
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
            DECLARE @ModelAverageLife NUMERIC(22,2)=-1;
            DECLARE @Model_Average_Life NUMERIC(22,8) = -1;
            DECLARE @Solver_Source_ID CHAR(2) = 'PP';
            DECLARE @Trial_ID INT = 0;
            DECLARE @localCounter INT = 0;
            DECLARE @counterInsert NVARCHAR(35) = '';

			DECLARE increment CURSOR LOCAL FOR
                SELECT TOP (100) PERCENT    PowerPlan.Fit_Stats_All.Trial_ID,
                                            PowerPlan.Fit_Stats_All.Mortality_Curve_ID, 
                                            PowerPlan.Fit_Stats_All.Fit_ASL
                FROM PowerPlan.Fit_Stats_All 
                    INNER JOIN PowerPlan.Fit_Statistics 
                    ON PowerPlan.Fit_Stats_All.Trial_ID = PowerPlan.Fit_Statistics.Trial_ID
                WHERE   PowerPlan.Fit_Statistics.Analysis_Version_ID=@Analysis_Version_ID AND
                        PowerPlan.Fit_Statistics.Analysis_Account_ID=@Analysis_Account_ID
            OPEN increment
			FETCH next FROM increment INTO @Trial_ID, @Mortality_Curve_ID, @ModelAverageLife;

            SET @Model_Average_Life = CAST(@ModelAverageLife AS NUMERIC(22,8));
			
			WHILE @@FETCH_STATUS = 0 BEGIN
                SET @localCounter = @localCounter + 1;
                SET @counterInsert = 'P' + RIGHT('0000000000'+CAST(@Trial_ID AS NVARCHAR(35)),10) + '.' + CAST(@localCounter AS NVARCHAR(35));
				EXEC Depr.runSolver_Model_LoadCurve @Analysis_Account_ID,
                                                    @Analysis_Version_ID,
                                                    @Mortality_Curve_ID,
                                                    @Model_Average_Life,
                                                    @Solver_Source_ID,
                                                    @counterInsert;                                                    

				FETCH next FROM increment INTO @Trial_ID, @Mortality_Curve_ID, @Model_Average_Life;
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
            DECLARE @ModelAverageLife NUMERIC(22,2)=-1;
            DECLARE @Solver_Source_ID CHAR(2) = 'RC';
            DECLARE @localCounter INT = 0;
            DECLARE @counterInsert NVARCHAR(35) = '';

			DECLARE increment CURSOR LOCAL FOR
                SELECT TOP (100) PERCENT    Depr.Rate_Case_Parameter.Rate_Case_ID, 
                                            Depr.Rate_Case_Parameter.Mortality_Curve_ID, 
                                            Depr.Rate_Case_Parameter.Expected_Average_Life
                FROM PowerPlan.Analysis_Version INNER JOIN (PowerPlan.DS_Acct_Dataset_Map 
                                                INNER JOIN (PowerPlan.DS_Data_Account_Depr_Group 
                                                INNER JOIN Depr.Rate_Case_Parameter 
                                                ON PowerPlan.DS_Data_Account_Depr_Group.Depr_Group_ID = Depr.Rate_Case_Parameter.Depr_Group_ID) 
                                                ON PowerPlan.DS_Acct_Dataset_Map.DS_Data_Account_ID = PowerPlan.DS_Data_Account_Depr_Group.DS_Data_Account_ID) 
                                                ON PowerPlan.Analysis_Version.DS_Analysis_Dataset_ID = PowerPlan.DS_Acct_Dataset_Map.DS_Analysis_Dataset_ID 
                WHERE   PowerPlan.Analysis_Version.Analysis_Version_ID=@Analysis_Version_ID AND
                        PowerPlan.DS_Acct_Dataset_Map.Analysis_Account_ID=@Analysis_Account_ID;

            OPEN increment
			FETCH next FROM increment INTO @counterInsert, @Mortality_Curve_ID, @ModelAverageLife;

            SET @Model_Average_Life = CAST(@ModelAverageLife AS NUMERIC(22,8));
			
			WHILE @@FETCH_STATUS = 0 BEGIN
                SET @Model_Average_Life = CAST(@ModelAverageLife AS NUMERIC(22,8));
                SET @localCounter = @localCounter + 1;
                SET @counterInsert = 'R' + RIGHT('0000000000'+@counterInsert,10) + '.' + CAST(@localCounter AS NVARCHAR(35));
				EXEC Depr.runSolver_Model_LoadCurve @Analysis_Account_ID,
                                                    @Analysis_Version_ID,
                                                    @Mortality_Curve_ID,
                                                    @Model_Average_Life,
                                                    @Solver_Source_ID,
                                                    @counterInsert;                                                    

				FETCH next FROM increment INTO @counterInsert, @Mortality_Curve_ID, @ModelAverageLife;
			END

			CLOSE increment
			DEALLOCATE increment
		END;
GO