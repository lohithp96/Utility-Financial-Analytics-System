USE SONGS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Matthew C. Vanderbilt /00562
-- Create date: 05/31/2017 17:41
-- Description:	Gets Mortality Curve Index
-- =============================================
CREATE PROCEDURE	[PowerPlan].[getMortality_Curve]
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
							FROM PowerPlan.Mortality_Curve
							ORDER BY PowerPlan.Mortality_Curve.Mortality_Curve
						ELSE IF @flagVerbose = 1 and @flagShowExpired = 0
							SELECT *
							FROM PowerPlan.Mortality_Curve
							WHERE PowerPlan.Mortality_Curve.ValidTo > SYSUTCDATETIME()
						ELSE IF @flagVerbose = 0 AND @flagShowExpired = 0
							SELECT	Mortality_Curve_ID,
									Mortality_Curve
							FROM PowerPlan.Mortality_Curve
							WHERE PowerPlan.Mortality_Curve.ValidTo > SYSUTCDATETIME()
							ORDER BY PowerPlan.Mortality_Curve.Mortality_Curve	
						ELSE
							SELECT	Mortality_Curve_ID,
									Mortality_Curve,
									Mortality_Curve_ID + ' - ' + Mortality_Curve + (CASE WHEN ValidTo > SYSUTCDATETIME() THEN '' ELSE ' {EXPIRED}' END) AS Display,
									(CASE WHEN ValidTo > SYSUTCDATETIME() THEN '1' ELSE '2' END) + Mortality_Curve_ID + ' - ' + Mortality_Curve AS SortOrder
							FROM PowerPlan.Mortality_Curve
							ORDER BY Mortality_Curve;
					END
					GO
