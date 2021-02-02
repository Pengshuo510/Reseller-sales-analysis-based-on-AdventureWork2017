CREATE DATABASE AW2021_DW;
GO

USE AW2021_DW;
GO


CREATE TABLE dbo.DimDate (
	DateKey INT NOT NULL,
	DateValue DATE NOT NULL,
	CYear SMALLINT NOT NULL,
	CMonth TINYINT NOT NULL,
	DayNo TINYINT NOT NULL,
	CQtr TINYINT NOT NULL,
	StartOfMonth DATE NOT NULL,
	EndOfMonth DATE NOT NULL,
	MonthName VARCHAR(9) NOT NULL,
	DayOfWeekName VARCHAR(9) NOT NULL,
	CONSTRAINT PK_DimDate PRIMARY KEY ( DateKey )
);



CREATE TABLE dbo.DimReseller (
	ResellerKey int NOT NULL,
	ResellerName nvarchar(50) NOT NULL,
	SalesRegion nvarchar(30) NULL,
	SalesCountry nvarchar(50) NULL,
	SalesGroup nvarchar(50) NULL,
	StartDate DATE NOT NULL,
	EndDate DATE NULL,
	CONSTRAINT PK_DimReseller_ResellerKey PRIMARY KEY (ResellerKey)
) 


CREATE TABLE dbo.DimLocation (
	LocationKey int NOT NULL,
	SalesRegion nvarchar(30) NULL,
	SalesCountry nvarchar(50) NULL,
	SalesGroup nvarchar(50) NULL,
	CONSTRAINT PK_DimLocation_LocationKey PRIMARY KEY (LocationKey)
) 



-- Product dimension table TYPE 2 SCD
CREATE TABLE dbo.DimProducts(
	ProductKey INT NOT NULL,
	ProductName NVARCHAR(50) NULL,
	ProductCategoryName nvarchar(50) NULL,
	StandardCost MONEY NULL,
	Color NVARCHAR(15) NULL,
	Size NVARCHAR(5) NULL,
	Weight DECIMAL(8,2) NULL,
	Class NCHAR(2) NULL,
	Style NCHAR(2) NULL,
	StartDate DATE NOT NULL,
	EndDate DATE NULL,
	
    CONSTRAINT PK_DimProducts PRIMARY KEY CLUSTERED (ProductKey)
);

-- Promotion dimension table TYPE 2 SCD
CREATE TABLE dbo.DimPromotion(
	PromotionKey INT NOT NULL,
	PromotionName NVARCHAR(255) NULL,
	DiscountPct SMALLMONEY NULL,
	PromotionType NVARCHAR(50) NULL,
	PromotionCategory NVARCHAR(50) NULL,
	StartDate DATE NOT NULL,
	EndDate DATE NULL,
	
    CONSTRAINT PK_DimPromotion PRIMARY KEY CLUSTERED (PromotionKey)
);
/*
-- Customer dimension table TYPE 2 SCD
CREATE TABLE dbo.DimCustomers(
	CustomerKey	INT NOT NULL,
	FirstName NVARCHAR(30) NULL,
	MiddleName NVARCHAR(30) NULL,
	LastName NVARCHAR(30) NULL,
	Title NVARCHAR(8) NULL,
	EmailAddress NVARCHAR(50) NULL,
	StartDate DATE NOT NULL,
	EndDate DATE NULL,
	
    CONSTRAINT PK_DimCustomers PRIMARY KEY CLUSTERED (CustomerKey)
); */

-- SalesPerson dimension table TYPE 1 SCD
CREATE TABLE dbo.DimSalesPerson (
	SalesPersonKey INT NOT NULL,
	FirstName NVARCHAR(30) NULL,
	MiddleName NVARCHAR(30) NULL,
	LastName NVARCHAR(30) NULL,
	Title NVARCHAR(8) NULL,

    CONSTRAINT PK_DimSalesPerson PRIMARY KEY CLUSTERED (SalesPersonKey)
);


-- Reseller Sales Fact table 
CREATE TABLE dbo.FactResellerSales (
	ProductKey INT NOT NULL,
	DateKey INT NOT NULL,
	ResellerKey INT,
	SalesPersonKey INT NOT NULL,
	PromotionKey INT NOT NULL,
	LocationKey INT ,
	--CustomerKey INT NOT NULL,
	UnitPrice MONEY NOT NULL,
	UnitPriceDsicount MONEY NOT NULL,
	SalesAmount MONEY NOT NULL,
	TaxAmt MONEY NOT NULL,
	Freight MONEY NOT NULL,
	
    --CONSTRAINT FK_FactOrders_DimCustomers FOREIGN KEY(CustomerKey) REFERENCES dbo.DimCustomers (CustomerKey),
    CONSTRAINT FK_FactOrders_DimDate FOREIGN KEY(DateKey) REFERENCES dbo.DimDate (DateKey),
	CONSTRAINT FK_FactOrders_DimLocation FOREIGN KEY(LocationKey) REFERENCES dbo.DimLocation (LocationKey),
    CONSTRAINT FK_FactOrders_DimProducts FOREIGN KEY(ProductKey) REFERENCES dbo.DimProducts (ProductKey),
    CONSTRAINT FK_FactOrders_DimSalesPerson FOREIGN KEY(SalesPersonKey) REFERENCES dbo.DimSalesPerson (SalesPersonKey),
	CONSTRAINT FK_FactOrders_DimPromotion FOREIGN KEY(PromotionKey) REFERENCES dbo.DimPromotion (PromotionKey),
	CONSTRAINT FK_FactOrders_DimReseller FOREIGN KEY(ResellerKey) REFERENCES dbo.DimReseller (ResellerKey)
);

