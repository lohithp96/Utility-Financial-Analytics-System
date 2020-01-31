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
					AS
					BEGIN
						-- SET NOCOUNT ON added to prevent extra result sets from
						-- interfering with SELECT statements.
						SET NOCOUNT ON;

						DELETE FROM Solver_Reults
					END
					GO