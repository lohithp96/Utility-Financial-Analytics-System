ALTER VIEW dbo.qryFERCAccounts AS SELECT dbo.idxPlanCategories.PlanCategoryID, dbo.idxPlanCategories.PlanCategoryName_Long, dbo.idxPlanCategories.PlanCategoryName_Short, dbo.idxFERCAccounts_Categories.FERCAccounts_CategoryID, dbo.idxFERCAccounts_Categories.FERCAccounts_Category, dbo.idxFERCAccounts_Headings.FERCAccounts_HeaderID, dbo.idxFERCAccounts_Headings.FERCAccounts_HeaderName, dbo.idxFERCAccounts.FERCAccount, dbo.idxFERCAccounts.FERCAccount_SCE, dbo.idxFERCAccounts.FERCAccount_Name, dbo.idxFERCAccounts.FERCAccount_Description
FROM ((dbo.idxFERCAccounts INNER JOIN dbo.idxFERCAccounts_Categories ON dbo.idxFERCAccounts.FERCAccounts_CategoryID = dbo.idxFERCAccounts_Categories.FERCAccounts_CategoryID) INNER JOIN dbo.idxFERCAccounts_Headings ON dbo.idxFERCAccounts.FERCAccounts_HeaderID = dbo.idxFERCAccounts_Headings.FERCAccounts_HeaderID) INNER JOIN dbo.idxPlanCategories ON dbo.idxFERCAccounts_Categories.PlanCategoryID = dbo.idxPlanCategories.PlanCategoryID;