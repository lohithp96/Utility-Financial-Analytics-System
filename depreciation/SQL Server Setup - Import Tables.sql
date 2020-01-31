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

IF OBJECT_ID ( 'zTemp.CPR_Activity','U') IS NOT NULL
    DROP TABLE zTemp.CPR_Activity;
GO
IF OBJECT_ID ( 'zTemp.CPR_Ledger','U') IS NOT NULL
    DROP TABLE zTemp.CPR_Ledger;
GO
IF OBJECT_ID ( 'zTemp.Prop_Group_Prop_Unit','U') IS NOT NULL
    DROP TABLE zTemp.Prop_Group_Prop_Unit;
GO
IF OBJECT_ID ( 'zTemp.Property_Group','U') IS NOT NULL
    DROP TABLE zTemp.Property_Group;
GO
IF OBJECT_ID ( 'zTemp.Disposition_Code','U') IS NOT NULL
    DROP TABLE zTemp.Disposition_Code;
GO
IF OBJECT_ID ( 'zTemp.FERC_Activity_Code','U') IS NOT NULL
    DROP TABLE zTemp.FERC_Activity_Code;
GO

IF SCHEMA_ID('zTemp') IS NOT NULL
	DROP SCHEMA zTemp;
GO

PRINT '** Create Schemas';
GO
CREATE SCHEMA zTemp;
GO
EXEC sys.sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'Unconstrained tables used for temporary storage during import processes.', 
	 @level0type=N'SCHEMA',
	 @level0name=N'zTemp';
GO

PRINT '-- zTemp.FERC_Activity_Code';
CREATE TABLE zTemp.FERC_Activity_Code
(
    [FERC_Activity_Code]    INT                 NULL,
    [time_stamp]            DATETIME2           NULL,
    [user_id]               VARCHAR(18)         NULL,
    [description]           NVARCHAR(35)        NULL
);

PRINT '-- zTemp.Disposition_Code';
CREATE TABLE zTemp.Disposition_Code
(
    [disposition_code]      INT                 NULL,
    [time_stamp]            DATETIME2           NULL,
    [user_id]               VARCHAR(18)         NULL,
    [description]           NVARCHAR(35)        NULL,
    [long_description]      NVARCHAR(254)       NULL,
    [tax_activity_code]     INT                 NULL,
    [disposition_type]      INT                 NULL
);

PRINT '-- zTemp.Property_Group';
CREATE TABLE zTemp.Property_Group
(
    [property_group_id]     INT                 NULL,
    [time_stamp]            DATETIME2           NULL,
    [user_id]               VARCHAR(18)         NULL,
    [description]           NVARCHAR(35)        NULL,
    [long_description]      NVARCHAR(254)       NULL,
    [status_code_id]        INT                 NULL,
    [external_property_group] NVARCHAR(35)      NULL,
    [repair_unit_code_id]   INT                 NULL
);

PRINT '-- zTemp.Prop_Group_Prop_Unit';
CREATE TABLE zTemp.Prop_Group_Prop_Unit
(
    [property_group_id]     INT                 NULL,
    [property_unit_id]      INT                 NULL,
    [time_stamp]            DATETIME2           NULL,
    [user_id]               VARCHAR(18)         NULL
);

PRINT '-- zTemp.CPR_Ledger';
CREATE TABLE zTemp.CPR_Ledger
(
    [asset_id]              INT                 NULL,
    [time_stamp]            DATETIME2           NULL,
    [user_id]               VARCHAR(18)         NULL,
    [property_group_id]     INT                 NULL,
    [depr_group_id]         INT                 NULL,
    [books_schema_id]       INT                 NULL,
    [retirement_unit_id]    INT                 NULL,
    [bus_segment_id]        INT                 NULL,
    [company_id]            INT                 NULL,
    [func_class_id]         INT                 NULL,
    [utility_account_id]    INT                 NULL,
    [gl_account_id]         INT                 NULL,
    [asset_location_id]     INT                 NULL,
    [sub_account_id]        INT                 NULL,
    [work_order_number]     NVARCHAR(35)        NULL,
    [ledger_status]         INT                 NULL,
    [in_service_year]       DATE                NULL,
    [accum_quantity]        NUMERIC(22,2)       NULL,
    [accum_cost]            NUMERIC(22,2)       NULL,
    [subledger_indicator]   INT                 NULL,
    [description]           NVARCHAR(35)        NULL,
    [long_description]      NVARCHAR(254)       NULL,
    [eng_in_service_year]   DATE                NULL,
    [serial_number]         NVARCHAR(35)        NULL,
    [accum_cost_2]          NUMERIC(22,2)       NULL,
    [second_financial_cost] NUMERIC(22,2)       NULL,
    [wip_computation_id]    INT                 NULL
);

CREATE TABLE zTemp.CPR_Activity
(
    [asset_id]              INT                 NULL,
    [asset_activity_id]     INT                 NULL,
    [time_stamp]            DATETIME2           NULL,
    [user_id]               VARCHAR(18)         NULL,
    [gl_posting_mo_yr]      DATE                NULL,
    [out_of_service_mo_yr]  DATE                NULL,
    [cpr_posting_mo_yr]     DATE                NULL,
    [work_order_number]     NVARCHAR(35)        NULL,
    [user_id1]              VARCHAR(18)         NULL,
    [user_id2]              VARCHAR(18)         NULL,
    [gl_je_code]            CHAR(18)            NULL,
    [description]           NVARCHAR(35)        NULL,
    [long_description]      NVARCHAR(254)       NULL,
    [disposition_code]      INT                 NULL,
    [activity_code]         CHAR(8)             NULL,
    [activity_status]       INT                 NULL,
    [activity_quantity]     NUMERIC(22,2)       NULL,
    [activity_cost]         NUMERIC(22,2)       NULL,
    [ferc_activity_code]    INT                 NULL,
    [month_number]          INT                 NULL,
    [activity_cost_2]       NUMERIC(22,2)       NULL,
    [user_id3]              VARCHAR(18)         NULL,
    [act_second_financial_cost] NUMERIC(22,2)   NULL,
    [tax_disposition_code]  INT                 NULL,
    [tax_orig_month_number] INT                 NULL,
    [orig_asset_activity_id]    INT             NULL
);