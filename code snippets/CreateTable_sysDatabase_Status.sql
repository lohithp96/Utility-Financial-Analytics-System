/***** THIS CREATES THE DATABASE ACCESS TABLES *****/

USE [SONGS]
GO

DROP TABLE dbo.sysDatabase_Status_idxDatabases;
DROP TABLE dbo.sysDatabase_Status_idxStatusIDs;
DROP TABLE dbo.sysDatabase_Status;

CREATE TABLE dbo.sysDatabase_Status_idxDatabases
	(
	DatabaseID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	DatabaseName VARCHAR(50) NOT NULL,
);

CREATE TABLE dbo.sysDatabase_Status_idxStatusIDs
	(
	DatabaseStatusID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	DatabaseStatus VARCHAR(50) NOT NULL,
);

CREATE TABLE dbo.sysDatabase_Status
	(
	RecordNumber INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	DatabaseID INT UNIQUE NOT NULL
		REFERENCES dbo.sysDatabase_Status_idxDatabases(DatabaseID),
	DatabaseStatusID INT NOT NULL
		REFERENCES dbo.sysDatabase_Status_idxStatusIDs(DatabaseStatusID),
	LastUpdate DATETIME,
);

GO