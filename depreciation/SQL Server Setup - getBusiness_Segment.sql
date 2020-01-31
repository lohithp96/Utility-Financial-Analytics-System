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
CREATE PROCEDURE	PowerPlan.getBusiness_Segment
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
							FROM PowerPlan.Business_Segment d
							ORDER BY d.Business_Segment
						ELSE IF @flagVerbose = 1 and @flagShowExpired = 0
							SELECT *
							FROM PowerPlan.Business_Segment d
							WHERE d.ValidTo > SYSUTCDATETIME()
						ELSE IF @flagVerbose = 0 AND @flagShowExpired = 0
							SELECT	d.Bus_Segment_ID,
									d.Business_Segment
							FROM PowerPlan.Business_Segment d
							WHERE d.ValidTo > SYSUTCDATETIME()
							ORDER BY d.Business_Segment	
						ELSE
							SELECT	d.Bus_Segment_ID,
									d.Business_Segment,
									d.Bus_Segment_ID + ' - ' + d.Business_Segment   + '(' + User_ID + ')' + (CASE WHEN ValidTo > SYSUTCDATETIME() THEN '' ELSE ' {EXPIRED}' END) AS Display,
									(CASE WHEN ValidTo > SYSUTCDATETIME() THEN '1' ELSE '2' END) + Bus_Segment_ID + ' - ' + Business_Segment AS SortOrder
							FROM PowerPlan.Business_Segment d
							ORDER BY d.Business_Segment;
					END
					GO