CREATE INDEX IX_FactOrders_ProductKey ON dbo.FactResellerSales(ProductKey);
CREATE INDEX IX_FactOrders_DateKey ON dbo.FactResellerSales(DateKey);
CREATE INDEX IX_FactOrders_ResellerKey ON dbo.FactResellerSales(ResellerKey);
CREATE INDEX IX_FactOrders_SalesPersonKey ON dbo.FactResellerSales(SalesPersonKey);
CREATE INDEX IX_FactOrders_PromotionKey ON dbo.FactResellerSales(PromotionKey);
CREATE INDEX IX_FactOrders_LocationKey ON dbo.FactResellerSales(LocationKey);
--CREATE INDEX IX_FactOrders_CustomerKey ON dbo.FactResellerSales(CustomerKey);




CREATE PROCEDURE dbo.DimDate_Load
	@DateValue DATE
AS
BEGIN;
INSERT INTO dbo.DimDate
	SELECT CAST( YEAR(@DateValue) * 10000 + MONTH(@DateValue) * 100 + DAY(@DateValue) AS INT),
	@DateValue,
	YEAR(@DateValue),
	MONTH(@DateValue),
	DAY(@DateValue),
	DATEPART(qq,@DateValue),
	DATEADD(DAY,1,EOMONTH(@DateValue,-1)),
	EOMONTH(@DateValue),
	DATENAME(mm,@DateValue),
	DATENAME(dw,@DateValue);
END;

DECLARE @StartDate  date = '20100101';
DECLARE @EndDate date = DATEADD(DAY, -1, DATEADD(YEAR, 10, @StartDate));
DECLARE @n INT = 0;
SELECT @StartDate, @EndDate
WHILE (1=1)
BEGIN
	EXEC [dbo].[DimDate_Load] @StartDate; 
	IF DATEDIFF(DAY, @StartDate, @EndDate) = 0 BREAK;
	SET @StartDate = DATEADD(day,1,@StartDate);
END;

SELECT * FROM dbo.DimDate


/* CREATING SOURCE STAGING TABLES */
CREATE TABLE dbo.Products_Stage(
	ProductName NVARCHAR(50),
	ProductCategoryName nvarchar(50),
	StandardCost MONEY,
	Color NVARCHAR(15),
	Size NVARCHAR(5),
	Weight DECIMAL(8,2),
	Class NCHAR(2),
	Style NCHAR(2)
);

CREATE TABLE dbo.Promotion_Stage(
	PromotionName NVARCHAR(255),
	DiscountPct SMALLMONEY,
	PromotionType NVARCHAR(50),
	PromotionCategory NVARCHAR(50)
);

/*
CREATE TABLE dbo.Customers_Stage(
	FirstName NVARCHAR(30),
	MiddleName NVARCHAR(30),
	LastName NVARCHAR(30),
	Title NVARCHAR(8),
	EmailAddress NVARCHAR(50)
);*/

CREATE TABLE dbo.SalesPeople_Stage (
	FirstName NVARCHAR(30),
	MiddleName NVARCHAR(30),
	LastName NVARCHAR(30),
	Title NVARCHAR(8),
);

CREATE TABLE dbo.Location_Stage(
	SalesRegion nvarchar(30) NULL,
	SalesCountry nvarchar(50) NULL,
	SalesGroup nvarchar(50) NULL
);

CREATE TABLE dbo.Reseller_Stage(
	ResellerName nvarchar(50) NOT NULL,
	SalesRegion nvarchar(30) NULL,
	SalesCountry nvarchar(50) NULL,
	SalesGroup nvarchar(50) NULL,
);

CREATE TABLE dbo.ResellerSales_Stage (
	--CustomerFirstName NVARCHAR(30),
	--CustomerLastName NVARCHAR(30),
	ResellerName NVARCHAR(100),
	ProductName NVARCHAR(100),
	SalesFirstName NVARCHAR(30),
	SalesLastName NVARCHAR(30),
	TerritoryName NVARCHAR(30),
	PromotionName nvarchar(255), 
	OrderDate DATE,
	UnitPrice MONEY,
	UnitPriceDsicount MONEY,
	SalesAmount MONEY,
	TaxAmt MONEY,
	Freight MONEY
);

