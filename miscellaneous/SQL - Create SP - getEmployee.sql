USE [SONGS];
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

/****** STORED PROCEDURES ******/
PRINT '/****** STORED PROCEDURES ******/';
GO
PRINT '-- SAP.getEmployee';
GO
CREATE Procedure	SAP.getEmployee
					(
						@InputWINUserName [nvarchar](15) = '',
						@InputEmployeeIDString [nvarchar](5) = '',
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
						@Administrator [bit] OUTPUT
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
						WHERE	SAP.Employee.WINUserName = @InputWINUserName OR 
								SAP.Employee.EmployeeIDString = @InputEmployeeIDString
					END;
GO