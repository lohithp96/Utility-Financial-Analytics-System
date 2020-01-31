IF OBJECT_ID ( 'Depr.runSolver_Model_PowerPlan','P') IS NOT NULL
    DROP PROCEDURE Depr.runSolver_Model_PowerPlan;
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