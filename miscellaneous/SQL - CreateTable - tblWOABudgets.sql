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
	[WOAForm_ID] [int] NOT NULL PRIMARY KEY,
	[Install_Labour] [money] NOT NULL DEFAULT 0,
	[Install_Services] [money] NOT NULL DEFAULT 0,
	[Install_Materials] [money] NOT NULL DEFAULT 0,
	[Install_OtherDirectCharges] [money] NOT NULL DEFAULT 0,
	[Install_DirectCosts] AS (Install_Labour +
							  Install_Services + 
							  Install_Materials + 
							  Install_OtherDirectCharges) 
							  PERSISTED,
	[Install_AffiliateTransferInCosts] [money] NOT NULL DEFAULT 0,
	[Install_LabourIndirects_PayrollTax] AS ROUND([Install_Labour] * [Loaders_Labour_PayrollTax],2),
	[Install_LabourIndirects_ICP] AS ROUND([Install_Labour] * [Loaders_Labour_ICP],2),
	[Install_LabourIndirects_PB] AS ROUND([Install_Labour] * [Loaders_Labour_PB],2),
	[Install_LabourIndirects_WC] AS ROUND([Install_Labour] * [Loaders_Labour_WC],2),
	[Install_LabourIndirects_VS] AS ROUND([Install_Labour] * [Loaders_Labour_VS],2),
	[Install_LabourIndirects_PLPD] AS ROUND([Install_Labour] * [Loaders_Labour_PLPD],2),
	[Install_LabourIndirects_UnionContract] AS ROUND([Install_Labour] * [Loaders_Labour_UnionContract],2),
	[Install_LabourIndirects_ShopOverheads] AS ROUND([Install_Labour] * [Loaders_Labour_ShopOverheads],2),
	[Install_LabourIndirects_SmallTools] AS ROUND([Install_Labour] * [Loaders_Labour_SmallTools],2),
	[Install_LabourIndirects_Engineering] AS ROUND([Install_Labour] * [Loaders_Other_Engineering],2),
	[Install_LabourIndirects_DOH] AS ROUND([Install_Labour] * [Loaders_Other_DOH],2),
	[Install_LabourIndirects_WildfireInsurance] AS ROUND([Install_Labour] * [Loaders_Other_WildfireInsurance],2),
	[Install_LabourIndirects_BillingSupplemental_Energy] AS ROUND([Install_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2),
	[Install_LabourIndirects_BillingSupplemental_NonEnergy] AS ROUND((ROUND([Install_Labour] * [Loaders_Labour_PayrollTax],2) +
																	  ROUND([Install_Labour] * [Loaders_Labour_ICP],2) +
																	  ROUND([Install_Labour] * [Loaders_Labour_PB],2) +
																	  ROUND([Install_Labour] * [Loaders_Labour_WC],2) +
																	  ROUND([Install_Labour] * [Loaders_Labour_VS],2) +
																	  ROUND([Install_Labour] * [Loaders_Labour_PLPD],2) +
																	  ROUND([Install_Labour] * [Loaders_Labour_UnionContract],2) +
																	  ROUND([Install_Labour] * [Loaders_Labour_ShopOverheads],2) +
																	  ROUND([Install_Labour] * [Loaders_Labour_SmallTools],2) +
																	  ROUND([Install_Labour] * [Loaders_Other_Engineering],2) +
																	  ROUND([Install_Labour] * [Loaders_Other_DOH],2) +
																	  ROUND([Install_Labour] * [Loaders_Other_WildfireInsurance],2) +
																	  ROUND([Install_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2)) * 
																	  [Loaders_Labour_BillingSupplemental_NonEnergy],2),
	[Install_LabourIndirects] AS (ROUND([Install_Labour] * [Loaders_Labour_PayrollTax],2) +
								  ROUND([Install_Labour] * [Loaders_Labour_ICP],2) +
								  ROUND([Install_Labour] * [Loaders_Labour_PB],2) +
								  ROUND([Install_Labour] * [Loaders_Labour_WC],2) +
								  ROUND([Install_Labour] * [Loaders_Labour_VS],2) +
								  ROUND([Install_Labour] * [Loaders_Labour_PLPD],2) +
								  ROUND([Install_Labour] * [Loaders_Labour_UnionContract],2) +
								  ROUND([Install_Labour] * [Loaders_Labour_ShopOverheads],2) +
								  ROUND([Install_Labour] * [Loaders_Labour_SmallTools],2) +
								  ROUND([Install_Labour] * [Loaders_Other_Engineering],2) +
								  ROUND([Install_Labour] * [Loaders_Other_DOH],2) +
								  ROUND([Install_Labour] * [Loaders_Other_WildfireInsurance],2) +
								  ROUND([Install_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2) +
								  ROUND((ROUND([Install_Labour] * [Loaders_Labour_PayrollTax],2) +
										 ROUND([Install_Labour] * [Loaders_Labour_ICP],2) +
										 ROUND([Install_Labour] * [Loaders_Labour_PB],2) +
										 ROUND([Install_Labour] * [Loaders_Labour_WC],2) +
										 ROUND([Install_Labour] * [Loaders_Labour_VS],2) +
										 ROUND([Install_Labour] * [Loaders_Labour_PLPD],2) +
										 ROUND([Install_Labour] * [Loaders_Labour_UnionContract],2) +
										 ROUND([Install_Labour] * [Loaders_Labour_ShopOverheads],2) +
										 ROUND([Install_Labour] * [Loaders_Labour_SmallTools],2) +
										 ROUND([Install_Labour] * [Loaders_Other_Engineering],2) +
										 ROUND([Install_Labour] * [Loaders_Other_DOH],2) +
										 ROUND([Install_Labour] * [Loaders_Other_WildfireInsurance],2) +
										 ROUND([Install_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2)) * 
										 [Loaders_Labour_BillingSupplemental_NonEnergy],2)) 
								  PERSISTED,
	[Install_ServiceIndirects_Purchasing] AS ROUND([Install_Services] * [Loaders_Materials_Purchasing],2),
	[Install_ServiceIndirects_ContractAdministration] AS ROUND([Install_Services] * [Loaders_Other_ContractAdministration],2),
	[Install_ServiceIndirects_Engineering] AS ROUND([Install_Services] * [Loaders_Other_Engineering],2),
	[Install_ServiceIndirects_DOH] AS ROUND([Install_Services] * [Loaders_Other_DOH],2),
	[Install_ServiceIndirects] AS (ROUND([Install_Services] * [Loaders_Materials_Purchasing],2) +
								   ROUND([Install_Services] * [Loaders_Other_ContractAdministration],2) + 
								   ROUND([Install_Services] * [Loaders_Other_Engineering],2) + 
								   ROUND([Install_Services] * [Loaders_Other_DOH],2)) 
								   PERSISTED,
	[Install_MaterialIndirects_Purchasing] AS ROUND([Install_Materials] * [Loaders_Materials_Purchasing],2),
	[Install_MaterialIndirects_Warehouse] AS ROUND([Install_Materials] * [Loaders_Materials_Warehouse],2),
	[Install_MaterialIndirects_ExemptMaterials] AS ROUND([Install_Materials] * [Loaders_Materials_ExemptMaterials],2),
	[Install_MaterialIndirects] AS (ROUND([Install_Materials] * [Loaders_Materials_Purchasing],2) +
									ROUND([Install_Materials] * [Loaders_Materials_Warehouse],2) + 
									ROUND([Install_Materials] * [Loaders_Materials_ExemptMaterials],2))
									PERSISTED,
	[Install_IndirectCosts] AS (ROUND([Install_Labour] * [Loaders_Labour_PayrollTax],2) +
								ROUND([Install_Labour] * [Loaders_Labour_ICP],2) +
								ROUND([Install_Labour] * [Loaders_Labour_PB],2) +
								ROUND([Install_Labour] * [Loaders_Labour_WC],2) +
								ROUND([Install_Labour] * [Loaders_Labour_VS],2) +
								ROUND([Install_Labour] * [Loaders_Labour_PLPD],2) +
								ROUND([Install_Labour] * [Loaders_Labour_UnionContract],2) +
								ROUND([Install_Labour] * [Loaders_Labour_ShopOverheads],2) +
								ROUND([Install_Labour] * [Loaders_Labour_SmallTools],2) +
								ROUND([Install_Labour] * [Loaders_Other_Engineering],2) +
								ROUND([Install_Labour] * [Loaders_Other_DOH],2) +
								ROUND([Install_Labour] * [Loaders_Other_WildfireInsurance],2) +
								ROUND([Install_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2) +
								ROUND((ROUND([Install_Labour] * [Loaders_Labour_PayrollTax],2) +
									   ROUND([Install_Labour] * [Loaders_Labour_ICP],2) +
									   ROUND([Install_Labour] * [Loaders_Labour_PB],2) +
									   ROUND([Install_Labour] * [Loaders_Labour_WC],2) +
									   ROUND([Install_Labour] * [Loaders_Labour_VS],2) +
									   ROUND([Install_Labour] * [Loaders_Labour_PLPD],2) +
									   ROUND([Install_Labour] * [Loaders_Labour_UnionContract],2) +
									   ROUND([Install_Labour] * [Loaders_Labour_ShopOverheads],2) +
									   ROUND([Install_Labour] * [Loaders_Labour_SmallTools],2) +
									   ROUND([Install_Labour] * [Loaders_Other_Engineering],2) +
									   ROUND([Install_Labour] * [Loaders_Other_DOH],2) +
									   ROUND([Install_Labour] * [Loaders_Other_WildfireInsurance],2) +
									   ROUND([Install_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2)) * 
									   [Loaders_Labour_BillingSupplemental_NonEnergy],2)) + 
							   (ROUND([Install_Services] * [Loaders_Materials_Purchasing],2) +
								ROUND([Install_Services] * [Loaders_Other_ContractAdministration],2) + 
								ROUND([Install_Services] * [Loaders_Other_Engineering],2) + 
								ROUND([Install_Services] * [Loaders_Other_DOH],2)) + 
							   (ROUND([Install_Materials] * [Loaders_Materials_Purchasing],2) +
								ROUND([Install_Materials] * [Loaders_Materials_Warehouse],2) + 
								ROUND([Install_Materials] * [Loaders_Materials_ExemptMaterials],2))
							   PERSISTED,
	[Install_AFUDC] AS ROUND(((Install_Labour +
							   Install_Services + 
							   Install_Materials + 
							   Install_OtherDirectCharges) + 
							  (ROUND([Install_Labour] * [Loaders_Labour_PayrollTax],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_ICP],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_PB],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_WC],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_VS],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_PLPD],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_UnionContract],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_ShopOverheads],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_SmallTools],2) +
							   ROUND([Install_Labour] * [Loaders_Other_Engineering],2) +
							   ROUND([Install_Labour] * [Loaders_Other_DOH],2) +
							   ROUND([Install_Labour] * [Loaders_Other_WildfireInsurance],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2) +
							   ROUND((ROUND([Install_Labour] * [Loaders_Labour_PayrollTax],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_ICP],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_PB],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_WC],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_VS],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_PLPD],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_UnionContract],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_ShopOverheads],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_SmallTools],2) +
									  ROUND([Install_Labour] * [Loaders_Other_Engineering],2) +
									  ROUND([Install_Labour] * [Loaders_Other_DOH],2) +
									  ROUND([Install_Labour] * [Loaders_Other_WildfireInsurance],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2)) * 
									  [Loaders_Labour_BillingSupplemental_NonEnergy],2)) + 
							  (ROUND([Install_Services] * [Loaders_Materials_Purchasing],2) +
							   ROUND([Install_Services] * [Loaders_Other_ContractAdministration],2) + 
							   ROUND([Install_Services] * [Loaders_Other_Engineering],2) + 
							   ROUND([Install_Services] * [Loaders_Other_DOH],2)) + 
							  (ROUND([Install_Materials] * [Loaders_Materials_Purchasing],2) +
							   ROUND([Install_Materials] * [Loaders_Materials_Warehouse],2) + 
							   ROUND([Install_Materials] * [Loaders_Materials_ExemptMaterials],2))) * 
							 ([Loaders_AFUDCITCCA_AFUDC] * [ExpectedProjectPeriods]),2)
							  PERSISTED,
	[Install_ITCCA] AS ROUND(((Install_Labour +
							   Install_Services + 
							   Install_Materials + 
							   Install_OtherDirectCharges) +
							  (ROUND([Install_Labour] * [Loaders_Labour_PayrollTax],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_ICP],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_PB],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_WC],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_VS],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_PLPD],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_UnionContract],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_ShopOverheads],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_SmallTools],2) +
							   ROUND([Install_Labour] * [Loaders_Other_Engineering],2) +
							   ROUND([Install_Labour] * [Loaders_Other_DOH],2) +
							   ROUND([Install_Labour] * [Loaders_Other_WildfireInsurance],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2) +
							   ROUND((ROUND([Install_Labour] * [Loaders_Labour_PayrollTax],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_ICP],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_PB],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_WC],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_VS],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_PLPD],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_UnionContract],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_ShopOverheads],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_SmallTools],2) +
									  ROUND([Install_Labour] * [Loaders_Other_Engineering],2) +
									  ROUND([Install_Labour] * [Loaders_Other_DOH],2) +
									  ROUND([Install_Labour] * [Loaders_Other_WildfireInsurance],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2)) * 
									  [Loaders_Labour_BillingSupplemental_NonEnergy],2)) + 
							  (ROUND([Install_Services] * [Loaders_Materials_Purchasing],2) +
							   ROUND([Install_Services] * [Loaders_Other_ContractAdministration],2) + 
							   ROUND([Install_Services] * [Loaders_Other_Engineering],2) + 
							   ROUND([Install_Services] * [Loaders_Other_DOH],2)) + 
							  (ROUND([Install_Materials] * [Loaders_Materials_Purchasing],2) +
							   ROUND([Install_Materials] * [Loaders_Materials_Warehouse],2) + 
							   ROUND([Install_Materials] * [Loaders_Materials_ExemptMaterials],2))) *  
							  [Loaders_AFUDCITCCA_ITCCA],2)
							  PERSISTED,
	[Install_TotalCosts] AS (Install_Labour +
							  Install_Services + 
							  Install_Materials + 
							  Install_OtherDirectCharges) + 
							(ROUND([Install_Labour] * [Loaders_Labour_PayrollTax],2) +
								ROUND([Install_Labour] * [Loaders_Labour_ICP],2) +
								ROUND([Install_Labour] * [Loaders_Labour_PB],2) +
								ROUND([Install_Labour] * [Loaders_Labour_WC],2) +
								ROUND([Install_Labour] * [Loaders_Labour_VS],2) +
								ROUND([Install_Labour] * [Loaders_Labour_PLPD],2) +
								ROUND([Install_Labour] * [Loaders_Labour_UnionContract],2) +
								ROUND([Install_Labour] * [Loaders_Labour_ShopOverheads],2) +
								ROUND([Install_Labour] * [Loaders_Labour_SmallTools],2) +
								ROUND([Install_Labour] * [Loaders_Other_Engineering],2) +
								ROUND([Install_Labour] * [Loaders_Other_DOH],2) +
								ROUND([Install_Labour] * [Loaders_Other_WildfireInsurance],2) +
								ROUND([Install_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2) +
								ROUND((ROUND([Install_Labour] * [Loaders_Labour_PayrollTax],2) +
									   ROUND([Install_Labour] * [Loaders_Labour_ICP],2) +
									   ROUND([Install_Labour] * [Loaders_Labour_PB],2) +
									   ROUND([Install_Labour] * [Loaders_Labour_WC],2) +
									   ROUND([Install_Labour] * [Loaders_Labour_VS],2) +
									   ROUND([Install_Labour] * [Loaders_Labour_PLPD],2) +
									   ROUND([Install_Labour] * [Loaders_Labour_UnionContract],2) +
									   ROUND([Install_Labour] * [Loaders_Labour_ShopOverheads],2) +
									   ROUND([Install_Labour] * [Loaders_Labour_SmallTools],2) +
									   ROUND([Install_Labour] * [Loaders_Other_Engineering],2) +
									   ROUND([Install_Labour] * [Loaders_Other_DOH],2) +
									   ROUND([Install_Labour] * [Loaders_Other_WildfireInsurance],2) +
									   ROUND([Install_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2)) * 
									   [Loaders_Labour_BillingSupplemental_NonEnergy],2)) + 
							   (ROUND([Install_Services] * [Loaders_Materials_Purchasing],2) +
								ROUND([Install_Services] * [Loaders_Other_ContractAdministration],2) + 
								ROUND([Install_Services] * [Loaders_Other_Engineering],2) + 
								ROUND([Install_Services] * [Loaders_Other_DOH],2)) + 
							   (ROUND([Install_Materials] * [Loaders_Materials_Purchasing],2) +
								ROUND([Install_Materials] * [Loaders_Materials_Warehouse],2) + 
								ROUND([Install_Materials] * [Loaders_Materials_ExemptMaterials],2)) +
							ROUND(((Install_Labour +
							   Install_Services + 
							   Install_Materials + 
							   Install_OtherDirectCharges) + 
							  (ROUND([Install_Labour] * [Loaders_Labour_PayrollTax],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_ICP],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_PB],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_WC],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_VS],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_PLPD],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_UnionContract],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_ShopOverheads],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_SmallTools],2) +
							   ROUND([Install_Labour] * [Loaders_Other_Engineering],2) +
							   ROUND([Install_Labour] * [Loaders_Other_DOH],2) +
							   ROUND([Install_Labour] * [Loaders_Other_WildfireInsurance],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2) +
							   ROUND((ROUND([Install_Labour] * [Loaders_Labour_PayrollTax],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_ICP],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_PB],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_WC],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_VS],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_PLPD],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_UnionContract],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_ShopOverheads],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_SmallTools],2) +
									  ROUND([Install_Labour] * [Loaders_Other_Engineering],2) +
									  ROUND([Install_Labour] * [Loaders_Other_DOH],2) +
									  ROUND([Install_Labour] * [Loaders_Other_WildfireInsurance],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2)) * 
									  [Loaders_Labour_BillingSupplemental_NonEnergy],2)) + 
							  (ROUND([Install_Services] * [Loaders_Materials_Purchasing],2) +
							   ROUND([Install_Services] * [Loaders_Other_ContractAdministration],2) + 
							   ROUND([Install_Services] * [Loaders_Other_Engineering],2) + 
							   ROUND([Install_Services] * [Loaders_Other_DOH],2)) + 
							  (ROUND([Install_Materials] * [Loaders_Materials_Purchasing],2) +
							   ROUND([Install_Materials] * [Loaders_Materials_Warehouse],2) + 
							   ROUND([Install_Materials] * [Loaders_Materials_ExemptMaterials],2))) * 
							 ([Loaders_AFUDCITCCA_AFUDC] * [ExpectedProjectPeriods]),2) + 
							ROUND(((Install_Labour +
							   Install_Services + 
							   Install_Materials + 
							   Install_OtherDirectCharges) +
							  (ROUND([Install_Labour] * [Loaders_Labour_PayrollTax],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_ICP],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_PB],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_WC],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_VS],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_PLPD],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_UnionContract],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_ShopOverheads],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_SmallTools],2) +
							   ROUND([Install_Labour] * [Loaders_Other_Engineering],2) +
							   ROUND([Install_Labour] * [Loaders_Other_DOH],2) +
							   ROUND([Install_Labour] * [Loaders_Other_WildfireInsurance],2) +
							   ROUND([Install_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2) +
							   ROUND((ROUND([Install_Labour] * [Loaders_Labour_PayrollTax],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_ICP],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_PB],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_WC],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_VS],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_PLPD],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_UnionContract],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_ShopOverheads],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_SmallTools],2) +
									  ROUND([Install_Labour] * [Loaders_Other_Engineering],2) +
									  ROUND([Install_Labour] * [Loaders_Other_DOH],2) +
									  ROUND([Install_Labour] * [Loaders_Other_WildfireInsurance],2) +
									  ROUND([Install_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2)) * 
									  [Loaders_Labour_BillingSupplemental_NonEnergy],2)) + 
							  (ROUND([Install_Services] * [Loaders_Materials_Purchasing],2) +
							   ROUND([Install_Services] * [Loaders_Other_ContractAdministration],2) + 
							   ROUND([Install_Services] * [Loaders_Other_Engineering],2) + 
							   ROUND([Install_Services] * [Loaders_Other_DOH],2)) + 
							  (ROUND([Install_Materials] * [Loaders_Materials_Purchasing],2) +
							   ROUND([Install_Materials] * [Loaders_Materials_Warehouse],2) + 
							   ROUND([Install_Materials] * [Loaders_Materials_ExemptMaterials],2))) *  
							  [Loaders_AFUDCITCCA_ITCCA],2) 
							PERSISTED,
	[Removal_Labour] [money] NOT NULL DEFAULT 0,
	[Removal_Services] [money] NOT NULL DEFAULT 0,
	[Removal_Materials] [money] NOT NULL DEFAULT 0,
	[Removal_OtherDirectCharges] [money] NOT NULL DEFAULT 0,
	[Removal_DirectCosts] AS (Removal_Labour +
							  Removal_Services + 
							  Removal_Materials + 
							  Removal_OtherDirectCharges) 
							  PERSISTED,
	[Removal_AffiliateTransferInCosts] [money] NOT NULL DEFAULT 0,
	[Removal_LabourIndirects_PayrollTax] AS ROUND([Removal_Labour] * [Loaders_Labour_PayrollTax],2),
	[Removal_LabourIndirects_ICP] AS ROUND([Removal_Labour] * [Loaders_Labour_ICP],2),
	[Removal_LabourIndirects_PB] AS ROUND([Removal_Labour] * [Loaders_Labour_PB],2),
	[Removal_LabourIndirects_WC] AS ROUND([Removal_Labour] * [Loaders_Labour_WC],2),
	[Removal_LabourIndirects_VS] AS ROUND([Removal_Labour] * [Loaders_Labour_VS],2),
	[Removal_LabourIndirects_PLPD] AS ROUND([Removal_Labour] * [Loaders_Labour_PLPD],2),
	[Removal_LabourIndirects_UnionContract] AS ROUND([Removal_Labour] * [Loaders_Labour_UnionContract],2),
	[Removal_LabourIndirects_ShopOverheads] AS ROUND([Removal_Labour] * [Loaders_Labour_ShopOverheads],2),
	[Removal_LabourIndirects_SmallTools] AS ROUND([Removal_Labour] * [Loaders_Labour_SmallTools],2),
	[Removal_LabourIndirects_Engineering] AS ROUND([Removal_Labour] * [Loaders_Other_Engineering],2),
	[Removal_LabourIndirects_DOH] AS ROUND([Removal_Labour] * [Loaders_Other_DOH],2),
	[Removal_LabourIndirects_WildfireInsurance] AS ROUND([Removal_Labour] * [Loaders_Other_WildfireInsurance],2),
	[Removal_LabourIndirects_BillingSupplemental_Energy] AS ROUND([Removal_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2),
	[Removal_LabourIndirects_BillingSupplemental_NonEnergy] AS ROUND((ROUND([Removal_Labour] * [Loaders_Labour_PayrollTax],2) +
																	  ROUND([Removal_Labour] * [Loaders_Labour_ICP],2) +
																	  ROUND([Removal_Labour] * [Loaders_Labour_PB],2) +
																	  ROUND([Removal_Labour] * [Loaders_Labour_WC],2) +
																	  ROUND([Removal_Labour] * [Loaders_Labour_VS],2) +
																	  ROUND([Removal_Labour] * [Loaders_Labour_PLPD],2) +
																	  ROUND([Removal_Labour] * [Loaders_Labour_UnionContract],2) +
																	  ROUND([Removal_Labour] * [Loaders_Labour_ShopOverheads],2) +
																	  ROUND([Removal_Labour] * [Loaders_Labour_SmallTools],2) +
																	  ROUND([Removal_Labour] * [Loaders_Other_Engineering],2) +
																	  ROUND([Removal_Labour] * [Loaders_Other_DOH],2) +
																	  ROUND([Removal_Labour] * [Loaders_Other_WildfireInsurance],2) +
																	  ROUND([Removal_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2)) * 
																	  [Loaders_Labour_BillingSupplemental_NonEnergy],2),
	[Removal_LabourIndirects] AS (ROUND([Removal_Labour] * [Loaders_Labour_PayrollTax],2) +
								  ROUND([Removal_Labour] * [Loaders_Labour_ICP],2) +
								  ROUND([Removal_Labour] * [Loaders_Labour_PB],2) +
								  ROUND([Removal_Labour] * [Loaders_Labour_WC],2) +
								  ROUND([Removal_Labour] * [Loaders_Labour_VS],2) +
								  ROUND([Removal_Labour] * [Loaders_Labour_PLPD],2) +
								  ROUND([Removal_Labour] * [Loaders_Labour_UnionContract],2) +
								  ROUND([Removal_Labour] * [Loaders_Labour_ShopOverheads],2) +
								  ROUND([Removal_Labour] * [Loaders_Labour_SmallTools],2) +
								  ROUND([Removal_Labour] * [Loaders_Other_Engineering],2) +
								  ROUND([Removal_Labour] * [Loaders_Other_DOH],2) +
								  ROUND([Removal_Labour] * [Loaders_Other_WildfireInsurance],2) +
								  ROUND([Removal_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2) +
								  ROUND((ROUND([Removal_Labour] * [Loaders_Labour_PayrollTax],2) +
										 ROUND([Removal_Labour] * [Loaders_Labour_ICP],2) +
										 ROUND([Removal_Labour] * [Loaders_Labour_PB],2) +
										 ROUND([Removal_Labour] * [Loaders_Labour_WC],2) +
										 ROUND([Removal_Labour] * [Loaders_Labour_VS],2) +
										 ROUND([Removal_Labour] * [Loaders_Labour_PLPD],2) +
										 ROUND([Removal_Labour] * [Loaders_Labour_UnionContract],2) +
										 ROUND([Removal_Labour] * [Loaders_Labour_ShopOverheads],2) +
										 ROUND([Removal_Labour] * [Loaders_Labour_SmallTools],2) +
										 ROUND([Removal_Labour] * [Loaders_Other_Engineering],2) +
										 ROUND([Removal_Labour] * [Loaders_Other_DOH],2) +
										 ROUND([Removal_Labour] * [Loaders_Other_WildfireInsurance],2) +
										 ROUND([Removal_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2)) * 
										 [Loaders_Labour_BillingSupplemental_NonEnergy],2)) 
								  PERSISTED,
	[Removal_ServiceIndirects_Purchasing] AS ROUND([Removal_Services] * [Loaders_Materials_Purchasing],2),
	[Removal_ServiceIndirects_ContractAdministration] AS ROUND([Removal_Services] * [Loaders_Other_ContractAdministration],2),
	[Removal_ServiceIndirects_Engineering] AS ROUND([Removal_Services] * [Loaders_Other_Engineering],2),
	[Removal_ServiceIndirects_DOH] AS ROUND([Removal_Services] * [Loaders_Other_DOH],2),
	[Removal_ServiceIndirects] AS (ROUND([Removal_Services] * [Loaders_Materials_Purchasing],2) +
								   ROUND([Removal_Services] * [Loaders_Other_ContractAdministration],2) + 
								   ROUND([Removal_Services] * [Loaders_Other_Engineering],2) + 
								   ROUND([Removal_Services] * [Loaders_Other_DOH],2)) 
								   PERSISTED,
	[Removal_MaterialIndirects_Purchasing] AS ROUND([Removal_Materials] * [Loaders_Materials_Purchasing],2),
	[Removal_MaterialIndirects_Warehouse] AS ROUND([Removal_Materials] * [Loaders_Materials_Warehouse],2),
	[Removal_MaterialIndirects_ExemptMaterials] AS ROUND([Removal_Materials] * [Loaders_Materials_ExemptMaterials],2),
	[Removal_MaterialIndirects] AS (ROUND([Removal_Materials] * [Loaders_Materials_Purchasing],2) +
									ROUND([Removal_Materials] * [Loaders_Materials_Warehouse],2) + 
									ROUND([Removal_Materials] * [Loaders_Materials_ExemptMaterials],2))
									PERSISTED,
	[Removal_IndirectCosts] AS (ROUND([Removal_Labour] * [Loaders_Labour_PayrollTax],2) +
								ROUND([Removal_Labour] * [Loaders_Labour_ICP],2) +
								ROUND([Removal_Labour] * [Loaders_Labour_PB],2) +
								ROUND([Removal_Labour] * [Loaders_Labour_WC],2) +
								ROUND([Removal_Labour] * [Loaders_Labour_VS],2) +
								ROUND([Removal_Labour] * [Loaders_Labour_PLPD],2) +
								ROUND([Removal_Labour] * [Loaders_Labour_UnionContract],2) +
								ROUND([Removal_Labour] * [Loaders_Labour_ShopOverheads],2) +
								ROUND([Removal_Labour] * [Loaders_Labour_SmallTools],2) +
								ROUND([Removal_Labour] * [Loaders_Other_Engineering],2) +
								ROUND([Removal_Labour] * [Loaders_Other_DOH],2) +
								ROUND([Removal_Labour] * [Loaders_Other_WildfireInsurance],2) +
								ROUND([Removal_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2) +
								ROUND((ROUND([Removal_Labour] * [Loaders_Labour_PayrollTax],2) +
									   ROUND([Removal_Labour] * [Loaders_Labour_ICP],2) +
									   ROUND([Removal_Labour] * [Loaders_Labour_PB],2) +
									   ROUND([Removal_Labour] * [Loaders_Labour_WC],2) +
									   ROUND([Removal_Labour] * [Loaders_Labour_VS],2) +
									   ROUND([Removal_Labour] * [Loaders_Labour_PLPD],2) +
									   ROUND([Removal_Labour] * [Loaders_Labour_UnionContract],2) +
									   ROUND([Removal_Labour] * [Loaders_Labour_ShopOverheads],2) +
									   ROUND([Removal_Labour] * [Loaders_Labour_SmallTools],2) +
									   ROUND([Removal_Labour] * [Loaders_Other_Engineering],2) +
									   ROUND([Removal_Labour] * [Loaders_Other_DOH],2) +
									   ROUND([Removal_Labour] * [Loaders_Other_WildfireInsurance],2) +
									   ROUND([Removal_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2)) * 
									   [Loaders_Labour_BillingSupplemental_NonEnergy],2)) + 
							   (ROUND([Removal_Services] * [Loaders_Materials_Purchasing],2) +
								ROUND([Removal_Services] * [Loaders_Other_ContractAdministration],2) + 
								ROUND([Removal_Services] * [Loaders_Other_Engineering],2) + 
								ROUND([Removal_Services] * [Loaders_Other_DOH],2)) + 
							   (ROUND([Removal_Materials] * [Loaders_Materials_Purchasing],2) +
								ROUND([Removal_Materials] * [Loaders_Materials_Warehouse],2) + 
								ROUND([Removal_Materials] * [Loaders_Materials_ExemptMaterials],2))
							   PERSISTED,
	[Removal_AFUDC] AS ROUND(((Removal_Labour +
							   Removal_Services + 
							   Removal_Materials + 
							   Removal_OtherDirectCharges) + 
							  (ROUND([Removal_Labour] * [Loaders_Labour_PayrollTax],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_ICP],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_PB],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_WC],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_VS],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_PLPD],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_UnionContract],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_ShopOverheads],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_SmallTools],2) +
							   ROUND([Removal_Labour] * [Loaders_Other_Engineering],2) +
							   ROUND([Removal_Labour] * [Loaders_Other_DOH],2) +
							   ROUND([Removal_Labour] * [Loaders_Other_WildfireInsurance],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2) +
							   ROUND((ROUND([Removal_Labour] * [Loaders_Labour_PayrollTax],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_ICP],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_PB],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_WC],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_VS],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_PLPD],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_UnionContract],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_ShopOverheads],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_SmallTools],2) +
									  ROUND([Removal_Labour] * [Loaders_Other_Engineering],2) +
									  ROUND([Removal_Labour] * [Loaders_Other_DOH],2) +
									  ROUND([Removal_Labour] * [Loaders_Other_WildfireInsurance],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2)) * 
									  [Loaders_Labour_BillingSupplemental_NonEnergy],2)) + 
							  (ROUND([Removal_Services] * [Loaders_Materials_Purchasing],2) +
							   ROUND([Removal_Services] * [Loaders_Other_ContractAdministration],2) + 
							   ROUND([Removal_Services] * [Loaders_Other_Engineering],2) + 
							   ROUND([Removal_Services] * [Loaders_Other_DOH],2)) + 
							  (ROUND([Removal_Materials] * [Loaders_Materials_Purchasing],2) +
							   ROUND([Removal_Materials] * [Loaders_Materials_Warehouse],2) + 
							   ROUND([Removal_Materials] * [Loaders_Materials_ExemptMaterials],2))) * 
							 ([Loaders_AFUDCITCCA_AFUDC] * [ExpectedProjectPeriods]),2)
							  PERSISTED,
	[Removal_ITCCA] AS ROUND(((Removal_Labour +
							   Removal_Services + 
							   Removal_Materials + 
							   Removal_OtherDirectCharges) +
							  (ROUND([Removal_Labour] * [Loaders_Labour_PayrollTax],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_ICP],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_PB],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_WC],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_VS],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_PLPD],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_UnionContract],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_ShopOverheads],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_SmallTools],2) +
							   ROUND([Removal_Labour] * [Loaders_Other_Engineering],2) +
							   ROUND([Removal_Labour] * [Loaders_Other_DOH],2) +
							   ROUND([Removal_Labour] * [Loaders_Other_WildfireInsurance],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2) +
							   ROUND((ROUND([Removal_Labour] * [Loaders_Labour_PayrollTax],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_ICP],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_PB],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_WC],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_VS],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_PLPD],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_UnionContract],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_ShopOverheads],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_SmallTools],2) +
									  ROUND([Removal_Labour] * [Loaders_Other_Engineering],2) +
									  ROUND([Removal_Labour] * [Loaders_Other_DOH],2) +
									  ROUND([Removal_Labour] * [Loaders_Other_WildfireInsurance],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2)) * 
									  [Loaders_Labour_BillingSupplemental_NonEnergy],2)) + 
							  (ROUND([Removal_Services] * [Loaders_Materials_Purchasing],2) +
							   ROUND([Removal_Services] * [Loaders_Other_ContractAdministration],2) + 
							   ROUND([Removal_Services] * [Loaders_Other_Engineering],2) + 
							   ROUND([Removal_Services] * [Loaders_Other_DOH],2)) + 
							  (ROUND([Removal_Materials] * [Loaders_Materials_Purchasing],2) +
							   ROUND([Removal_Materials] * [Loaders_Materials_Warehouse],2) + 
							   ROUND([Removal_Materials] * [Loaders_Materials_ExemptMaterials],2))) *  
							  [Loaders_AFUDCITCCA_ITCCA],2)
							  PERSISTED,
	[Removal_TotalCosts] AS (Removal_Labour +
							  Removal_Services + 
							  Removal_Materials + 
							  Removal_OtherDirectCharges) + 
							(ROUND([Removal_Labour] * [Loaders_Labour_PayrollTax],2) +
								ROUND([Removal_Labour] * [Loaders_Labour_ICP],2) +
								ROUND([Removal_Labour] * [Loaders_Labour_PB],2) +
								ROUND([Removal_Labour] * [Loaders_Labour_WC],2) +
								ROUND([Removal_Labour] * [Loaders_Labour_VS],2) +
								ROUND([Removal_Labour] * [Loaders_Labour_PLPD],2) +
								ROUND([Removal_Labour] * [Loaders_Labour_UnionContract],2) +
								ROUND([Removal_Labour] * [Loaders_Labour_ShopOverheads],2) +
								ROUND([Removal_Labour] * [Loaders_Labour_SmallTools],2) +
								ROUND([Removal_Labour] * [Loaders_Other_Engineering],2) +
								ROUND([Removal_Labour] * [Loaders_Other_DOH],2) +
								ROUND([Removal_Labour] * [Loaders_Other_WildfireInsurance],2) +
								ROUND([Removal_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2) +
								ROUND((ROUND([Removal_Labour] * [Loaders_Labour_PayrollTax],2) +
									   ROUND([Removal_Labour] * [Loaders_Labour_ICP],2) +
									   ROUND([Removal_Labour] * [Loaders_Labour_PB],2) +
									   ROUND([Removal_Labour] * [Loaders_Labour_WC],2) +
									   ROUND([Removal_Labour] * [Loaders_Labour_VS],2) +
									   ROUND([Removal_Labour] * [Loaders_Labour_PLPD],2) +
									   ROUND([Removal_Labour] * [Loaders_Labour_UnionContract],2) +
									   ROUND([Removal_Labour] * [Loaders_Labour_ShopOverheads],2) +
									   ROUND([Removal_Labour] * [Loaders_Labour_SmallTools],2) +
									   ROUND([Removal_Labour] * [Loaders_Other_Engineering],2) +
									   ROUND([Removal_Labour] * [Loaders_Other_DOH],2) +
									   ROUND([Removal_Labour] * [Loaders_Other_WildfireInsurance],2) +
									   ROUND([Removal_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2)) * 
									   [Loaders_Labour_BillingSupplemental_NonEnergy],2)) + 
							   (ROUND([Removal_Services] * [Loaders_Materials_Purchasing],2) +
								ROUND([Removal_Services] * [Loaders_Other_ContractAdministration],2) + 
								ROUND([Removal_Services] * [Loaders_Other_Engineering],2) + 
								ROUND([Removal_Services] * [Loaders_Other_DOH],2)) + 
							   (ROUND([Removal_Materials] * [Loaders_Materials_Purchasing],2) +
								ROUND([Removal_Materials] * [Loaders_Materials_Warehouse],2) + 
								ROUND([Removal_Materials] * [Loaders_Materials_ExemptMaterials],2)) +
							ROUND(((Removal_Labour +
							   Removal_Services + 
							   Removal_Materials + 
							   Removal_OtherDirectCharges) + 
							  (ROUND([Removal_Labour] * [Loaders_Labour_PayrollTax],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_ICP],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_PB],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_WC],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_VS],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_PLPD],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_UnionContract],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_ShopOverheads],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_SmallTools],2) +
							   ROUND([Removal_Labour] * [Loaders_Other_Engineering],2) +
							   ROUND([Removal_Labour] * [Loaders_Other_DOH],2) +
							   ROUND([Removal_Labour] * [Loaders_Other_WildfireInsurance],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2) +
							   ROUND((ROUND([Removal_Labour] * [Loaders_Labour_PayrollTax],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_ICP],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_PB],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_WC],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_VS],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_PLPD],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_UnionContract],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_ShopOverheads],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_SmallTools],2) +
									  ROUND([Removal_Labour] * [Loaders_Other_Engineering],2) +
									  ROUND([Removal_Labour] * [Loaders_Other_DOH],2) +
									  ROUND([Removal_Labour] * [Loaders_Other_WildfireInsurance],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2)) * 
									  [Loaders_Labour_BillingSupplemental_NonEnergy],2)) + 
							  (ROUND([Removal_Services] * [Loaders_Materials_Purchasing],2) +
							   ROUND([Removal_Services] * [Loaders_Other_ContractAdministration],2) + 
							   ROUND([Removal_Services] * [Loaders_Other_Engineering],2) + 
							   ROUND([Removal_Services] * [Loaders_Other_DOH],2)) + 
							  (ROUND([Removal_Materials] * [Loaders_Materials_Purchasing],2) +
							   ROUND([Removal_Materials] * [Loaders_Materials_Warehouse],2) + 
							   ROUND([Removal_Materials] * [Loaders_Materials_ExemptMaterials],2))) * 
							 ([Loaders_AFUDCITCCA_AFUDC] * [ExpectedProjectPeriods]),2) + 
							ROUND(((Removal_Labour +
							   Removal_Services + 
							   Removal_Materials + 
							   Removal_OtherDirectCharges) +
							  (ROUND([Removal_Labour] * [Loaders_Labour_PayrollTax],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_ICP],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_PB],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_WC],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_VS],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_PLPD],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_UnionContract],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_ShopOverheads],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_SmallTools],2) +
							   ROUND([Removal_Labour] * [Loaders_Other_Engineering],2) +
							   ROUND([Removal_Labour] * [Loaders_Other_DOH],2) +
							   ROUND([Removal_Labour] * [Loaders_Other_WildfireInsurance],2) +
							   ROUND([Removal_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2) +
							   ROUND((ROUND([Removal_Labour] * [Loaders_Labour_PayrollTax],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_ICP],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_PB],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_WC],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_VS],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_PLPD],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_UnionContract],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_ShopOverheads],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_SmallTools],2) +
									  ROUND([Removal_Labour] * [Loaders_Other_Engineering],2) +
									  ROUND([Removal_Labour] * [Loaders_Other_DOH],2) +
									  ROUND([Removal_Labour] * [Loaders_Other_WildfireInsurance],2) +
									  ROUND([Removal_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2)) * 
									  [Loaders_Labour_BillingSupplemental_NonEnergy],2)) + 
							  (ROUND([Removal_Services] * [Loaders_Materials_Purchasing],2) +
							   ROUND([Removal_Services] * [Loaders_Other_ContractAdministration],2) + 
							   ROUND([Removal_Services] * [Loaders_Other_Engineering],2) + 
							   ROUND([Removal_Services] * [Loaders_Other_DOH],2)) + 
							  (ROUND([Removal_Materials] * [Loaders_Materials_Purchasing],2) +
							   ROUND([Removal_Materials] * [Loaders_Materials_Warehouse],2) + 
							   ROUND([Removal_Materials] * [Loaders_Materials_ExemptMaterials],2))) *  
							  [Loaders_AFUDCITCCA_ITCCA],2) 
							PERSISTED,
	[Other_Labour] [money] NOT NULL DEFAULT 0,
	[Other_Services] [money] NOT NULL DEFAULT 0,
	[Other_Materials] [money] NOT NULL DEFAULT 0,
	[Other_OtherDirectCharges] [money] NOT NULL DEFAULT 0,
	[Other_DirectCosts] AS (Other_Labour +
							  Other_Services + 
							  Other_Materials + 
							  Other_OtherDirectCharges) 
							  PERSISTED,
	[Other_AffiliateTransferInCosts] [money] NOT NULL DEFAULT 0,
	[Other_LabourIndirects_PayrollTax] AS ROUND([Other_Labour] * [Loaders_Labour_PayrollTax],2),
	[Other_LabourIndirects_ICP] AS ROUND([Other_Labour] * [Loaders_Labour_ICP],2),
	[Other_LabourIndirects_PB] AS ROUND([Other_Labour] * [Loaders_Labour_PB],2),
	[Other_LabourIndirects_WC] AS ROUND([Other_Labour] * [Loaders_Labour_WC],2),
	[Other_LabourIndirects_VS] AS ROUND([Other_Labour] * [Loaders_Labour_VS],2),
	[Other_LabourIndirects_PLPD] AS ROUND([Other_Labour] * [Loaders_Labour_PLPD],2),
	[Other_LabourIndirects_UnionContract] AS ROUND([Other_Labour] * [Loaders_Labour_UnionContract],2),
	[Other_LabourIndirects_ShopOverheads] AS ROUND([Other_Labour] * [Loaders_Labour_ShopOverheads],2),
	[Other_LabourIndirects_SmallTools] AS ROUND([Other_Labour] * [Loaders_Labour_SmallTools],2),
	[Other_LabourIndirects_Engineering] AS ROUND([Other_Labour] * [Loaders_Other_Engineering],2),
	[Other_LabourIndirects_DOH] AS ROUND([Other_Labour] * [Loaders_Other_DOH],2),
	[Other_LabourIndirects_WildfireInsurance] AS ROUND([Other_Labour] * [Loaders_Other_WildfireInsurance],2),
	[Other_LabourIndirects_BillingSupplemental_Energy] AS ROUND([Other_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2),
	[Other_LabourIndirects_BillingSupplemental_NonEnergy] AS ROUND((ROUND([Other_Labour] * [Loaders_Labour_PayrollTax],2) +
																	  ROUND([Other_Labour] * [Loaders_Labour_ICP],2) +
																	  ROUND([Other_Labour] * [Loaders_Labour_PB],2) +
																	  ROUND([Other_Labour] * [Loaders_Labour_WC],2) +
																	  ROUND([Other_Labour] * [Loaders_Labour_VS],2) +
																	  ROUND([Other_Labour] * [Loaders_Labour_PLPD],2) +
																	  ROUND([Other_Labour] * [Loaders_Labour_UnionContract],2) +
																	  ROUND([Other_Labour] * [Loaders_Labour_ShopOverheads],2) +
																	  ROUND([Other_Labour] * [Loaders_Labour_SmallTools],2) +
																	  ROUND([Other_Labour] * [Loaders_Other_Engineering],2) +
																	  ROUND([Other_Labour] * [Loaders_Other_DOH],2) +
																	  ROUND([Other_Labour] * [Loaders_Other_WildfireInsurance],2) +
																	  ROUND([Other_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2)) * 
																	  [Loaders_Labour_BillingSupplemental_NonEnergy],2),
	[Other_LabourIndirects] AS (ROUND([Other_Labour] * [Loaders_Labour_PayrollTax],2) +
								  ROUND([Other_Labour] * [Loaders_Labour_ICP],2) +
								  ROUND([Other_Labour] * [Loaders_Labour_PB],2) +
								  ROUND([Other_Labour] * [Loaders_Labour_WC],2) +
								  ROUND([Other_Labour] * [Loaders_Labour_VS],2) +
								  ROUND([Other_Labour] * [Loaders_Labour_PLPD],2) +
								  ROUND([Other_Labour] * [Loaders_Labour_UnionContract],2) +
								  ROUND([Other_Labour] * [Loaders_Labour_ShopOverheads],2) +
								  ROUND([Other_Labour] * [Loaders_Labour_SmallTools],2) +
								  ROUND([Other_Labour] * [Loaders_Other_Engineering],2) +
								  ROUND([Other_Labour] * [Loaders_Other_DOH],2) +
								  ROUND([Other_Labour] * [Loaders_Other_WildfireInsurance],2) +
								  ROUND([Other_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2) +
								  ROUND((ROUND([Other_Labour] * [Loaders_Labour_PayrollTax],2) +
										 ROUND([Other_Labour] * [Loaders_Labour_ICP],2) +
										 ROUND([Other_Labour] * [Loaders_Labour_PB],2) +
										 ROUND([Other_Labour] * [Loaders_Labour_WC],2) +
										 ROUND([Other_Labour] * [Loaders_Labour_VS],2) +
										 ROUND([Other_Labour] * [Loaders_Labour_PLPD],2) +
										 ROUND([Other_Labour] * [Loaders_Labour_UnionContract],2) +
										 ROUND([Other_Labour] * [Loaders_Labour_ShopOverheads],2) +
										 ROUND([Other_Labour] * [Loaders_Labour_SmallTools],2) +
										 ROUND([Other_Labour] * [Loaders_Other_Engineering],2) +
										 ROUND([Other_Labour] * [Loaders_Other_DOH],2) +
										 ROUND([Other_Labour] * [Loaders_Other_WildfireInsurance],2) +
										 ROUND([Other_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2)) * 
										 [Loaders_Labour_BillingSupplemental_NonEnergy],2)) 
								  PERSISTED,
	[Other_ServiceIndirects_Purchasing] AS ROUND([Other_Services] * [Loaders_Materials_Purchasing],2),
	[Other_ServiceIndirects_ContractAdministration] AS ROUND([Other_Services] * [Loaders_Other_ContractAdministration],2),
	[Other_ServiceIndirects_Engineering] AS ROUND([Other_Services] * [Loaders_Other_Engineering],2),
	[Other_ServiceIndirects_DOH] AS ROUND([Other_Services] * [Loaders_Other_DOH],2),
	[Other_ServiceIndirects] AS (ROUND([Other_Services] * [Loaders_Materials_Purchasing],2) +
								   ROUND([Other_Services] * [Loaders_Other_ContractAdministration],2) + 
								   ROUND([Other_Services] * [Loaders_Other_Engineering],2) + 
								   ROUND([Other_Services] * [Loaders_Other_DOH],2)) 
								   PERSISTED,
	[Other_MaterialIndirects_Purchasing] AS ROUND([Other_Materials] * [Loaders_Materials_Purchasing],2),
	[Other_MaterialIndirects_Warehouse] AS ROUND([Other_Materials] * [Loaders_Materials_Warehouse],2),
	[Other_MaterialIndirects_ExemptMaterials] AS ROUND([Other_Materials] * [Loaders_Materials_ExemptMaterials],2),
	[Other_MaterialIndirects] AS (ROUND([Other_Materials] * [Loaders_Materials_Purchasing],2) +
									ROUND([Other_Materials] * [Loaders_Materials_Warehouse],2) + 
									ROUND([Other_Materials] * [Loaders_Materials_ExemptMaterials],2))
									PERSISTED,
	[Other_IndirectCosts] AS (ROUND([Other_Labour] * [Loaders_Labour_PayrollTax],2) +
								ROUND([Other_Labour] * [Loaders_Labour_ICP],2) +
								ROUND([Other_Labour] * [Loaders_Labour_PB],2) +
								ROUND([Other_Labour] * [Loaders_Labour_WC],2) +
								ROUND([Other_Labour] * [Loaders_Labour_VS],2) +
								ROUND([Other_Labour] * [Loaders_Labour_PLPD],2) +
								ROUND([Other_Labour] * [Loaders_Labour_UnionContract],2) +
								ROUND([Other_Labour] * [Loaders_Labour_ShopOverheads],2) +
								ROUND([Other_Labour] * [Loaders_Labour_SmallTools],2) +
								ROUND([Other_Labour] * [Loaders_Other_Engineering],2) +
								ROUND([Other_Labour] * [Loaders_Other_DOH],2) +
								ROUND([Other_Labour] * [Loaders_Other_WildfireInsurance],2) +
								ROUND([Other_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2) +
								ROUND((ROUND([Other_Labour] * [Loaders_Labour_PayrollTax],2) +
									   ROUND([Other_Labour] * [Loaders_Labour_ICP],2) +
									   ROUND([Other_Labour] * [Loaders_Labour_PB],2) +
									   ROUND([Other_Labour] * [Loaders_Labour_WC],2) +
									   ROUND([Other_Labour] * [Loaders_Labour_VS],2) +
									   ROUND([Other_Labour] * [Loaders_Labour_PLPD],2) +
									   ROUND([Other_Labour] * [Loaders_Labour_UnionContract],2) +
									   ROUND([Other_Labour] * [Loaders_Labour_ShopOverheads],2) +
									   ROUND([Other_Labour] * [Loaders_Labour_SmallTools],2) +
									   ROUND([Other_Labour] * [Loaders_Other_Engineering],2) +
									   ROUND([Other_Labour] * [Loaders_Other_DOH],2) +
									   ROUND([Other_Labour] * [Loaders_Other_WildfireInsurance],2) +
									   ROUND([Other_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2)) * 
									   [Loaders_Labour_BillingSupplemental_NonEnergy],2)) + 
							   (ROUND([Other_Services] * [Loaders_Materials_Purchasing],2) +
								ROUND([Other_Services] * [Loaders_Other_ContractAdministration],2) + 
								ROUND([Other_Services] * [Loaders_Other_Engineering],2) + 
								ROUND([Other_Services] * [Loaders_Other_DOH],2)) + 
							   (ROUND([Other_Materials] * [Loaders_Materials_Purchasing],2) +
								ROUND([Other_Materials] * [Loaders_Materials_Warehouse],2) + 
								ROUND([Other_Materials] * [Loaders_Materials_ExemptMaterials],2))
							   PERSISTED,
	[Other_AFUDC] [money] DEFAULT 0,
	[Other_ITCCA] [money] DEFAULT 0,
	[Other_TotalCosts] AS (Other_Labour +
							  Other_Services + 
							  Other_Materials + 
							  Other_OtherDirectCharges) + 
							(ROUND([Other_Labour] * [Loaders_Labour_PayrollTax],2) +
								ROUND([Other_Labour] * [Loaders_Labour_ICP],2) +
								ROUND([Other_Labour] * [Loaders_Labour_PB],2) +
								ROUND([Other_Labour] * [Loaders_Labour_WC],2) +
								ROUND([Other_Labour] * [Loaders_Labour_VS],2) +
								ROUND([Other_Labour] * [Loaders_Labour_PLPD],2) +
								ROUND([Other_Labour] * [Loaders_Labour_UnionContract],2) +
								ROUND([Other_Labour] * [Loaders_Labour_ShopOverheads],2) +
								ROUND([Other_Labour] * [Loaders_Labour_SmallTools],2) +
								ROUND([Other_Labour] * [Loaders_Other_Engineering],2) +
								ROUND([Other_Labour] * [Loaders_Other_DOH],2) +
								ROUND([Other_Labour] * [Loaders_Other_WildfireInsurance],2) +
								ROUND([Other_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2) +
								ROUND((ROUND([Other_Labour] * [Loaders_Labour_PayrollTax],2) +
									   ROUND([Other_Labour] * [Loaders_Labour_ICP],2) +
									   ROUND([Other_Labour] * [Loaders_Labour_PB],2) +
									   ROUND([Other_Labour] * [Loaders_Labour_WC],2) +
									   ROUND([Other_Labour] * [Loaders_Labour_VS],2) +
									   ROUND([Other_Labour] * [Loaders_Labour_PLPD],2) +
									   ROUND([Other_Labour] * [Loaders_Labour_UnionContract],2) +
									   ROUND([Other_Labour] * [Loaders_Labour_ShopOverheads],2) +
									   ROUND([Other_Labour] * [Loaders_Labour_SmallTools],2) +
									   ROUND([Other_Labour] * [Loaders_Other_Engineering],2) +
									   ROUND([Other_Labour] * [Loaders_Other_DOH],2) +
									   ROUND([Other_Labour] * [Loaders_Other_WildfireInsurance],2) +
									   ROUND([Other_Labour] * [Loaders_Labour_BillingSupplemental_Energy],2)) * 
									   [Loaders_Labour_BillingSupplemental_NonEnergy],2)) + 
							   (ROUND([Other_Services] * [Loaders_Materials_Purchasing],2) +
								ROUND([Other_Services] * [Loaders_Other_ContractAdministration],2) + 
								ROUND([Other_Services] * [Loaders_Other_Engineering],2) + 
								ROUND([Other_Services] * [Loaders_Other_DOH],2)) + 
							   (ROUND([Other_Materials] * [Loaders_Materials_Purchasing],2) +
								ROUND([Other_Materials] * [Loaders_Materials_Warehouse],2) + 
								ROUND([Other_Materials] * [Loaders_Materials_ExemptMaterials],2))
							PERSISTED,
	[Loaders_Labour_PayrollTax] [float] NOT NULL DEFAULT 0,
	[Loaders_Labour_ICP] [float] NOT NULL DEFAULT 0,
	[Loaders_Labour_PB] [float] NOT NULL DEFAULT 0,
	[Loaders_Labour_WC] [float] NOT NULL DEFAULT 0,
	[Loaders_Labour_VS] [float] NOT NULL DEFAULT 0,
	[Loaders_Labour_PLPD] [float] NOT NULL DEFAULT 0,
	[Loaders_Labour_UnionContract] [float] NOT NULL DEFAULT 0,
	[Loaders_Labour_BillingSupplemental_Energy] [float] NOT NULL DEFAULT 0,
	[Loaders_Labour_BillingSupplemental_NonEnergy] [float] NOT NULL DEFAULT 0,
	[Loaders_Labour_ShopOverheads] [float] NOT NULL DEFAULT 0,
	[Loaders_Labour_SmallTools] [float] NOT NULL DEFAULT 0,
	[Loaders_Materials_Purchasing] [float] NOT NULL DEFAULT 0,
	[Loaders_Materials_Warehouse] [float] NOT NULL DEFAULT 0,
	[Loaders_Materials_ExemptMaterials] [float] NOT NULL DEFAULT 0,
	[Loaders_Other_ContractAdministration] [float] NOT NULL DEFAULT 0,
	[Loaders_Other_PSEPInsurance] [float] NOT NULL DEFAULT 0,
	[Loaders_Other_Engineering] [float] NOT NULL DEFAULT 0,
	[Loaders_Other_DOH] [float] NOT NULL DEFAULT 0,
	[Loaders_Other_AG] [float] NOT NULL DEFAULT 0,
	[Loaders_Other_WildfireInsurance] [float] NOT NULL DEFAULT 0,
	[Loaders_Other_BillingFixedCost] [float] NOT NULL DEFAULT 0,
	[Loaders_AFUDCITCCA_AFUDC] [float] NOT NULL DEFAULT 0,
	[Loaders_AFUDCITCCA_ITCCA] [float] NOT NULL DEFAULT 0,
	[ExpectedProjectPeriods] [int] NOT NULL DEFAULT 0,
	[Created_Date] [datetime] NOT NULL DEFAULT (CONVERT([datetime],getdate())),
	[Created_User] [nvarchar](12) NULL DEFAULT 0,
	[LastUpdated_Date] [datetime] NULL DEFAULT 0,
	[LastUpdated_User] [nvarchar](12) NULL DEFAULT 0)
GO