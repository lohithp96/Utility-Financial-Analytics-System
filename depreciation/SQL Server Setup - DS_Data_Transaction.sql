USE [SONGS]
GO

IF OBJECT_ID ( 'PowerPlan.DS_Data_Transaction','U') IS NOT NULL
    DROP TABLE PowerPlan.DS_Data_Transaction;
GO

PRINT '-- PowerPlan.DS_Data_Transaction';
CREATE TABLE PowerPlan.DS_Data_Transaction
(
    [DS_Trans_ID] [INT] NOT NULL
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[DS_Data_Account_ID] [int] NOT NULL    CONSTRAINT FK_PowerPlan_DSDataTransaction_DSDataAccount_DSDataAccountID
                                            FOREIGN KEY (DS_Data_Account_ID)
                                            REFERENCES PowerPlan.DS_Data_Account(DS_Data_Account_ID)
    ,[Analysis_Trans_ID] [int] NOT NULL     CONSTRAINT FK_PowerPlan_DSDataTransaction_AnalysisTransactionCode_AnalysisTransID
                                            FOREIGN KEY (Analysis_Trans_ID)
                                            REFERENCES PowerPlan.Analysis_Transaction_Code(Analysis_Trans_ID)    
    ,[Vintage] [INT] NULL
    ,[Activity_Year] [INT] NOT NULL
    ,[Adjustment_Year] [INT] NULL
    ,[Effective_Date] date NULL
    ,[Amount] numeric(22,2) NULL
    ,[Quantity] numeric(22,2) NULL
    ,[Transaction_Input_Type_ID] [int] NULL CONSTRAINT DK_PowerPlan_DSDataTransaction_TransactionInputType_TransactionInputTypeID
                                            FOREIGN KEY (Transaction_Input_Type_ID)
                                            REFERENCES PowerPlan.Transaction_Input_Type(Transaction_Input_Type_ID)
    ,[Description] nvarchar(254) NULL
    ,[Set_of_Books_ID] [int] NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_DSDataTransaction_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_DSDataTransaction_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_DSDataTransaction_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_DSDataTransaction_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_DSDataTransaction_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
    ,CONSTRAINT PK_PowerPlan_DSDataTransaction PRIMARY KEY ([DS_Trans_ID])
);
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(O)  [05] This table contains all the accounting transactions for each vintage and activity year for a depreciation study data account.  Transactions can be either aged or unaged.  Transactions can be inputted directly by the user or transferred from the CPR.  The transfer from the CPR can be executed for particular activity years, and combined with previous aged transactions.  These transactions will be included in all analysis datasets and analysis scenarios.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'DS_Data_Transaction';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) System-assigned key to uniquely identify each transaction.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'DS_Data_Transaction',
    @level2type=N'COLUMN',  @level2name=N'DS_Trans_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'DS_Data_Transaction',
    @level2type=N'COLUMN',  @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'DS_Data_Transaction',
    @level2type=N'COLUMN',  @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a particular depr study data account.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'DS_Data_Transaction',
    @level2type=N'COLUMN',  @level2name=N'DS_Data_Account_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a particular analysis transaction.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'DS_Data_Transaction',
    @level2type=N'COLUMN',  @level2name=N'Analysis_Trans_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(Engineering) in-service year of plant addition. (4 digits)',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'DS_Data_Transaction',
    @level2type=N'COLUMN',  @level2name=N'Vintage';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Year of transaction activity, when posted to the companys books.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'DS_Data_Transaction',
    @level2type=N'COLUMN',  @level2name=N'Activity_Year';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Adjusting year, when the posting year does not reflect the event year, e.g. a retirement of vintage 1955 property, posted in 2004, but out-of-service in 2003.  2003 would be the adjusting year.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'DS_Data_Transaction',
    @level2type=N'COLUMN',  @level2name=N'Adjustment_Year';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Effective date of the transaction.  Provides month of activity if necessary.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'DS_Data_Transaction',
    @level2type=N'COLUMN',  @level2name=N'Effective_Date';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Dollar amount of the transaction.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'DS_Data_Transaction',
    @level2type=N'COLUMN',  @level2name=N'Amount';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Physical quantity of the transaction (dependent of the CPR unit of measure).',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'DS_Data_Transaction',
    @level2type=N'COLUMN',  @level2name=N'Quantity';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'System-assigned identifier of a particular transaction input type: 1)CPT 2)Derived 3)Input',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'DS_Data_Transaction',
    @level2type=N'COLUMN',  @level2name=N'Transaction_Input_Type_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'User editable description about the transaction.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'DS_Data_Transaction',
    @level2type=N'COLUMN',  @level2name=N'Description';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'System-assigned identifier of a particular set of books.',
    @level0type=N'SCHEMA',  @level0name=N'PowerPlan',
    @level1type=N'TABLE',   @level1name=N'DS_Data_Transaction',
    @level2type=N'COLUMN',  @level2name=N'Set_of_Books_ID';
GO