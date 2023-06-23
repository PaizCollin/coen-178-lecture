-- Procedure: addItemOrder
-- adds item order into the Orders table
CREATE OR REPLACE PROCEDURE addItemOrder(p_orderID in Orders.orderID%type, p_itemID in Orders.itemID%type, p_custID in Orders.custID%type, p_dateOrdered in Orders.dateOrdered%type, p_numItems in Orders.numItems%type, p_shippedDate in Orders.shippedDate%type)
AS
    insufficientItems EXCEPTION;
    l_numCopies ComicBooks.numCopies%type;
    l_custType Customers.custType%type;
    l_shippingFee Orders.shippingFee%type;

BEGIN
    SELECT numCopies INTO l_numCopies FROM ComicBooks WHERE itemID = p_itemID;
    SELECT custType INTO l_custType FROM Customers WHERE custID = p_custID;

    -- if gold member, set fee to $0.00, else $10.00 for regular members
    IF(l_custType = 'regular') THEN 
        l_shippingFee := 10.00;
    ELSIF(l_custType = 'gold') THEN 
        l_shippingFee := 0.00;
    END IF;

    -- if enough items in stock for order, insert order, update combook numCopies
    IF(l_numCopies >= p_numItems) THEN
        INSERT INTO Orders VALUES (p_orderID, p_custID, p_itemID, p_dateOrdered, p_numItems, NULL, l_shippingFee);
        UPDATE ComicBooks SET numCopies = l_numCopies - p_numItems WHERE itemID = p_itemID;
    ELSE
        RAISE insufficientItems;
    END IF;

EXCEPTION
    WHEN insufficientItems THEN DBMS_OUTPUT.PUT_LINE('Insufficient item stock');
    WHEN NO_DATA_FOUND THEN
    DECLARE
        l_custType Customers.custType%type;
        l_shippingFee Orders.shippingFee%type;
    BEGIN
        SELECT custType INTO l_custType FROM Customers WHERE custID = p_custID;
        IF(l_custType = 'regular') THEN 
            l_shippingFee := 10.00;
        ELSIF(l_custType = 'gold') THEN 
            l_shippingFee := 0.00;
        END IF;

        INSERT INTO Orders VALUES (p_orderID, p_custID, p_itemID, p_dateOrdered, p_numItems, NULL, l_shippingFee);
    END;
END;
/
show errors;



-- Trigger: changeCustType
-- updates the shipping fee on orders based on customer's type (gold $0.00, regular $10.00)
CREATE OR REPLACE TRIGGER changeCustType 
    AFTER UPDATE ON Customers
    FOR EACH ROW
BEGIN
    IF :new.custType = 'gold' THEN
        UPDATE Orders SET shippingFee = 0.00 WHERE custID = :new.custID AND (SYSDATE() <= shippedDate OR shippedDate IS NULL);
    ELSE
        UPDATE Orders SET shippingFee = 10.00 WHERE custID = :new.custID AND (SYSDATE() <= shippedDate OR shippedDate IS NULL);
    END IF;
END changeCustType;
/
show errors;



-- Procedure: setShippingDate
-- sets shipping date in Orders table based on provided orderID and date
CREATE OR REPLACE PROCEDURE setShippingDate(p_orderID in Orders.orderID%type, p_shippedDate in Orders.shippedDate%type)
AS
    shipBeforeOrder EXCEPTION;
    l_dateOrdered Orders.dateOrdered%type;

BEGIN
    SELECT dateOrdered INTO l_dateOrdered FROM Orders WHERE orderID = p_orderID;
    
    IF(l_dateOrdered <= p_shippedDate) THEN
        UPDATE Orders SET shippedDate = p_shippedDate WHERE orderID = p_orderID;
    ELSE
        RAISE shipBeforeOrder;
    END IF;

EXCEPTION
    WHEN shipBeforeOrder THEN DBMS_OUTPUT.PUT_LINE('Shipping date must not come before order date');

END;
/
show errors;



-- Procedure: computeTotal
-- takes an orderID, computes the total for that order and returns that total
CREATE OR REPLACE FUNCTION computeTotal(p_orderID in Orders.orderID%type)
RETURN NUMBER 
IS
    l_subtotal StoreItems.price%type;
    l_total StoreItems.price%type;
    l_price StoreItems.price%type;
    l_tax StoreItems.price%type;
    l_shippingFee Orders.shippingFee%type;
    l_numItems Orders.numItems%type;
    l_itemID Orders.itemID%type;

BEGIN
    SELECT itemID INTO l_itemID FROM Orders WHERE orderID = p_orderID;
    SELECT price INTO l_price FROM StoreItems WHERE itemID = l_itemID;
    SELECT numItems INTO l_numItems FROM Orders WHERE orderID = p_orderID;
    SELECT shippingFee INTO l_shippingFee FROM Orders WHERE orderID = p_orderID;

    l_subtotal := l_price * l_numItems;

    IF(l_shippingFee = 0.00 AND l_subtotal >= 100.00) THEN
        l_subtotal := l_subtotal * 0.9;
    END IF;

    l_tax := l_subtotal * 0.05;
    l_total := l_subtotal + l_shippingFee + l_tax;

    RETURN l_total;
