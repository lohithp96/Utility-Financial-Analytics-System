/***************************************************************************************
Name      : Depreciation Accounting - SQL Database Object Table Setup
License   : Copyright (C) 2017 San Diego Gas & Electric company
            All Rights Reserved
Created   : 05/09/2017 10:51 Matthew C. Vanderbilt /00562 (START)
            05/09/2017 11:14 Matthew C. Vanderbilt /00562 (END)
****************************************************************************************
ATTRIBUTIONS:
- none
****************************************************************************************
DESCRIPTION / NOTES:
- none
****************************************************************************************
PREREQUISITES:
- none
***************************************************************************************/

/*  GENERAL CONFIGURATION AND SETUP ***************************************************/
PRINT '** General Configuration & Setup';
/*  Change database context to the specified database in SQL Server. 
    https://docs.microsoft.com/en-us/sql/t-sql/language-elements/use-transact-sql */
USE [SONGS];
GO

/*  Specify ISO compliant behavior of the Equals (=) and Not Equal To (<>) comparison
    operators when they are used with null values.
    https://docs.microsoft.com/en-us/sql/t-sql/statements/set-ansi-nulls-transact-sql
    -   When SET ANSI_NULLS is ON, a SELECT statement that uses WHERE column_name = NULL 
        returns zero rows even if there are null values in column_name. A SELECT 
        statement that uses WHERE column_name <> NULL returns zero rows even if there 
        are nonnull values in column_name. 
    -   When SET ANSI_NULLS is OFF, the Equals (=) and Not Equal To (<>) comparison 
        operators do not follow the ISO standard. A SELECT statement that uses WHERE 
        column_name = NULL returns the rows that have null values in column_name. A 
        SELECT statement that uses WHERE column_name <> NULL returns the rows that 
        have nonnull values in the column. Also, a SELECT statement that uses WHERE 
        column_name <> XYZ_value returns all rows that are not XYZ_value and that are 
        not NULL. */
SET ANSI_NULLS ON;
GO

/*  Causes SQL Server to follow  ISO rules regarding quotation mark identifiers &
    literal strings.
    https://docs.microsoft.com/en-us/sql/t-sql/statements/set-quoted-identifier-transact-sql
    -   When SET QUOTED_IDENTIFIER is ON, identifiers can be delimited by double 
        quotation marks, and literals must be delimited by single quotation marks. When 
        SET QUOTED_IDENTIFIER is OFF, identifiers cannot be quoted and must follow all 
        Transact-SQL rules for identifiers. */
SET QUOTED_IDENTIFIER ON;
GO

/*  SETUP ERROR HANDLING (from AdventureWorks2012) ************************************/
PRINT '** Setup Error Handling';
GO

PRINT '-- dbo.GetErrorInfo';
IF OBJECT_ID ( 'dbo.GetErrorInfo', 'P' ) IS NOT NULL
	DROP PROCEDURE dbo.GetErrorInfo;
GO
CREATE PROCEDURE dbo.GetErrorInfo
AS
SELECT
    ERROR_NUMBER() AS ErrorNumber
    ,ERROR_SEVERITY() AS ErrorSeverity
    ,ERROR_STATE() AS ErrorState
    ,ERROR_PROCEDURE() AS ErrorProcedure
    ,ERROR_LINE() AS ErrorLine
    ,ERROR_MESSAGE() AS ErrorMessage;
GO

-- uspPrintError prints error information about the error that caused 
-- execution to jump to the CATCH block of a TRY...CATCH construct. 
-- Should be executed from within the scope of a CATCH block otherwise 
-- it will return without printing any error information.
PRINT '-- dbo.PrintError';
IF OBJECT_ID ( 'dbo.PrintError', 'P' ) IS NOT NULL
	DROP PROCEDURE dbo.PrintError;
GO
CREATE PROCEDURE dbo.PrintError
AS
BEGIN
    SET NOCOUNT ON;

    -- Print error information. 
    PRINT 'Error ' + CONVERT(varchar(50), ERROR_NUMBER()) +
          ', Severity ' + CONVERT(varchar(5), ERROR_SEVERITY()) +
          ', State ' + CONVERT(varchar(5), ERROR_STATE()) + 
          ', Procedure ' + ISNULL(ERROR_PROCEDURE(), '-') + 
          ', Line ' + CONVERT(varchar(5), ERROR_LINE());
    PRINT ERROR_MESSAGE();
END;
GO

-- uspLogError logs error information in the ErrorLog table about the 
-- error that caused execution to jump to the CATCH block of a 
-- TRY...CATCH construct. This should be executed from within the scope 
-- of a CATCH block otherwise it will return without inserting error 
-- information.
PRINT '-- dbo.LogError'; 
IF OBJECT_ID ( 'dbo.LogError', 'P' ) IS NOT NULL
	DROP PROCEDURE dbo.LogError;
GO
CREATE PROCEDURE dbo.LogError
	(
		@ErrorLogID [int] = 0 OUTPUT	-- contains the ErrorLogID of the row inserted
	)									-- by uspLogError in the ErrorLog table
