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

-- runSolver_Model_Loop
CREATE	PROCEDURE	[Depr].[runSolver_Model_Loop]
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
CREATE	PROCEDURE	[Depr].[runSolver_Model_LoadCurve]
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
CREATE	PROCEDURE	[Depr].[setSolver_Model] 
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
CREATE	PROCEDURE [Depr].[setSolver_Model_FitCurve]
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
			DECLARE @result_Check NUMERIC(22,8) = 0;
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
				
				SET @result_Check = 0
				SELECT TOP (1) @result_Check =	Depr.Solver_Results.Wtd_Squared_Difference
										FROM	Depr.Solver_Results
										WHERE	Depr.Solver_Results.Analysis_Version_ID = @Analysis_Version_ID AND 
												Depr.Solver_Results.Analysis_Account_ID = @Analysis_Account_ID AND 
												Depr.Solver_Results.Mortality_Curve_ID = @Mortality_Curve_ID AND 
												Depr.Solver_Results.Average_Life = @alternateASL AND 
												Depr.Solver_Results.Solver_Source_ID = 'DB'
				
                SET @result_Current = @result_Check
				IF @result_Check = 0 OR @result_Check = NULL
					BEGIN
						EXEC Depr.runSolver_Model_LoadCurve @Analysis_Account_ID, @Analysis_Version_ID, @Mortality_Curve_ID, @ASL, 'DB', @counterIndex
						-- Increment Counter
						SET @localCounter = @localCounter+1;
						-- GATHER Weighted Squared Difference
						SELECT TOP (1) @result_Current =	(SUM(m.Wtd_Squared_Diff))
													FROM	Depr.Solver_Model m;
					END
				
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
						
						SET @result_Check = 0
						SELECT TOP (1) @result_Check =	Depr.Solver_Results.Wtd_Squared_Difference
												FROM	Depr.Solver_Results
												WHERE	Depr.Solver_Results.Analysis_Version_ID = @Analysis_Version_ID AND 
														Depr.Solver_Results.Analysis_Account_ID = @Analysis_Account_ID AND 
														Depr.Solver_Results.Mortality_Curve_ID = @Mortality_Curve_ID AND 
														Depr.Solver_Results.Average_Life = @alternateASL AND 
														Depr.Solver_Results.Solver_Source_ID = 'DB'

						SET @result_Left = @result_Check
                        IF @result_Check = 0 OR @result_Check = NULL
							BEGIN
								EXEC Depr.runSolver_Model_LoadCurve @Analysis_Account_ID, @Analysis_Version_ID, @Mortality_Curve_ID, @alternateASL, 'DB', @counterIndex;
								-- Increment Counter
								SET @localCounter = @localCounter+1;
								-- GATHER Weighted Squared Difference
								SELECT TOP (1) @result_Left = (SUM(m.Wtd_Squared_Diff)) FROM Depr.Solver_Model m;
							END

						SET @alternateASL = @ASL + (@minimumIncrement*CAST(@otherCounter AS NUMERIC(22,8)));
						SET @alternateASL = CASE	WHEN @alternateASL < @Model_Age_Min THEN @Model_Age_Min 
																			WHEN @alternateASL > @Model_Age_Max THEN @Model_Age_Max
																			ELSE @alternateASL END
						SET @counterIndex = 'C' + RIGHT('0000000000'+CAST(@localCounter AS NVARCHAR(35)),10) + '.' + CAST(@otherCounter AS NVARCHAR(35));

						SET @result_Check = 0
						SELECT TOP (1) @result_Check =	Depr.Solver_Results.Wtd_Squared_Difference
												FROM	Depr.Solver_Results
												WHERE	Depr.Solver_Results.Analysis_Version_ID = @Analysis_Version_ID AND 
														Depr.Solver_Results.Analysis_Account_ID = @Analysis_Account_ID AND 
														Depr.Solver_Results.Mortality_Curve_ID = @Mortality_Curve_ID AND 
														Depr.Solver_Results.Average_Life = @ASL AND 
														Depr.Solver_Results.Solver_Source_ID = 'DB'
                        
                        SET @result_Right = @result_Check
						IF @result_Check = 0 OR @result_Check = NULL
							BEGIN
								EXEC Depr.runSolver_Model_LoadCurve @Analysis_Account_ID, @Analysis_Version_ID, @Mortality_Curve_ID, @alternateASL, 'DB', @counterIndex;
								-- Increment Counter
								SET @localCounter = @localCounter+1;
								-- GATHER Weighted Squared Difference
								SELECT TOP (1) @result_Right = (SUM(m.Wtd_Squared_Diff)) FROM Depr.Solver_Model m;
							END
						ELSE
						
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