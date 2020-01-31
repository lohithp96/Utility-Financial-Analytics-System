USE [SONGS];
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

/***** DELETE EXISTING OBJECTS ******/
PRINT '/***** DELETE EXISTING OBJECTS ******/';
GO
-- DELETE PROCEDURES
IF OBJECT_ID ( 'SAP.getEmployee', 'P' ) IS NOT NULL
	DROP PROCEDURE SAP.getEmployee;
GO

-- DELETE TABLES
IF OBJECT_ID('SAP.EmployeeAuthorization') IS NOT NULL
	DROP TABLE SAP.EmployeeAuthorization;
GO
IF OBJECT_ID('SAP.Employee') IS NOT NULL
	DROP TABLE SAP.Employee;
GO

-- DELETE SCHEMAS
IF SCHEMA_ID('SAP') IS NULL
	CREATE SCHEMA SAP;
GO

/** --	SAP.Employee
		{MUST BE AFTER SAP.CostCenter}
		{MUST BE BEFORE WOA.WorkOrder}**/
PRINT '-- SAP.Employee';
GO
CREATE TABLE SAP.Employee
(
	EmployeeID [int] NOT NULL PRIMARY KEY,
	EmployeeIDString AS (FORMAT(EmployeeID,'00000')),
	SAPUserName [nvarchar](15) NULL,
	WINUserName [nvarchar](15) NULL,
	SQLUserName [nvarchar](50) NULL,
	OrganizationNode [hierarchyid] NULL,
	OrganizationLevel AS (OrganizationNode.GetLevel()),
	ManagerID [int] REFERENCES SAP.Employee(EmployeeID),
	CostCenterID [int] NULL	CONSTRAINT FK_SAPEmployee_CostCenterID_CostCenter
								FOREIGN KEY (CostCenterID)
								REFERENCES SAP.CostCenter(CostCenterID),
	JobTitle [nvarchar](50) NOT NULL,
	EmployeeName_First [nvarchar](50) NULL,
	EmployeeName_Last [nvarchar](50) NULL,
	EmailAddress [nvarchar](100) NULL,
	PhoneNumber [nchar](10) NULL,
	Accountant [bit] NOT NULL DEFAULT 0,
	Administrator [bit] NOT NULL DEFAULT 0,
	CreatedBy AS USER_NAME(),
	CreatedDate AS SYSUTCDATETIME(),
	LastUpdatedBy [nvarchar](256) NULL,
	LastUpdatedDate datetime2(2) NULL,
	rowguid [uniqueidentifier] ROWGUIDCOL NOT NULL DEFAULT NEWSEQUENTIALID (),
	versionnumber rowversion,
	ValidFrom datetime2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
	ValidTo datetime2(2) NOT NULL DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
GO

/** --	SAP.EmployeeAuthorization
		{MUST BE AFTER SAP.Employee}**/
PRINT '-- SAP.EmployeeAuthorization';
GO
CREATE TABLE SAP.EmployeeAuthorization
(
	EmployeeAuthorizationID [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	EmployeeID [int] NOT NULL	CONSTRAINT FK_SAPEmployeeAuthorization_EmployeeID_Employee
								FOREIGN KEY (EmployeeID)
								REFERENCES SAP.Employee(EmployeeID),
	ApprovalLevelID [nvarchar](2) NULL,
	DelegatingManagerID [int] NULL	CONSTRAINT FK_SAPEmployeeAuthorization_DelegatingManagerID_Employee
										FOREIGN KEY (DelegatingManagerID)
										REFERENCES SAP.Employee(EmployeeID),
	Delegated_Category_1 [money] NOT NULL DEFAULT 0,
	Delegated_Category_2 [money] NOT NULL DEFAULT 0,
	Delegated_Category_3_PurchReq [money] NOT NULL DEFAULT 0,
	Delegated_Category_4A_POInv [money] NOT NULL DEFAULT 0,
	Delegated_Category_4B_NonPOInv [money] NOT NULL DEFAULT 0,
	Delegated_Category_5_EmpReimb [money] NOT NULL DEFAULT 0,
	Delegated_Category_6_ProCard [money] NOT NULL DEFAULT 0,
	CreatedBy AS USER_NAME(),
	CreatedDate AS SYSUTCDATETIME(),
	LastUpdatedBy [nvarchar](256) NULL,
	LastUpdatedDate datetime2(2) NULL,
	rowguid [uniqueidentifier] ROWGUIDCOL NOT NULL DEFAULT NEWSEQUENTIALID (),
	versionnumber rowversion,
	ValidFrom datetime2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
	ValidTo datetime2(2) NOT NULL DEFAULT CAST('9999-12-31 12:00:00' AS datetime2(2))
);
GO

/****** STORED PROCEDURES ******/
PRINT '/****** STORED PROCEDURES ******/';
GO
PRINT '-- SAP.getEmployee';
GO
CREATE Procedure	SAP.getEmployee
					(
						@InputWINUserName [nvarchar](15) = "",
						@InputEmployeeIDString [nvarchar](5) = "",
						@EmployeeID [int] OUTPUT,
						@EmployeeIDString [nchar](5) OUTPUT,
						@SAPUserName [nvarchar](15) OUTPUT,
						@WINUserName [nvarchar](15) OUTPUT,
						@SQLUserName [nvarchar](50) Output,
						@ManagerID [int] OUTPUT,
						@CostCenterID [int] OUTPUT,
						@JobTitle [nvarchar](50) OUTPUT,
						@EmployeeName_First [nvarchar](50) OUTPUT,
						@EmployeeName_Last [nvarchar](50) OUTPUT,
						@EmailAddress [nvarchar](100) OUTPUT,
						@PhoneNumber [nchar](10) OUTPUT,
						@Accountant [bit] OUTPUT,
						@Administrator [bit] OUTPUT,
					)
					AS
					BEGIN
						SET NOCOUNT ON
						SELECT	TOP 1 
								@EmployeeID = EmployeeID,
								@EmployeeIDString = EmployeeIDString,
								@SAPUserName = SAPUserName,
								@WINUserName = WINUserName,
								@SQLUserName = SQLUserName,
								@ManagerID = ManagerID,
								@CostCenterID = CostCenterID,
								@JobTitle = JobTitle,
								@EmployeeName_First = EmployeeName_First,
								@EmployeeName_Last = EmployeeName_Last,
								@EmailAddress = EmailAddress,
								@PhoneNumber = PhoneNumber,
								@Accountant = Accountant,
								@Administrator = Administrator
						FROM	SAP.Employee
						WHERE	SAP.WINUserName = @InputWINUserName OR 
								SAP.EmployeeIDString = @InputEmployeeIDString
					END;
GO