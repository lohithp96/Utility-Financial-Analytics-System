USE SONGS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Matthew C. Vanderbilt /00562
-- Create date: 06/07/2017 12:05
-- Description:	Gets Mortality Curve Index
-- =============================================

IF OBJECT_ID ( 'Depr.Solver_Results_Summary','P') IS NOT NULL
    DROP PROCEDURE Depr.Solver_Results_Summary;
GO

CREATE PROCEDURE	Depr.Solver_Results_Summary
					(
						@Analysis_Version_ID INT = 0,
						@Depr_Group_ID INT = 0
					) 
					AS
					BEGIN
						-- SET NOCOUNT ON added to prevent extra result sets from
						-- interfering with SELECT statements.
						SET NOCOUNT ON;

                        -- Declare / Initialize Variables
                        DECLARE @Analysis_Account_ID INT = 0;

                        -- Determine Analysis Depr. Group
                        SELECT TOP (1)  @Analysis_Account_ID = adg.Analysis_Depr_Group_ID
                        FROM            PowerPlan.Depr_Group AS dg INNER JOIN
                                        PowerPlan.Analysis_Depr_Group AS adg ON dg.Depr_Group = adg.Analysis_Depr_Group INNER JOIN
                                        PowerPlan.DS_Analysis_Dataset AS ads ON adg.DS_Analysis_Dataset_ID = ads.DS_Analysis_Dataset_ID INNER JOIN
                                        PowerPlan.Analysis_Version AS av ON ads.DS_Analysis_Dataset_ID = av.DS_Analysis_Dataset_ID
                        WHERE           (av.Analysis_Version_ID = @Analysis_Version_ID) AND 
                                        (dg.Depr_Group_ID = @Depr_Group_ID)

                        -- Return Sorted, Summarized, Results
                        SELECT  TOP (100) PERCENT
                                Depr.Solver_Results.Trial_ID, 
                                Depr.Solver_Results.Analysis_Version_ID, 
                                Depr.Solver_Results.Analysis_Account_ID, 
                                Depr.Solver_Results.Mortality_Curve_ID, 
                                Depr.Solver_Results.Average_Life, 
                                Depr.Solver_Results.Solver_Source_ID, 
                                Depr.Solver_Results.Trial_Counter, 
                                Depr.Solver_Results.Direct_Difference, 
                                Depr.Solver_Results.Absolute_Difference, 
                                Depr.Solver_Results.Squared_Difference, 
                                Depr.Solver_Results.Wtd_Squared_Difference, 
                                Depr.Solver_Results.CreatedBy, 
                                Depr.Solver_Results.CreatedDate, 
                                Depr.Solver_Results.LastUpdatedBy, 
                                Depr.Solver_Results.LastUpdatedDate, 
                                Depr.Solver_Results.rowguid, 
                                Depr.Solver_Results.versionnumber, 
                                Depr.Solver_Results.ValidFrom, 
                                Depr.Solver_Results.ValidTo
                        FROM    (SELECT TOP (100) PERCENT 
                                        MIN(results.Trial_ID) AS bestTrial_ID, 
                                        results.Analysis_Version_ID, 
                                        results.Analysis_Account_ID, 
                                        results.Mortality_Curve_ID, 
                                        results.Solver_Source_ID
                                FROM    Depr.Solver_Results AS results INNER JOIN
                                        (SELECT Analysis_Version_ID, 
                                                Analysis_Account_ID, 
                                                Solver_Source_ID, 
                                                Mortality_Curve_ID, 
                                                MIN(Wtd_Squared_Difference) AS best_Wtd_Squared_Difference
                                        FROM    Depr.Solver_Results AS Solver_Results_1
                                        GROUP BY Solver_Source_ID, 
                                                Analysis_Version_ID, 
                                                Analysis_Account_ID, 
                                                Mortality_Curve_ID) AS _bestResults ON 
                                                results.Analysis_Version_ID = _bestResults.Analysis_Version_ID AND 
                                                results.Analysis_Account_ID = _bestResults.Analysis_Account_ID AND 
                                                results.Solver_Source_ID = _bestResults.Solver_Source_ID AND 
                                                results.Mortality_Curve_ID = _bestResults.Mortality_Curve_ID AND 
                                                results.Wtd_Squared_Difference = _bestResults.best_Wtd_Squared_Difference
                                GROUP BY results.Analysis_Version_ID, 
                                        results.Analysis_Account_ID, 
                                        results.Mortality_Curve_ID, 
                                        results.Solver_Source_ID) AS d INNER JOIN
                                Depr.Solver_Results ON d.bestTrial_ID = Depr.Solver_Results.Trial_ID
                        WHERE   (Depr.Solver_Results.Analysis_Version_ID = @Analysis_Version_ID) AND 
                                (Depr.Solver_Results.Analysis_Account_ID = @Analysis_Account_ID)
                        ORDER BY Depr.Solver_Results.Wtd_Squared_Difference

END
GO
