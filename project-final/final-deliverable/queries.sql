-- test procedure addItemOrder (gold, comics)
exec addItemOrder('00001', '00002', '00001','01-JUN-22',1,NULL);
SELECT computeTotal('00001') FROM DUAL;

-- test procedure addItemOrder (regular, comics)
exec addItemOrder('00002', '00002', '00008','01-JUN-22',2,NULL);
SELECT computeTotal('00002') FROM DUAL;

-- test procedure addItemOrder (gold, tshirts)
exec addItemOrder('00003', '00005', '00001','01-JUN-22',3,NULL);
SELECT computeTotal('00003') FROM DUAL;

-- test procedure addItemOrder (regular, tshirts)
exec addItemOrder('00004', '00008', '00008','01-JUN-22',4,NULL);
SELECT computeTotal('00004') FROM DUAL;

-- test procedure addItemOrder (insufficient items exception)
SELECT * FROM ComicBooks;
exec addItemOrder('00005', '00002', '00001','01-JUN-22',10,NULL);
SELECT * FROM ComicBooks;

-- compare gold member total vs. regular member total (discount/shipping fee)
-- gold member
exec addItemOrder('00006', '00001', '00003','01-JUN-22',1,NULL);
SELECT computeTotal('00006') FROM DUAL;
-- regular member
exec addItemOrder('00007', '00001', '00008','01-JUN-22',1,NULL);
SELECT computeTotal('00007') FROM DUAL;



-- test trigger changeCustType
SELECT * FROM Customers;
SELECT * FROM Orders;

UPDATE Customers SET custType = 'gold', dateJoined = '05-FEB-22' WHERE custID = '00008';
UPDATE Customers SET custType = 'regular', dateJoined = NULL WHERE custID = '00001';

SELECT * FROM Customers;
SELECT * FROM Orders;



-- test procedure setShippingDate
SELECT * FROM Orders;
exec setShippingDate('00001', '02-JUN-22');
SELECT * FROM Orders;

-- test procedure setShippingDate (shipping date before order date exception)
exec setShippingDate('00002', '01-MAY-22');
SELECT * FROM Orders;



-- test procedure showItemOrders
exec addItemOrder('00008', '00004', '00008','01-JUN-22',3,NULL);
exec addItemOrder('00009', '00007', '00008','01-JUN-22',12,NULL);
exec showItemOrders('00008', '01-MAY-22');

-- test procedure showItemOrders (before date)
exec addItemOrder('00010', '00006', '00008','01-APR-22',4,NULL);
exec showItemOrders('00008', '01-MAY-22');