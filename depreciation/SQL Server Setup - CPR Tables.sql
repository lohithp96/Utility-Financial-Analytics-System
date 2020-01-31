USE SONGS
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Matthew C. Vanderbilt /00562
-- Create date: 06/01/2017 09:31
-- Description:	Gets Analysis Version Index
-- =============================================

IF OBJECT_ID ( 'PowerPlan.CPR_Activity','U') IS NOT NULL
    DROP TABLE PowerPlan.CPR_Activity;
GO
IF OBJECT_ID ( 'PowerPlan.CPR_Ledger','U') IS NOT NULL
    DROP TABLE PowerPlan.CPR_Ledger;
GO
IF OBJECT_ID ( 'PowerPlan.Prop_Group_Prop_Unit','U') IS NOT NULL
    DROP TABLE PowerPlan.Prop_Group_Prop_Unit;
GO
IF OBJECT_ID ( 'PowerPlan.Property_Group','U') IS NOT NULL
    DROP TABLE PowerPlan.Property_Group;
GO
IF OBJECT_ID ( 'PowerPlan.Disposition_Code','U') IS NOT NULL
    DROP TABLE PowerPlan.Disposition_Code;
GO
IF OBJECT_ID ( 'PowerPlan.FERC_Activity_Code','U') IS NOT NULL
    DROP TABLE PowerPlan.FERC_Activity_Code;
GO

PRINT '-- PowerPlan.FERC_Activity_Code';
CREATE TABLE PowerPlan.FERC_Activity_Code
(
    [FERC_Activity_Code]      INT             NOT NULL,
    [time_stamp]            DATETIME2           NULL,
    [user_id]               VARCHAR(18)         NULL,
    [description]           NVARCHAR(35)        NULL,
    [CreatedBy]             NVARCHAR(50)    NOT NULL    CONSTRAINT  DK_PowerPlan_FERCActivityCode_CreatedBy    DEFAULT USER_NAME(),
    [CreatedDate]           DATETIME2(2)    NOT NULL    CONSTRAINT  DK_PowerPlan_FERCActivityCode_CreatedDate  DEFAULT SYSUTCDATETIME(),
    [LastUpdatedBy]         NVARCHAR(256)       NULL,
    [LastUpdatedDate]       DATETIME2(2)        NULL,
    [rowguid] UNIQUEIDENTIFIER ROWGUIDCOL   NOT NULL    CONSTRAINT  DK_PowerPlan_FERCActivityCode_rowguid      DEFAULT NEWSEQUENTIALID (),
    [versionnumber]         ROWVERSION,
    [ValidFrom]             DATETIME2(2)    NOT NULL    CONSTRAINT  DK_PowerPlan_FERCActivityCode_ValidFrom    DEFAULT SYSUTCDATETIME(),
    [ValidTo]               DATETIME2(2)    NOT NULL    CONSTRAINT  DK_PowerPlan_FERCActivityCode_ValidTo      DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2)),
    CONSTRAINT PK_PowerPlan_FERCActivityCode PRIMARY KEY ([FERC_Activity_Code])
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(F)  [01] The FERC activity code table helps classify transactions for FERC reporting.  In PowerPlan, transfers and adjustment transactions can be classified, for example, as FERC Additions or FERC Retirements.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'FERC_Activity_Code';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) Identifier of FERC transaction activity type: 1. Addition; 2. Retirement; 3. Adjustmetn; 4. Transfer.  Note: this can vary from the PowerPlan transaction type.  For example, a PowerPlan adjustment can be a FERC addition.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'FERC_Activity_Code',
    @level2type=N'COLUMN', @level2name=N'FERC_Activity_Code';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard System-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'FERC_Activity_Code',
    @level2type=N'COLUMN', @level2name=N'time_stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard System-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'FERC_Activity_Code',
    @level2type=N'COLUMN', @level2name=N'user_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records a short description of the FERC Activity code.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'FERC_Activity_Code',
    @level2type=N'COLUMN', @level2name=N'description';
GO

