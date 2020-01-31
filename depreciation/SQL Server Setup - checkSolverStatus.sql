USE SONGS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Matthew C. Vanderbilt /00562
-- Create date: 06/03/2017 08:14
-- Description:	Use with App - Checks Status
-- =============================================
IF OBJECT_ID ( 'Depr.checkSolverStatus','P') IS NOT NULL
    DROP PROCEDURE Depr.checkSolverStatus;
GO

CREATE PROCEDURE	[Depr].[checkSolverStatus] 
					AS
					BEGIN
						-- SET NOCOUNT ON added to prevent extra result sets from
						-- interfering with SELECT statements.
						SET NOCOUNT ON;

						DECLARE @currentCounter as INT = 0;
                        DECLARE @previousCounter as int = -1;

                        WHILE @currentCounter<>@previousCounter BEGIN
                            SELECT  TOP (100) PERCENT
                                    PowerPlan.Analysis_Version.Analysis_Version, 
                                    PowerPlan.Analysis_Account.Analysis_Account, 
                                    Count(Depr.Solver_Results.Trial_ID) AS CountOfTrial_ID, 
                                    Min(Depr.Solver_Results.CreatedDate) AS FirstRun, 
                                    Max(Depr.Solver_Results.CreatedDate) AS LatestRun
                            FROM (Depr.Solver_Results   INNER JOIN PowerPlan.Analysis_Account ON Depr.Solver_Results.Analysis_Account_ID = PowerPlan.Analysis_Account.Analysis_Account_ID) 
                                                        INNER JOIN PowerPlan.Analysis_Version ON Depr.Solver_Results.Analysis_Version_ID = PowerPlan.Analysis_Version.Analysis_Version_ID
                            GROUP BY    PowerPlan.Analysis_Version.Analysis_Version, 
                                        PowerPlan.Analysis_Account.Analysis_Account
                            ORDER BY    Max(Depr.Solver_Results.CreatedDate) DESC;

                            SET @previousCounter = @currentCounter;

                            SELECT TOP (1) @currentCounter = Count(Depr.Solver_Results.Trial_ID)
                            FROM Depr.Solver_Results;

                            WAITFOR DELAY '00:01:00'
                        END
					END
					GO