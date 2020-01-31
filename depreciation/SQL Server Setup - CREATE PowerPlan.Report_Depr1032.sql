SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Matthew C. Vanderbilt /00562
-- Create date: 04 OCT 2017 14:57
-- Description:	Create Derp-1032 Report Table
-- =============================================

IF OBJECT_ID ( 'PowerPlan.Report_Depr1032','U') IS NOT NULL
    DROP TABLE PowerPlan.Report_Depr1032;
GO

PRINT '-- PowerPlan.Report_Depr1032';
CREATE TABLE PowerPlan.Report_Depr1032
(
	RecordID				INT			IDENTITY(1,1)	NOT NULL,
    company_id              INT                         NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_CompanyID               DEFAULT 2100,
    set_of_books_id         INT                         NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_SetOfBooksID            DEFAULT 1,
    depr_group_id			INT							NOT NULL    CONSTRAINT  FK_PowerPlan_ReportDepr1032_DeprGroup_DeprGroupID
																	FOREIGN KEY (depr_group_id)
																	REFERENCES  PowerPlan.Depr_Group(Depr_Group_ID),
	gl_post_mo_yr           DATETIME2(2)                    NULL,
    start_month             DATETIME2(2)                    NULL,
    rate                    DECIMAL(22,8)               NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_Rate                    DEFAULT 0,
    salvage_rate            DECIMAL(22,8)               NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_SalvageRate             DEFAULT 0,
    cor_rate                DECIMAL(22,8)               NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_CORRate                 DEFAULT 0,
    depreciation_base       NUMERIC(22,2)               NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_DepreciationBase        DEFAULT 0,
    salvage_base            NUMERIC(22,2)               NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_SalvageBase             DEFAULT 0,
    ending_balance          NUMERIC(22,2)               NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_EndingBalance           DEFAULT 0,
    ending_reserve          NUMERIC(22,2)               NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_EndingReserve           DEFAULT 0,
    depreciation_expense    NUMERIC(22,2)               NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_DepreciationExpense     DEFAULT 0,
    depr_exp_adjust         NUMERIC(22,2)               NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_DeprExpAdjust           DEFAULT 0,
    depr_exp_alloc_adjust   NUMERIC(22,2)               NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_DeprExpAllocAdjust      DEFAULT 0,
    cost_of_removal         NUMERIC(22,2)               NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_CostOfRemoval           DEFAULT 0,
    retirements             NUMERIC(22,2)               NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_Retirements             DEFAULT 0,
    salvage_returns         NUMERIC(22,2)               NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_SalvageReturns          DEFAULT 0,
    salvage_cash            NUMERIC(22,2)               NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_SalvageCash             DEFAULT 0,
    reserve_credits         NUMERIC(22,2)               NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_ReserveCredits          DEFAULT 0,
    reserve_adjustments     NUMERIC(22,2)               NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_ReserveAdjustments      DEFAULT 0,
    reserve_tran_in         NUMERIC(22,2)               NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_ReserveTranIn           DEFAULT 0,
    reserve_train_out       NUMERIC(22,2)               NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_ReserveTranOut          DEFAULT 0,
    gain_loss               NUMERIC(22,2)               NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_GainLoss                DEFAULT 0,
    salvage_expense         NUMERIC(22,2)               NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_SalvageExpense          DEFAULT 0,
    salvage_exp_adjust      NUMERIC(22,2)               NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_SalvageExpAdjust        DEFAULT 0,
    salvage_exp_alloc_adj   NUMERIC(22,2)               NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_SalvageExpAllocAdj      DEFAULT 0,
    current_net_salv_amort  NUMERIC(22,2)               NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_CurrentNetSalvAmort     DEFAULT 0,
    cor_beg_reserve         NUMERIC(22,2)               NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_CORBegReserve           DEFAULT 0,
    cor_expense             NUMERIC(22,2)               NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_CORExpense              DEFAULT 0,
    cor_exp_adjust          NUMERIC(22,2)               NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_CORExpAdjust            DEFAULT 0,
    cor_res_tran_in         NUMERIC(22,2)               NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_CORResTranIn            DEFAULT 0,
    cor_res_tran_out        NUMERIC(22,2)               NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_CORResTranOut           DEFAULT 0,
    cor_res_adjust          NUMERIC(22,2)               NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_CORResAdjust            DEFAULT 0,
    cor_end_reserve         NUMERIC(22,2)               NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_COREndReserve           DEFAULT 0,
    cor_exp_alloc_adjust    NUMERIC(22,2)               NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_CORExpAllocAdjust       DEFAULT 0,
    CreatedBy				NVARCHAR(50)				NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_CreatedBy               DEFAULT USER_NAME(),
    CreatedDate				DATETIME2(2)				NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_CreatedDate             DEFAULT SYSUTCDATETIME(),
    LastUpdatedBy			NVARCHAR(256)					NULL,
    LastUpdatedDate			DATETIME2(2)					NULL,
    rowguid					UNIQUEIDENTIFIER ROWGUIDCOL	NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_rowguid                 DEFAULT NEWSEQUENTIALID (),
    versionnumber			ROWVERSION,
    ValidFrom				DATETIME2(2)				NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_ValidFrom               DEFAULT SYSUTCDATETIME(),
    ValidTo					DATETIME2(2)				NOT NULL    CONSTRAINT  DK_PowerPlan_ReportDepr1032_ValidTo                 DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2)),
    CONSTRAINT PK_PowerPlan_Report_Depr1032 PRIMARY KEY (RecordID)
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Depr - 1032 - Depreciation expense, plant balance, reserve, etc. for a month by company and set of books.  Each depreciation group is sorted by depreciation group within depr summary 2.  Amort of COR and Salvage is in other reserve transactions.',
    @level0type=N'SCHEMA', @level0name=N'PowerPlan',
    @level1type=N'TABLE',  @level1name=N'Report_Depr1032';
GO