DROP TABLE dbo.idxPlanCategories_Components_Locations;

DROP TABLE dbo.idxPlanCategories_Components;

DROP TABLE dbo.idxPlanCategories;

CREATE TABLE dbo.idxPlanCategories
(
    PlanCategoryID VARCHAR(3) PRIMARY KEY NOT NULL,
    PlanCategoryName_Long VARCHAR(25) NOT NULL,
    PlanCategoryName_Short VARCHAR(7) NOT NULL,
);

CREATE TABLE dbo.idxPlanCategories_Components
 (
	PlanCategoryID VARCHAR(3) NOT NULL,
	PlanCategory_ComponentID VARCHAR(3) PRIMARY KEY NOT NULL,
	PlanCategory_ComponentName_Long VARCHAR(25) NOT NULL,
	PlanCategory_ComponentName_Short VARCHAR(15) NOT NULL,
 );
 
 CREATE TABLE dbo.idxPlanCategories_Components_Locations
  (
	PlanCategory_ComponentID VARCHAR(3) NOT NULL,
	PlanCategory_Component_LocationID VARCHAR(3) PRIMARY KEY NOT NULL,
	PlanCategory_Component_LocationName_Long VARCHAR(25) NOT NULL,
	PlanCategory_Component_LocationName_Short VARCHAR(15) NOT NULL,
	SDGE_CostCenter CHAR(9) NOT NULL,
  );