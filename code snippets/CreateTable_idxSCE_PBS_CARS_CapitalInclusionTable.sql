DROP TABLE dbo.idxSCE_PBS_CARS_CapitalInclusionTable;

CREATE TABLE dbo.idxSCE_PBS_CARS_CapitalInclusionTable
(
    SCEGeneratorID VARCHAR(5) NOT NULL,
    SCEBillingGroup VARCHAR(13) NOT NULL,
	SCELocation CHAR(4) NOT NULL,
	SCEFunction CHAR(4) NOT NULL,
    SCELocationFunction AS (SCELocation + '-' + SCEFunction) PERSISTED PRIMARY KEY,
);

ALTER TABLE [dbo].[idxSCE_PBS_CARS_CapitalInclusionTable] ADD  CONSTRAINT [DF_idxSCE_PBS_CARS_CapitalInclusionTable_SCEFunction]  DEFAULT (('0000')) FOR [SCEFunction]
GO