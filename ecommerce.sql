CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;

CREATE TABLE customer(
	CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    SSN CHAR(11) NOT NULL,
    Address VARCHAR(200) NOT NULL,
     ContactEmail VARCHAR(255) NOT NULL,
    ContactPhone VARCHAR(20) NOT NULL,
    CONSTRAINT unique_ssn_customer UNIQUE (SSN)
);

CREATE TABLE product(
	ProductID INT AUTO_INCREMENT PRIMARY KEY,
    ProductName VARCHAR(10) NOT NULL,
    ClassificationKids BOOL DEFAULT FALSE,
    Category ENUM('Eletrônico', 'Vestimenta','Binquedo','Alimentos','Móveis') NOT NULL,
    Review FLOAT DEFAULT 0,
    Size VARCHAR(30),
    CONSTRAINT unique_product_name UNIQUE (ProductName)
);

CREATE TABLE product_review(
	 ReviewID INT PRIMARY KEY,
    ProductID INT,
    Rating INT,
    Comment TEXT,
    ReviewDate DATE,
    CONSTRAINT fk_review_product FOREIGN KEY (ProductID) REFERENCES product (ProductID)
);

CREATE TABLE orders(
	OrderID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerOrderID INT, 
    OrderStatus ENUM('Cancelado','Confirmado','Em processamento') DEFAULT 'Em processamento',
    OrderDescription VARCHAR(255),
    ShippingFee FLOAT DEFAULT 10,
    CONSTRAINT fk_customer_orders FOREIGN KEY(CustomerOrderID) REFERENCES customer (CustomerID)
		ON UPDATE CASCADE 
);



CREATE TABLE product_storage(
	ProductStorageID INT AUTO_INCREMENT PRIMARY KEY,
    StorageLocation VARCHAR(255),
    Quantity INT DEFAULT 0
);

CREATE TABLE supplier(
	SupplierID INT AUTO_INCREMENT PRIMARY KEY,
    CompanyName VARCHAR(255) NOT NULL,
    BusinessID CHAR(14) NOT NULL,
    ContactName VARCHAR(255) NOT NULL,
    ContactEmail VARCHAR(255) NOT NULL,
    ContactPhone VARCHAR(20) NOT NULL,
    ContactAddress VARCHAR(255) NOT NULL,
    CONSTRAINT unique_supplier_business_id UNIQUE (BusinessID)
);

CREATE TABLE seller(
	SellerID INT AUTO_INCREMENT PRIMARY KEY,
    CompanyName VARCHAR(255) NOT NULL,
    BusinessID CHAR(14),
    SSN CHAR(11),
    ContactName VARCHAR(255) NOT NULL,
    ContactEmail VARCHAR(255) NOT NULL,
    ContactPhone VARCHAR(20) NOT NULL,
    ContactAddress VARCHAR(255) NOT NULL,
    CONSTRAINT unique_seller_business_id UNIQUE (BusinessID),
    CONSTRAINT unique_seller_ssn UNIQUE (SSN),
    CONSTRAINT chk_valid_id CHECK (
        (LENGTH(BusinessID) = 11 OR LENGTH(BusinessID) = 14) AND
        BusinessID REGEXP '^[0-9]+$')
);

CREATE TABLE product_seller (
	ProductSellerID INT,
	ProductID INT,
    ProductQuantity INT DEFAULT 1,
    PRIMARY KEY (ProductSellerID, ProductID),
    CONSTRAINT fk_product_seller_id FOREIGN KEY (ProductSellerID) REFERENCES seller (SellerID),
    CONSTRAINT fk_product_id FOREIGN KEY (ProductID) REFERENCES product (ProductID)
);

CREATE TABLE product_supplier(
	ProductSupplierID INT,
    ProductSupplierProductID INT,
    Quantity INT NOT NULL,
    PRIMARY KEY (ProductSupplierID, ProductSupplierProductID),
    CONSTRAINT fk_product_supplier_supplier FOREIGN KEY (ProductSupplierID) REFERENCES supplier (SupplierID),
    CONSTRAINT fk_product_supplier_product FOREIGN KEY (ProductSupplierProductID) REFERENCES product (ProductID)
);

CREATE TABLE product_orders(
	ProductID INT,
    ProductOrderID INT,
    ProductQuantity INT DEFAULT 1,
    ProductStatus ENUM('Disponível', 'Sem estoque') DEFAULT 'Disponível',
    PRIMARY KEY (ProductID, ProductOrderID),
    CONSTRAINT fk_product_order_product_id FOREIGN KEY (ProductID) REFERENCES product (ProductID),
    CONSTRAINT fk_product_order_id FOREIGN KEY (ProductOrderID) REFERENCES orders (OrderID)
);

CREATE TABLE storage_location(
	ProductLocationID INT,
    StorageLocationID INT,
    Location VARCHAR (255) NOT NULL,
    PRIMARY KEY (ProductLocationID, StorageLocationID),
    CONSTRAINT fk_storage_location_product FOREIGN KEY (ProductLocationID) REFERENCES product (ProductID),
    CONSTRAINT fk_storage_location_storage FOREIGN KEY (StorageLocationID) REFERENCES product_storage (ProductStorageID)
);

CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;

CREATE TABLE payment(
	PaymentID INT PRIMARY KEY,
	OrderID INT,
    PaymentType ENUM('Cartão de Crédito','Cartão de Débito','Boleto','Dois cartões'),
    CardNumber VARCHAR(16),
    ExpiryDate DATE,
    CVV VARCHAR(4),
    PaymentCash BOOL DEFAULT FALSE,
    CONSTRAINT fk_payment_order FOREIGN KEY (OrderID) REFERENCES orders(OrderID)
);

DELIMITER //
CREATE TRIGGER trg_check_card_expiry BEFORE INSERT ON payment
FOR EACH ROW
BEGIN
    IF NEW.ExpiryDate < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Card expiry date must be in the future';
    END IF;
END;
//
DELIMITER ;
