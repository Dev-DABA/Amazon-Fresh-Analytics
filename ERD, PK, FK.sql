Use amazon;
ALTER TABLE customers
ADD PRIMARY KEY (CustomerID(255));
ALTER TABLE orders
ADD PRIMARY KEY (OrderID(255));
ALTER TABLE order_details
ADD PRIMARY KEY (OrderID(255), ProductID(255));
SELECT OrderID, ProductID, COUNT(*)
FROM order_details
GROUP BY OrderID, ProductID
HAVING COUNT(*) > 1;

SELECT *
FROM order_details
WHERE OrderID IS NULL
   OR ProductID IS NULL
   OR OrderID = ''
   OR ProductID = '';
   
DELETE od FROM order_details od
JOIN (
    SELECT OrderID, ProductID, ROW_NUMBER() OVER (PARTITION BY OrderID, ProductID ORDER BY (SELECT NULL)) AS row_num
    FROM order_details
) duplicates ON od.OrderID = duplicates.OrderID AND od.ProductID = duplicates.ProductID
WHERE duplicates.row_num > 1;

ALTER TABLE order_details
ADD PRIMARY KEY (OrderID(255), ProductID(255));

ALTER TABLE products
ADD PRIMARY KEY (ProductID(255));

ALTER TABLE reviews
ADD PRIMARY KEY (ReviewID(255));

ALTER TABLE suppliers
ADD PRIMARY KEY (SupplierID(255));



ALTER TABLE customers MODIFY CustomerID VARCHAR(255);
ALTER TABLE orders MODIFY CustomerID VARCHAR(255);

ALTER TABLE orders ADD CONSTRAINT fk_orders_customer FOREIGN KEY (CustomerID) REFERENCES customers(CustomerID);

DESCRIBE orders;
DESCRIBE order_details;

ALTER TABLE order_details MODIFY OrderID VARCHAR(255);
ALTER TABLE order_details MODIFY ProductID VARCHAR(255);
ALTER TABLE orders MODIFY OrderID VARCHAR(255);
ALTER TABLE Products MODIFY ProductID VARCHAR(255);


ALTER TABLE order_details ADD CONSTRAINT fk_order_details_order FOREIGN KEY (OrderID) REFERENCES orders(OrderID);
ALTER TABLE order_details ADD CONSTRAINT fk_order_details_product FOREIGN KEY (ProductID) REFERENCES products(ProductID);

ALTER TABLE Suppliers MODIFY SupplierID VARCHAR(255);
ALTER TABLE Products MODIFY SupplierID VARCHAR(255);

DESCRIBE products;
DESCRIBE suppliers;

DESCRIBE reviews;

ALTER TABLE reviews MODIFY ProductID VARCHAR(255);
ALTER TABLE reviews MODIFY CustomerID VARCHAR(255);
ALTER TABLE reviews MODIFY ReviewID VARCHAR(255);

ALTER TABLE reviews ADD CONSTRAINT fk_reviews_product FOREIGN KEY (ProductID) REFERENCES products(ProductID);
ALTER TABLE reviews ADD CONSTRAINT fk_reviews_customer FOREIGN KEY (CustomerID) REFERENCES customers(CustomerID);

Use amazon;

SELECT * FROM customers
WHERE City = 'North Timothy';
SELECT * FROM products
WHERE Category = 'Fruits';

ALTER TABLE customers
MODIFY Age INT NOT NULL;
ALTER TABLE customers
ADD CONSTRAINT chk_age CHECK (Age >=18);
ALTER TABLE customers
ADD CONSTRAINT uq_name UNIQUE (Name);

SELECT * 
FROM customers
WHERE Age IS NULL OR Age < 18;

INSERT INTO Products (ProductID, ProductName, Category,SubCategory, PricePerUnit)
VALUES ('2aa28375-c563-41b5-aa33-8e2c2e0f4ce5', 'papaya', 'Fruits', 'Sub-Fruits-1', 60);

INSERT INTO Products (ProductID, ProductName, Category ,SubCategory, PricePerUnit)
VALUES ('2aa28375-c563-41b5-aa33-8e2c2e0f3fy7', 'Banana', 'Fruits', 'Sub-Fruits-2', 20);

INSERT INTO Products (ProductID, ProductName, Category,SubCategory, PricePerUnit)
VALUES ('05765892-c750-44cc-96e2-31fa53d42of9', 'baby Carrot','Sub-Vegetables-1', 'Vegetables', 30);

Select  * from products where Productname='baby carrot';

