INSERT INTO Customers VALUES ('00001', 'Collin', 8585250001, '111 Seagrove St', '01-JAN-22', 'gold');
INSERT INTO Customers VALUES ('00002', 'Sam', 8585250002, '222 Seachase St', '01-JAN-22', 'gold');
INSERT INTO Customers VALUES ('00003', 'Rob', 4187931234, '333 Benton St', '01-JAN-22', 'gold');
INSERT INTO Customers VALUES ('00004', 'Kyle', 8585250003, '444 Pepperdine Bend', '01-JAN-22', 'gold');
INSERT INTO Customers VALUES ('00005', 'Jason', 4187935678, '555 Bradshaw Ct', NULL, 'regular');
INSERT INTO Customers VALUES ('00006', 'Augustine', 8585250004, '666 Seagrove St', NULL, 'regular');
INSERT INTO Customers VALUES ('00007', 'David', 8585250005, '777 Del Mar Heights St', NULL, 'regular');
INSERT INTO Customers VALUES ('00008', 'Andrew', 8585250006, '888 Pepperdine Bend', NULL, 'regular');

INSERT INTO StoreItems VALUES ('00001', 100.00);
INSERT INTO StoreItems VALUES ('00002', 50.00);
INSERT INTO StoreItems VALUES ('00003', 80.00);
INSERT INTO StoreItems VALUES ('00004', 20.50);
INSERT INTO StoreItems VALUES ('00005', 30.00);
INSERT INTO StoreItems VALUES ('00006', 35.00);
INSERT INTO StoreItems VALUES ('00007', 19.50);
INSERT INTO StoreItems VALUES ('00008', 25.00);

INSERT INTO ComicBooks VALUES ('00001', '1111111111111', '28-FEB-99', 2, 'Databaseables I');
INSERT INTO ComicBooks VALUES ('00002', '2222222222222', '05-FEB-01', 5, 'Databaseables II');
INSERT INTO ComicBooks VALUES ('00003', '3333333333333', '01-AUG-01', 10, 'Databaseables III');
INSERT INTO ComicBooks VALUES ('00004', '4444444444444', '21-OCT-01', 20, 'Databaseables IV');

INSERT INTO TShirts VALUES ('00005', 'M');
INSERT INTO TShirts VALUES ('00006', 'XL');
INSERT INTO TShirts VALUES ('00007', 'S');
INSERT INTO TShirts VALUES ('00008', 'L');

SELECT * FROM Customers;
SELECT * FROM StoreItems;
SELECT * FROM ComicBooks;
SELECT * FROM TShirts;