/* CREATING EXTRACT STAGING STORED PROCEDURES */
CREATE PROCEDURE dbo.Products_Extract
AS
BEGIN;
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	DECLARE @RowCt INT;
	
	TRUNCATE TABLE dbo.Products_Stage;
	
	INSERT INTO dbo.Products_Stage(
		ProductName,
		ProductCategoryName,
		StandardCost,
		Color,
		Size,
		Weight,
		Class,
		Style
	)
	SELECT 
		p.Name,
		ps.Name,
		p.StandardCost,
		p.Color,
		p.Size,
		p.Weight,
		p.Class,
		p.Style
	FROM AdventureWorks2021.dbo.Product p
	LEFT JOIN AdventureWorks2021.dbo.ProductSubcategory ps
		ON p.ProductSubcategoryID = ps.ProductSubcategoryID
	
	SET @RowCt = @@ROWCOUNT;
    IF @RowCt = 0 
    BEGIN;
        THROW 50001, 'No records found. Check with source system.', 1;
    END;
END; --END OF PROCEDURE Products_Extract
GO

CREATE PROCEDURE dbo.Promotion_Extract
AS
BEGIN;
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	DECLARE @RowCt INT;
	
	TRUNCATE TABLE dbo.Promotion_Stage;
	
	INSERT INTO dbo.Promotion_Stage(
		PromotionName,
		DiscountPct,
		PromotionType,
		PromotionCategory
	)
	SELECT 
		so.Description,
		so.DiscountPct,
		so.Type,
		so.Category
	FROM AdventureWorks2021.dbo.SpecialOffer so
	
	SET @RowCt = @@ROWCOUNT;
    IF @RowCt = 0 
    BEGIN;
        THROW 50001, 'No records found. Check with source system.', 1;
    END;
END; --END OF PROCEDURE Promotion_Extract
GO

/*
CREATE PROCEDURE dbo.Customers_Extract
AS
BEGIN;
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @RowCt INT;

    TRUNCATE TABLE dbo.Customers_Stage;

	INSERT INTO dbo.Customers_Stage(
		FirstName,
		MiddleName,
		LastName,
		Title,
		EmailAddress
	)
	SELECT 
		p.FirstName,
		p.MiddleName,
		p.LastName,
		p.Title,
		ea.EmailAddress
	FROM AdventureWorks2021.dbo.Customer c
	LEFT JOIN AdventureWorks2021.dbo.Person p
		ON c.PersonID = p.PersonID
	LEFT JOIN AdventureWorks2021.dbo.EmailAddress ea
		ON c.PersonID = ea.PersonID;

    SET @RowCt = @@ROWCOUNT;
    IF @RowCt = 0 
    BEGIN;
        THROW 50001, 'No records found. Check with source system.', 1;
    END;
END; --END OF PROCEDURE Customers_Extract
GO */

CREATE PROCEDURE dbo.SalesPeople_Extract
AS
BEGIN;
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	DECLARE @RowCt INT;
	
	TRUNCATE TABLE dbo.SalesPeople_Stage;
	
	INSERT INTO dbo.SalesPeople_Stage (
		FirstName,
		MiddleName,
		LastName,
		Title
	)
	SELECT
		p.FirstName,
		p.MiddleName,
		p.LastName,
		p.Title
	FROM AdventureWorks2021.dbo.Person p
	LEFT JOIN AdventureWorks2021.dbo.SalesPerson sp
		ON p.PersonID = sp.SalesPersonID
	
	SET @RowCt = @@ROWCOUNT;
    IF @RowCt = 0 
    BEGIN;
        THROW 50001, 'No records found. Check with source system.', 1;
    END;
END; --END OF PROCEDURE SalesPeople_Extract
GO

CREATE PROCEDURE dbo.Location_Extract
AS
BEGIN;
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	DECLARE @RowCt INT;
	
	TRUNCATE TABLE dbo.Location_Stage;
	
	INSERT INTO dbo.Location_Stage(
		SalesRegion,
		SalesCountry,
		SalesGroup
	)
	SELECT 
		st.Name,
		cr.Name,
		st.[Group]
	FROM AdventureWorks2021.dbo.SalesTerritory st
	LEFT JOIN AdventureWorks2021.dbo.CountryRegion cr
	ON st.CountryRegionCode = cr.CountryRegionCode;
	
	SET @RowCt = @@ROWCOUNT;
    IF @RowCt = 0 
    BEGIN;
        THROW 50001, 'No records found. Check with source system.', 1;
    END;
END; --END OF PROCEDURE Products_Extract
GO

CREATE PROCEDURE dbo.Reseller_Extract
AS
BEGIN;
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	DECLARE @RowCt INT;
	
	TRUNCATE TABLE dbo.Reseller_Stage;
	
	INSERT INTO dbo.Reseller_Stage(
		ResellerName,
		SalesRegion,
		SalesCountry,
		SalesGroup
	)
	SELECT 
		s.Name,
		st.Name,
		cr.Name,
		st.[Group]
	FROM AdventureWorks2021.dbo.Store s
	LEFT JOIN AdventureWorks2021.dbo.Customer cust
	ON s.StoreID = cust.StoreID
	LEFT JOIN AdventureWorks2021.dbo.SalesOrder so
	ON cust.CustomerID = so.CustomerID
	LEFT JOIN AdventureWorks2021.dbo.SalesTerritory st
	ON so.TerritoryID = st.TerritoryID
	LEFT JOIN AdventureWorks2021.dbo.CountryRegion cr
	ON st.CountryRegionCode = cr.CountryRegionCode;
	
	SET @RowCt = @@ROWCOUNT;
    IF @RowCt = 0 
    BEGIN;
        THROW 50001, 'No records found. Check with source system.', 1;
    END;
