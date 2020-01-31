USE SONGS;
GO

IF OBJECT_ID ( 'dbo.setAccessLog', 'P' ) IS NOT NULL
	DROP PROCEDURE dbo.setAccessLog;
GO

IF OBJECT_ID('dbo.AccessLog','U') IS NOT NULL
	DROP TABLE dbo.AccessLog;
GO

-- dbo.AccessLog
PRINT '-- dbo.AccessLog';
GO
CREATE TABLE dbo.AccessLog
(
	AccessLogID [bigint] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	ApplicationProfile [nvarchar](64) NULL,
	ApplicationName [nvarchar](64) NULL,
	SQLDateTime AS SYSUTCDATETIME(),
	SystemDateTime [DATETIME],
	ComputerName [nvarchar](15) NULL,
	UserName [nvarchar](256) NULL,
	SQLUserName AS USER_NAME(),
	WindowsType [int] NULL,
	WindowsVersionString [nvarchar](256) NULL,
	OSBuild [int] NULL,
	OSMajorVersion [int] NULL,
	OSMinorVersion [int] NULL,
	OSAdditional [nvarchar](256) NULL,
	WindowsUpTime [int] NULL,
	HardwareProfile [nvarchar](256) NULL,
	DisplayColors [int] NULL,
	LargeFonts [bit] null,
	ScreenResolutionX [int] NULL,
	ScreenResolutionY [int] NULL,
	ScreenSaverActive [bit] NULL,
	ScreenSaverTimeout [int] NULL,
	SystemDirectory [nvarchar](260) NULL,
	WindowsDirectory [nvarchar](260) NULL,
	TempPath [nvarchar](260) NULL,
	rowguid [uniqueidentifier] ROWGUIDCOL NOT NULL DEFAULT NEWSEQUENTIALID (),
	versionnumber rowversion
);
EXEC sys.sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'Access Log from Database Applications', 
	 @level0type=N'SCHEMA', @level0name=N'dbo', 
	 @level1type=N'TABLE',  @level1name=N'AccessLog';
GO
EXEC sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'Primary key for Access Log (bigint).', 
	 @level0type=N'SCHEMA', @level0name=N'dbo', 
	 @level1type=N'TABLE',  @level1name=N'AccessLog', 
	 @level2type=N'COLUMN', @level2name=N'AccessLogID';
GO
EXEC sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'Name of the computer [nvarchar](15)', 
	 @level0type=N'SCHEMA', @level0name=N'dbo', 
	 @level1type=N'TABLE',  @level1name=N'AccessLog', 
	 @level2type=N'COLUMN', @level2name=N'ComputerName';
GO
EXEC sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'Name of the Current Hardware Profile [nvarchar](256)', 
	 @level0type=N'SCHEMA', @level0name=N'dbo', 
	 @level1type=N'TABLE',  @level1name=N'AccessLog', 
	 @level2type=N'COLUMN', @level2name=N'HardwareProfile';
GO
EXEC sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'Windows User Name [nvarchar](256)', 
	 @level0type=N'SCHEMA', @level0name=N'dbo', 
	 @level1type=N'TABLE',  @level1name=N'AccessLog', 
	 @level2type=N'COLUMN', @level2name=N'UserName';
GO
EXEC sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'Number of Colors Displayed by the Adapter {-1 = True Color} [int]', 
	 @level0type=N'SCHEMA', @level0name=N'dbo', 
	 @level1type=N'TABLE',  @level1name=N'AccessLog', 
	 @level2type=N'COLUMN', @level2name=N'DisplayColors';
GO
EXEC sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'Windows Type {0 = Win32s; 1 = Win95; 2 = WinNT}', 
	 @level0type=N'SCHEMA', @level0name=N'dbo', 
	 @level1type=N'TABLE',  @level1name=N'AccessLog', 
	 @level2type=N'COLUMN', @level2name=N'WindowsType';
GO

PRINT '-- dbo.setAccessLog';
GO
CREATE PROCEDURE dbo.setAccessLog
				(
						@ApplicationProfile [nvarchar](64) = "UNK",
						@ApplicationName [nvarchar](64) = "UNKNOWN - NOT PROVIDED",
						@SystemDateTime [DATETIME] = NULL,
						@ComputerName [nvarchar](15) = NULL,
						@UserName [nvarchar](256) = NULL,
						@WindowsType [int] = NULL,
						@WindowsVersionString [nvarchar](256) = NULL,
						@OSBuild [int] = NULL,
						@OSMajorVersion [int] = NULL,
						@OSMinorVersion [int] = NULL,
						@OSAdditional [nvarchar](256) = NULL,
						@WindowsUpTime [int] = NULL,
						@HardwareProfile [nvarchar](256) = NULL,
						@DisplayColors [int] = NULL,
						@LargeFonts [bit] = null,
						@ScreenResolutionX [int] = NULL,
						@ScreenResolutionY [int] = NULL,
						@ScreenSaverActive [bit] = NULL,
						@ScreenSaverTimeout [int] = NULL,
						@SystemDirectory [nvarchar](260) = NULL,
						@WindowsDirectory [nvarchar](260) = NULL,
						@TempPath [nvarchar](260) = NULL
				)
				AS
				SET NOCOUNT ON
				INSERT INTO dbo.AccessLog   (ApplicationProfile,
												ApplicationName,
												SystemDateTime,
												ComputerName,
												UserName,
												WindowsType,
												WindowsVersionString,
												OSBuild,
												OSMajorVersion,
												OSMinorVersion,
												OSAdditional,
												WindowsUpTime,
												HardwareProfile,
												DisplayColors,
												LargeFonts,
												ScreenResolutionX,
												ScreenResolutionY,
												ScreenSaverActive,
												ScreenSaverTimeout,
												SystemDirectory,
												WindowsDirectory,
												TempPath)
							VALUES (@ApplicationProfile,
									@ApplicationName,
									@SystemDateTime,
									@ComputerName,
									@UserName,
									@WindowsType,
									@WindowsVersionString,
									@OSBuild,
									@OSMajorVersion,
									@OSMinorVersion,
									@OSAdditional,
									@WindowsUpTime,
									@HardwareProfile,
									@DisplayColors,
									@LargeFonts,
									@ScreenResolutionX,
									@ScreenResolutionY,
									@ScreenSaverActive,
									@ScreenSaverTimeout,
									@SystemDirectory,
									@WindowsDirectory,
									@TempPath);
GO