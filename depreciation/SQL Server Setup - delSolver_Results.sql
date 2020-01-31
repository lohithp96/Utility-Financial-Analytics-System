USE SONGS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Matthew C. Vanderbilt /00562
-- Create date: 06/02/2017 08:09
-- Description:	Gets Analysis Version Index
-- =============================================
DROP PROCEDURE Depr.delSolver_Results
GO

CREATE PROCEDURE	[Depr].[delSolver_Results] 
                    (
                        @Analysis_Account_ID INT = -1,
                        @Analysis_Version_ID INT = -1
                    )
					AS
					BEGIN
						-- SET NOCOUNT ON added to prevent extra result sets from
						-- interfering with SELECT statements.
						SET NOCOUNT ON;
						DELETE FROM Solver_Results WHERE Solver_Results.Analysis_Account_ID=@Analysis_Account_ID AND Solver_Results.Analysis_Version_ID=@Analysis_Version_ID
					END
					GO