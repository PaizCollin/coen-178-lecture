CREATE TABLE StoreItems (
    itemID VARCHAR(5) PRIMARY KEY,
    price NUMBER(9,2)
);

CREATE TABLE ComicBooks (
    itemID VARCHAR(5) REFERENCES StoreItems(itemID),
    ISBN CHAR(13) UNIQUE,
    publishedDate DATE,
    numCopies INT CHECK(numCopies >= 0),
    title VARCHAR(20),
    PRIMARY KEY(itemID)
);

CREATE TABLE TShirts (
    itemID VARCHAR(5) REFERENCES StoreItems(itemID),
    shirtSize VARCHAR(2),
    PRIMARY KEY(itemID)
);

CREATE TABLE Customers (
    custID VARCHAR(5) PRIMARY KEY,
    name VARCHAR(20),
    phone INT UNIQUE NOT NULL,
    address VARCHAR(30),
    dateJoined DATE DEFAULT NULL,
    custType VARCHAR(7) CHECK (custType = 'regular' OR custType = 'gold')
);

CREATE TABLE Orders (
    orderID VARCHAR(5) PRIMARY KEY,
    custID VARCHAR(5) REFERENCES Customers(custID),
    itemID VARCHAR(5) REFERENCES StoreItems(itemID),
    dateOrdered DATE,
    numItems INT,
    shippedDate DATE,
    shippingFee NUMBER(9,2) DEFAULT 10.00,
    CONSTRAINT checkTime CHECK (shippedDate >= dateOrdered)
);