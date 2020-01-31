SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Matthew C. Vanderbilt /00562
-- Create date: 19 SEP 2017 08:03
-- Description:	Create Derp-2002 Report Table
-- =============================================

IF OBJECT_ID ( 'PowerPlan.Report_Depr2002','U') IS NOT NULL
    DROP TABLE PowerPlan.Report_Depr2002;
GO

PRINT '-- PowerPlan.Report_Depr2002';
CREATE TABLE PowerPlan.Report_Depr2002
(
	RecordID				INT			IDENTITY(1,1)	NOT NULL,
	company					NVARCHAR(100)				NOT NULL,
	depr_group				NVARCHAR(35)				NOT NULL,
	gl_account				NVARCHAR(35)				NOT NULL,
	utility_account			NVARCHAR(35)				NOT NULL,
	accumulated_cost		NUMERIC(22,2)				NOT NULL	CONSTRAINT	DK_PowerPlan_Report_Depr2002_accumulated_cost	DEFAULT 0,
	month_number			INT							NOT NULL,
	company_id				INT							NOT NULL	CONSTRAINT	DK_PowerPlan_Report_Depr2002_company_id			DEFAULT 2100,
	depr_group_id			INT								NULL    CONSTRAINT  FK_PowerPlan_Report_Depr2002_DeprGroup_DeprGroupID
																	FOREIGN KEY (depr_group_id)
																	REFERENCES  PowerPlan.Depr_Group(Depr_Group_ID),
	utility_account_id		INT							NOT NULL,
    CreatedBy				NVARCHAR(50)				NOT NULL    CONSTRAINT  DK_PowerPlan_Report_Depr2002_CreatedBy    DEFAULT USER_NAME(),
    CreatedDate				DATETIME2(2)				NOT NULL    CONSTRAINT  DK_PowerPlan_Report_Depr2002_CreatedDate  DEFAULT SYSUTCDATETIME(),
    LastUpdatedBy			NVARCHAR(256)					NULL,
    LastUpdatedDate			DATETIME2(2)					NULL,
    rowguid					UNIQUEIDENTIFIER ROWGUIDCOL	NOT NULL    CONSTRAINT  DK_PowerPlan_Report_Depr2002_rowguid      DEFAULT NEWSEQUENTIALID (),
    versionnumber			ROWVERSION,
    ValidFrom				DATETIME2(2)				NOT NULL    CONSTRAINT  DK_PowerPlan_Report_Depr2002_ValidFrom    DEFAULT SYSUTCDATETIME(),
    ValidTo					DATETIME2(2)				NOT NULL    CONSTRAINT  DK_PowerPlan_Report_Depr2002_ValidTo      DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2)),
    CONSTRAINT PK_PowerPlan_Report_Depr2002 PRIMARY KEY (RecordID)
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Depr - 2002 - CPR Balance by Depr Group: Financial CPR balances by CPR GL Account (101,016) and utility account within depreciation group for any month or the current period.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Report_Depr2002';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'COMPANY_SETUP.DESCRIPTION: Records a short description of the company.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Report_Depr2002',
    @level2type=N'COLUMN', @level2name=N'company';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'DEPR_GROUP.DESCRIPTION: Name identifier of the depreciation group to be used by the user.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Report_Depr2002',
    @level2type=N'COLUMN', @level2name=N'depr_group';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'GL_ACCOUNT.DESCRIPTION: Records a short description of the account.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Report_Depr2002',
    @level2type=N'COLUMN', @level2name=N'gl_account';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'UTILITY_ACCOUNT.DESCRIPTION: Records a short description of the plant account.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Report_Depr2002',
    @level2type=N'COLUMN', @level2name=N'utility_account';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(FK) COMPANY_SETUP.COMPANY_ID: System-assigned identifier of a particular company.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Report_Depr2002',
    @level2type=N'COLUMN', @level2name=N'company_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(FK) DEPR_GROUP.DEPR_GROUP_ID: System-assigned identifier of a particular depreciation group.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Report_Depr2002',
    @level2type=N'COLUMN', @level2name=N'depr_group_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'UTILITY_ACCOUNT.UTILITY_ACCOUNT_ID: User-designated identifier of a unique plant account.  It can be a FERC utility plant account such as 314 or the Companys own account number structure.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Report_Depr2002',
    @level2type=N'COLUMN', @level2name=N'utility_account_id';
GO