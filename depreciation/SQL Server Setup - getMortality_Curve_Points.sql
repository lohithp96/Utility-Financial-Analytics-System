USE SONGS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Matthew C. Vanderbilt /00562
-- Create date: 06/01/2017 09:16
-- Description:	Gets Business Segment Index
-- =============================================
IF OBJECT_ID ( 'PowerPlan.getMortality_Curve_Points','P') IS NOT NULL
    DROP PROCEDURE PowerPlan.getMortality_Curve_Points;
GO
CREATE PROCEDURE	PowerPlan.getMortality_Curve_Points
					(
						@flagVerbose bit = 0,
						@flagShowExpired bit = 0
					) 
					AS
					BEGIN
						-- SET NOCOUNT ON added to prevent extra result sets from
						-- interfering with SELECT statements.
						SET NOCOUNT ON;

						IF @flagVerbose = 1 AND @flagShowExpired = 1
							SELECT *
							FROM PowerPlan.Mortality_Curve_Points d
							ORDER BY d.Mortality_Curve_ID, d.Data_Point
						ELSE IF @flagVerbose = 1 and @flagShowExpired = 0
							SELECT *
							FROM PowerPlan.Mortality_Curve_Points d
							WHERE d.ValidTo > SYSUTCDATETIME()
						ELSE IF @flagVerbose = 0 AND @flagShowExpired = 0
							SELECT	d.Mortality_Curve_ID,
                                    d.Data_Point,
                                    d.Age_Per_Exp_Life,
                                    d.Rem_Life_Percentage,
                                    d.Surviving_Percentage
							FROM PowerPlan.Mortality_Curve_Points d
							WHERE d.ValidTo > SYSUTCDATETIME()
							ORDER BY d.Mortality_Curve_ID, d.Data_Point	
						ELSE
							SELECT	d.Mortality_Curve_ID,
                                    d.Data_Point,
                                    d.Age_Per_Exp_Life,
                                    d.Rem_Life_Percentage,
                                    d.Surviving_Percentage
							FROM PowerPlan.Mortality_Curve_Points d
							ORDER BY d.Mortality_Curve_ID, d.Data_Point	
					END
					GO