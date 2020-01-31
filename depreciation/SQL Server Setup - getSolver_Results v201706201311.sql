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
IF OBJECT_ID ( 'Depr.getSolver_Results','P') IS NOT NULL
    DROP PROCEDURE Depr.getSolver_Results;
GO

CREATE PROCEDURE	Depr.getSolver_Results
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
                        SELECT TOP (1) @Analysis_Account_ID = PowerPlan.Analysis_Account_Depr_Group.Analysis_Account_ID
                        FROM    PowerPlan.Depr_Group INNER JOIN
                                PowerPlan.Analysis_Depr_Group ON PowerPlan.Depr_Group.Depr_Group = PowerPlan.Analysis_Depr_Group.Analysis_Depr_Group INNER JOIN
                                PowerPlan.DS_Analysis_Dataset ON PowerPlan.Analysis_Depr_Group.DS_Analysis_Dataset_ID = PowerPlan.DS_Analysis_Dataset.DS_Analysis_Dataset_ID INNER JOIN
                                PowerPlan.Analysis_Version ON PowerPlan.DS_Analysis_Dataset.DS_Analysis_Dataset_ID = PowerPlan.Analysis_Version.DS_Analysis_Dataset_ID INNER JOIN
                                PowerPlan.Analysis_Account_Depr_Group ON PowerPlan.Analysis_Depr_Group.Analysis_Depr_Group_ID = PowerPlan.Analysis_Account_Depr_Group.Analysis_Depr_Group_ID AND 
                                PowerPlan.DS_Analysis_Dataset.DS_Analysis_Dataset_ID = PowerPlan.Analysis_Account_Depr_Group.DS_Analysis_Dataset_ID
                        WHERE   (PowerPlan.Analysis_Version.Analysis_Version_ID = @Analysis_Version_ID) AND 
                                (PowerPlan.Depr_Group.Depr_Group_ID =  @Depr_Group_ID)

                        -- Return Sorted, Summarized, Results
                        SELECT          TOP (100) PERCENT 
                                        Depr.Solver_Results.*, 
                                        Common.MROUND(Depr.Solver_Results.Average_Life * dbo.Mortality_Curve_Points_MinMax.minLife/100, DEFAULT) AS minLifeData, 
                                        Common.MROUND(Depr.Solver_Results.Average_Life *  dbo.Mortality_Curve_Points_MinMax.maxLife/100, DEFAULT) AS maxLifeData
                        FROM            Depr.Solver_Results INNER JOIN
                                        dbo.Mortality_Curve_Points_MinMax ON Depr.Solver_Results.Mortality_Curve_ID=dbo.Mortality_Curve_Points_MinMax.Mortality_Curve_ID
                        WHERE           (Depr.Solver_Results.Analysis_Version_ID = @Analysis_Version_ID) AND 
                                        (Depr.Solver_Results.Analysis_Account_ID = @Analysis_Account_ID)
                        ORDER BY        Depr.Solver_Results.Wtd_Squared_Difference

END
GO
