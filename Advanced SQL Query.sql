#Note: Theroy Questions from Q1 to Q5 are available in doc file.

create database ADVSQL;
use ADVSQL;

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10,2)
);

INSERT INTO Products VALUES
(1, 'Keyboard', 'Electronics', 1200),
(2, 'Mouse', 'Electronics', 800),
(3, 'Chair', 'Furniture', 2500),
(4, 'Desk', 'Furniture', 5500);

CREATE TABLE Sales (
    SaleID INT PRIMARY KEY,
    ProductID INT,
    Quantity INT,
    SaleDate DATE,
    FOREIGN KEY (ProductID) REFERENCES Products (ProductID)
);

INSERT INTO Sales VALUES
(1, 1, 4, '2024-01-05'),
(2, 2, 10, '2024-01-06'),
(3, 3, 2, '2024-01-10'),
(4, 4, 1, '2024-01-11'); 

#Q6. Write a CTE to calculate the total revenue for each product, and return only products where revenue > 3000.
#Ans 6:
WITH ProductRevenue AS (
    SELECT 
        p.ProductName, 
        SUM(p.Price * s.Quantity) AS TotalRevenue
    FROM Products p
    JOIN Sales s ON p.ProductID = s.ProductID
    GROUP BY p.ProductName
)
SELECT * FROM ProductRevenue 
WHERE TotalRevenue > 3000;

#Q7. Create a view named vw_CategorySummary that shows: Category, TotalProducts, AveragePrice.
#Ans 7:
CREATE VIEW vw_CategorySummary AS
SELECT 
    Category, 
    COUNT(ProductID) AS TotalProducts, 
    AVG(Price) AS AveragePrice
FROM Products
GROUP BY Category;
SELECT * FROM vw_CategorySummary;

#Q8. Create an updatable view containing ProductID, ProductName, and Price. Then update the price of ProductID = 1 using the view.
#Ans 8:
-- Step 1: Creating the view
CREATE VIEW vw_UpdatableProducts AS
SELECT ProductID, ProductName, Price
FROM Products;

-- Step 2: Updating the view
UPDATE vw_UpdatableProducts
SET Price = 1500.00
WHERE ProductID = 1;
select * from vw_UpdatableProducts;
SELECT * FROM Products;

#Q9. Create a stored procedure that accepts a category name and returns all products belonging to that category.
#Ans 9:
-- 1. Change the delimiter
DELIMITER //
-- 2. Create the procedure
CREATE PROCEDURE GetProductsByCategory(IN p_CategoryName VARCHAR(50))
BEGIN
    SELECT * FROM Products 
    WHERE Category = p_CategoryName;
END //
-- 3. Change the delimiter back to standard
DELIMITER ;
CALL GetProductsByCategory('Electronics');
CALL GetProductsByCategory('Furniture');

#Q10. Create an AFTER DELETE trigger on the Products table that archives deleted product rows into a new table ProductArchive. 
#The archive should store ProductID, ProductName, Category, Price, and DeletedAt timestamp.
#Ans 10:
-- Step 1: Create the Archive Table
CREATE TABLE ProductArchive (
    ProductID INT,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10,2),
    DeletedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Step 2: Create the AFTER DELETE Trigger
DELIMITER //

CREATE TRIGGER trg_AfterDeleteProduct
AFTER DELETE ON Products
FOR EACH ROW
BEGIN
    INSERT INTO ProductArchive (ProductID, ProductName, Category, Price, DeletedAt)
    VALUES (OLD.ProductID, OLD.ProductName, OLD.Category, OLD.Price, CURRENT_TIMESTAMP);
END //

DELIMITER ;

-- 1. First, we delete the related record from the child table (Sales)
DELETE FROM Sales WHERE ProductID = 4;

-- 2. Now we can safely delete the row from the parent table (Products)
DELETE FROM Products WHERE ProductID = 4;

-- 3. Checing the archive table to see your trigger in action!
SELECT * FROM ProductArchive;