IF OBJECT_ID ( 'Depr.runSolver_Model_RateCase','P') IS NOT NULL
    DROP PROCEDURE Depr.runSolver_Model_RateCase;
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
                SELECT TOP  (100) PERCENT 
                            Depr.Rate_Case_Parameter.Rate_Case_ID, 
                            Depr.Rate_Case_Parameter.Mortality_Curve_ID, 
                            Depr.Rate_Case_Parameter.Expected_Average_Life
                FROM        PowerPlan.DS_Acct_Dataset_Map INNER JOIN
                            PowerPlan.Analysis_Version ON PowerPlan.DS_Acct_Dataset_Map.DS_Analysis_Dataset_ID = PowerPlan.Analysis_Version.DS_Analysis_Dataset_ID INNER JOIN
                            PowerPlan.DS_Data_Account_Depr_Group ON PowerPlan.DS_Acct_Dataset_Map.DS_Data_Account_ID = PowerPlan.DS_Data_Account_Depr_Group.DS_Data_Account_ID INNER JOIN
                            Depr.Rate_Case_Parameter ON PowerPlan.DS_Data_Account_Depr_Group.Depr_Group_ID = Depr.Rate_Case_Parameter.Depr_Group_ID
                WHERE       (PowerPlan.Analysis_Version.Analysis_Version_ID = @Analysis_Version_ID) AND 
                            (PowerPlan.DS_Acct_Dataset_Map.Analysis_Account_ID = @Analysis_Account_ID)

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

				FETCH next FROM increment INTO @counterInsert, @Mortality_Curve_ID, @Model_Average_Life;
			END

			CLOSE increment
			DEALLOCATE increment
		END;
GO