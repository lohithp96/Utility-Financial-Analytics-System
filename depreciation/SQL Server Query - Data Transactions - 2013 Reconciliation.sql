SELECT  TOP (100) PERCENT       DSAccount.DS_Data_Account
                                ,DSData.Vintage
                                ,SUM(CASE WHEN (DSData.Activity_Year<2013 OR (DSData.Activity_Year=2013 AND TxCode.Analysis_Transaction_Code<>'Balance')) THEN (TXCode.Sum_Factor*DSData.Amount) ELSE 0 END) AS ImportedActivity
                                ,SUM(CASE WHEN (DSData.Activity_Year=2013 AND TxCode.Analysis_Transaction_Code='Balance') THEN (TXCode.Sum_Factor*DSData.Amount) ELSE 0 END) AS Balance2013
FROM    PowerPlan.DS_Data_Transaction DSData INNER JOIN
        PowerPlan.DS_Data_Account DSAccount ON PowerPlan.DS_Data_Transaction.DS_Data_Account_ID = PowerPlan.DS_Data_Account.DS_Data_Account_ID INNER JOIN
        PowerPlan.Analysis_Transaction_Code TxCode ON PowerPlan.DS_Data_Transaction.Analysis_Trans_ID = PowerPlan.Analysis_Transaction_Code.Analysis_Trans_ID INNER JOIN
        PowerPlan.Transaction_Input_Type InputType ON PowerPlan.DS_Data_Transaction.Transaction_Input_Type_ID = PowerPlan.Transaction_Input_Type.Transaction_Input_Type_ID
GROUP BY PowerPlan.DS_Data_Account.DS_Data_Account, PowerPlan.DS_Data_Transaction.Vintage
ORDER BY PowerPlan.DS_Data_Account.DS_Data_Account, PowerPlan.DS_Data_Transaction.Vintage