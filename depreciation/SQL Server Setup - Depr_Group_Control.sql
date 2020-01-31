IF OBJECT_ID ( 'PowerPlan.Depr_Group_Control','U') IS NOT NULL
    DROP TABLE PowerPlan.Depr_Group_Control;
GO

PRINT '-- PowerPlan.Depr_Group_Control';
CREATE TABLE PowerPlan.Depr_Group_Control
(
    [group_cntl_id] INT NOT NULL,
    [depr_group_id] INT NOT NULL            CONSTRAINT FK_PowerPlan_DeprGroupControl_DeprGroup_DeprGroupID
                                            FOREIGN KEY (depr_group_id)
                                            REFERENCES PowerPlan.Depr_Group(Depr_Group_ID),
    [time_stamp] datetime2 NULL,
    [user_id] varchar(18) NULL,
    [gl_account_id] INT NULL,
    [major_location_id] INT NULL,
    [utility_account_id] int null,
    [bus_segment_id] [int] NOT NULL         CONSTRAINT FK_PowerPlan_DeprGroupControl_BusSegment_BusSegmentID
                                            FOREIGN KEY (bus_segment_id)
                                            REFERENCES PowerPlan.Business_Segment(Bus_Segment_ID),
    [sub_account_id] INT NULL,
    [subledger_type_id] INT NULL,
    [book_vintage] date NULL,
    [asset_location_id] INT NULL,
    [parent_group_cntl] INT NULL,
    [location_type_id] INT NULL,
    [retirement_unit_id] INT NULL,
    [property_unit_id] INT NULL,
    [class_code_id] INT NULL,
    [cc_value] NVARCHAR(254) NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_PowerPlan_DeprGroupControl_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_PowerPlan_DeprGroupControl_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_PowerPlan_DeprGroupControl_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_PowerPlan_DeprGroupControl_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_PowerPlan_DeprGroupControl_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
    ,CONSTRAINT PK_PowerPlan_DeprGroupControl PRIMARY KEY(group_cntl_id)
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(O)  [01] [05] The Depreciation Group Control data table is the controlling mechanism for the setup of depreciation groups.  It records the relationship between a given depreciation group and the company, business segment, utility account, sub account, vintage, property unit, retirement unit, or major location, and/or asset locations that make up the group.  Sub-account, major location, vintage, property unit, retirement unit, and asset location are exception fields.  The company business segment and utility account are required and determine the default for non-specified sub-accounts, major locations, property units, and retirement units.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Depr_Group_Control';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) System-assigned identifier of a particular control within a depreciationg roup or a row on this table.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Depr_Group_Control',
    @level2type=N'COLUMN', @level2name=N'group_cntl_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a particular depreciation group.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Depr_Group_Control',
    @level2type=N'COLUMN', @level2name=N'depr_group_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Depr_Group_Control',
    @level2type=N'COLUMN', @level2name=N'time_stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Depr_Group_Control',
    @level2type=N'COLUMN', @level2name=N'user_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a unique General Ledger account.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Depr_Group_Control',
    @level2type=N'COLUMN', @level2name=N'gl_account_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a unique major location.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Depr_Group_Control',
    @level2type=N'COLUMN', @level2name=N'major_location_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) User-designated identifier of a unique utility plant account.  It can be a FERC utility plant account such as 314 or the companys own account number structure.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Depr_Group_Control',
    @level2type=N'COLUMN', @level2name=N'utility_account_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a unique business segment.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Depr_Group_Control',
    @level2type=N'COLUMN', @level2name=N'bus_segment_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) User-designated values to further detail a particular utility account.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Depr_Group_Control',
    @level2type=N'COLUMN', @level2name=N'sub_account_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a particular sub-ledger.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Depr_Group_Control',
    @level2type=N'COLUMN', @level2name=N'subledger_type_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Four digit year.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Depr_Group_Control',
    @level2type=N'COLUMN', @level2name=N'book_vintage';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a particular asset location.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Depr_Group_Control',
    @level2type=N'COLUMN', @level2name=N'asset_location_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a particular row (i.e., group_cntrl_id) on this table.  The parent group control references teh default row that is further defining.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Depr_Group_Control',
    @level2type=N'COLUMN', @level2name=N'parent_group_cntl';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a particular location type.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Depr_Group_Control',
    @level2type=N'COLUMN', @level2name=N'location_type_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'System-assigned identifier of a particular retirement unit.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Depr_Group_Control',
    @level2type=N'COLUMN', @level2name=N'retirement_unit_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'System-assigned identifier of a particular property unit.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Depr_Group_Control',
    @level2type=N'COLUMN', @level2name=N'property_unit_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'System-assigned identifier of a particular class code.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Depr_Group_Control',
    @level2type=N'COLUMN', @level2name=N'class_code_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'The value of the identifier class code that can be used to map assets to depreciation groups.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Depr_Group_Control',
    @level2type=N'COLUMN', @level2name=N'cc_value';
GO