/****** Script for SelectTopNRows command from SSMS  ******/
SELECT FORMAT([SONGS].[dbo].[SDGE_SAP_KOB1].[Date_Posting], 'yyyyMM', 'en-US') AS 'Invoice_Key'
      ,(CASE WHEN [SONGS].[dbo].[SDGE_SAP_KOB1].[CostCenter]='2100-3416' THEN 'SDG&E Operations' 
	         WHEN [SONGS].[dbo].[SDGE_SAP_KOB1].[CostElement] LIKE '698%' THEN 'SDG&E Settlements'
			 WHEN [SONGS].[dbo].[SDGE_SAP_KOB1].[OffsetAccount] LIKE '14%' THEN 'SDG&E Settlements'
			 WHEN [SONGS].[dbo].[SDGE_SAP_KOB1].[Details] LIKE '%REFUND%' THEN 'Prior Period Adjustments'
			 WHEN [SONGS].[dbo].[SDGE_SAP_KOB1].[ReferenceDocument] IN('1700019137') THEN 'Prior Period Adjustments'
			 WHEN [SONGS].[dbo].[SDGE_SAP_KOB1].[CostElement] IN('6220000','6220005') THEN CASE
			      WHEN [SONGS].[dbo].[SDGE_SAP_KOB1].[Details] LIKE '%NONLAB%' THEN 'SONGS Non-Labor'
				  WHEN [SONGS].[dbo].[SDGE_SAP_KOB1].[Details] LIKE '%NL%' THEN 'SONGS Non-Labor'
				  WHEN [SONGS].[dbo].[SDGE_SAP_KOB1].[Details] LIKE '%LAB%' THEN 'SONGS Labor'
				  WHEN [SONGS].[dbo].[SDGE_SAP_KOB1].[Details] LIKE '%L%' THEN 'SONGS Labor'
				  WHEN [SONGS].[dbo].[SDGE_SAP_KOB1].[Details] LIKE '%ADV%' THEN 'SONGS Advance'
				  ELSE 'SONGS Mixed' END
			 WHEN [SONGS].[dbo].[SDGE_SAP_KOB1].[CostElement]='6900001' THEN 'SDG&E AFUDC'
			 WHEN [SONGS].[dbo].[SDGE_SAP_KOB1].[CostElement]='6900200' THEN 'SDG&E Transfers'
			 WHEN ISNULL([SONGS].[dbo].[SDGE_SAP_KOB1].[CostCenter],'SDGE_OH')='SDGE_OH' THEN 'SDG&E Overheads'
	         ELSE 'SDG&E Overheads' END) AS 'TransactionType'
	  ,[SONGS].[dbo].[SDGE_SAP_KOB1].[Amount]
FROM [SONGS].[dbo].[SDGE_SAP_KOB1] INNER JOIN [SONGS].[dbo].[idxSDGE_SAP_Orders] ON 
     [SONGS].[dbo].[SDGE_SAP_KOB1].OrderNumber = [SONGS].[dbo].[idxSDGE_SAP_Orders].[OrderNumber]
WHERE DATEPART(yyyy,[SONGS].[dbo].[SDGE_SAP_KOB1].[Date_Posting])>=2012 AND
      ISNULL([SONGS].[dbo].[idxSDGE_SAP_Orders].[FERCAccount],'999') NOT LIKE '5%' AND
	  [SONGS].[dbo].[idxSDGE_SAP_Orders].[OrderDescription] LIKE '%Z %' AND
	  ([SONGS].[dbo].[SDGE_SAP_KOB1].[CostCenter]='' OR
	   [SONGS].[dbo].[SDGE_SAP_KOB1].[CostCenter] IN('2100-0300','2100-0302','2100-3416','2100-0379','2100-9514') OR
	   ISNULL([SONGS].[dbo].[SDGE_SAP_KOB1].[CostCenter],'IZNULL')='IZNULL');