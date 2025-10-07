-- Snowflake/Synapse compatible DDL (simplified)
CREATE TABLE DimCustomers (
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100),
    Phone VARCHAR(20),
    LoyaltyPoints INT,
    Tier VARCHAR(20),
    SignupDate DATE,
    City VARCHAR(50),
    State VARCHAR(10),
    PostalCode VARCHAR(10)
);

CREATE TABLE DimProducts (
    ProductID INT PRIMARY KEY,
    SKU VARCHAR(50),
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Subcategory VARCHAR(50),
    UnitPrice NUMBER(10,2),
    Cost NUMBER(10,2),
    Supplier VARCHAR(50),
    Discontinued BOOLEAN
);

CREATE TABLE DimStores (
    StoreID INT PRIMARY KEY,
    StoreName VARCHAR(50),
    Region VARCHAR(20),
    City VARCHAR(50),
    State VARCHAR(10),
    OpenDate DATE,
    SquareFeet INT
);

CREATE TABLE FactOrders (
    OrderID INT PRIMARY KEY,
    OrderDateTime TIMESTAMP,
    StoreID INT,
    CustomerID INT,
    ProductID INT,
    Quantity INT,
    UnitPrice NUMBER(10,2),
    DiscountPct NUMBER(5,2),
    PaymentID VARCHAR(50),
    PaymentMethod VARCHAR(20),
    Channel VARCHAR(20),
    Status VARCHAR(20),
    OrderTotal NUMBER(12,2),
    Currency VARCHAR(5)
);

CREATE TABLE Payments (
    PaymentID VARCHAR(50) PRIMARY KEY,
    OrderID INT,
    Amount NUMBER(12,2),
    Currency VARCHAR(5),
    Method VARCHAR(20),
    Gateway VARCHAR(20),
    Status VARCHAR(20),
    AuthCode VARCHAR(20),
    FraudScore NUMBER(5,3)
);