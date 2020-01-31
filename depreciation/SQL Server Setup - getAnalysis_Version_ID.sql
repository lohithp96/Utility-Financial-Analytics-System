USE SONGS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Matthew C. Vanderbilt /00562
-- Create date: 06/01/2017 09:31
-- Description:	Gets Analysis Version Index
-- =============================================
CREATE PROCEDURE	[PowerPlan].[getAnalysis_Version]
					(
						@flagVerbose bit = 0,
						@flagShowExpired bit = 0,
						@Analysis_Version_ID int = NULL
					) 
					AS
					BEGIN
						-- SET NOCOUNT ON added to prevent extra result sets from
						-- interfering with SELECT statements.
						SET NOCOUNT ON;

						IF @flagVerbose = 1 AND @flagShowExpired = 1
							SELECT *
							FROM PowerPlan.Analysis_Version
							WHERE 1=1 
							      AND (@Analysis_Version_ID IS NULL OR PowerPlan.Analysis_Version.Analysis_Version_ID = @Analysis_Version_ID)
							ORDER BY PowerPlan.Analysis_Version.Time_Stamp
						ELSE IF @flagVerbose = 1 and @flagShowExpired = 0
							SELECT *
							FROM PowerPlan.Analysis_Version
							WHERE 1=1 
							      AND PowerPlan.Analysis_Version.ValidTo > SYSUTCDATETIME()
								  AND (@Analysis_Version_ID IS NULL OR PowerPlan.Analysis_Version.Analysis_Version_ID = @Analysis_Version_ID)
						ELSE IF @flagVerbose = 0 AND @flagShowExpired = 0
							SELECT	Analysis_Version_ID,
									Analysis_Version
							FROM PowerPlan.Analysis_Version
							WHERE 1=1 
							      AND PowerPlan.Analysis_Version.ValidTo > SYSUTCDATETIME()
								  AND (@Analysis_Version_ID IS NULL OR PowerPlan.Analysis_Version.Analysis_Version_ID = @Analysis_Version_ID)
							ORDER BY PowerPlan.Analysis_Version.Time_Stamp	
						ELSE
							SELECT	Analysis_Version_ID,
									Analysis_Version,
									Analysis_Version_ID + ' - ' + Analysis_Version + '(' + User_ID + ')' + (CASE WHEN ValidTo > SYSUTCDATETIME() THEN '' ELSE ' {EXPIRED}' END) AS Display,
									(CASE WHEN ValidTo > SYSUTCDATETIME() THEN '1' ELSE '2' END) + Analysis_Version_ID + ' - ' + Analysis_Version AS SortOrder
							FROM PowerPlan.Analysis_Version
							WHERE 1=1 
							      AND (@Analysis_Version_ID IS NULL OR PowerPlan.Analysis_Version.Analysis_Version_ID = @Analysis_Version_ID)
							ORDER BY PowerPlan.Analysis_Version.Time_Stamp;
					END
					GO