CREATE TABLE Authors (
    AuthorID INT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    BirthYear INT
);

CREATE TABLE Books (
    ISBN CHAR(13) PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    Publisher VARCHAR(255),
    PublicationYear INT,
    Price DECIMAL(10,2) NOT NULL,
    StockQuantity INT NOT NULL
);

CREATE TABLE BookAuthors (
    ISBN CHAR(13) NOT NULL,
    AuthorID INT NOT NULL,
    PRIMARY KEY (ISBN, AuthorID),
    FOREIGN KEY (ISBN) REFERENCES Books(ISBN)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    Address VARCHAR(255),
    RegistrationDate DATE
);


CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATE NOT NULL,
    TotalAmount DECIMAL(10,2) NOT NULL,
    Status VARCHAR(50) NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


CREATE TABLE OrderItems (
    OrderID INT NOT NULL,
    ISBN CHAR(13) NOT NULL,
    Quantity INT NOT NULL,
    PriceAtOrder DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (OrderID, ISBN),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (ISBN) REFERENCES Books(ISBN)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);


INSERT INTO Authors (AuthorID, Name, BirthYear) VALUES
(1, 'J.K. Rowling', 1965),
(2, 'George R.R. Martin', 1948),
(3, 'Isaac Asimov', 1920),
(4, 'Neil Gaiman', 1960),
(5, 'Terry Pratchett', 1948);


INSERT INTO Books (ISBN, Title, Publisher, PublicationYear, Price, StockQuantity) VALUES
('9780747532743', 'Harry Potter and the Philosopher''s Stone', 'Bloomsbury', 1997, 20.99, 50),
('9780553103540', 'A Game of Thrones', 'Bantam', 1996, 25.50, 30),
('9780553108033', 'A Clash of Kings', 'Bantam', 1998, 27.00, 25),
('9780451524935', 'Foundation', 'Gnome Press', 1951, 15.99, 40),
('9780060558123', 'American Gods', 'HarperCollins', 2001, 22.00, 20),
('9780060853983', 'Good Omens', 'HarperCollins', 1990, 18.50, 15),
('9780006479888', 'The Colour of Magic', 'Corgi', 1983, 17.00, 10),
('9780553579901', 'A Storm of Swords', 'Bantam', 2000, 28.50, 20),
('9780553382563', 'I, Robot', 'Gnome Press', 1950, 14.99, 35),
('9780062278470', 'Coraline', 'HarperCollins', 2002, 16.50, 25);


INSERT INTO BookAuthors (ISBN, AuthorID) VALUES
('9780747532743', 1),
('9780553103540', 2),
('9780553108033', 2),
('9780451524935', 3),
('9780553382563', 3),
('9780060558123', 4),
('9780060853983', 4),
('9780060853983', 5), 
('9780006479888', 5),
('9780062278470', 4),
('9780553579901', 2);


INSERT INTO Customers (CustomerID, Name, Email, Address, RegistrationDate) VALUES
(1, 'Alice Johnson', 'alice.johnson@example.com', '123 Main St, Cityville', '2023-01-15'),
(2, 'Bob Smith', 'bob.smith@example.com', '456 Oak Ave, Townsville', '2023-03-22'),
(3, 'Charlie Brown', 'charlie.brown@example.com', '789 Pine Rd, Villagetown', '2023-06-10'),
(4, 'Diana Prince', 'diana.prince@example.com', '321 Elm St, Metropolis', '2023-07-05'),
(5, 'Ethan Hunt', 'ethan.hunt@example.com', '654 Cedar Ln, Gotham', '2023-08-18');


INSERT INTO Orders (OrderID, CustomerID, OrderDate, TotalAmount, Status) VALUES
(1, 1, '2024-01-15', 41.98, 'shipped'),
(2, 2, '2024-02-10', 25.50, 'pending'),
(3, 3, '2024-02-18', 44.00, 'shipped'),
(4, 1, '2024-03-05', 36.50, 'pending'),
(5, 4, '2024-03-20', 22.00, 'shipped'),
(6, 5, '2024-04-02', 45.50, 'pending'),
(7, 2, '2024-04-10', 28.50, 'shipped'),
(8, 3, '2024-05-01', 31.50, 'shipped');


INSERT INTO OrderItems (OrderID, ISBN, Quantity, PriceAtOrder) VALUES
(1, '9780747532743', 2, 20.99),
(2, '9780553103540', 1, 25.50),
(3, '9780060558123', 2, 22.00),
(3, '9780451524935', 1, 15.99),
(4, '9780060853983', 1, 18.50),
(4, '9780006479888', 1, 17.00),
(5, '9780060558123', 1, 22.00),
(6, '9780553108033', 1, 27.00),
(6, '9780553579901', 1, 28.50),
(7, '9780553579901', 1, 28.50),
(8, '9780062278470', 1, 16.50),
(8, '9780451524935', 1, 15.99);


-- 1.List all books with their title, author(s), and price. 
SELECT 
    b.Title,
    STRING_AGG(a.Name, ', ') AS Authors,
    b.Price
FROM Books b
JOIN BookAuthors ba ON b.ISBN = ba.ISBN
JOIN Authors a ON ba.AuthorID = a.AuthorID
GROUP BY b.ISBN, b.Title, b.Price
ORDER BY b.Title;


-- 2.Find all customers who registered in 2023.
SELECT Name, Email, RegistrationDate
FROM Customers
WHERE EXTRACT(YEAR FROM RegistrationDate) = 2023;


--3.Show orders that have a status of 'pending' and were placed in the last 30 days 
SELECT OrderID, CustomerID, OrderDate, TotalAmount, Status
FROM Orders
WHERE Status = 'pending'
  AND OrderDate >= '2024-03-12'::date - INTERVAL '30 days';


--4.Count how many books each author has written.
SELECT a.Name, COUNT(ba.ISBN) AS NumBooks
FROM Authors a
JOIN BookAuthors ba ON a.AuthorID = ba.AuthorID
GROUP BY a.AuthorID, a.Name
ORDER BY NumBooks DESC;


--5.Display the total number of orders placed by each customer, sorted descending.
SELECT c.Name, COUNT(o.OrderID) AS NumOrders
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.Name
ORDER BY NumOrders DESC;


--6.Calculate the total revenue generated from all orders 
SELECT SUM(Quantity * PriceAtOrder) AS TotalRevenue
FROM OrderItems;


--7.Find the top 3 best-selling books by total quantity sold
SELECT b.Title, SUM(oi.Quantity) AS TotalSold
FROM OrderItems oi
JOIN Books b ON oi.ISBN = b.ISBN
GROUP BY b.ISBN, b.Title
ORDER BY TotalSold DESC
LIMIT 3;


--8.List customers who have spent more than $100 in total across all their orders
SELECT c.Name, SUM(oi.Quantity * oi.PriceAtOrder) AS TotalSpent
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderItems oi ON o.OrderID = oi.OrderID
GROUP BY c.CustomerID, c.Name
HAVING SUM(oi.Quantity * oi.PriceAtOrder) > 100
ORDER BY TotalSpent DESC;


--9.For each month in 2024, show the number of orders and total sales. 
SELECT 
    TO_CHAR(OrderDate, 'YYYY-MM') AS Month,
    COUNT(DISTINCT o.OrderID) AS NumOrders,
    SUM(oi.Quantity * oi.PriceAtOrder) AS TotalSales
FROM Orders o
JOIN OrderItems oi ON o.OrderID = oi.OrderID
WHERE EXTRACT(YEAR FROM OrderDate) = 2024
GROUP BY TO_CHAR(OrderDate, 'YYYY-MM')
ORDER BY Month;