PRINT '-- PowerPlan.Disposition_Code';
CREATE TABLE PowerPlan.Disposition_Code
(
    [disposition_code]      INT             NOT NULL,
    [time_stamp]            DATETIME2           NULL,
    [user_id]               VARCHAR(18)         NULL,
    [description]           NVARCHAR(35)        NULL,
    [long_description]      NVARCHAR(254)       NULL,
    [tax_activity_code]     INT                 NULL,
    [disposition_type]      INT                 NULL,
    [CreatedBy]             NVARCHAR(50)    NOT NULL    CONSTRAINT  DK_PowerPlan_DispositionCode_CreatedBy    DEFAULT USER_NAME(),
    [CreatedDate]           DATETIME2(2)    NOT NULL    CONSTRAINT  DK_PowerPlan_DispositionCode_CreatedDate  DEFAULT SYSUTCDATETIME(),
    [LastUpdatedBy]         NVARCHAR(256)       NULL,
    [LastUpdatedDate]       DATETIME2(2)        NULL,
    [rowguid] UNIQUEIDENTIFIER ROWGUIDCOL   NOT NULL    CONSTRAINT  DK_PowerPlan_DispositionCode_rowguid      DEFAULT NEWSEQUENTIALID (),
    [versionnumber]         ROWVERSION,
    [ValidFrom]             DATETIME2(2)    NOT NULL    CONSTRAINT  DK_PowerPlan_DispositionCode_ValidFrom    DEFAULT SYSUTCDATETIME(),
    [ValidTo]               DATETIME2(2)    NOT NULL    CONSTRAINT  DK_PowerPlan_DispositionCode_ValidTo      DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2)),
    CONSTRAINT PK_PowerPlan_DispositionCode PRIMARY KEY ([disposition_code])
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(F) [11] The Disposition Code table identifies the various means of disposition or retirement.  (See WO Control or CPR Ledger.)',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Disposition_Code';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) Identifier of particular disposition codes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Disposition_Code',
    @level2type=N'COLUMN', @level2name=N'disposition_code';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard System-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Disposition_Code',
    @level2type=N'COLUMN', @level2name=N'time_stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard System-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Disposition_Code',
    @level2type=N'COLUMN', @level2name=N'user_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records the description of the disposition code.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Disposition_Code',
    @level2type=N'COLUMN', @level2name=N'description';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records the optional more detailed description of the disposition code.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Disposition_Code',
    @level2type=N'COLUMN', @level2name=N'long_description';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Indicating special dispositions for tax such as extra tax expense.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Disposition_Code',
    @level2type=N'COLUMN', @level2name=N'tax_activity_code';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'1 = Input BOOK or TAX used for Tax Reporting, Depreciation Study, etc.  2=Automatic TAX calculated in the CWIP tax engine and assigend directly to CPR transactions.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Disposition_Code',
    @level2type=N'COLUMN', @level2name=N'disposition_type';
GO

PRINT '-- PowerPlan.Property_Group';
CREATE TABLE PowerPlan.Property_Group
(
    [property_group_id]     INT             NOT NULL,
    [time_stamp]            DATETIME2           NULL,
    [user_id]               VARCHAR(18)         NULL,
    [description]           NVARCHAR(35)    NOT NULL,
    [long_description]      NVARCHAR(254)       NULL,
    [status_code_id]        INT             NOT NULL,
    [external_property_group] NVARCHAR(35)      NULL,
    [repair_unit_code_id]   INT                 NULL,
    [CreatedBy]             NVARCHAR(50)    NOT NULL    CONSTRAINT  DK_PowerPlan_PropertyGroup_CreatedBy    DEFAULT USER_NAME(),
    [CreatedDate]           DATETIME2(2)    NOT NULL    CONSTRAINT  DK_PowerPlan_PropertyGroup_CreatedDate  DEFAULT SYSUTCDATETIME(),
    [LastUpdatedBy]         NVARCHAR(256)       NULL,
    [LastUpdatedDate]       DATETIME2(2)        NULL,
    [rowguid] UNIQUEIDENTIFIER ROWGUIDCOL   NOT NULL    CONSTRAINT  DK_PowerPlan_PropertyGroup_rowguid      DEFAULT NEWSEQUENTIALID (),
    [versionnumber]         ROWVERSION,
    [ValidFrom]             DATETIME2(2)    NOT NULL    CONSTRAINT  DK_PowerPlan_PropertyGroup_ValidFrom    DEFAULT SYSUTCDATETIME(),
    [ValidTo]               DATETIME2(2)    NOT NULL    CONSTRAINT  DK_PowerPlan_PropertyGroup_ValidTo      DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2)),
    CONSTRAINT PK_PowerPlan_PropertyGroup PRIMARY KEY ([property_group_id])
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(S)  [01] [12] The Property Group data table maintains a list of user-defined groupings that allow the utility to summarize property units in ways that facilitate reporting and searching. For example, a utility may wish to have the property group TRANSFORMERS set up to include all the types of transformers they own and maintain. PUMPS or other general property units could also be set up as a group. The utility may also wish to break down power plants into engineering systems for easy identification by the field.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Property_Group';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) System-assigned identifier of a particular property group.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Property_Group',
    @level2type=N'COLUMN', @level2name=N'property_group_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard System-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Property_Group',
    @level2type=N'COLUMN', @level2name=N'time_stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard System-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Property_Group',
    @level2type=N'COLUMN', @level2name=N'user_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records a short description of the property group.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Property_Group',
    @level2type=N'COLUMN', @level2name=N'description';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records a detailed description of the property group.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Property_Group',
    @level2type=N'COLUMN', @level2name=N'long_description';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) Identifier of status: 1. Active; 2. Inactive',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Property_Group',
    @level2type=N'COLUMN', @level2name=N'status_code_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'External description or code for the property group.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Property_Group',
    @level2type=N'COLUMN', @level2name=N'external_property_group';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'System-assigned identifier of a tax unit of property.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Property_Group',
    @level2type=N'COLUMN', @level2name=N'repair_unit_code_id';
