USE [SONGS]
GO

/****** Object:  StoredProcedure [Depr].[getRate_Case_Parameters]    Script Date: 8/24/2017 12:13:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE	[Depr].[getRate_Case_Parameters]
					(
						@Analysis_Version_ID int = NULL,
                        @Raw_Data int = NULL,
						@Rate_Case_ID_CPUC nvarchar(7) = NULL,
						@Rate_Case_ID_FERC nvarchar(7) = NULL
					) 
					AS
					BEGIN
						-- SET NOCOUNT ON added to prevent extra result sets from
						-- interfering with SELECT statements.
						SET NOCOUNT ON;

						DECLARE @SQL NVARCHAR(MAX) = NULL;

						IF ISNULL(@Raw_Data,-1)=-1 
							SET @SQL = 'SELECT TOP (100) PERCENT 
										p.Rate_Case_ID, 
										rc.Rate_Case, 
										p.Depr_Group_ID, 
										p.Depr_Method_Id, 
										g.Depr_Group, 
										m.Depr_Method, 
										v.Analysis_Version_ID, 
										v.Analysis_Version, 
										map.DS_Analysis_Dataset_ID, 
										map.DS_Data_Account_ID, 
										map.Analysis_Account_ID, 
										p.Mortality_Curve_ID, 
										c.Mortality_Curve, 
										p.Expected_Average_Life, 
										p.End_Of_Life, 
										p.Net_Salvage_Pct, 
										p.Interim_Retirement_Pct, 
										p.Rate, 
										p.Cost_of_Removal_Rate ';
						ELSE 
							SET @SQL = 'SELECT TOP (100) PERCENT 
										p.*,
										rc.*,
										g.*,
										m.*,
										v.*,
										map.*,
										c.* ';

						SET @SQL = @SQL + 'FROM    Depr.Rate_Case_Parameter AS p LEFT OUTER JOIN
											PowerPlan.Depreciation_Method AS m ON p.Depr_Method_Id = m.Depr_Method_Id AND p.Depr_Method_Id = m.Depr_Method_Id LEFT OUTER JOIN
											PowerPlan.Depr_Group AS g ON p.Depr_Group_ID = g.Depr_Group_ID LEFT OUTER JOIN
											PowerPlan.Mortality_Curve AS c ON p.Mortality_Curve_ID = c.Mortality_Curve_ID AND p.Mortality_Curve_ID = c.Mortality_Curve_ID LEFT OUTER JOIN
											Depr.Rate_Case AS rc ON p.Rate_Case_ID = rc.Rate_Case_ID AND p.Rate_Case_ID = rc.Rate_Case_ID LEFT OUTER JOIN
											PowerPlan.Analysis_Version AS v INNER JOIN
											PowerPlan.DS_Data_Account_Depr_Group INNER JOIN
											PowerPlan.DS_Acct_Dataset_Map AS map ON PowerPlan.DS_Data_Account_Depr_Group.DS_Data_Account_ID = map.DS_Data_Account_ID ON 
											v.DS_Analysis_Dataset_ID = map.DS_Analysis_Dataset_ID ON 
											p.Depr_Group_ID = PowerPlan.DS_Data_Account_Depr_Group.Depr_Group_ID ';

						IF NOT(ISNULL(@Analysis_Version_ID,-1)=-1 AND ISNULL(@Rate_Case_ID_CPUC,-1)=-1 AND ISNULL(@Rate_Case_ID_FERC,-1)=-1)
							BEGIN
								SET @SQL = @SQL + 'WHERE (';

								IF ISNULL(@Analysis_Version_ID,-1)<>-1 SET @SQL = @SQL + 'v.Analysis_Version_ID=' + CONVERT(NVARCHAR,@Analysis_VERSION_ID);

								IF NOT(ISNULL(@Rate_Case_ID_CPUC,'')='' AND ISNULL(@Rate_Case_ID_FERC,'')='')
									BEGIN
										IF ISNULL(@Analysis_Version_ID,-1)<>-1 SET @SQL = @SQL + ' AND ';
										SET @SQL = @SQL + 'p.Rate_Case_ID IN(';

										IF ISNULL(@Rate_Case_ID_CPUC,'')<>''
											BEGIN
												SET @SQL = @SQL + '''' + @Rate_Case_ID_CPUC + '''';
												IF ISNULL(@Rate_Case_ID_FERC,'')<>'' SET @SQL = @SQL + ',';
											END;

										IF ISNULL(@Rate_Case_ID_FERC,'')<>'' SET @SQL = @SQL + '''' + @Rate_Case_ID_FERC + '''';

										SET @SQL = @SQL + ') ';
									END;

								SET @SQL = @SQL + ') ';
							END;
		
						SET @SQL = @SQL + 'ORDER BY p.Rate_Case_ID, g.Depr_Group;';
						PRINT @SQL;
						EXEC(@SQL);
					END

GO


