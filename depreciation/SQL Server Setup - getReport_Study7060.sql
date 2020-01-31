USE SONGS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Matthew C. Vanderbilt /00562
-- Create date: 06/09/2017 09:22
-- Description:	Gets OLT Data
-- =============================================

IF OBJECT_ID ( 'PowerPlan.getReport_Study7060','P') IS NOT NULL
    DROP PROCEDURE PowerPlan.getReport_Study7060;
GO

CREATE PROCEDURE	PowerPlan.getReport_Study7060
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
                                        PowerPlan.Report_Study7060.*
                        FROM            PowerPlan.Report_Study7060
                        WHERE           (PowerPlan.Report_Study7060.Analysis_Version_ID = @Analysis_Version_ID) AND 
                                        (PowerPlan.Report_Study7060.Analysis_Account_ID = @Analysis_Account_ID)
                        ORDER BY        PowerPlan.Report_Study7060.Abs_Age

END
GO