END;
/
show errors;

-- Procedure: showItemOrders
-- displays the details of each item order from a customer after a certain date
CREATE OR REPLACE PROCEDURE showItemOrders(p_custID in Orders.custID%type, p_date in Orders.dateOrdered%type)
AS
    l_custID Customers.custID%type;
    l_name Customers.name%type;
    l_phone Customers.phone%type;
    l_address Customers.address%type;

    l_orderID Orders.orderID%type;
    l_itemID Orders.itemID%type;
    l_title ComicBooks.title%type;
    l_price StoreItems.price%type;
    l_shirtSize TShirts.shirtSize%type;
    l_dateOrdered Orders.dateOrdered%type;
    l_shippedDate Orders.shippedDate%type;
    l_numItems Orders.numItems%type;

    l_subtotal StoreItems.price%type;
    l_tax StoreItems.price%type;
    l_shippingFee StoreItems.price%type;
    l_discount StoreItems.price%type;
    l_itemstotal StoreItems.price%type;
    l_grandtotal StoreItems.price%type := 0.0;

    CURSOR c_comics IS SELECT orderID, custID, itemID, title, price, dateOrdered, shippedDate, numItems, shippingFee FROM (ComicBooks JOIN ORDERS USING(itemID)) JOIN StoreItems USING(itemID) WHERE custID = p_custID AND dateOrdered >= p_date;

    CURSOR c_tshirts IS SELECT orderID, custID, itemID, shirtSize, price, dateOrdered, shippedDate, numItems, shippingFee FROM (TShirts JOIN ORDERS USING(itemID)) JOIN StoreItems USING(itemID) WHERE custID = p_custID AND dateOrdered >= p_date;

BEGIN
    SELECT custID, name, phone, address INTO l_custID, l_name, l_phone, l_address FROM Customers WHERE custID = p_custID;
    DBMS_OUTPUT.PUT_LINE('Customer Details: ');
    DBMS_OUTPUT.PUT_LINE('CustomerID: ' || l_custID || ' | Name: ' || l_name || ' | Phone: ' || l_phone || ' | Address: ' || l_address);

    DBMS_OUTPUT.PUT_LINE('Comic Book Orders: ');
    OPEN c_comics;
    LOOP
        FETCH c_comics INTO l_orderID, l_custID, l_itemID, l_title, l_price, l_dateOrdered, l_shippedDate, l_numItems, l_shippingFee;
        EXIT WHEN c_comics%notfound;

        l_subtotal := l_price * l_numItems;

        IF(l_shippingFee = 0.00 AND l_subtotal >= 100.00) THEN
            l_discount := 0.10;
        ELSE
            l_discount := 0.00;
        END IF;

        l_discount := l_discount * l_subtotal;
        l_subtotal := l_subtotal - l_discount;
        l_tax := l_subtotal * 0.05;
        l_subtotal := l_subtotal + l_tax;
        l_itemstotal := l_subtotal + l_shippingFee;
        l_grandtotal := l_grandtotal + l_itemstotal;

        DBMS_OUTPUT.PUT_LINE('OrderID: ' || l_orderID || ' | ItemID: ' || l_itemID || ' | Title: ' || l_title || ' | Price: $' || l_price || ' | Date Ordered: ' || l_dateOrdered || ' | Date Shipped: ' || l_shippedDate || ' | Count: ' || l_numItems || ' | Discount: $' || l_discount || ' | Tax: $' || l_tax || ' | Order Total: $' || l_itemsTotal);
    END LOOP;
    CLOSE c_comics;

    DBMS_OUTPUT.PUT_LINE('TShirt Orders: ');
    OPEN c_tshirts;
    LOOP
        FETCH c_tshirts INTO l_orderID, l_custID, l_itemID, l_shirtSize, l_price, l_dateOrdered, l_shippedDate, l_numItems, l_shippingFee;
        EXIT WHEN c_tshirts%notfound;
        
        l_subtotal := l_price * l_numItems;

        IF(l_shippingFee = 0.00 AND l_subtotal >= 100.00) THEN
            l_discount := 0.10;
        ELSE
            l_discount := 0.00;
        END IF;

        l_discount := l_discount * l_subtotal;
        l_subtotal := l_subtotal - l_discount;
        l_tax := l_subtotal * 0.05;
        l_subtotal := l_subtotal + l_tax;
        l_itemstotal := l_subtotal + l_shippingFee;
        l_grandtotal := l_grandtotal + l_itemstotal;

        DBMS_OUTPUT.PUT_LINE('OrderID: ' || l_orderID || ' | ItemID: ' || l_itemID || ' | Size: ' || l_shirtSize || ' | Price: $' || l_price || ' | Date Ordered: ' || l_dateOrdered || ' | Date Shipped: ' || l_shippedDate || ' | Count: ' || l_numItems || ' | Discount: $' || l_discount || ' | Tax: $' || l_tax || ' | Order Total: $' || l_itemsTotal);
    END LOOP;
    CLOSE c_tshirts;

    DBMS_OUTPUT.PUT_LINE( ' Grand Total: $' || l_grandtotal);
END;
/
show errors;