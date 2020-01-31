USE SONGS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Matthew C. Vanderbilt /00562
-- Create date: 06/02/2017 09:12
-- Description:	Reset Solver Results Master
-- =============================================
IF OBJECT_ID ( 'Depr.setSolver_Model_Master','P') IS NOT NULL
    DROP PROCEDURE Depr.setSolver_Model_Master;
GO

CREATE PROCEDURE	Depr.setSolver_Model_Master 
                    (
                        @Age_Max NUMERIC(22,2) = 500.5
                    )
					AS
					BEGIN
						-- SET NOCOUNT ON added to prevent extra result sets from
						-- interfering with SELECT statements.
						SET NOCOUNT ON;
                        DECLARE @Age NUMERIC(22,2);
                        SET @Age = 0;
                        DELETE FROM Depr.Solver_Model_Master;
						WHILE @Age <= @Age_Max
                            BEGIN
                                INSERT INTO Depr.Solver_Model_Master(AGE) VALUES(@Age);
                                IF @Age=0
                                    SET @Age = 0.5;
                                ELSE
                                    SET @Age = @Age+1;
                            END;
					END
					GO