CREATE DATABASE AdventureWorks2021

USE AdventureWorks2021

--AdventureWorks2017.Production.ProductSubcategory
CREATE TABLE dbo.ProductSubcategory (
	ProductSubcategoryID int IDENTITY(1,1) NOT NULL,
	Name nvarchar(30) NOT NULL,
	CONSTRAINT PK_ProductSubcategory_ProductSubcategoryID PRIMARY KEY (ProductSubcategoryID)
)

--AdventureWorks2017.Production.ProductModel
CREATE TABLE dbo.ProductModel (
	ProductModelID int IDENTITY(1,1) NOT NULL,
	Name nvarchar(30) NOT NULL,
	CONSTRAINT PK_ProductModel_ProductModelID PRIMARY KEY (ProductModelID)
)

--AdventureWorks2017.Production.Product
CREATE TABLE dbo.Product (
	ProductID int IDENTITY(1,1) NOT NULL,
	Name nvarchar(50) NOT NULL,
	ProductNumber nvarchar(25) NOT NULL,
	Color nvarchar(15)  NULL,
	ReorderPoint smallint NOT NULL,
	StandardCost money NOT NULL,
	ListPrice money NOT NULL,
	[Size] nvarchar(5) NULL,
	Weight decimal(8,2) NULL,
	DaysToManufacture int NOT NULL,
	ProductLine nchar(2) NULL,
	Class nchar(2) NULL,
	[Style] nchar(2) NULL,
	ProductSubcategoryID int NULL,
	ProductModelID int NULL,
	SellStartDate datetime NOT NULL,
	SellEndDate datetime NULL,
	DiscontinuedDate datetime NULL,
	CONSTRAINT PK_Product_ProductID PRIMARY KEY (ProductID),
	CONSTRAINT FK_Product_ProductSubcategory_ProductSubcategoryID FOREIGN KEY (ProductSubcategoryID) REFERENCES dbo.ProductSubcategory(ProductSubcategoryID),
	CONSTRAINT FK_Product_ProductModel_ProductModelID FOREIGN KEY (ProductModelID) REFERENCES dbo.ProductModel(ProductModelID),
)

--AdventureWorks2017.Sales.SpecialOffer
CREATE TABLE dbo.SpecialOffer (
	SpecialOfferID int IDENTITY(1,1) NOT NULL,
	Description nvarchar(255)  NOT NULL,
	DiscountPct smallmoney NOT NULL,
	[Type] nvarchar(50)  NOT NULL,
	Category nvarchar(50)  NOT NULL,
	StartDate datetime NOT NULL,
	EndDate datetime NOT NULL,
	MinQty int NOT NULL,
	MaxQty int NULL,
	CONSTRAINT PK_SpecialOffer_SpecialOfferID PRIMARY KEY (SpecialOfferID)
) 


--AdventureWorks2017.Person.CountryRegion
CREATE TABLE dbo.CountryRegion (
	CountryRegionCode nvarchar(3) NOT NULL,
	Name nvarchar(100) NOT NULL,
	CONSTRAINT PK_CountryRegion_CountryRegionCode PRIMARY KEY (CountryRegionCode)
) 

--AdventureWorks2017.Sales.SalesTerritory
CREATE TABLE dbo.SalesTerritory (
	TerritoryID int IDENTITY(1,1) NOT NULL,
	Name nvarchar(30) NOT NULL,
	CountryRegionCode nvarchar(3) NOT NULL,
	[Group] nvarchar(50) NOT NULL,
	SalesYTD money NOT NULL,
	SalesLastYear money NOT NULL,
	CostYTD money NOT NULL,
	CostLastYear money NOT NULL,
	CONSTRAINT PK_SalesTerritory_TerritoryID PRIMARY KEY (TerritoryID),
	CONSTRAINT FK_SalesTerritory_CountryRegion FOREIGN KEY (CountryRegionCode) REFERENCES dbo.CountryRegion(CountryRegionCode)
)


--AdventureWorks2017.Person.Person
CREATE TABLE dbo.Person (
	PersonID int NOT NULL,
	PersonType nchar(2) NOT NULL,
	Title nvarchar(8)  NULL,
	FirstName nvarchar(30) NOT NULL,
	MiddleName nvarchar(30) NULL,
	LastName nvarchar(30)  NOT NULL,
	Suffix nvarchar(10) NULL,
	EmailPromotion int NOT NULL,
	AdditionalContactInfo xml NULL,
	Demographics xml NULL,
	CONSTRAINT PK_Person_PersonID PRIMARY KEY (PersonID)
)

--AdventureWorks2017.Person.EmailAddress
CREATE TABLE dbo.EmailAddress (
	PersonID int NOT NULL,
	EmailAddressID int IDENTITY(1,1) NOT NULL,
	EmailAddress nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	CONSTRAINT PK_EmailAddress_PersonID_EmailAddressID PRIMARY KEY (PersonID,EmailAddressID),
	CONSTRAINT FK_EmailAddress_Person_PersonID FOREIGN KEY (PersonID) REFERENCES dbo.Person(PersonID)
)

