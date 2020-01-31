USE [SONGS]
GO

DROP TABLE dbo.idxSCE_PBS_Audit_ManualExclusions

CREATE TABLE dbo.idxSCE_PBS_Audit_ManualExclusions
	(
	PBS_Audit_ManualExclusionID INTEGER IDENTITY(1,1) PRIMARY KEY NOT NULL,
	SCELocation CHAR(4) NOT NULL,
	SCEFunction CHAR(4) NOT NULL,
	CARSSourceCode CHAR(3) NOT NULL,
	CARSReferenceNumber VARCHAR(6) NOT NULL,
)

GO