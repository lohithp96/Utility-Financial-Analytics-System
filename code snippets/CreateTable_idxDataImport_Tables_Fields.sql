USE [SONGS]
GO

DROP TABLE dbo.idxDataImport_Tables_Fields;

CREATE TABLE dbo.idxDataImport_Tables_Fields
(
    FieldIndex INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	TableID TINYINT NOT NULL,
    FieldName VARCHAR(50) NOT NULL,
    FieldName_ImportDefault VARCHAR(75) NULL,
	FieldTypeID TINYINT NOT NULL,
	FieldSize INT NOT NULL,
	FieldTitle VARCHAR(100) NULL,
);

GO