UPDATE Products SET StockQuantity = 100 
WHERE ProductID = 'd79d1b95-ecdf-4810-aea0-45e9bd10627d'; 

Select  * from products where ProductID = 'd79d1b95-ecdf-4810-aea0-45e9bd10627d'; 

DELETE FROM Suppliers
WHERE City = 'South Ana';  
Select  * from Suppliers; 

Use Amazon;

ALTER TABLE Reviews
ADD CONSTRAINT chk_rating_range
CHECK (Rating BETWEEN 1 AND 5);

ALTER TABLE Customers
MODIFY PrimeMember VARCHAR(10) DEFAULT 'No';

SELECT * FROM Orders WHERE OrderDate > '2024-01-01';

SELECT ProductID, AVG(Rating) AS AvgRating FROM Reviews
GROUP BY ProductID
HAVING AVG(Rating) > 4;

SELECT ProductID, SUM(Quantity) AS TotalUnitsSold
FROM Order_Details
GROUP BY ProductID
ORDER BY TotalUnitsSold DESC;

use amazon;

SELECT o.CustomerID, SUM(od.Quantity * od.UnitPrice) AS TotalSpending
FROM Orders o
JOIN Order_Details od ON o.OrderID = od.OrderID
GROUP BY o.CustomerID;

SELECT 
    o.CustomerID, 
    SUM(od.Quantity * od.UnitPrice) AS TotalSpending,
    RANK() OVER (ORDER BY SUM(od.Quantity * od.UnitPrice) DESC) AS SpendingRank
FROM Orders o
JOIN Order_Details od ON o.OrderID = od.OrderID
GROUP BY o.CustomerID;

SELECT o.CustomerID, SUM(od.Quantity * od.UnitPrice) AS TotalSpending
FROM Orders o
JOIN Order_Details od ON o.OrderID = od.OrderID
GROUP BY o.CustomerID
HAVING TotalSpending > 5000;

SELECT 
    o.OrderID,
    SUM(od.Quantity * p.Priceperunit) AS TotalRevenue
FROM Orders o
JOIN Order_Details od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
GROUP BY o.OrderID;


SELECT 
    o.CustomerID,
    COUNT(*) AS TotalOrders
FROM Orders o
WHERE o.OrderDate='2025-01-01' 
GROUP BY o.CustomerID
ORDER BY TotalOrders DESC;

SELECT 
    s.SupplierID,
    s.SupplierName,
    SUM(p.StockQuantity) AS TotalStock
FROM Products p
JOIN Suppliers s ON p.SupplierID = s.SupplierID
GROUP BY s.SupplierID, s.SupplierName
ORDER BY TotalStock DESC;  

CREATE TABLE ProductCategories (
    CategoryID INT AUTO_INCREMENT PRIMARY KEY,
    Category VARCHAR(100),
    SubCategory VARCHAR(100),
    UNIQUE (Category, SubCategory)
);

INSERT INTO ProductCategories (Category, SubCategory)
SELECT DISTINCT Category, SubCategory FROM Products;

ALTER TABLE Products ADD COLUMN CategoryID INT;

UPDATE Products p
JOIN ProductCategories pc 
  ON p.Category = pc.Category AND p.SubCategory = pc.SubCategory
SET p.CategoryID = pc.CategoryID;

ALTER TABLE Products DROP COLUMN Category, DROP COLUMN SubCategory;

ALTER TABLE Products
ADD CONSTRAINT fk_products_category
FOREIGN KEY (CategoryID) REFERENCES ProductCategories(CategoryID);

SELECT ProductID, TotalRevenue
FROM (
    SELECT 
        od.ProductID,
        SUM(od.Quantity * p.Priceperunit) AS TotalRevenue
    FROM Order_Details od
    JOIN Products p ON od.ProductID = p.ProductID
    GROUP BY od.ProductID
    ORDER BY TotalRevenue DESC
    LIMIT 3
) AS TopProducts;

SELECT * FROM Customers
WHERE CustomerID NOT IN (
    SELECT DISTINCT CustomerID
    FROM Orders
);

SELECT City, COUNT(*) AS PrimeMemberCount
FROM Customers
WHERE PrimeMember = 'Yes'
GROUP BY City
ORDER BY PrimeMemberCount DESC;

SELECT pc.Category, COUNT(*) AS OrderFrequency
FROM Order_Details od
JOIN Products p ON od.ProductID = p.ProductID  
JOIN ProductCategories pc ON p.categoryID = pc.categoryID
GROUP BY pc.Category
ORDER BY OrderFrequency DESC
LIMIT 3;