END; --END OF PROCEDURE Products_Extract
GO

CREATE PROCEDURE dbo.ResellerSales_Extract
AS
BEGIN;
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @RowCt INT;

    TRUNCATE TABLE dbo.ResellerSales_Stage;

	--WITH CustomerDetails AS (
	--	SELECT 
	--		c.CustomerID,
	--		p.FirstName AS CustomerFirstName,
	--		p.LastName AS CustomerLastName
    --    FROM AdventureWorks2021.dbo.Customer c
    --    LEFT JOIN AdventureWorks2021.dbo.person p
    --        ON c.PersonID = p.PersonID )
	--SELECT * FROM CustomerDetails;
	WITH SalePersonDetails AS (
		SELECT
			sp.SalesPersonID,
			p.FirstName AS SalesPersonFirstName,
			p.LastName AS SalesPersonLastName
		FROM AdventureWorks2021.dbo.SalesPerson sp
		LEFT JOIN AdventureWorks2021.dbo.person p
			ON sp.SalesPersonID = p.PersonID )
	
	INSERT INTO dbo.ResellerSales_Stage(
		--CustomerFirstName,
		--CustomerLastName,
		ResellerName,
		ProductName,
		SalesFirstName,
		SalesLastName,
		TerritoryName,
		PromotionName,
		OrderDate,
		UnitPrice,
		UnitPriceDsicount,
		SalesAmount,
		TaxAmt,
		Freight
	)
	SELECT
		--pd.FirstName,
		--pd.LastName,
		s.Name,
		pr.Name,
		spd.SalesPersonFirstName,
		spd.SalesPersonLastName,
		st.Name,
		spo.Description,
		so.OrderDate,
		sod.UnitPrice,
		sod.UnitPriceDiscount,
		so.SubTotal,
		so.TaxAmt,
		so.Freight
	FROM AdventureWorks2021.dbo.SalesOrderDetail sod
	LEFT JOIN AdventureWorks2021.dbo.SalesOrder so
		ON sod.SalesOrderID = so.SalesOrderID
	LEFT JOIN AdventureWorks2021.dbo.Customer cust
		ON so.CustomerID = cust.CustomerID
	--LEFT JOIN CustomerDetails cd
	--	ON so.CustomerID = cd.CustomerID
	LEFT JOIN AdventureWorks2021.dbo.Product pr
		ON sod.ProductID = pr.ProductID
	LEFT JOIN AdventureWorks2021.dbo.Store s
		ON s.StoreID = cust.StoreID
	LEFT JOIN SalePersonDetails spd
		ON spd.SalesPersonID = s.SalesPersonID
	LEFT JOIN AdventureWorks2021.dbo.SalesTerritory st
		ON so.TerritoryID = st.TerritoryID
	LEFT JOIN AdventureWorks2021.dbo.SpecialOffer spo
		ON sod.SpecialOfferID = spo.SpecialOfferID;

    SET @RowCt = @@ROWCOUNT;
    IF @RowCt = 0 
    BEGIN;
        THROW 50001, 'No records found. Check with source system.', 1;
    END;
END; --END OF PROCEDURE ResellerSales_Extract
GO


/* CREATING TARGET STAGING TABLES */
CREATE TABLE dbo.Products_Preload(
	ProductKey INT NOT NULL,
	ProductName NVARCHAR(50) NULL,
	ProductCategoryName nvarchar(50) NULL,
	StandardCost MONEY NULL,
	Color NVARCHAR(15) NULL,
	Size NVARCHAR(5) NULL,
	Weight DECIMAL(8,2) NULL,
	Class NCHAR(2) NULL,
	Style NCHAR(2) NULL,
	StartDate DATE NOT NULL,
	EndDate DATE NULL,
	
    CONSTRAINT PK_Products_Preload PRIMARY KEY CLUSTERED (ProductKey)
);

CREATE TABLE dbo.Promotion_Preload(
	PromotionKey INT NOT NULL,
	PromotionName NVARCHAR(255) NULL,
	DiscountPct SMALLMONEY NULL,
	PromotionType NVARCHAR(50) NULL,
	PromotionCategory NVARCHAR(50) NULL,
	StartDate DATE NOT NULL,
	EndDate DATE NULL,
	
    CONSTRAINT PK_Promotion_Preload PRIMARY KEY CLUSTERED (PromotionKey)
);

/*
CREATE TABLE dbo.Customers_Preload (
	CustomerKey	INT NOT NULL,
	FirstName NVARCHAR(30) NULL,
	MiddleName NVARCHAR(30) NULL,
	LastName NVARCHAR(30) NULL,
	Title NVARCHAR(8) NULL,
	EmailAddress NVARCHAR(50) NULL,
	StartDate DATE NOT NULL,
	EndDate DATE NULL,
	
    CONSTRAINT PK_Customers_Preload PRIMARY KEY CLUSTERED (CustomerKey)
);*/