GO

PRINT '-- PowerPlan.Prop_Group_Prop_Unit';
CREATE TABLE PowerPlan.Prop_Group_Prop_Unit
(
    [property_group_id]     INT             NOT NULL    CONSTRAINT  FK_PowerPlan_PropGroupPropUnit_PropertyGroupID
                                                        FOREIGN KEY (property_group_id)
                                                        REFERENCES  PowerPlan.Property_Group(property_group_id),
    [property_unit_id]      INT             NOT NULL    CONSTRAINT  FK_PowerPlan_PropGroupPropUnit_PropertyUnitID
                                                        FOREIGN KEY (property_unit_id)
                                                        REFERENCES  PowerPlan.Property_Unit(Property_Unit_ID),
    [time_stamp]            DATETIME2           NULL,
    [user_id]               VARCHAR(18)         NULL,
    [CreatedBy]             NVARCHAR(50)    NOT NULL    CONSTRAINT  DK_PowerPlan_PropGroupPropUnit_CreatedBy    DEFAULT USER_NAME(),
    [CreatedDate]           DATETIME2(2)    NOT NULL    CONSTRAINT  DK_PowerPlan_PropGroupPropUnit_CreatedDate  DEFAULT SYSUTCDATETIME(),
    [LastUpdatedBy]         NVARCHAR(256)       NULL,
    [LastUpdatedDate]       DATETIME2(2)        NULL,
    [rowguid] UNIQUEIDENTIFIER ROWGUIDCOL   NOT NULL    CONSTRAINT  DK_PowerPlan_PropGroupPropUnit_rowguid      DEFAULT NEWSEQUENTIALID (),
    [versionnumber]         ROWVERSION,
    [ValidFrom]             DATETIME2(2)    NOT NULL    CONSTRAINT  DK_PowerPlan_PropGroupPropUnit_ValidFrom    DEFAULT SYSUTCDATETIME(),
    [ValidTo]               DATETIME2(2)    NOT NULL    CONSTRAINT  DK_PowerPlan_PropGroupPropUnit_ValidTo      DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2)),
    CONSTRAINT PK_PowerPlan_PropGroupPropUnit PRIMARY KEY ([property_group_id],[property_unit_id])
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(sp*)  [01] [12] The Property Group/Property Unit data table maintains the relationships between user-defined property groups and particular property units.  A property unit may be related to multiple property groups.  (However, each particular asset in the CPR is assigned to only one property group.)',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Prop_Group_Prop_Unit';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK)(fk) System-assigned identifier of a particular property group.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Prop_Group_Prop_Unit',
    @level2type=N'COLUMN', @level2name=N'property_group_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK)(fk) System-assigned identifier of a particular property unit.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Prop_Group_Prop_Unit',
    @level2type=N'COLUMN', @level2name=N'property_unit_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard System-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Prop_Group_Prop_Unit',
    @level2type=N'COLUMN', @level2name=N'time_stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard System-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Prop_Group_Prop_Unit',
    @level2type=N'COLUMN', @level2name=N'user_id';
