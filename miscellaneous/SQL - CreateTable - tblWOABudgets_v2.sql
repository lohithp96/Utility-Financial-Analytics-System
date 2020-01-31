USE [SONGS]
GO

/****** Object:  Table [dbo].[tblWOAForm_Budget]    Script Date: 3/7/2016 10:59:27 AM ******/
IF OBJECT_ID('[dbo].[tblWOAForm_Budget]','U') IS NOT NULL
	DROP TABLE [dbo].[tblWOAForm_Budget]
GO

/****** Object:  Table [dbo].[tblWOAForm_Budget]    Script Date: 3/4/2016 2:22:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblWOAForm_Budget](
	[WOAForm_ID]                                              [int]          NOT NULL            PRIMARY KEY CONSTRAINT [FK_tblWOAForm_Budget_tblWOAFrorm] 
							                                                                                            FOREIGN KEY([WOAForm_ID])
							                                                                                            REFERENCES [dbo].tblWOAForm ([WOAForm_ID])
																																   ON DELETE CASCADE
																																   ON UPDATE CASCADE,
	Install_Direct_Labour_Union                               [money]        NOT NULL DEFAULT 0,
	Install_Direct_Labour_NonUnion_Regular                    [money]        NOT NULL DEFAULT 0,
	Install_Direct_Labour_NonUnion_Executive                  [money]        NOT NULL DEFAULT 0,
	Install_Direct_Labour                                     AS                              (Install_Direct_Labour_Union + 
	                                                                                           Install_Direct_Labour_NonUnion_Regular + 
																							   Install_Direct_Labour_NonUnion_Executive)
																							  PERSISTED,
	Install_Direct_Contract_PurchasedServices                 [money]        NOT NULL DEFAULT 0,
	Install_Direct_Contract_ConstructionServices              [money]        NOT NULL DEFAULT 0,
	Install_Direct_Contract                                   AS                              (Install_Direct_Contract_PurchasedServices + 
	                                                                                           Install_Direct_Contract_ConstructionServices)
																							  PERSISTED,
	Install_Direct_Materials_WarehouseIssuances               [money]        NOT NULL DEFAULT 0,
	Install_Direct_Materials_PurchasedMaterials               [money]        NOT NULL DEFAULT 0,
	Install_Direct_Materials                                  AS                              (Install_Direct_Materials_WarehouseIssuances + 
	                                                                                           Install_Direct_Materials_PurchasedMaterials)
																							  PERSISTED,
	Install_Direct_Other_PSEPServices                         [money]        NOT NULL DEFAULT 0,
	Install_Direct_Other_CustomerValue                        [money]        NOT NULL DEFAULT 0,
	Install_Direct_Other_Miscellaneous                        [money]        NOT NULL DEFAULT 0,
	Install_Direct_Other                                      AS                              (Install_Direct_Other_PSEPServices + 
	                                                                                           Install_Direct_Other_CustomerValue +
																							   Install_Direct_Other_Miscellaneous)
																							  PERSISTED,
	Install_Direct                                            AS                              (Install_Direct_Labour_Union + 
	                                                                                           Install_Direct_Labour_NonUnion_Regular + 
																							   Install_Direct_Labour_NonUnion_Executive +
																							   Install_Direct_Contract_PurchasedServices + 
	                                                                                           Install_Direct_Contract_ConstructionServices +
																							   Install_Direct_Materials_WarehouseIssuances + 
	                                                                                           Install_Direct_Materials_PurchasedMaterials + 
																							   Install_Direct_Other_PSEPServices + 
	                                                                                           Install_Direct_Other_CustomerValue +
																							   Install_Direct_Other_Miscellaneous)
																							  PERSISTED,
	Install_Indirect_Core_ICP                                 [money]        NOT NULL DEFAULT 0,
	Install_Indirect_Core_PayrollTax                          [money]        NOT NULL DEFAULT 0,
	Install_Indirect_Core_PensionBenefits                     [money]        NOT NULL DEFAULT 0,
	Install_Indirect_Core_PLPDOverhead                        [money]        NOT NULL DEFAULT 0,
	Install_Indirect_Core_UnionContract                       [money]        NOT NULL DEFAULT 0,
	Install_Indirect_Core_VacationSick                        [money]        NOT NULL DEFAULT 0,
	Install_Indirect_Core_WorkersComp                         [money]        NOT NULL DEFAULT 0,
	Install_Indirect_Core                                     AS                              (Install_Indirect_Core_ICP + 
	                                                                                           Install_Indirect_Core_PayrollTax +
																							   Install_Indirect_Core_PensionBenefits +
																							   Install_Indirect_Core_PLPDOverhead +
																							   Install_Indirect_Core_UnionContract +
																							   Install_Indirect_Core_VacationSick +
																							   Install_Indirect_Core_WorkersComp)
																							  PERSISTED,
	Install_Indirect_Purchasing_ContractAdministration        [money]        NOT NULL DEFAULT 0,
	Install_Indirect_Purchasing_ExemptMaterials               [money]        NOT NULL DEFAULT 0,
	Install_Indirect_Purchasing_Purchasing                    [money]        NOT NULL DEFAULT 0,
	Install_Indirect_Purchasing_ShopOverheads                 [money]        NOT NULL DEFAULT 0,
	Install_Indirect_Purchasing_SmallTools                    [money]        NOT NULL DEFAULT 0,
	Install_Indirect_Purchasing_Warehousing                   [money]        NOT NULL DEFAULT 0,
	Install_Indirect_Purchasing                               AS                              (Install_Indirect_Purchasing_ContractAdministration + 
	                                                                                           Install_Indirect_Purchasing_ExemptMaterials +
																							   Install_Indirect_Purchasing_Purchasing +
																							   Install_Indirect_Purchasing_ShopOverheads +
																							   Install_Indirect_Purchasing_SmallTools +
																							   Install_Indirect_Purchasing_Warehousing)
																							  PERSISTED,
	Install_Indirect_AG_AG                                    [money]        NOT NULL DEFAULT 0,
	Install_Indirect_AG_DOH                                   [money]        NOT NULL DEFAULT 0,
	Install_Indirect_AG_Engineering                           [money]        NOT NULL DEFAULT 0,
	Install_Indirect_AG_PSEPInsurance                         [money]        NOT NULL DEFAULT 0,
	Install_Indirect_AG_WildfireInsurance                     [money]        NOT NULL DEFAULT 0,
	Install_Indirect_AG                                       AS                              (Install_Indirect_AG_AG + 
	                                                                                           Install_Indirect_AG_DOH +
																							   Install_Indirect_AG_Engineering +
																							   Install_Indirect_AG_PSEPInsurance +
																							   Install_Indirect_AG_WildfireInsurance)
																							  PERSISTED,
	Install_Indirect_Billing_FixedCostLoader                  [money]        NOT NULL DEFAULT 0,
	Install_Indirect_Billing_Supplemental_Energy_Executive    [money]        NOT NULL DEFAULT 0,
	Install_Indirect_Billing_Supplemental_Energy_NonExecutive [money]        NOT NULL DEFAULT 0,
	Install_Indirect_Billing_Supplemental_NonEnergy           [money]        NOT NULL DEFAULT 0,
	Install_Indirect_Billing                                  AS                              (Install_Indirect_Billing_FixedCostLoader + 
	                                                                                           Install_Indirect_Billing_Supplemental_Energy_Executive +
																							   Install_Indirect_Billing_Supplemental_Energy_NonExecutive +
																							   Install_Indirect_Billing_Supplemental_NonEnergy)
																							  PERSISTED,
	Install_Indirect_AFUDCITCCA_AFUDC                         [money]        NOT NULL DEFAULT 0,
	Install_Indirect_AFUDCITCCA_ITCCA                         [money]        NOT NULL DEFAULT 0,
	Install_Indirect_AFUDCITCCA                               AS                              (Install_Indirect_AFUDCITCCA_AFUDC + 
	                                                                                           Install_Indirect_AFUDCITCCA_ITCCA)
																							  PERSISTED,
	Install_Indirect                                          AS                              (Install_Indirect_Core_ICP + 
	                                                                                           Install_Indirect_Core_PayrollTax +
																							   Install_Indirect_Core_PensionBenefits +
																							   Install_Indirect_Core_PLPDOverhead +
																							   Install_Indirect_Core_UnionContract +
																							   Install_Indirect_Core_VacationSick +
																							   Install_Indirect_Core_WorkersComp +
																							   Install_Indirect_Purchasing_ContractAdministration + 
	                                                                                           Install_Indirect_Purchasing_ExemptMaterials +
																							   Install_Indirect_Purchasing_Purchasing +
																							   Install_Indirect_Purchasing_ShopOverheads +
																							   Install_Indirect_Purchasing_SmallTools +
																							   Install_Indirect_Purchasing_Warehousing +
																							   Install_Indirect_AG_AG + 
	                                                                                           Install_Indirect_AG_DOH +
																							   Install_Indirect_AG_Engineering +
																							   Install_Indirect_AG_PSEPInsurance +
																							   Install_Indirect_AG_WildfireInsurance +
																							   Install_Indirect_Billing_FixedCostLoader + 
	                                                                                           Install_Indirect_Billing_Supplemental_Energy_Executive +
																							   Install_Indirect_Billing_Supplemental_Energy_NonExecutive +
																							   Install_Indirect_Billing_Supplemental_NonEnergy +
																							   Install_Indirect_AFUDCITCCA_AFUDC + 
	                                                                                           Install_Indirect_AFUDCITCCA_ITCCA)
																							  PERSISTED,
	Install                                                   AS                              (Install_Direct_Labour_Union + 
	                                                                                           Install_Direct_Labour_NonUnion_Regular + 
																							   Install_Direct_Labour_NonUnion_Executive +
																							   Install_Direct_Contract_PurchasedServices + 
	                                                                                           Install_Direct_Contract_ConstructionServices +
																							   Install_Direct_Materials_WarehouseIssuances + 
	                                                                                           Install_Direct_Materials_PurchasedMaterials + 
																							   Install_Direct_Other_PSEPServices + 
	                                                                                           Install_Direct_Other_CustomerValue +
																							   Install_Direct_Other_Miscellaneous +
																							   Install_Indirect_Core_ICP + 
	                                                                                           Install_Indirect_Core_PayrollTax +
																							   Install_Indirect_Core_PensionBenefits +
																							   Install_Indirect_Core_PLPDOverhead +
																							   Install_Indirect_Core_UnionContract +
																							   Install_Indirect_Core_VacationSick +
																							   Install_Indirect_Core_WorkersComp +
																							   Install_Indirect_Purchasing_ContractAdministration + 
	                                                                                           Install_Indirect_Purchasing_ExemptMaterials +
																							   Install_Indirect_Purchasing_Purchasing +
																							   Install_Indirect_Purchasing_ShopOverheads +
																							   Install_Indirect_Purchasing_SmallTools +
																							   Install_Indirect_Purchasing_Warehousing +
																							   Install_Indirect_AG_AG + 
	                                                                                           Install_Indirect_AG_DOH +
																							   Install_Indirect_AG_Engineering +
																							   Install_Indirect_AG_PSEPInsurance +
																							   Install_Indirect_AG_WildfireInsurance +
																							   Install_Indirect_Billing_FixedCostLoader + 
	                                                                                           Install_Indirect_Billing_Supplemental_Energy_Executive +
																							   Install_Indirect_Billing_Supplemental_Energy_NonExecutive +
																							   Install_Indirect_Billing_Supplemental_NonEnergy +
																							   Install_Indirect_AFUDCITCCA_AFUDC + 
	                                                                                           Install_Indirect_AFUDCITCCA_ITCCA)
																							  PERSISTED,
	[Loaders_Labour_PayrollTax]                               [float]        NOT NULL DEFAULT 0,
	[Loaders_Labour_ICP]                                      [float]        NOT NULL DEFAULT 0,
	[Loaders_Labour_PB]                                       [float]        NOT NULL DEFAULT 0,
	[Loaders_Labour_WC]                                       [float]        NOT NULL DEFAULT 0,
	[Loaders_Labour_VS]                                       [float]        NOT NULL DEFAULT 0,
	[Loaders_Labour_PLPD]                                     [float]        NOT NULL DEFAULT 0,
	[Loaders_Labour_UnionContract]                            [float]        NOT NULL DEFAULT 0,
	[Loaders_Labour_BillingSupplemental_Energy]               [float]        NOT NULL DEFAULT 0,
	[Loaders_Labour_BillingSupplemental_NonEnergy]            [float]        NOT NULL DEFAULT 0,
	[Loaders_Labour_ShopOverheads]                            [float]        NOT NULL DEFAULT 0,
	[Loaders_Labour_SmallTools]                               [float]        NOT NULL DEFAULT 0,
	[Loaders_Materials_Purchasing]                            [float]        NOT NULL DEFAULT 0,
	[Loaders_Materials_Warehouse]                             [float]        NOT NULL DEFAULT 0,
	[Loaders_Materials_ExemptMaterials]                       [float]        NOT NULL DEFAULT 0,
	[Loaders_Other_ContractAdministration]                    [float]        NOT NULL DEFAULT 0,
	[Loaders_Other_PSEPInsurance]                             [float]        NOT NULL DEFAULT 0,
	[Loaders_Other_Engineering]                               [float]        NOT NULL DEFAULT 0,
	[Loaders_Other_DOH]                                       [float]        NOT NULL DEFAULT 0,
	[Loaders_Other_AG]                                        [float]        NOT NULL DEFAULT 0,
	[Loaders_Other_WildfireInsurance]                         [float]        NOT NULL DEFAULT 0,
	[Loaders_Other_BillingFixedCost]                          [float]        NOT NULL DEFAULT 0,
	[Loaders_AFUDCITCCA_AFUDC]                                [float]        NOT NULL DEFAULT 0,
	[Loaders_AFUDCITCCA_ITCCA]                                [float]        NOT NULL DEFAULT 0,
	[ExpectedProjectPeriods]                                  [int]          NOT NULL DEFAULT 0,
	[Created_Date]                                            [datetime]     NOT NULL DEFAULT (CONVERT([datetime],getdate())),
	[Created_User]                                            [nvarchar](12)     NULL DEFAULT 0,
	[LastUpdated_Date]                                        [datetime]         NULL DEFAULT 0,
	[LastUpdated_User]                                        [nvarchar](12)     NULL DEFAULT 0)
GO