CREATE TABLE dbo.SalesPerson_Preload (
	SalesPersonKey INT NOT NULL,
	FirstName NVARCHAR(30) NULL,
	MiddleName NVARCHAR(30) NULL,
	LastName NVARCHAR(30) NULL,
	Title NVARCHAR(8) NULL,

    CONSTRAINT PK_SalesPerson_Preload PRIMARY KEY CLUSTERED (SalesPersonKey)
);

CREATE TABLE dbo.Location_Preload(
	LocationKey int NOT NULL,
	SalesRegion nvarchar(30) NULL,
	SalesCountry nvarchar(50) NULL,
	SalesGroup nvarchar(50) NULL
	
    CONSTRAINT PK_Location_Preload PRIMARY KEY CLUSTERED (LocationKey)
);

CREATE TABLE dbo.Reseller_Preload (
	ResellerKey int NOT NULL,
	ResellerName nvarchar(50) NOT NULL,
	SalesRegion nvarchar(30) NULL,
	SalesCountry nvarchar(50) NULL,
	SalesGroup nvarchar(50) NULL,
	StartDate DATE NOT NULL,
	EndDate DATE NULL,

	CONSTRAINT PK_Reseller_Preload PRIMARY KEY (ResellerKey)
);

CREATE TABLE dbo.ResellerSales_Preload (
	ProductKey INT NOT NULL,
	DateKey INT NOT NULL,
	ResellerKey INT ,
	SalesPersonKey INT NOT NULL,
	PromotionKey INT NOT NULL,
	LocationKey INT,
	--CustomerKey INT NOT NULL,
	UnitPrice MONEY NOT NULL,
	UnitPriceDsicount MONEY NOT NULL,
	SalesAmount MONEY NOT NULL,
	TaxAmt MONEY NOT NULL,
	Freight MONEY NOT NULL,
);

/* CREATING SEQUENCE TO MAINTAIN THE SURROGATE KEY */
CREATE SEQUENCE dbo.ProductKey START WITH 1;
CREATE SEQUENCE dbo.PromotionKey START WITH 1;
CREATE SEQUENCE dbo.DateKey START WITH 1;
CREATE SEQUENCE dbo.ResellerKey START WITH 1;
CREATE SEQUENCE dbo.SalesPersonKey START WITH 1;
CREATE SEQUENCE dbo.LocationKey START WITH 1;
--CREATE SEQUENCE dbo.CustomerKey START WITH 1;

/* CREATING TRANSFORM STORED PROCEDURES AND HANDLE THE SCD TYPE 1 & 2 */
CREATE PROCEDURE dbo.Products_Transform    -- Type 2 SCD
	@StartDate DATE
AS
BEGIN;
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	
	TRUNCATE TABLE dbo.Products_Preload;
	
    DECLARE @EndDate DATE = DATEADD(dd,-1,@StartDate);

	BEGIN TRANSACTION

	/*ADD UPDATED RECORDS*/
	INSERT INTO dbo.Products_Preload
	SELECT	
		NEXT VALUE FOR dbo.ProductKey AS ProductKey,
		stg.ProductName,
		stg.ProductCategoryName,
		stg.StandardCost,
		stg.Color,
		stg.Size,
		stg.Weight,
		stg.Class,
		stg.Style,
		@StartDate,
		NULL
	FROM dbo.Products_Stage stg
	JOIN dbo.DimProducts dp
		ON stg.ProductName = dp.ProductName
		AND dp.EndDate IS NULL
	WHERE
		stg.ProductName <> dp.ProductName
		OR stg.ProductCategoryName <> dp.ProductCategoryName
		OR stg.StandardCost <> dp.StandardCost
		OR stg.Color <> dp.Color
		OR stg.Size <> dp.Size
		OR stg.Weight <> dp.Weight
		OR stg.Class <> dp.Class
		OR stg.Style <> dp.Style;
			
	/*ADD EXISTING RECORDS, AND EXPIRE AS NECESSARY*/
	INSERT INTO dbo.Products_Preload
	SELECT
		dp.ProductKey,
		dp.ProductName,
		dp.ProductCategoryName,
		dp.StandardCost,
		dp.Color,
		dp.Size,
		dp.Weight,
		dp.Class,
		dp.Style,
		dp.StartDate,
		CASE
			WHEN pl.ProductName IS NULL THEN NULL
			ELSE @EndDate
		END AS EndDate
	FROM dbo.DimProducts dp
	LEFT JOIN dbo.Products_Preload pl
		ON pl.ProductName = dp.ProductName
		AND dp.EndDate IS NULL;

	/*CREATE NEW RECORDS*/
	INSERT INTO dbo.Products_Preload
	SELECT
		NEXT VALUE FOR dbo.ProductKey AS ProductKey,
		stg.ProductName,
		stg.ProductCategoryName,
		stg.StandardCost,
		stg.Color,
		stg.Size,
		stg.Weight,
		stg.Class,
		stg.Style,
		@StartDate,
		NULL
	FROM dbo.Products_Stage stg
	WHERE NOT EXISTS
		(SELECT 1
			FROM dbo.DimProducts dp
			WHERE stg.ProductName = dp.ProductName);
	/*EXPIRE MISSING RECORDS*/
	INSERT INTO dbo.Products_Preload
	SELECT
		dp.ProductKey,
		dp.ProductName,
		dp.ProductCategoryName,
		dp.StandardCost,
		dp.Color,
		dp.Size,
		dp.Weight,
		dp.Class,
		dp.Style,
		dp.StartDate,
		@EndDate
	FROM dbo.DimProducts dp
	WHERE NOT EXISTS
		(SELECT 1
			FROM dbo.Products_Stage stg
			WHERE stg.ProductName = dp.ProductName)
		AND dp.EndDate IS NULL;

	COMMIT TRANSACTION;