GO

PRINT '-- PowerPlan.CPR_Ledger';
CREATE TABLE PowerPlan.CPR_Ledger
(
    [asset_id]              INT             NOT NULL,
    [time_stamp]            DATETIME2           NULL,
    [user_id]               VARCHAR(18)         NULL,
    [property_group_id]     INT             NOT NULL    CONSTRAINT  FK_PowerPlan_CPRLedger_PropertyGroup_PropertyGroupID
                                                        FOREIGN KEY (property_group_id)
                                                        REFERENCES  PowerPlan.Property_Group(property_Group_id),
    [depr_group_id]         INT                 NULL    CONSTRAINT  FK_PowerPlan_CPRLedger_DeprGroup_DeprGroupID
                                                        FOREIGN KEY (depr_group_id)
                                                        REFERENCES  PowerPlan.Depr_Group(Depr_Group_ID),
    [books_schema_id]       INT             NOT NULL,
    [retirement_unit_id]    INT             NOT NULL    CONSTRAINT  FK_CPRLedger_RetirementUnit_RetirementUnitID
                                                        FOREIGN KEY (retirement_unit_id)
                                                        REFERENCES  PowerPlan.Retirement_Unit(Retirement_Unit_ID),
    [bus_segment_id]        INT             NOT NULL    CONSTRAINT  FK_PowerPlan_CPRLedger_BusinessSegment_BusSegmentID
                                                        FOREIGN KEY (bus_segment_id)
                                                        REFERENCES  PowerPlan.Business_Segment(Bus_Segment_ID),
    [company_id]            INT             NOT NULL,
    [func_class_id]         INT             NOT NULL    CONSTRAINT  FK_PowerPlan_CPRLedger_FuncClass_FuncClassID
                                                        FOREIGN KEY (func_class_id)
                                                        REFERENCES  PowerPlan.Func_Class(Func_Class_ID),
    [utility_account_id]    INT             NOT NULL,
    [gl_account_id]         INT             NOT NULL,
    [asset_location_id]     INT             NOT NULL    CONSTRAINT  FK_PowerPlan_CPRLedger_AssetLocation_AssetLocation_ID
                                                        FOREIGN KEY (asset_location_id)
                                                        REFERENCES  PowerPlan.Asset_Location(Asset_LocatioN_ID),
    [sub_account_id]        INT             NOT NULL,
    [work_order_number]     NVARCHAR(35)        NULL,
    [ledger_status]         INT             NOT NULL,
    [in_service_year]       DATETIME2       NOT NULL,
    [accum_quantity]        NUMERIC(22,2)   NOT NULL,
    [accum_cost]            NUMERIC(22,2)   NOT NULL,
    [subledger_indicator]   INT             NOT NULL,
    [description]           NVARCHAR(35)    NOT NULL,
    [long_description]      NVARCHAR(254)       NULL,
    [eng_in_service_year]   DATETIME2       NOT NULL,
    [serial_number]         NVARCHAR(35)        NULL,
    [accum_cost_2]          NUMERIC(22,2)       NULL,
    [second_financial_cost] NUMERIC(22,2)       NULL,
    [wip_computation_id]    INT                 NULL,
    [CreatedBy]             NVARCHAR(50)    NOT NULL    CONSTRAINT  DK_PowerPlan_CPRLedger_CreatedBy    DEFAULT USER_NAME(),
    [CreatedDate]           DATETIME2(2)    NOT NULL    CONSTRAINT  DK_PowerPlan_CPRLedger_CreatedDate  DEFAULT SYSUTCDATETIME(),
    [LastUpdatedBy]         NVARCHAR(256)       NULL,
    [LastUpdatedDate]       DATETIME2(2)        NULL,
    [rowguid] UNIQUEIDENTIFIER ROWGUIDCOL   NOT NULL    CONSTRAINT  DK_PowerPlan_CPRLedger_rowguid      DEFAULT NEWSEQUENTIALID (),
    [versionnumber]         ROWVERSION,
    [ValidFrom]             DATETIME2(2)    NOT NULL    CONSTRAINT  DK_PowerPlan_CPRLedger_ValidFrom    DEFAULT SYSUTCDATETIME(),
    [ValidTo]               DATETIME2(2)    NOT NULL    CONSTRAINT  DK_PowerPlan_CPRLedger_ValidTo      DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2)),
    CONSTRAINT PK_PowerPlan_CPRLedger PRIMARY KEY ([asset_id])
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(C)   [01] [09] The CPR Ledger data table maintains record of all capitalized assets owned and operated by the utility and other affiliated companies.  The CPR Ledger record maintains location, retirement unit, in service date, and account information regarding each record.  A ledger entry can be for mass or specific property.  For each CPR ledger entry there may be multiple activity entries.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Ledger';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) System-assigned identifier of a particular asset recorded on the CPR Ledger.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Ledger',
    @level2type=N'COLUMN', @level2name=N'asset_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Ledger',
    @level2type=N'COLUMN', @level2name=N'time_stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Ledger',
    @level2type=N'COLUMN', @level2name=N'user_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fK) System-assigned identifier of a particular property group.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Ledger',
    @level2type=N'COLUMN', @level2name=N'property_group_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigend identifier of a particular depreciation group.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Ledger',
    @level2type=N'COLUMN', @level2name=N'depr_group_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a unique book schema. The default book schema is ALL, with others being dependent on the jurisdictions, tax distinguishing items, etc., the utility wishes to maintain in PowerPlan.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Ledger',
    @level2type=N'COLUMN', @level2name=N'books_schema_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a particular retirement unit.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Ledger',
    @level2type=N'COLUMN', @level2name=N'retirement_unit_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a unique business segment.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Ledger',
    @level2type=N'COLUMN', @level2name=N'bus_segment_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a particular company.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Ledger',
    @level2type=N'COLUMN', @level2name=N'company_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier for a particular functional class of plant such as Steam Production.  Functional classes should be set up for non-regulated accounts to support the drill-downs into the PowerPlan Ledgers.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Ledger',
    @level2type=N'COLUMN', @level2name=N'func_class_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) User-designated identifier of a unique utility plant account.  It can be a FERC utiltiy plant account such as 314 or the companys own account number structure.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Ledger',
    @level2type=N'COLUMN', @level2name=N'utility_account_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a particular detailed asset location.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Ledger',
    @level2type=N'COLUMN', @level2name=N'gl_account_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) User-designated value to add detail for a particular utility account.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Ledger',
    @level2type=N'COLUMN', @level2name=N'sub_account_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Companys work order associated with the asset.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Ledger',
    @level2type=N'COLUMN', @level2name=N'work_order_number';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records the STATUS of the ledger entry at a point in time.  For uncommitted conversion batches, it is the batch number.  For others it is: 1 = ACTIVE.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Ledger',
    @level2type=N'COLUMN', @level2name=N'ledger_status';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records the month and year in which the asset was first placed in 106 or 101, etc.  The in-service year, in terms of vintage, is in eng-in-service year.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Ledger',
    @level2type=N'COLUMN', @level2name=N'in_service_year';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records the accumualted quantity of assets represented by the ledger entry.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Ledger',
    @level2type=N'COLUMN', @level2name=N'accum_quantity';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records the accumualted financial cost of the remaining assets recorded with the ledger entry (including alla ctivity).  (Functional cost currency)',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Ledger',
    @level2type=N'COLUMN', @level2name=N'accum_cost';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) System-assigned identifier of a particular sub-ledger.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Ledger',
    @level2type=N'COLUMN', @level2name=N'subledger_indicator';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records a short description of the entry.  This is generated from the retirement unit',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Ledger',
    @level2type=N'COLUMN', @level2name=N'description';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records an optional detailed description of the entity.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Ledger',
    @level2type=N'COLUMN', @level2name=N'long_description';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'mot null Year the asset was first placed in service.  This is used as the vintage year.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Ledger',
    @level2type=N'COLUMN', @level2name=N'eng_in_service_year';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records the serial number associated with the asset component by the manufacturer.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Ledger',
    @level2type=N'COLUMN', @level2name=N'serial_number';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records the accumulated cost, in the total currenty, of the remaining assets recorded with the ledger entry.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Ledger',
    @level2type=N'COLUMN', @level2name=N'accum_cost_2';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Optional second financial cost.  (See accum_cost above)  E.g. If the first financial set is U.S. GAAP, the second set could be IFRS.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Ledger',
    @level2type=N'COLUMN', @level2name=N'second_financial_cost';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'This is the id of the special CWIP computation creating this record.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Ledger',
    @level2type=N'COLUMN', @level2name=N'wip_computation_id';
