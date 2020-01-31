USE SONGS;
GO

/****** Object:  StoredProcedure [PowerPlan].[getDS_Data_Transaction]    Script Date: 21 SEP 2017 13:35 /00562-Vanderbilt ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ( 'PowerPlan.getDS_Data_Transaction','P') IS NOT NULL
    DROP PROCEDURE PowerPlan.getDS_Data_Transaction;
GO

CREATE PROCEDURE	PowerPlan.getDS_Data_Transaction
					(
						@Depr_Group_ID INT = 0,
                        @Summary_Trans NVARCHAR(35) = '',
                        @startActivity_Year INT = 0,
                        @endActivity_Year INT = 0,
                        @startVintage INT = 0,
                        @endVintage INT = 0,
                        @excludeAROs INT = 1,
                        @excludeCPUC INT = 0,
                        @excludeFERC INT = 1,
                        @excludeLand INT = 1,
                        @excludeNonUtility INT = 1,
                        @excludeNuclear INT = 1,
                        @flagGroupTransactions INT = 1,
                        @flagPrintSQL INT = 0
					) 
					AS
					BEGIN
						-- SET NOCOUNT ON added to prevent extra result sets from
						-- interfering with SELECT statements.
						SET NOCOUNT ON;

                        DECLARE @SQL NVARCHAR(MAX) = NULL;
                        DECLARE @filterExists INT = 0;
                        
                        IF @Summary_Trans<> ''
                            BEGIN
                                SET @filterExists = @Depr_Group_ID + 1 + @startActivity_Year + @endActivity_Year + @startVintage + @endVintage + @excludeAROs + @excludeCPUC + @excludeFERC + @excludeLand + @excludeNonUtility + @excludeNuclear;
                            END;

                        -- Return Sorted Results
                        SET @SQL = 'SELECT  TOP (100)   PERCENT ';
                        IF @flagGroupTransactions <> 1 SET @SQL = @SQL + 'PowerPlan.DS_Data_Transaction.DS_Trans_ID, ';
                        SET @SQL = @SQL +  'PowerPlan.DS_Data_Transaction.DS_Data_Account_ID, 
                                            PowerPlan.DS_Data_Account_Depr_Group.Depr_Group_ID, 
                                            PowerPlan.DS_Data_Account.DS_Data_Account, 
                                            PowerPlan.Depr_Group.Depr_Group,
                                            PowerPlan.Summary_Transaction_Code.Summary_Trans,
                                            PowerPlan.DS_Data_Transaction.Analysis_Trans_ID, 
                                            PowerPlan.Analysis_Transaction_Code.Analysis_Transaction_Code,
                                            PowerPlan.DS_Data_Transaction.Vintage, 
                                            PowerPlan.DS_Data_Transaction.Activity_Year, 
                                            PowerPlan.DS_Data_Transaction.Adjustment_Year, 
                                            YEAR(PowerPlan.DS_Data_Transaction.Effective_Date) AS Effective_Year, ';
                        IF @flagGroupTransactions=1 
                            BEGIN
                                SET @SQL = @SQL + 'SUM(PowerPlan.DS_Data_Transaction.Quantity) AS Quantity, ';
                                SET @SQL = @SQL + 'SUM(PowerPlan.DS_Data_Transaction.Amount * PowerPlan.Analysis_Transaction_Code.Sum_Factor) AS Value ';
                            END;
                        ELSE 
                            BEGIN
                                SET @SQL = @SQL + 'PowerPlan.DS_Data_Transaction.Quantity, ';
                                SET @SQL = @SQL + '(PowerPlan.DS_Data_Transaction.Amount * PowerPlan.Analysis_Transaction_Code.Sum_Factor) AS Value, ';
                                SET @SQL = @SQL +  'PowerPlan.DS_Data_Transaction.Transaction_Input_Type_ID, 
                                                    PowerPlan.Transaction_Input_Type.Transaction_Input_Type, 
                                                    PowerPlan.DS_Data_Transaction.Description ';
                            END;
                        
                        SET @SQL = @SQL +
                                   'FROM    PowerPlan.DS_Data_Transaction INNER JOIN
                                            PowerPlan.DS_Data_Account ON PowerPlan.DS_Data_Transaction.DS_Data_Account_ID = PowerPlan.DS_Data_Account.DS_Data_Account_ID INNER JOIN
                                            PowerPlan.DS_Data_Account_Depr_Group ON PowerPlan.DS_Data_Account.DS_Data_Account_ID = PowerPlan.DS_Data_Account_Depr_Group.DS_Data_Account_ID INNER JOIN
                                            PowerPlan.Depr_Group ON PowerPlan.DS_Data_Account_Depr_Group.Depr_Group_ID = PowerPlan.Depr_Group.Depr_Group_ID INNER JOIN
                                            PowerPlan.Analysis_Transaction_Code ON PowerPlan.DS_Data_Transaction.Analysis_Trans_ID = PowerPlan.Analysis_Transaction_Code.Analysis_Trans_ID INNER JOIN
                                            PowerPlan.Transaction_Input_Type ON PowerPlan.DS_Data_Transaction.Transaction_Input_Type_ID = PowerPlan.Transaction_Input_Type.Transaction_Input_Type_ID INNER JOIN
                                            PowerPlan.Summary_Transaction_Code ON PowerPlan.Analysis_Transaction_Code.Summary_Trans_ID = PowerPlan.Summary_Transaction_Code.Summary_Trans_ID ';
                        IF @flagGroupTransactions = 1
                            SET @SQL = @SQL + 'GROUP BY ' +
                                           'PowerPlan.DS_Data_Transaction.DS_Data_Account_ID, 
                                            PowerPlan.DS_Data_Account_Depr_Group.Depr_Group_ID, 
                                            PowerPlan.DS_Data_Account.DS_Data_Account, 
                                            PowerPlan.Depr_Group.Depr_Group,
                                            PowerPlan.Summary_Transaction_Code.Summary_Trans,
                                            PowerPlan.DS_Data_Transaction.Analysis_Trans_ID, 
                                            PowerPlan.Analysis_Transaction_Code.Analysis_Transaction_Code,
                                            PowerPlan.DS_Data_Transaction.Vintage, 
                                            PowerPlan.DS_Data_Transaction.Activity_Year, 
                                            PowerPlan.DS_Data_Transaction.Adjustment_Year, 
                                            YEAR(PowerPlan.DS_Data_Transaction.Effective_Date) ';
                        IF @filterExists <> 0
                            BEGIN
                                IF @flagGroupTransactions = 1 SET @SQL = @SQL + 'HAVING ((1=1) ';
                                ELSE SET @SQL = @SQL + 'WHERE ((1=1) ';
                                IF @Depr_Group_ID <> 0 SET @SQL = @SQL + 'AND (PowerPlan.DS_Data_Account_Depr_Group.Depr_Group_ID = ' + CONVERT(NVARCHAR,@Depr_Group_ID) + ') ';
                                IF @Summary_Trans <> '' SET @SQL = @SQL + 'AND (PowerPlan.Summary_Transaction_Code.Summary_Trans LIKE ''%' + @Summary_Trans + '%'') ';
                                IF @startActivity_Year <> 0 SET @SQL = @SQL + 'AND (PowerPlan.DS_Data_Transaction.Activity_Year >= ' + CONVERT(NVARCHAR,@startActivity_Year) +  ') ';
                                IF @endActivity_Year <> 0 SET @SQL = @SQL + 'AND (PowerPlan.DS_Data_Transaction.Activity_Year <= ' + CONVERT(NVARCHAR,@endActivity_Year) + ') ';
                                IF @startVintage <> 0 SET @SQL = @SQL + 'AND (PowerPlan.DS_Data_Transaction.Vintage >= ' + CONVERT(NVARCHAR,@startVintage) +  ') ';
                                IF @endVintage <> 0 SET @SQL = @SQL + 'AND (PowerPlan.DS_Data_Transaction.Vintage <= ' + CONVERT(NVARCHAR,@endVintage) + ') ';
                                IF @excludeAROs=1 SET @SQL = @SQL + 'AND (PowerPlan.Depr_Group.Depr_Group NOT LIKE ''% ARC%'') ';
                                IF @excludeAROs=1 SET @SQL = @SQL + 'AND (PowerPlan.Depr_Group.Depr_Group NOT LIKE ''% ARO%'') ';
                                IF @excludeCPUC=1 SET @SQL = @SQL + 'AND ((PowerPlan.Depr_Group.Depr_Group LIKE ''E35%'') ' +
                                                                    'OR  (PowerPlan.Depr_Group.Depr_Group LIKE ''E0435%'') ' +
                                                                    'OR  (PowerPlan.Depr_Group.Depr_Group LIKE ''E0535%'')) ';
                                IF @excludeFERC=1 SET @SQL = @SQL + 'AND ((PowerPlan.Depr_Group.Depr_Group NOT LIKE ''E35%'') ' +
                                                                    'AND  (PowerPlan.Depr_Group.Depr_Group NOT LIKE ''E0435%'') ' +
                                                                    'AND  (PowerPlan.Depr_Group.Depr_Group NOT LIKE ''E0535%'')) ';
                                IF @excludeLand=1 SET @SQL = @SQL + 'AND NOT ((PowerPlan.Depr_Group.Depr_Group LIKE ''%LAND%'') ' +
                                                                    'AND ((PowerPlan.Depr_Group.Depr_Group LIKE ''%.10%'') ' +
                                                                    'OR   (PowerPlan.Depr_Group.Depr_Group LIKE ''%.11%'') ' +
                                                                    'OR   (PowerPlan.Depr_Group.Depr_Group LIKE ''%.12%'') ' +
                                                                    'OR   (PowerPlan.Depr_Group.Depr_Group LIKE ''%.16%''))) ';
                                IF @excludeNonUtility=1 SET @SQL = @SQL + 'AND (PowerPlan.Depr_Group.Depr_Group NOT LIKE ''NU%'') ';
                                IF @excludeNuclear=1 SET @SQL = @SQL + 'AND (PowerPlan.Depr_Group.Depr_Group NOT LIKE ''%E32%'') ';
                                SET @SQL = @SQL + ') ';
                            END;

                        SET @SQL = @SQL +
                                   'ORDER BY    PowerPlan.Depr_Group.Depr_Group, 
                                                PowerPlan.DS_Data_Transaction.Vintage, 
                                                PowerPlan.DS_Data_Transaction.Activity_Year';

                        IF @flagPrintSQL=1
                            BEGIN
                                PRINT @SQL;
                            END;
                        
                        IF @flagPrintSQL=0
                            BEGIN
                                EXEC(@SQL);
                                PRINT @SQL;
                            END;

END
GO