END; --END OF PROCEDURE Products_Transform
GO

CREATE PROCEDURE dbo.Promotion_Transform    -- Type 2 SCD
	@StartDate DATE
AS
BEGIN;
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	
	TRUNCATE TABLE dbo.Promotion_Preload;

	DECLARE @EndDate DATE = DATEADD(dd,-1,@StartDate);

	BEGIN TRANSACTION

	/*ADD UPDATED RECORDS*/
	INSERT INTO dbo.Promotion_Preload
	SELECT	
		NEXT VALUE FOR dbo.PromotionKey AS PromotionKey,
		ps.PromotionName,
		ps.DiscountPct,
		ps.PromotionType,
		ps.PromotionCategory,
		@StartDate,
		NULL
	FROM dbo.Promotion_Stage ps
	JOIN dbo.DimPromotion dp
		ON ps.DiscountPct = dp.DiscountPct
		AND dp.EndDate IS NULL
	WHERE
		ps.DiscountPct <> dp.DiscountPct
		OR ps.PromotionType <> dp.PromotionType
		OR ps.PromotionCategory <> dp.PromotionCategory;

	/*ADD EXISTING RECORDS, AND EXPIRE AS NECESSARY*/
	INSERT INTO dbo.Promotion_Preload
	SELECT
		dp.PromotionKey,
		dp.PromotionName,
		dp.DiscountPct,
		dp.PromotionType,
		dp.PromotionCategory,
		dp.StartDate,
		CASE
			WHEN pl.DiscountPct IS NULL THEN NULL
			ELSE @EndDate
		END AS EndDate
	FROM dbo.DimPromotion dp
	LEFT JOIN dbo.Promotion_Preload pl
		ON pl.DiscountPct = dp.DiscountPct
		AND dp.EndDate IS NULL;

	/*CREATE NEW RECORDS*/
	INSERT INTO dbo.Promotion_Preload
	SELECT
		NEXT VALUE FOR dbo.PromotionKey AS PromotionKey,
		ps.PromotionName,
		ps.DiscountPct,
		ps.PromotionType,
		ps.PromotionCategory,
		@StartDate,
		NULL
	FROM dbo.Promotion_Stage ps
	WHERE NOT EXISTS
		(SELECT 1
			FROM dbo.DimPromotion dp
			WHERE ps.DiscountPct = dp.DiscountPct);

	/*EXPIRE MISSING RECORDS*/
	INSERT INTO dbo.Promotion_Preload
	SELECT
		dp.PromotionKey,
		dp.PromotionName,
		dp.DiscountPct,
		dp.PromotionType,
		dp.PromotionCategory,
		dp.StartDate,
		@EndDate
	FROM dbo.DimPromotion dp
	WHERE NOT EXISTS
		(SELECT 1
			FROM dbo.Promotion_Stage ps
			WHERE ps.DiscountPct = dp.DiscountPct)
		AND dp.EndDate IS NULL;

    COMMIT TRANSACTION;
END; --END OF PROCEDURE Promotion_Transform
GO

CREATE PROCEDURE dbo.SalesPerson_Transform    -- Type 1 SCD
AS
BEGIN;
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	
	TRUNCATE TABLE dbo.SalesPerson_Preload;
	
	BEGIN TRANSACTION
	
	/*CREATE NEW RECORD*/
	INSERT INTO dbo.SalesPerson_Preload
	SELECT 
		NEXT VALUE FOR dbo.SalespersonKey AS SalespersonKey,
		s.FirstName,
		s.MiddleName,
		s.LastName,
		s.Title
	FROM dbo.SalesPeople_Stage s
	WHERE NOT EXISTS 
		(SELECT 1
			FROM dbo.DimSalesPerson ds
			WHERE s.FirstName = ds.FirstName
				AND s.LastName = ds.LastName );
	
	/*UPDATE EXISTING RECORDS*/
	INSERT INTO dbo.SalesPerson_Preload
	SELECT 
		ds.SalesPersonKey,
		s.FirstName,
		s.MiddleName,
		s.LastName,
		s.Title
	FROM dbo.SalesPeople_Stage s
	JOIN dbo.DimSalesPerson ds 
		ON s.FirstName = ds.FirstName
			AND s.LastName = ds.LastName;

	COMMIT TRANSACTION;