GO

CREATE TABLE PowerPlan.CPR_Activity
(
    [asset_id]              INT             NOT NULL    CONSTRAINT  FK_PowerPlan_CPRActivity_CPRLedger_AssetID
                                                        FOREIGN KEY (asset_id)
                                                        REFERENCES  PowerPlan.CPR_Ledger(asset_id),
    [asset_activity_id]     INT             NOT NULL,
    [time_stamp]            DATETIME2           NULL,
    [user_id]               VARCHAR(18)         NULL,
    [gl_posting_mo_yr]      DATETIME2           NULL,
    [out_of_service_mo_yr]  DATETIME2           NULL,
    [cpr_posting_mo_yr]     DATETIME2           NULL,
    [work_order_number]     NVARCHAR(35)        NULL,
    [user_id1]              VARCHAR(18)         NULL,
    [user_id2]              VARCHAR(18)         NULL,
    [gl_je_code]            CHAR(18)            NULL,
    [description]           NVARCHAR(35)    NOT NULL,
    [long_description]      NVARCHAR(254)       NULL,
    [disposition_code]      INT                 NULL    CONSTRAINT  FK_PowerPlan_CPRActivity_DispositionCode_DispositionCodeID
                                                        FOREIGN KEY (disposition_code)
                                                        REFERENCES  PowerPlan.Disposition_Code(disposition_code),
    [activity_code]         CHAR(8)         NOT NULL,
    [activity_status]       INT             NOT NULL,
    [activity_quantity]     NUMERIC(22,2)   NOT NULL,
    [activity_cost]         NUMERIC(22,2)   NOT NULL,
    [ferc_activity_code]    INT             NOT NULL    CONSTRAINT  FK_PowerPlan_CPRActivity_FERCActivityCode_FERCActivityCode
                                                        FOREIGN KEY (ferc_activity_code)
                                                        REFERENCES  PowerPlan.FERC_Activity_Code(ferc_activity_code),
    [month_number]          INT             NOT NULL,
    [activity_cost_2]       NUMERIC(22,2)       NULL,
    [user_id3]              VARCHAR(18)         NULL,
    [act_second_financial_cost] NUMERIC(22,2)   NULL,
    [tax_disposition_code]  INT                 NULL,
    [tax_orig_month_number] INT                 NULL,
    [orig_asset_activity_id]    INT             NULL,
    [CreatedBy]             NVARCHAR(50)    NOT NULL    CONSTRAINT  DK_PowerPlan_CPRActivity_CreatedBy    DEFAULT USER_NAME(),
    [CreatedDate]           DATETIME2(2)    NOT NULL    CONSTRAINT  DK_PowerPlan_CPRActivity_CreatedDate  DEFAULT SYSUTCDATETIME(),
    [LastUpdatedBy]         NVARCHAR(256)       NULL,
    [LastUpdatedDate]       DATETIME2(2)        NULL,
    [rowguid] UNIQUEIDENTIFIER ROWGUIDCOL   NOT NULL    CONSTRAINT  DK_PowerPlan_CPRActivity_rowguid      DEFAULT NEWSEQUENTIALID (),
    [versionnumber]         ROWVERSION,
    [ValidFrom]             DATETIME2(2)    NOT NULL    CONSTRAINT  DK_PowerPlan_CPRActivity_ValidFrom    DEFAULT SYSUTCDATETIME(),
    [ValidTo]               DATETIME2(2)    NOT NULL    CONSTRAINT  DK_PowerPlan_CPRActivity_ValidTo      DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2)),
    CONSTRAINT PK_PowerPlan_CPRActivity PRIMARY KEY ([asset_id],[asset_activity_id])
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(C)  [01] [05] [09] {A} The CPR Activity table records the historical record of accounting activities associated with a given ledger entry on the CPR Ledger.  This activity includes the original addition, subsequent transfers and adjustments, joint tenancy transactions, and the assets eventual retirement.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Activity';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK)(fk) System-assigned identifier of a particular asset recorded on teh CPR Ledger.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Activity',
    @level2type=N'COLUMN', @level2name=N'asset_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) System-assigned identifier of a CPR activity associated wiht a given asset on the CPR Ledger.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Activity',
    @level2type=N'COLUMN', @level2name=N'asset_activity_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned timestamp used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Activity',
    @level2type=N'COLUMN', @level2name=N'time_stamp';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Standard system-assigned user id used for audit purposes.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Activity',
    @level2type=N'COLUMN', @level2name=N'user_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records teh accounting month and year in which a given CPR activity was posted to the General Ledger.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Activity',
    @level2type=N'COLUMN', @level2name=N'gl_posting_mo_yr';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records teh month and year in which the asset being retired from the CPR Ledger entry was reported as out of service.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Activity',
    @level2type=N'COLUMN', @level2name=N'out_of_service_mo_yr';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records the month, day, and year in which the activity was physically posted on the CPR Ledger.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Activity',
    @level2type=N'COLUMN', @level2name=N'cpr_posting_mo_yr';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'The work order number or identifier associated with the activity.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Activity',
    @level2type=N'COLUMN', @level2name=N'work_order_number';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'System-assigned user id associated with the activity being recorded.  An example would be the user id assocaited with the analyst who generated the activity entry.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Activity',
    @level2type=N'COLUMN', @level2name=N'user_id1';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'System-assigned user id assocaited with the activity being recorded.  An example would be the user id assocaited with the supervisor who poasted the activity entry.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Activity',
    @level2type=N'COLUMN', @level2name=N'user_id2';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records the General Ledger transaction code used to generate a General Ledger journal entry.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Activity',
    @level2type=N'COLUMN', @level2name=N'gl_je_code';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records a short description of the transaction.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Activity',
    @level2type=N'COLUMN', @level2name=N'description';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records an optional detailed description of the entity.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Activity',
    @level2type=N'COLUMN', @level2name=N'long_description';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) The disposition code is obtained from the work order account retiremetn type or from the CPR; it can be used for reporting Depreciation Studies (See Disposition Code Table), or tax.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Activity',
    @level2type=N'COLUMN', @level2name=N'disposition_code';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records teh type of activity the entry represents.  Possible types would include additions, transfers in, transfers out, joint tenancy adjustments, and retirements of various sorts.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Activity',
    @level2type=N'COLUMN', @level2name=N'activity_code';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'For all non-transfers, it is the pend_trans_id to provide trace back to the pending archive.  On a transfer to UTRT this is the asset_id of the transfer from.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Activity',
    @level2type=N'COLUMN', @level2name=N'activity_status';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records teh quantity of assets associated with the given CPR Ledger entry being affected by the activity entry.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Activity',
    @level2type=N'COLUMN', @level2name=N'activity_quantity';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records the total cost of the activity entry as it relates to the given CPR Ledger (this is the total of the first financial bases of the activity, in the fucntional currency.)',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Activity',
    @level2type=N'COLUMN', @level2name=N'activity_cost';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) Identifier of FERC transaction activity type: 1. Addition; 2. Retiremetn; 3. Adjustment; 4. Transfer.  Note: this can vary from teh PowerPlan transaction type.  For example, a PowerPlan adjustment can be a FERC addition.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Activity',
    @level2type=N'COLUMN', @level2name=N'ferc_activity_code';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'The integer representation of the gl_posting_mo_yr (the accounting date of the transaction), e.g., May 2004 is 200405.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Activity',
    @level2type=N'COLUMN', @level2name=N'month_number';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Records the total cost of the activity entry in the local currency, if used.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Activity',
    @level2type=N'COLUMN', @level2name=N'activity_cost_2';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'The user who approved the pending transaction.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Activity',
    @level2type=N'COLUMN', @level2name=N'user_id3';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Optional second financial cost.  (See activity_cost above.)  E.g. if the first financial set is U.S. GAAP, the second set could be IFRS.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Activity',
    @level2type=N'COLUMN', @level2name=N'act_second_financial_cost';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'The tax disposition code, such as tax units of property repairs, is filled in directly on the CPR from the CWIP tax engine (see Disposition Code Table).',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Activity',
    @level2type=N'COLUMN', @level2name=N'tax_disposition_code';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Month number of the original asset activity that the tax expense calculation was based on.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Activity',
    @level2type=N'COLUMN', @level2name=N'tax_orig_month_number';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'System-assigned identifier of the original asset activity that the tax expense calculation was based on.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'CPR_Activity',
    @level2type=N'COLUMN', @level2name=N'orig_asset_activity_id';
GO