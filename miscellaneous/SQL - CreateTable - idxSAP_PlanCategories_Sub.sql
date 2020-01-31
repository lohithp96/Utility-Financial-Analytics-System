USE [SONGS]
GO

/****** Object:  Table [dbo].[idxSAP_PlanCategories_Sub]    Script Date: 3/7/2016 5:02 PM ******/
IF OBJECT_ID('[dbo].[idxSAP_PlanCategories_Sub]','U') IS NOT NULL
	DROP TABLE [dbo].idxSAP_PlanCategories_Sub
GO

/****** Object:  Table [dbo].[idxSAP_PlanCategories_Sub]    Script Date: 3/7/2016 4:59:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[idxSAP_PlanCategories_Sub](
	[PlanCategory_Sub] [nchar](3) NOT NULL PRIMARY KEY,
	[PlanCategory] [nchar](3) NULL 
	                          CONSTRAINT [FK_idxSAP_PlanCategories_Sub_idxSAP_PlanCategories] 
							  FOREIGN KEY([PlanCategory])
							  REFERENCES [dbo].[idxSAP_PlanCategories] ([PlanCategory]),
	[PlanCategory_Sub_Description] [nvarchar](30) NULL,
	[CostingSheet_Procedure] [nchar](6) NULL
	                                    CONSTRAINT [FK_idxSAP_PlanCategories_Sub_idxSAP_CostingSheets]
										FOREIGN KEY([CostingSheet_Procedure])
										REFERENCES [dbo].[idxSAP_CostingSheets]([CostingSheet_Procedure]),
	[OverheadKey] [nvarchar](6) NULL,
								CONSTRAINT [FK_idxSAP_PlanCategories_Sub_idxSAP_OverheadKeys]
								FOREIGN KEY([OverheadKey])
								REFERENCES [dbo].[idxSAP_OverheadKeys]([OverheadKey]),
	[Created_Date] [datetime] NULL DEFAULT (CONVERT([datetime],getdate())),
	[Created_User] [nvarchar](12) NULL,
	[LastUpdated_Date] [datetime] NULL,
	[LastUpdated_User] [nvarchar](12) NULL,
	[Active] [bit] NOT NULL DEFAULT ((1)))

GO
