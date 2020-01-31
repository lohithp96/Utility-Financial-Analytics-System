USE SONGS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Matthew C. Vanderbilt /00562
-- Create date: 06/02/2017 13:09
-- Description: Creates MRound Function
-- =============================================
PRINT 'DROP Common.MRound';
GO
IF OBJECT_ID ( 'Common.MRound','FN') IS NOT NULL
    DROP FUNCTION Common.MRound;
GO

CREATE FUNCTION Common.MROUND 
	(	@inputValue FLOAT, 
		@multiple FLOAT = NULL
	)
	RETURNS FLOAT
	WITH EXECUTE AS CALLER
	AS
	BEGIN
		DECLARE @returnValue FLOAT = 0;
		DECLARE @multiplier BIT = 1;
		IF (@inputValue IS NULL) SET @inputValue = 0;
		IF (ISNULL(@multiple,0)=0) SET @multiple = CAST(1 AS FLOAT)/CAST(12 AS FLOAT);
		IF @inputValue<0 SET @multiplier = -1;
		SET @inputValue = ABS(@inputValue);
		SET @returnValue = CAST(CAST((@inputValue/@multiple) AS INT) AS FLOAT) * @multiple;
		IF ((@inputValue/@multiple) - CAST(@inputValue/@multiple AS INT)) >= 0.5 SET @returnValue = @returnValue + @multiple;
		SET @returnValue = @returnValue * @multiplier;
		RETURN(@returnValue);
	END;
GO