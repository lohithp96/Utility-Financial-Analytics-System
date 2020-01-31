USE [SONGS]
GO

DROP TABLE dbo.SONGSGL_Materials;

CREATE TABLE dbo.SONGSGL_Materials
(
    Invoice_Key CHAR(6) NOT NULL,
	PlanCategoryID VARCHAR(3) NOT NULL,
	FieldIndex INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	Materials_PlantID CHAR(4) NULL,
	Materials_StorageLocationID CHAR(8) NULL,
	Materials_TypeID INT NULL,
	Materials_GroupID CHAR(10) NULL,
	MaterialID CHAR(8) NULL,
	PeriodEnd VARCHAR(7) NULL,
	Quantity INT NULL,
	Units VARCHAR(3) NULL,
	StockValue MONEY NULL,
	StockValue_Units VARCHAR(3) NULL,
);

GO