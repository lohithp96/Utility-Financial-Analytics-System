USE [SONGS]
GO

DROP TABLE dbo.idxSCE_PBS_CARS_OMExclusionTable

CREATE TABLE dbo.idxSCE_PBS_CARS_OMExclusionTable
	(
	SCEGeneratorID TINYINT NOT NULL,
	FERCAccount CHAR(3) NOT NULL,
	SCELocation CHAR(4) NOT NULL,
	SCEFunction CHAR(4) NOT NULL,
	SCE_PBS_CARS_OMExclusionIndex AS (SCELocation + '-' + SCEFunction) PERSISTED NOT NULL,
)

GO
