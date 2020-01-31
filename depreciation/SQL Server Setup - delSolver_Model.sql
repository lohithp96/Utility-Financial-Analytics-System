USE SONGS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Matthew C. Vanderbilt /00562
-- Create date: 06/02/2017 10:29
-- Description:	Delete Solver Model Data
-- =============================================
IF OBJECT_ID ( 'Depr.setSolver_Model','P') IS NOT NULL
    DROP PROCEDURE Depr.setSolver_Model;
GO

CREATE PROCEDURE	Depr.setSolver_Model 
                    AS
					BEGIN
						-- SET NOCOUNT ON added to prevent extra result sets from
						-- interfering with SELECT statements.
						SET NOCOUNT ON;
                        DELETE FROM Depr.Solver_Model;
					END
					GO