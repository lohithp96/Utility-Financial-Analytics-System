USE [SONGS]
GO

DROP TABLE dbo.idxSCE_SAP_CostCenters_LocationFunctions;

CREATE TABLE dbo.idxSCE_SAP_CostCenters_LocationFunctions
(
    SCECostCenter CHAR(7) NOT NULL,
    SCELocation CHAR(4) NOT NULL,
	SCEFunction CHAR(4) NOT NULL,
	SCECostCenter_Location_Function AS (SCECostCenter + '.' + SCELocation + '-' + SCEFunction) PRIMARY KEY PERSISTED,
);

GO