END; --END OF PROCEDURE SalesPeople_Transform
GO

CREATE PROCEDURE dbo.Location_Transform    -- Type 1 SCD
AS
BEGIN;
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	
	TRUNCATE TABLE dbo.Location_Preload;
	
	BEGIN TRANSACTION
	
	/*CREATE NEW RECORD*/
	INSERT INTO dbo.Location_Preload
	SELECT 
		NEXT VALUE FOR dbo.LocationKey AS LocationKey,
		l.SalesRegion,
		l.SalesCountry,
		l.SalesGroup
	FROM dbo.Location_Stage l
	WHERE NOT EXISTS 
		(SELECT 1
			FROM dbo.DimLocation lo
			WHERE l.SalesRegion = lo.SalesRegion );
	
	/*UPDATE EXISTING RECORDS*/
	INSERT INTO dbo.Location_Preload
	SELECT 
		lo.LocationKey,
		l.SalesRegion,
		l.SalesCountry,
		l.SalesGroup
	FROM dbo.Location_Stage l
	JOIN dbo.DimLocation lo
		ON l.SalesRegion = lo.SalesRegion;

	COMMIT TRANSACTION;
END; --END OF PROCEDURE SalesPeople_Transform
GO


CREATE PROCEDURE dbo.Reseller_Transform    -- Type 2 SCD
	@StartDate DATE
AS
BEGIN;
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	
	TRUNCATE TABLE dbo.Reseller_Preload;

	DECLARE @EndDate DATE = DATEADD(dd,-1,@StartDate);

	BEGIN TRANSACTION

	/*ADD UPDATED RECORDS*/
	INSERT INTO dbo.Reseller_Preload
	SELECT	
		NEXT VALUE FOR dbo.ResellerKey AS ResellerKey,
		r.ResellerName,
		r.SalesRegion,
		r.SalesCountry,
		r.SalesGroup,
		@StartDate,
		NULL
	FROM dbo.Reseller_Stage r
	JOIN dbo.DimReseller re
		ON r.ResellerName = re.ResellerName
		AND re.EndDate IS NULL
	WHERE
		r.SalesRegion <> re.SalesRegion
		OR r.SalesCountry <> re.SalesCountry
		OR r.SalesGroup <> re.SalesGroup;

	/*ADD EXISTING RECORDS, AND EXPIRE AS NECESSARY*/
	INSERT INTO dbo.Reseller_Preload
	SELECT
		dr.ResellerKey,
		dr.ResellerName,
		dr.SalesRegion,
		dr.SalesCountry,
		dr.SalesGroup,
		dr.StartDate,
		CASE
			WHEN rp.ResellerName IS NULL THEN NULL
			ELSE @EndDate
		END AS EndDate
	FROM dbo.DimReseller dr
	LEFT JOIN dbo.Reseller_Preload rp
		ON dr.ResellerName = rp.ResellerName
		AND dr.EndDate IS NULL;

	/*CREATE NEW RECORDS*/
	INSERT INTO dbo.Reseller_Preload
	SELECT
		NEXT VALUE FOR dbo.ResellerKey AS ResellerKey,
		r.ResellerName,
		r.SalesRegion,
		r.SalesCountry,
		r.SalesGroup,
		@StartDate,
		NULL
	FROM dbo.Reseller_Stage r
	WHERE NOT EXISTS
		(SELECT 1
			FROM dbo.DimReseller re
			WHERE r.ResellerName = re.ResellerName);

	/*EXPIRE MISSING RECORDS*/
	INSERT INTO dbo.Reseller_Preload
	SELECT
		dr.ResellerKey,
		dr.ResellerName,
		dr.SalesRegion,
		dr.SalesCountry,
		dr.SalesGroup,
		dr.StartDate,
		@EndDate
	FROM dbo.DimReseller dr
	WHERE NOT EXISTS
		(SELECT 1
			FROM dbo.Reseller_Stage rs
			WHERE rs.ResellerName = dr.ResellerName)
		AND dr.EndDate IS NULL;

    COMMIT TRANSACTION;
END; --END OF PROCEDURE Promotion_Transform
GO

