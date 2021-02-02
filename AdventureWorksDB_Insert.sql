USE AdventureWorks2021

SET IDENTITY_INSERT dbo.ProductSubcategory OFF
INSERT INTO dbo.ProductSubcategory(
	ProductSubcategoryID,
	Name
)
SELECT ProductSubcategoryID , Name
FROM AdventureWorks2017.Production.ProductSubcategory



SET IDENTITY_INSERT dbo.ProductModel OFF
INSERT INTO dbo.ProductModel(
	ProductModelID, 
	Name
)
SELECT ProductModelID, Name
FROM AdventureWorks2017.Production.ProductModel



  
SET IDENTITY_INSERT dbo.Product OFF
INSERT INTO dbo.Product(
	ProductID,
	Name,
	ProductNumber,
	Color,
	ReorderPoint,
	StandardCost,
	ListPrice,
	[Size],
	Weight,
	DaysToManufacture,
	ProductLine,
	Class,
	[Style],
	ProductSubcategoryID,
	ProductModelID,
	SellStartDate,
	SellEndDate,
	DiscontinuedDate
)
SELECT
	ProductID,
	Name,
	ProductNumber,
	Color,
	ReorderPoint,
	StandardCost,
	ListPrice,
	[Size],
	Weight,
	DaysToManufacture,
	ProductLine,
	Class,
	[Style],
	ProductSubcategoryID,
	ProductModelID,
	SellStartDate,
	SellEndDate,
	DiscontinuedDate
FROM AdventureWorks2017.Production.Product




SET IDENTITY_INSERT dbo.SpecialOffer OFF
INSERT INTO dbo.SpecialOffer(
	SpecialOfferID,
	Description,
	DiscountPct,
	[Type],
	Category,
	StartDate,
	EndDate,
	MinQty,
	MaxQty 
)
SELECT 
	SpecialOfferID,
	Description,
	DiscountPct,
	[Type],
	Category,
	StartDate,
	EndDate,
	MinQty,
	MaxQty 
FROM AdventureWorks2017.Sales.SpecialOffer





SET IDENTITY_INSERT dbo.CountryRegion OFF
INSERT INTO dbo.CountryRegion(
	CountryRegionCode,
	Name 
)
SELECT 
	CountryRegionCode,
	Name 
FROM AdventureWorks2017.Person.CountryRegion




SET IDENTITY_INSERT dbo.SalesTerritory OFF
INSERT INTO dbo.SalesTerritory(
	TerritoryID,
	Name,
	CountryRegionCode,
	[Group],
	SalesYTD,
	SalesLastYear,
	CostYTD,
	CostLastYear
)
SELECT 
	TerritoryID,
	Name,
	CountryRegionCode,
	[Group],
	SalesYTD,
	SalesLastYear,
	CostYTD,
	CostLastYear 
FROM AdventureWorks2017.Sales.SalesTerritory




SET IDENTITY_INSERT dbo.Person OFF
INSERT INTO dbo.Person(
	PersonID,
	PersonType,
	Title,
	FirstName,
	MiddleName,
	LastName,
	Suffix,
	EmailPromotion,
	AdditionalContactInfo,
	Demographics
)
SELECT 
	BusinessEntityID,
	PersonType,
	Title,
	FirstName,
	MiddleName,
	LastName,
	Suffix,
	EmailPromotion,
	AdditionalContactInfo,
	Demographics
FROM AdventureWorks2017.Person.Person




SET IDENTITY_INSERT dbo.EmailAddress OFF
INSERT INTO dbo.EmailAddress(
	PersonID,
	EmailAddressID,
	EmailAddress
)
SELECT 
	BusinessEntityID,
	EmailAddressID,
	EmailAddress
FROM AdventureWorks2017.Person.EmailAddress





SET IDENTITY_INSERT dbo.SalesPerson ON
INSERT INTO dbo.SalesPerson(
	SalesPersonID,
	SalesQuota,
	Bonus,
	CommissionPct,
	SalesYTD,
	SalesLastYear
)
SELECT 
	BusinessEntityID,
	SalesQuota,
	Bonus,
	CommissionPct,
	SalesYTD,
	SalesLastYear
FROM AdventureWorks2017.Sales.SalesPerson




SET IDENTITY_INSERT dbo.Store ON
INSERT INTO dbo.Store(
	StoreID,
	Name,
	SalesPersonID,
	Demographics
)
SELECT 
	BusinessEntityID,
	Name,
	SalesPersonID,
	Demographics
FROM AdventureWorks2017.Sales.Store




SET IDENTITY_INSERT dbo.Customer OFF
INSERT INTO dbo.Customer(
	CustomerID,
	PersonID,
	StoreID,
	AccountNumber
)
SELECT 
	CustomerID,
	PersonID,
	StoreID,
	AccountNumber
FROM AdventureWorks2017.Sales.Customer




SET IDENTITY_INSERT dbo.SalesOrder OFF
INSERT INTO dbo.SalesOrder(
	SalesOrderID,
	RevisionNumber,
	OrderDate,
	Status,
	OnlineOrderFlag,
	SalesOrderNumber,
	PurchaseOrderNumber,
	AccountNumber,
	CustomerID,
	TerritoryID ,
	SubTotal,
	TaxAmt,
	Freight,
	TotalDue,
	Comment
)
SELECT 
	SalesOrderID,
	RevisionNumber,
	OrderDate,
	Status,
	OnlineOrderFlag,
	SalesOrderNumber,
	PurchaseOrderNumber,
	AccountNumber,
	CustomerID,
	TerritoryID ,
	SubTotal,
	TaxAmt,
	Freight,
	TotalDue,
	Comment
FROM AdventureWorks2017.Sales.SalesOrderHeader



SET IDENTITY_INSERT dbo.SalesOrderDetail OFF
INSERT INTO dbo.SalesOrderDetail(
	SalesOrderID,
	SalesOrderDetailID,
	CarrierTrackingNumber,
	OrderQty,
	ProductID,
	SpecialOfferID,
	UnitPrice,
	UnitPriceDiscount,
	LineTotal
)
SELECT 
	SalesOrderID,
	SalesOrderDetailID,
	CarrierTrackingNumber,
	OrderQty,
	ProductID,
	SpecialOfferID,
	UnitPrice,
	UnitPriceDiscount,
	LineTotal
FROM AdventureWorks2017.Sales.SalesOrderDetail







