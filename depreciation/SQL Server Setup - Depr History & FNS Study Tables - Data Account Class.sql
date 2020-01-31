USE SONGS
GO

DROP TABLE PowerPlan.Data_Account_Class
GO

PRINT '-- PowerPlan.Data_Account_Class';
CREATE TABLE PowerPlan.Data_Account_Class
(
    [Data_Account_Class_ID] [int] NOT NULL
    ,[Time_Stamp] datetime2 NULL
    ,[User_ID] varchar(18) NULL
    ,[Data_Account_Class] [nvarchar](35) NOT NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_DataAccountClass_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_DataAccountClass_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_DataAccountClass_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_DataAccountClass_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_DataAccountClass_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
    ,CONSTRAINT PK_PowerPlan_DataAccountClass PRIMARY KEY ([Data_Account_Class_ID])
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(S) [05] This table contains a roll-up of analysis accounts used in depreciation studies.  It is used for reporting and query.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Data_Account_Class';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) System-assigned identifier of a particular analysis account class.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Data_Account_Class',
    @level2type=N'COLUMN', @level2name=N'Data_Account_Class_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Data_Account_Class',
    @level2type=N'COLUMN', @level2name=N'Time_Stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Data_Account_Class',
    @level2type=N'COLUMN', @level2name=N'User_ID';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records a short description of the analysis account class.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Data_Account_Class',
    @level2type=N'COLUMN', @level2name=N'Data_Account_Class';
GO

ALTER TABLE PowerPlan.DS_Data_Account
CREATE CONSTRAINT FK_PowerPlan_DSDataAccount_DataAccountClass_DataAccountClassID
                                            FOREIGN KEY (Data_Account_Class_ID)
                                            REFERENCES PowerPlan.Data_Account_Class(Data_Account_Class_ID)
GO