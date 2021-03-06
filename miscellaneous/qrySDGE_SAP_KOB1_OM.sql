/****** Script for SelectTopNRows command from SSMS  ******/
SELECT FORMAT([SONGS].[dbo].[SDGE_SAP_KOB1].[Date_Posting], 'yyyyMM', 'en-US') AS 'Posting_Date'
      ,(CASE WHEN [SONGS].[dbo].[SDGE_SAP_KOB1].[Details] LIKE '%REFUND%' THEN 'Prior Period Adjustments'
			 WHEN [SONGS].[dbo].[SDGE_SAP_KOB1].[ReferenceDocument] IN('1700019137') THEN 'Prior Period Adjustments'
	         ELSE RTRIM([SONGS].[dbo].[idxSDGE_SAP_GLAccounts].[SONGSCategory]) END) AS 'TransactionType'
	  ,[SONGS].[dbo].[SDGE_SAP_KOB1].[Amount]
FROM [SONGS].[dbo].[SDGE_SAP_KOB1] INNER JOIN [SONGS].[dbo].[idxSDGE_SAP_Orders] ON 
     [SONGS].[dbo].[SDGE_SAP_KOB1].[OrderNumber] = [SONGS].[dbo].[idxSDGE_SAP_Orders].[OrderNumber] 
	 INNER JOIN [SONGS].[dbo].[idxSDGE_SAP_GLAccounts] ON 
	 [SONGS].[dbo].[SDGE_SAP_KOB1].[CostElement] = [SONGS].[dbo].[idxSDGE_SAP_GLAccounts].[GLAccount]
WHERE ((100*DATEPART(yyyy,[SONGS].[dbo].[SDGE_SAP_KOB1].[Date_Posting]))+DATEPART(MM,[SONGS].[dbo].[SDGE_SAP_KOB1].[Date_Posting]))>=201201 AND
      ISNULL([SONGS].[dbo].[idxSDGE_SAP_Orders].[FERCAccount],'999') LIKE '5%' AND
	  ([SONGS].[dbo].[SDGE_SAP_KOB1].[CostCenter]='' OR
	   [SONGS].[dbo].[SDGE_SAP_KOB1].[CostCenter] IN('2100-0300','2100-0302','2100-0379','2100-9514') OR
	   ISNULL([SONGS].[dbo].[SDGE_SAP_KOB1].[CostCenter],'IZNULL')='IZNULL');