USE [SONGS]
GO

--DROP TABLE dbo.idxSCE_SAP_Activities;

CREATE TABLE dbo.idxSCE_SAP_Activities
(
    ActivityKey INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	ActivityName VARCHAR(50) NULL,
	ActivityNotes VARCHAR(MAX) NULL,
);

GO