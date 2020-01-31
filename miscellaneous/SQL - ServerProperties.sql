SELECT	'ServerNameFunction' AS [PropertyName],
		@@SERVERNAME AS [PropertyValue]
UNION
SELECT	'VersionFunction' AS [PropertyName],
		@@VERSION AS [PropertyValue]
UNION	
SELECT	'BuildCLRVersion' AS [PropertyName],
		SERVERPROPERTY('BuildCLRVersion') AS [PropertyValue]
UNION	
SELECT	'Collation' AS [PropertyName],
		SERVERPROPERTY('Collation') AS [PropertyValue]
UNION	
SELECT	'CollationID' AS [PropertyName],
		SERVERPROPERTY('CollationID') AS [PropertyValue]
UNION	
SELECT	'ComparisonStyle' AS [PropertyName],
		SERVERPROPERTY('ComparisonStyle') AS [PropertyValue]
UNION	
SELECT	'ComputerNamePhysicalNetBIOS' AS [PropertyName],
		SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS [PropertyValue]
UNION	
SELECT	'Edition' AS [PropertyName],
		SERVERPROPERTY('Edition') AS [PropertyValue]
UNION	
SELECT	'EditionID' AS [PropertyName],
		SERVERPROPERTY('EditionID') AS [PropertyValue]
UNION	
SELECT	'EngineEdition' AS [PropertyName],
		SERVERPROPERTY('EngineEdition') AS [PropertyValue]
UNION
SELECT	'HadrManagerStatus' AS [PropertyName],
		SERVERPROPERTY('HadrManagerStatus') AS [PropertyValue]
UNION	
SELECT	'InstanceDefaultDataPath' AS [PropertyName],
		SERVERPROPERTY('InstanceDefaultDataPath') AS [PropertyValue]
UNION	
SELECT	'InstanceDefaultLogPath' AS [PropertyName],
		SERVERPROPERTY('InstanceDefaultLogPath') AS [PropertyValue]
UNION	
SELECT	'InstanceName' AS [PropertyName],
		SERVERPROPERTY('InstanceName') AS [PropertyValue]
UNION	
SELECT	'IsAdvancedAnalyticsInstalled' AS [PropertyName],
		SERVERPROPERTY('IsAdvancedAnalyticsInstalled') AS [PropertyValue]
UNION	
SELECT	'IsClustered' AS [PropertyName],
		SERVERPROPERTY('IsClustered') AS [PropertyValue]
UNION	
SELECT	'IsFullTextInstalled' AS [PropertyName],
		SERVERPROPERTY('IsFullTextInstalled') AS [PropertyValue]
UNION	
SELECT	'IsHadrEnabled' AS [PropertyName],
		SERVERPROPERTY('IsHadrEnabled') AS [PropertyValue]
UNION	
SELECT	'IsIntegratedSecurityOnly' AS [PropertyName],
		SERVERPROPERTY('IsIntegratedSecurityOnly') AS [PropertyValue]
UNION	
SELECT	'IsLocalDB' AS [PropertyName],
		SERVERPROPERTY('IsLocalDB') AS [PropertyValue]
UNION	
SELECT	'IsPolybaseInstalled' AS [PropertyName],
		SERVERPROPERTY('IsPolybaseInstalled') AS [PropertyValue]
UNION	
SELECT	'IsSingleUser' AS [PropertyName],
		SERVERPROPERTY('IsSingleUser') AS [PropertyValue]
UNION	
SELECT	'IsXTPSupported' AS [PropertyName],
		SERVERPROPERTY('IsXTPSupported') AS [PropertyValue]
UNION	
SELECT	'LCID' AS [PropertyName],
		SERVERPROPERTY('LCID') AS [PropertyValue]
UNION	
SELECT	'LicenseType' AS [PropertyName],
		SERVERPROPERTY('LicenseType') AS [PropertyValue]
UNION	
SELECT	'MachineName' AS [PropertyName],
		SERVERPROPERTY('MachineName') AS [PropertyValue]
UNION
SELECT	'NumLicenses' AS [PropertyName],
		SERVERPROPERTY('NumLicenses') AS [PropertyValue]
UNION	
SELECT	'ProcessID' AS [PropertyName],
		SERVERPROPERTY('ProcessID') AS [PropertyValue]
UNION	
SELECT	'ProductBuild' AS [PropertyName],
		SERVERPROPERTY('ProductBuild') AS [PropertyValue]
UNION	
SELECT	'ProductBuildType ' AS [PropertyName],
		SERVERPROPERTY('ProductBuildType ') AS [PropertyValue]
UNION	
SELECT	'ProductLevel' AS [PropertyName],
		SERVERPROPERTY('ProductLevel') AS [PropertyValue]
UNION	
SELECT	'ProductMajorVersion' AS [PropertyName],
		SERVERPROPERTY('ProductMajorVersion') AS [PropertyValue]
UNION	
SELECT	'ProductMinorVersion' AS [PropertyName],
		SERVERPROPERTY('ProductMinorVersion') AS [PropertyValue]
UNION	
SELECT	'ProductUpdateLevel' AS [PropertyName],
		SERVERPROPERTY('ProductUpdateLevel') AS [PropertyValue]
UNION	
SELECT	'ProductUpdateReference' AS [PropertyName],
		SERVERPROPERTY('ProductUpdateReference') AS [PropertyValue]
UNION	
SELECT	'ProductVersion' AS [PropertyName],
		SERVERPROPERTY('ProductVersion') AS [PropertyValue]
UNION	
SELECT	'ResourceLastUpdateDateTime' AS [PropertyName],
		SERVERPROPERTY('ResourceLastUpdateDateTime') AS [PropertyValue]
UNION	
SELECT	'ResourceVersion' AS [PropertyName],
		SERVERPROPERTY('ResourceVersion') AS [PropertyValue]
UNION	
SELECT	'ServerName' AS [PropertyName],
		SERVERPROPERTY('ServerName') AS [PropertyValue]
UNION	
SELECT	'SqlCharSet' AS [PropertyName],
		SERVERPROPERTY('SqlCharSet') AS [PropertyValue]
UNION	
SELECT	'SqlCharSetName' AS [PropertyName],
		SERVERPROPERTY('SqlCharSetName') AS [PropertyValue]
UNION	
SELECT	'SqlSortOrder' AS [PropertyName],
		SERVERPROPERTY('SqlSortOrder') AS [PropertyValue]
UNION
SELECT	'SqlSortOrderName' AS [PropertyName],
		SERVERPROPERTY('SqlSortOrderName') AS [PropertyValue]
UNION	
SELECT	'FilestreamShareName' AS [PropertyName],
		SERVERPROPERTY('FilestreamShareName') AS [PropertyValue]
UNION	
SELECT	'FilestreamConfiguredLevel' AS [PropertyName],
		SERVERPROPERTY('FilestreamConfiguredLevel') AS [PropertyValue]
UNION	
SELECT	'FilestreamEffectiveLevel' AS [PropertyName],
		SERVERPROPERTY('FilestreamEffectiveLevel') AS [PropertyValue];
GO