--AdventureWorks2017.Sales.SalesPerson
CREATE TABLE dbo.SalesPerson (
	SalesPersonID int NOT NULL,
	--TerritoryID int NULL,
	SalesQuota money NULL,
	Bonus money NOT NULL,
	CommissionPct smallmoney NOT NULL,
	SalesYTD money NOT NULL,
	SalesLastYear money NOT NULL,
	CONSTRAINT PK_SalesPerson_SalesPersonID PRIMARY KEY (SalesPersonID)
	--CONSTRAINT FK_SalesPerson_SalesTerritory_TerritoryID FOREIGN KEY (TerritoryID) REFERENCES dbo.SalesTerritory(TerritoryID)
)


--AdventureWorks2017.Sales.Store
CREATE TABLE dbo.Store (
	StoreID int NOT NULL,
	Name nvarchar(100)  NOT NULL,
	SalesPersonID int NULL,
	Demographics xml NULL,
	CONSTRAINT PK_Store_StoreID PRIMARY KEY (StoreID),
	CONSTRAINT FK_Store_SalesPerson_SalesPersonID FOREIGN KEY (SalesPersonID) REFERENCES dbo.SalesPerson(SalesPersonID)
)



--AdventureWorks2017.Sales.Customer
CREATE TABLE dbo.Customer (
	CustomerID int IDENTITY(1,1) NOT NULL,
	PersonID int NULL,
	StoreID int NULL,
	--TerritoryID int NULL,
	AccountNumber varchar(10)  NOT NULL,
	CONSTRAINT PK_Customer_CustomerID PRIMARY KEY (CustomerID),
	CONSTRAINT FK_Customer_Person_PersonID FOREIGN KEY (PersonID) REFERENCES dbo.Person(PersonID),
	--CONSTRAINT FK_Customer_SalesTerritory_TerritoryID FOREIGN KEY (TerritoryID) REFERENCES dbo.SalesTerritory(TerritoryID),
	CONSTRAINT FK_Customer_Store_StoreID FOREIGN KEY (StoreID) REFERENCES dbo.Store(StoreID)
)

--AdventureWorks2017.Sales.SalesOrderHeader
CREATE TABLE dbo.SalesOrder (
	SalesOrderID int IDENTITY(1,1) NOT NULL,
	RevisionNumber tinyint NOT NULL,
	OrderDate datetime NOT NULL,
	Status tinyint NOT NULL,
	OnlineOrderFlag int NOT NULL,
	SalesOrderNumber nvarchar(25) NOT NULL,
	PurchaseOrderNumber nvarchar(25) NULL,
	AccountNumber nvarchar(25)  NULL,
	CustomerID int NOT NULL,
	--SalesPersonID int NULL,
	TerritoryID int NULL,
	SubTotal money NOT NULL,
	TaxAmt money NOT NULL,
	Freight money NOT NULL,
	TotalDue money NOT NULL,
	Comment nvarchar(128) NULL,
	CONSTRAINT PK_SalesOrder_SalesOrderID PRIMARY KEY (SalesOrderID),
	CONSTRAINT FK_SalesOrder_Customer_CustomerID FOREIGN KEY (CustomerID) REFERENCES dbo.Customer(CustomerID),
	--CONSTRAINT FK_SalesOrder_SalesPerson_SalesPersonID FOREIGN KEY (SalesPersonID) REFERENCES dbo.SalesPerson(SalesPersonID),
	CONSTRAINT FK_SalesOrder_SalesTerritory_TerritoryID FOREIGN KEY (TerritoryID) REFERENCES dbo.SalesTerritory(TerritoryID)
) 


--AdventureWorks2017.Sales.SalesOrderDetail
CREATE TABLE dbo.SalesOrderDetail (
	SalesOrderID int NOT NULL,
	SalesOrderDetailID int IDENTITY(1,1) NOT NULL,
	CarrierTrackingNumber nvarchar(25) NULL,
	OrderQty smallint NOT NULL,
	ProductID int NOT NULL,
	SpecialOfferID int NOT NULL,
	UnitPrice money NOT NULL,
	UnitPriceDiscount money NOT NULL,
	LineTotal numeric(38,6) NOT NULL,
	CONSTRAINT PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID PRIMARY KEY (SalesOrderID,SalesOrderDetailID),
	CONSTRAINT FK_SalesOrderDetail_SalesOrder_SalesOrderID FOREIGN KEY (SalesOrderID) REFERENCES dbo.SalesOrder(SalesOrderID) ON DELETE CASCADE,
	CONSTRAINT FK_SalesOrderDetail_ProductID FOREIGN KEY (ProductID) REFERENCES dbo.Product(ProductID),
	CONSTRAINT FK_SalesOrderDetail_SpecialOfferID FOREIGN KEY (SpecialOfferID) REFERENCES dbo.SpecialOffer(SpecialOfferID)
) 


 