CREATE PROCEDURE dbo.ResellerSales_Transform
AS
BEGIN;

    SET NOCOUNT ON;
    SET XACT_ABORT ON;
	DECLARE @RowCt INT;

    TRUNCATE TABLE dbo.ResellerSales_Preload;

    INSERT INTO dbo.ResellerSales_Preload -- (ProductKey, DateKey, ResellerKey, SalesPersonKey, PromotionKey, LocationKey, UnitPrice, UnitPriceDsicount, SalesAmount, TaxAmt, Freight)
    SELECT 
		pr.ProductKey,
		CAST(YEAR(rss.OrderDate) * 10000 + MONTH(rss.OrderDate) * 100 + DAY(rss.OrderDate) AS INT) AS DateKey,
		re.ResellerKey,
		sp.SalesPersonKey,
		pp.PromotionKey,
		lo.LocationKey,
		--cu.CustomerKey,
		rss.UnitPrice,
		rss.UnitPriceDsicount,
		rss.SalesAmount,
		rss.TaxAmt,
		rss.Freight
    FROM dbo.ResellerSales_Stage rss
    --JOIN dbo.Customers_Preload cu
	--	ON rss.CustomerFirstName = cu.FirstName
	--	AND rss.CustomerLastName = cu.LastName
    JOIN dbo.Reseller_Preload re
		ON rss.ResellerName = re.ResellerName
    JOIN dbo.Products_Preload pr
		ON rss.ProductName = pr.ProductName
    JOIN dbo.SalesPerson_Preload sp
		ON rss.SalesFirstName = sp.FirstName
		AND rss.SalesLastName = sp.LastName
	JOIN dbo.Promotion_Preload pp
		ON rss.PromotionName = pp.PromotionName
	JOIN dbo.Location_Preload lo
		ON rss.TerritoryName = lo.SalesRegion;
		
	SET @RowCt = @@ROWCOUNT;
    IF @RowCt = 0 
    BEGIN;
        THROW 50001, 'No records found. Check with source system.', 1;
    END;
	
END; --END OF PROCEDURE Orders_Transform
GO

CREATE PROCEDURE dbo.Products_Load
AS
BEGIN;

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    DELETE p
    FROM dbo.DimProducts p
    JOIN dbo.Products_Preload pl
        ON p.ProductKey = pl.ProductKey;

    INSERT INTO dbo.DimProducts 
    SELECT * 
    FROM dbo.Products_Preload;

    COMMIT TRANSACTION;
END;
GO

CREATE PROCEDURE dbo.Promotion_Load
AS
BEGIN;

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    DELETE p
    FROM dbo.DimPromotion p
    JOIN dbo.Promotion_Preload pl
        ON p.PromotionKey = pl.PromotionKey;

    INSERT INTO dbo.DimPromotion
    SELECT * 
    FROM dbo.Promotion_Preload;

    COMMIT TRANSACTION;
END;
GO

CREATE PROCEDURE dbo.Customers_Load
AS
BEGIN;

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    DELETE cu
    FROM dbo.DimCustomers cu
    JOIN dbo.Customers_Preload pl
        ON cu.CustomerKey = pl.CustomerKey;

    INSERT INTO dbo.DimCustomers 
    SELECT * 
    FROM dbo.Customers_Preload;

    COMMIT TRANSACTION;
END;
GO

CREATE PROCEDURE dbo.SalesPeople_Load
AS
BEGIN;

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    DELETE s
    FROM dbo.DimSalesPerson s
    JOIN dbo.SalesPerson_Preload pl
        ON s.SalespersonKey = pl.SalespersonKey;

    INSERT INTO dbo.DimSalesPerson 
    SELECT * 
    FROM dbo.SalesPerson_Preload;

    COMMIT TRANSACTION;
END;
GO

CREATE PROCEDURE dbo.Location_Load
AS
BEGIN;

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    DELETE l
    FROM dbo.DimLocation l
    JOIN dbo.Location_Preload lp
        ON l.LocationKey = lp.LocationKey;

    INSERT INTO dbo.DimLocation 
    SELECT * 
    FROM dbo.Location_Preload;

    COMMIT TRANSACTION;
END;
GO

CREATE PROCEDURE dbo.Reseller_Load
AS
BEGIN;

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    DELETE r
    FROM dbo.DimReseller r
    JOIN dbo.Reseller_Preload rp
        ON r.ResellerKey = rp.ResellerKey;

    INSERT INTO dbo.DimReseller 
    SELECT * 
    FROM dbo.Reseller_Preload;

    COMMIT TRANSACTION;
END;
GO

CREATE PROCEDURE dbo.ResellerSales_Load
AS
BEGIN;

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    INSERT INTO dbo.FactResellerSales
    SELECT * 
    FROM dbo.ResellerSales_Preload;

END;
GO






EXECUTE dbo.Products_Extract;
EXECUTE dbo.Promotion_Extract;
--EXECUTE dbo.Customers_Extract;
EXECUTE dbo.SalesPeople_Extract;
EXECUTE dbo.Location_Extract;
EXECUTE dbo.Reseller_Extract;
EXECUTE dbo.ResellerSales_Extract;

EXECUTE dbo.Products_Transform '2011-05-31';
EXECUTE dbo.Promotion_Transform '2011-05-31';
--EXECUTE dbo.Customers_Transform '2011-05-31';
EXECUTE dbo.SalesPerson_Transform;
EXECUTE dbo.Reseller_Transform '2011-05-31';
EXECUTE dbo.Location_Transform;
EXECUTE dbo.ResellerSales_Transform;

EXECUTE dbo.DimDate_Load ;
EXECUTE dbo.Products_Load;
EXECUTE dbo.Promotion_Load;
--EXECUTE dbo.Customers_Load;
EXECUTE dbo.SalesPeople_Load;
EXECUTE dbo.Location_Load;
EXECUTE dbo.Reseller_Load;
EXECUTE dbo.ResellerSales_Load;
