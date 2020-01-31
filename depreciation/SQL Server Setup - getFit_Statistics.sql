USE SONGS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Matthew C. Vanderbilt /00562
-- Create date: 06/08/2017 10:31
-- Description:	Gets PowerPlan Fit Statistics
-- =============================================

IF OBJECT_ID ( 'Depr.getFit_Statistics','P') IS NOT NULL
    DROP PROCEDURE Depr.getFit_Statistics;
GO
IF OBJECT_ID ( 'Depr.getFit_Stats_All','P') IS NOT NULL
    DROP PROCEDURE Depr.getFit_Stats_All;
GO
IF OBJECT_ID ( 'PowerPlan.getFit_Statistics','P') IS NOT NULL
    DROP PROCEDURE PowerPlan.getFit_Statistics;
GO
IF OBJECT_ID ( 'PowerPlan.getFit_Stats_All','P') IS NOT NULL
    DROP PROCEDURE PowerPlan.getFit_Stats_All;
GO


CREATE PROCEDURE	PowerPlan.getFit_Statistics
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
                        SELECT      PowerPlan.Fit_Statistics.*, 
                                    Common.MROUND(PowerPlan.Fit_Statistics.Best_Fit_ASL * dbo.Mortality_Curve_Points_MinMax.minLife/100, DEFAULT) AS minLifeData, 
                                    Common.MROUND(PowerPlan.Fit_Statistics.Best_Fit_ASL * dbo.Mortality_Curve_Points_MinMax.maxLife/100, DEFAULT) AS maxLifeData
                        FROM        PowerPlan.Fit_Statistics INNER JOIN
                                    dbo.Mortality_Curve_Points_MinMax ON PowerPlan.Fit_Statistics.Best_Fit_Curve = dbo.Mortality_Curve_Points_MinMax.Mortality_Curve_ID
                        WHERE       (PowerPlan.Fit_Statistics.Analysis_Version_ID = @Analysis_Version_ID) AND 
                                    (PowerPlan.Fit_Statistics.Analysis_Account_ID = @Analysis_Account_ID)

END
GO

CREATE PROCEDURE	PowerPlan.getFit_Stats_All
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
                        SELECT TOP (100) PERCENT 
                                    PowerPlan.Fit_Statistics.Analysis_Version_ID, 
                                    PowerPlan.Fit_Statistics.Analysis_Account_ID,
                                    PowerPlan.Fit_Stats_All.*, 
                                    Common.MROUND(PowerPlan.Fit_Stats_All.Fit_ASL * dbo.Mortality_Curve_Points_MinMax.minLife / 100, DEFAULT) AS minLifeData, 
                                    Common.MROUND(PowerPlan.Fit_Stats_All.Fit_ASL * dbo.Mortality_Curve_Points_MinMax.maxLife / 100, DEFAULT) AS maxLifeData
                        FROM        PowerPlan.Fit_Statistics INNER JOIN
                                    PowerPlan.Fit_Stats_All ON PowerPlan.Fit_Statistics.Trial_ID = PowerPlan.Fit_Stats_All.Trial_ID INNER JOIN
                                    dbo.Mortality_Curve_Points_MinMax ON PowerPlan.Fit_Stats_All.Mortality_Curve_ID = dbo.Mortality_Curve_Points_MinMax.Mortality_Curve_ID
                        WHERE       (PowerPlan.Fit_Statistics.Analysis_Version_ID = @Analysis_Version_ID) AND 
                                    (PowerPlan.Fit_Statistics.Analysis_Account_ID = @Analysis_Account_ID)
                        ORDER BY    PowerPlan.Fit_Stats_All.Error_Sum_Squares

END
GO