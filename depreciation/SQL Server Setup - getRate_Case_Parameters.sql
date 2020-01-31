USE SONGS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Matthew C. Vanderbilt /00562
-- Create date: 06/02/2017 07:23
-- Description:	Gets Rate Case Parameters
-- =============================================
IF OBJECT_ID ( 'Depr.getRate_Case_Parameters','P') IS NOT NULL
    DROP PROCEDURE Depr.getRate_Case_Parameters;
GO

CREATE PROCEDURE	Depr.getRate_Case_Parameters
					(
						@Analysis_Version_ID int = NULL
					) 
					AS
					BEGIN
						-- SET NOCOUNT ON added to prevent extra result sets from
						-- interfering with SELECT statements.
						SET NOCOUNT ON;

						IF ISNULL(@Analysis_Version_ID,-1)=-1
							SELECT TOP (100) PERCENT 
                                p.Rate_Case_ID, 
                                Depr.Rate_Case.Rate_Case, 
                                p.Depr_Group_ID, 
                                p.Depr_Method_Id, 
                                PowerPlan.Depr_Group.Depr_Group, 
                                PowerPlan.Depreciation_Method.Depr_Method, 
                                PowerPlan.Analysis_Version.Analysis_Version_ID, 
                                PowerPlan.Analysis_Version.Analysis_Version, 
                                PowerPlan.DS_Acct_Dataset_Map.DS_Analysis_Dataset_ID, 
                                PowerPlan.DS_Acct_Dataset_Map.DS_Data_Account_ID, 
                                PowerPlan.DS_Acct_Dataset_Map.Analysis_Account_ID, 
                                p.Mortality_Curve_ID, 
                                PowerPlan.Mortality_Curve.Mortality_Curve, 
                                p.Expected_Average_Life, 
                                p.End_Of_Life, 
                                p.Net_Salvage_Pct, 
                                p.Interim_Retirement_Pct, 
                                p.Rate, 
                                p.Cost_of_Removal_Rate
                            FROM    Depr.Rate_Case_Parameter AS p LEFT OUTER JOIN
                                    PowerPlan.Depreciation_Method ON p.Depr_Method_Id = PowerPlan.Depreciation_Method.Depr_Method_Id AND p.Depr_Method_Id = PowerPlan.Depreciation_Method.Depr_Method_Id LEFT OUTER JOIN
                                    PowerPlan.Depr_Group ON p.Depr_Group_ID = PowerPlan.Depr_Group.Depr_Group_ID LEFT OUTER JOIN
                                    PowerPlan.Mortality_Curve ON p.Mortality_Curve_ID = PowerPlan.Mortality_Curve.Mortality_Curve_ID AND p.Mortality_Curve_ID = PowerPlan.Mortality_Curve.Mortality_Curve_ID LEFT OUTER JOIN
                                    Depr.Rate_Case ON p.Rate_Case_ID = Depr.Rate_Case.Rate_Case_ID AND p.Rate_Case_ID = Depr.Rate_Case.Rate_Case_ID LEFT OUTER JOIN
                                    PowerPlan.Analysis_Version INNER JOIN
                                    PowerPlan.DS_Data_Account_Depr_Group INNER JOIN
                                    PowerPlan.DS_Acct_Dataset_Map ON PowerPlan.DS_Data_Account_Depr_Group.DS_Data_Account_ID = PowerPlan.DS_Acct_Dataset_Map.DS_Data_Account_ID ON 
                                    PowerPlan.Analysis_Version.DS_Analysis_Dataset_ID = PowerPlan.DS_Acct_Dataset_Map.DS_Analysis_Dataset_ID ON 
                                    p.Depr_Group_ID = PowerPlan.DS_Data_Account_Depr_Group.Depr_Group_ID
                            ORDER BY p.Rate_Case_ID, PowerPlan.Depr_Group.Depr_Group
						ELSE
							SELECT TOP (100) PERCENT 
                                p.Rate_Case_ID, 
                                Depr.Rate_Case.Rate_Case, 
                                p.Depr_Group_ID, 
                                p.Depr_Method_Id, 
                                PowerPlan.Depr_Group.Depr_Group, 
                                PowerPlan.Depreciation_Method.Depr_Method, 
                                PowerPlan.Analysis_Version.Analysis_Version_ID, 
                                PowerPlan.Analysis_Version.Analysis_Version, 
                                PowerPlan.DS_Acct_Dataset_Map.DS_Analysis_Dataset_ID, 
                                PowerPlan.DS_Acct_Dataset_Map.DS_Data_Account_ID, 
                                PowerPlan.DS_Acct_Dataset_Map.Analysis_Account_ID, 
                                p.Mortality_Curve_ID, 
                                PowerPlan.Mortality_Curve.Mortality_Curve, 
                                p.Expected_Average_Life, 
                                p.End_Of_Life, 
                                p.Net_Salvage_Pct, 
                                p.Interim_Retirement_Pct, 
                                p.Rate, 
                                p.Cost_of_Removal_Rate
                            FROM    Depr.Rate_Case_Parameter AS p LEFT OUTER JOIN
                                    PowerPlan.Depreciation_Method ON p.Depr_Method_Id = PowerPlan.Depreciation_Method.Depr_Method_Id AND p.Depr_Method_Id = PowerPlan.Depreciation_Method.Depr_Method_Id LEFT OUTER JOIN
                                    PowerPlan.Depr_Group ON p.Depr_Group_ID = PowerPlan.Depr_Group.Depr_Group_ID LEFT OUTER JOIN
                                    PowerPlan.Mortality_Curve ON p.Mortality_Curve_ID = PowerPlan.Mortality_Curve.Mortality_Curve_ID AND p.Mortality_Curve_ID = PowerPlan.Mortality_Curve.Mortality_Curve_ID LEFT OUTER JOIN
                                    Depr.Rate_Case ON p.Rate_Case_ID = Depr.Rate_Case.Rate_Case_ID AND p.Rate_Case_ID = Depr.Rate_Case.Rate_Case_ID LEFT OUTER JOIN
                                    PowerPlan.Analysis_Version INNER JOIN
                                    PowerPlan.DS_Data_Account_Depr_Group INNER JOIN
                                    PowerPlan.DS_Acct_Dataset_Map ON PowerPlan.DS_Data_Account_Depr_Group.DS_Data_Account_ID = PowerPlan.DS_Acct_Dataset_Map.DS_Data_Account_ID ON 
                                    PowerPlan.Analysis_Version.DS_Analysis_Dataset_ID = PowerPlan.DS_Acct_Dataset_Map.DS_Analysis_Dataset_ID ON 
                                    p.Depr_Group_ID = PowerPlan.DS_Data_Account_Depr_Group.Depr_Group_ID
                            WHERE (PowerPlan.Analysis_Version.Analysis_Version_ID = @Analysis_Version_ID)
                            ORDER BY p.Rate_Case_ID, PowerPlan.Depr_Group.Depr_Group
					END
					GO