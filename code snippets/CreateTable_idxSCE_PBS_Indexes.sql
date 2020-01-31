USE [SONGS]
GO

DROP TABLE dbo.idxSCE_PBS_Generators;
DROP TABLE dbo.idxSCE_PBS_CostGroups;

CREATE TABLE dbo.idxSCE_PBS_Generators
	(
	SCEGeneratorID TINYINT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	SCEGenerator_Short VARCHAR(5) NOT NULL,
	SCEGenerator VARCHAR(50) NULL,
);

CREATE TABLE dbo.idxSCE_PBS_CostGroups
	(
	SCEGeneratorID TINYINT NOT NULL,
	SCECostGroupID TINYINT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	SCECostGroup_Short VARCHAR(15) NOT NULL,
	SCECostGroup VARCHAR(25) NULL,
);

GO


GO