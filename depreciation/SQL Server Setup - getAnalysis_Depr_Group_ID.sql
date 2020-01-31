USE SONGS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Matthew C. Vanderbilt /00562
-- Create date: 06/07/2017 14:32
-- Description:	Gets Analysis Depr Group Index
-- =============================================
CREATE PROCEDURE	[PowerPlan].[getAnalysis_Depr_Group]
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
							FROM PowerPlan.Analysis_Depr_Group
							ORDER BY PowerPlan.Analysis_Depr_Group.Time_Stamp
						ELSE IF @flagVerbose = 1 and @flagShowExpired = 0
							SELECT *
							FROM PowerPlan.Analysis_Depr_Group
							WHERE PowerPlan.Analysis_Depr_Group.ValidTo > SYSUTCDATETIME()
						ELSE IF @flagVerbose = 0 AND @flagShowExpired = 0
							SELECT	Analysis_Depr_Group_ID,
									Analysis_Depr_Group
							FROM PowerPlan.Analysis_Depr_Group
							WHERE PowerPlan.Analysis_Depr_Group.ValidTo > SYSUTCDATETIME()
							ORDER BY PowerPlan.Analysis_Depr_Group.Time_Stamp	
						ELSE
							SELECT	Analysis_Depr_Group_ID,
									Analysis_Depr_Group,
									Analysis_Depr_Group_ID + ' - ' + Analysis_Depr_Group + '(' + User_ID + ')' + (CASE WHEN ValidTo > SYSUTCDATETIME() THEN '' ELSE ' {EXPIRED}' END) AS Display,
									(CASE WHEN ValidTo > SYSUTCDATETIME() THEN '1' ELSE '2' END) + Analysis_Depr_Group_ID + ' - ' + Analysis_Depr_Group AS SortOrder
							FROM PowerPlan.Analysis_Depr_Group
							ORDER BY PowerPlan.Analysis_Depr_Group.Time_Stamp;
					END
					GO