AS
BEGIN
    SET NOCOUNT ON;

    -- Output parameter value of 0 indicates that error 
    -- information was not logged
    SET @ErrorLogID = 0;

    BEGIN TRY
        -- Return if there is no error information to log
        IF ERROR_NUMBER() IS NULL
            RETURN;

        -- Return if inside an uncommittable transaction.
        -- Data insertion/modification is not allowed when 
        -- a transaction is in an uncommittable state.
        IF XACT_STATE() = -1
        BEGIN
            PRINT 'Cannot log error since the current transaction is in an uncommittable state. ' 
                + 'Rollback the transaction before executing uspLogError in order to successfully log error information.';
            RETURN;
        END

        INSERT [dbo].[ErrorLog] 
            (
            [UserName], 
            [ErrorNumber], 
            [ErrorSeverity], 
            [ErrorState], 
            [ErrorProcedure], 
            [ErrorLine], 
            [ErrorMessage]
            ) 
        VALUES 
            (
            CONVERT(sysname, CURRENT_USER), 
            ERROR_NUMBER(),
            ERROR_SEVERITY(),
            ERROR_STATE(),
            ERROR_PROCEDURE(),
            ERROR_LINE(),
            ERROR_MESSAGE()
            );

        -- Pass back the ErrorLogID of the row inserted
        SET @ErrorLogID = @@IDENTITY;
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred in stored procedure uspLogError: ';
        EXECUTE [dbo].[PrintError];
        RETURN -1;
    END CATCH
END;
GO

/*  DELETE EXISTING OBJECTS ***********************************************************/
PRINT '** Delete Existing Objects';
GO

PRINT '-- Delete Tables';
GO
IF OBJECT_ID ( 'sys.objects_log','U') IS NOT NULL
    DROP TABLE sys.objects_log;
GO

PRINT '-- Delete Schemas';
GO
PRINT '-- -- _sys';
IF SCHEMA_ID('_sys') IS NOT NULL
	DROP SCHEMA _sys;
GO

/*  CREATE SCHEMAS ********************************************************************/
PRINT '** Create Schemas';
GO
CREATE SCHEMA _sys;
GO
EXEC sys.sp_addextendedproperty 
	 @name=N'MS_Description', 
	 @value=N'Contains custom system-level objects.', 
	 @level0type=N'SCHEMA',
	 @level0name=N'_sys';
GO

/*  CREATE TABLES *********************************************************************/
PRINT '** Create Tables';
GO

PRINT '-- _sys.objects_log';
CREATE TABLE _sys.objects_log
(
    [objects_log_id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY
    ,[type] char(1) NOT NULL
    ,[object_id] [int] NOT NULL
	,[source_file] [nvarchar](MAX) NULL
    ,[source_time_stamp] datetime2 NOT NULL
    ,[CreatedBy] [nvarchar](50) NOT NULL    CONSTRAINT DK_sys_objectslog_CreatedBy   DEFAULT USER_NAME()
    ,[CreatedDate] [datetime2](2) NOT NULL  CONSTRAINT DK_sys_objectslog_CreatedDate DEFAULT SYSUTCDATETIME()
    ,[LastUpdatedBy] [nvarchar](256) NULL
    ,[LastUpdatedDate] datetime2(2) NULL
    ,[rowguid] [uniqueidentifier] ROWGUIDCOL NOT NULL   CONSTRAINT DK_sys_objectslog_rowguid DEFAULT NEWSEQUENTIALID ()
    ,[versionnumber] rowversion
    ,[ValidFrom] datetime2(2) NOT NULL      CONSTRAINT DK_sys_objectslog_ValidFrom   DEFAULT SYSUTCDATETIME()
    ,[ValidTo] datetime2(2) NOT NULL        CONSTRAINT DK_sys_objectslog_ValidTo DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'The objects_log table is for recording each major activity performed on the table and identifying source files and updated-through dates.',
    @level0type=N'SCHEMA', @level0name=N'_sys',
    @level1type=N'TABLE',  @level1name=N'objects_log';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(PK) System-assigned identifier of a row on this table.',
    @level0type=N'SCHEMA', @level0name=N'_sys',
    @level1type=N'TABLE',  @level1name=N'objects_log',
    @level2type=N'COLUMN', @level2name=N'objects_log_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Type is the type of modification: N (new), U (update), and D (delete).',
    @level0type=N'SCHEMA', @level0name=N'_sys',
    @level1type=N'TABLE',  @level1name=N'objects_log',
    @level2type=N'COLUMN', @level2name=N'type';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'(fk) Object identification number. Is unique within a database.',
    @level0type=N'SCHEMA', @level0name=N'_sys',
    @level1type=N'TABLE',  @level1name=N'objects_log',
    @level2type=N'COLUMN', @level2name=N'object_id';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Optional full path for source-file location.',
    @level0type=N'SCHEMA', @level0name=N'_sys',
    @level1type=N'TABLE',  @level1name=N'objects_log',
    @level2type=N'COLUMN', @level2name=N'source_file';
GO
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Valid-as-of or valid-through date/time stamp of source-file data.',
    @level0type=N'SCHEMA', @level0name=N'_sys',
    @level1type=N'TABLE',  @level1name=N'objects_log',
    @level2type=N'COLUMN', @level2name=N'source_time_stamp';
GO