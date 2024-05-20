CREATE TABLE CUSTOMERS(
     CUSTOMER_ID NUMBER(6,0), 
     CUST_FIRST_NAME VARCHAR2(20), 
     CUST_LAST_NAME VARCHAR2(20), 
     CREDIT_LIMIT NUMBER(9,2), 
     CUST_EMAIL VARCHAR2(30), 
     INCOME_LEVEL VARCHAR2(20), 
     REGION VARCHAR2(1));


SELECT * FROM CUSTOMERS


CREATE TABLE ORDER_ITEMS 
    (ORDER_ID NUMBER(12), 
    LINE_ITEM_ID NUMBER(3), 
    PRODUCT_ID NUMBER(6), 
    UNIT_PRICE NUMBER(8), 
    QUANTITY NUMBER(8)) ;
    
    
SELECT * FROM  ORDER_ITEMS


CREATE TABLE ORDERS 
    (ORDER_ID NUMBER(12), 
    ORDER_DATE TIMESTAMP (6) WITH LOCAL TIME ZONE, 
    ORDER_MODE VARCHAR2(8), 
    CUSTOMER_ID NUMBER(6), 
    ORDER_STATUS NUMBER(2), 
    ORDER_TOTAL NUMBER(8), 
    SALES_REP_ID NUMBER(6), 
    PROMOTION_ID NUMBER(6)) ;
    
SELECT * FROM ORDERS

CREATE TABLE PRODUCT_INFORMATION 
    (PRODUCT_ID NUMBER(6), 
    PRODUCT_NAME VARCHAR2(50), 
    PRODUCT_DESCRIPTION VARCHAR2(2000), 
    CATEGORY_ID NUMBER(2), 
    WEIGHT_CLASS NUMBER(1), 
    WARRANTY_PERIOD INTERVAL YEAR (2) TO MONTH, 
    SUPPLIER_ID NUMBER(6), 
    PRODUCT_STATUS VARCHAR2(20), 
    LIST_PRICE NUMBER(8), 
    MIN_PRICE NUMBER(8,2), 
    CATALOG_URL VARCHAR2(50)) ;
    
Insert into PRODUCT_INFORMATION (PRODUCT_ID,PRODUCT_NAME,PRODUCT_DESCRIPTION,CATEGORY_ID,WEIGHT_CLASS,WARRANTY_PERIOD,SUPPLIER_ID,PRODUCT_STATUS,LIST_PRICE,MIN_PRICE,CATALOG_URL) values (3091,'VRAM - 64 MB','Citrus Video RAM memory module - 64 MB capacity. Physically, VRAM looks just like DRAM with added hardware called a shift register. The special feature of VRAM is that it can transfer one entire row of data (up to 256 bits) into this shift register in a single clock cycle. This ability significantly reduces retrieval time, since the number of fetches is reduced from a possible 256 to a single fetch. The main benefit of having a shift register available for data dumps is that it frees the CPU to refresh the screen rather than retrieve data, thereby doubling the data bandwidth. For this reason, VRAM is often referred to as being dual-ported. However, the shift register will only be used when the VRAM chip is given special instructions to do so. The command to use the shift register is built into the graphics controller.',14,1,'0-6',102098,'orderable',279,243,'http://www.supp-102098.com/cat/hw/p3091.html');
Insert into PRODUCT_INFORMATION (PRODUCT_ID,PRODUCT_NAME,PRODUCT_DESCRIPTION,CATEGORY_ID,WEIGHT_CLASS,WARRANTY_PERIOD,SUPPLIER_ID,PRODUCT_STATUS,LIST_PRICE,MIN_PRICE,CATALOG_URL) values (1787,'CPU D300','Dual CPU @ 300Mhz. For light personal processing only, or file servers with less than 5 concurrent users. This product will probably become obsolete soon.',15,1,'3-0',102097,'orderable',101,90,'http://www.supp-102097.com/cat/hw/p1787.html');
Insert into PRODUCT_INFORMATION (PRODUCT_ID,PRODUCT_NAME,PRODUCT_DESCRIPTION,CATEGORY_ID,WEIGHT_CLASS,WARRANTY_PERIOD,SUPPLIER_ID,PRODUCT_STATUS,LIST_PRICE,MIN_PRICE,CATALOG_URL) values (2439,'CPU D400','Dual CPU @ 400Mhz. Good price/performance ratio; for mid-size LAN file servers (up to 100 concurrent users).',15,1,'3-0',102092,'orderable',123,105,'http://www.supp-102092.com/cat/hw/p2439.html');
Insert into PRODUCT_INFORMATION (PRODUCT_ID,PRODUCT_NAME,PRODUCT_DESCRIPTION,CATEGORY_ID,WEIGHT_CLASS,WARRANTY_PERIOD,SUPPLIER_ID,PRODUCT_STATUS,LIST_PRICE,MIN_PRICE,CATALOG_URL) values (1788,'CPU D600','Dual CPU @ 600Mhz. State of the art, high clock speed; for heavy load WAN servers (up to 200 concurrent users).',15,1,'5-0',102067,'orderable',178,149,'http://www.supp-102067.com/cat/hw/p1788.html');
    
SELECT * FROM PRODUCT_INFORMATION
    
    
    
    
CREATE DATABASE LINK tienda2 CONNECT TO SYSTEM IDENTIFIED BY "12345" USING
'(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=172.17.0.3)(PORT=1521))
(CONNECT_DATA=(SERVER=dedicated)(SID=XE)))';

SELECT * FROM CUSTOMERS@TIENDA2
SELECT * FROM ORDER_ITEMS@TIENDA2
SELECT * FROM ORDERS @TIENDA2
--SELECT * FROM PRODUCT_INFORMATION@TIENDA2

--Sinonimos 

-- Sinónimos en Tienda1 para acceder a Tienda2
CREATE SYNONYM CUSTOMERS_T2 FOR CUSTOMERS@TIENDA2;
CREATE SYNONYM ORDERS_T2 FOR ORDERS@TIENDA2;
CREATE SYNONYM ORDER_ITEMS_T2 FOR ORDER_ITEMS@TIENDA2;
--CREATE SYNONYM PRODUCT_INFORMATION_T2 FOR PRODUCT_INFORMATION@TIENDA2;

SELECT * FROM ORDERS_T2
SELECT * FROM CUSTOMERS_T2
SELECT * FROM ORDER_ITEMS_T2



--PROCESAMIENTO ALMACENADOS(CLIENTES)
CREATE OR REPLACE PROCEDURE INSERT_CUSTOMER(
    p_customer_id IN NUMBER,
    p_first_name IN VARCHAR2,
    p_last_name IN VARCHAR2,
    p_credit_limit IN NUMBER,
    p_cust_email IN VARCHAR2,
    p_income_level IN VARCHAR2,
    p_region IN VARCHAR2
) AS
BEGIN
    -- Insertar un nuevo cliente
    INSERT INTO CUSTOMERS (
        CUSTOMER_ID, 
        CUST_FIRST_NAME, 
        CUST_LAST_NAME, 
        CREDIT_LIMIT, 
        CUST_EMAIL, 
        INCOME_LEVEL, 
        REGION
    ) VALUES (
        p_customer_id, 
        p_first_name, 
        p_last_name, 
        p_credit_limit, 
        p_cust_email, 
        p_income_level, 
        p_region
    );
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error al insertar el cliente: ' || SQLERRM);
END;
/
--Ejemplo de Insertar 
BEGIN
    INSERT_CUSTOMER(
        p_customer_id => 123456,
        p_first_name => 'John',
        p_last_name => 'Doe',
        p_credit_limit => 5000,
        p_cust_email => 'john.doe@example.com',
        p_income_level => 'High',
        p_region => 'A'
    );
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al insertar cliente: ' || SQLERRM);
        ROLLBACK;
END;
/

CREATE OR REPLACE PROCEDURE UPDATE_CUSTOMER(
    p_customer_id IN NUMBER,
    p_first_name IN VARCHAR2,
    p_last_name IN VARCHAR2,
    p_credit_limit IN NUMBER,
    p_cust_email IN VARCHAR2,
    p_income_level IN VARCHAR2,
    p_region IN VARCHAR2
) AS
BEGIN
    -- Actualizar detalles del cliente
    UPDATE CUSTOMERS SET
        CUST_FIRST_NAME = p_first_name,
        CUST_LAST_NAME = p_last_name,
        CREDIT_LIMIT = p_credit_limit,
        CUST_EMAIL = p_cust_email,
        INCOME_LEVEL = p_income_level,
        REGION = p_region
    WHERE CUSTOMER_ID = p_customer_id;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No se encontró el cliente con ID: ' || p_customer_id);
    ELSE
        COMMIT;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error al actualizar el cliente: ' || SQLERRM);
END;
/
--EJEMPLO DE ACTUALIZAR 
BEGIN
    UPDATE_CUSTOMER(
        p_customer_id => 123456,
        p_first_name => 'John',
        p_last_name => 'Doe Updated',
        p_credit_limit => 10000,
        p_cust_email => 'john.updated@example.com',
        p_income_level => 'Very High',
        p_region => 'B'
    );
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al actualizar cliente: ' || SQLERRM);
        ROLLBACK;
END;
/


CREATE OR REPLACE PROCEDURE DELETE_CUSTOMER(
    p_customer_id IN NUMBER
) AS
BEGIN
    -- Eliminar un cliente
    DELETE FROM CUSTOMERS WHERE CUSTOMER_ID = p_customer_id;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No se encontró el cliente con ID: ' || p_customer_id);
    ELSE
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Cliente eliminado exitosamente con ID: ' || p_customer_id);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error al eliminar el cliente: ' || SQLERRM);
END;
/
--EJEMPLO DE ELIMINAR 
BEGIN
    DELETE_CUSTOMER(
        p_customer_id => 123456
    );
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al eliminar cliente: ' || SQLERRM);
        ROLLBACK;
END;
/

--PROCESAMIENTO ALMACENADOS(OREDER_ITEMS)
CREATE OR REPLACE PROCEDURE INSERT_ORDER_ITEM(
    p_order_id IN NUMBER,
    p_line_item_id IN NUMBER,
    p_product_id IN NUMBER,
    p_unit_price IN NUMBER,
    p_quantity IN NUMBER
) AS
BEGIN
    INSERT INTO ORDER_ITEMS (
        ORDER_ID, 
        LINE_ITEM_ID, 
        PRODUCT_ID, 
        UNIT_PRICE, 
        QUANTITY
    ) VALUES (
        p_order_id, 
        p_line_item_id, 
        p_product_id, 
        p_unit_price, 
        p_quantity
    );
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error al insertar ítem de orden: ' || SQLERRM);
END;
/
--EJEMPLO DE INSERTAR 
BEGIN
    INSERT_ORDER_ITEM(
        p_order_id => 1001,
        p_line_item_id => 1,
        p_product_id => 501,
        p_unit_price => 199.99,
        p_quantity => 2
    );
    COMMIT; -- Esta línea es opcional si el procedimiento ya maneja la transacción.
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al insertar ítem de orden: ' || SQLERRM);
        ROLLBACK;
END;
/


CREATE OR REPLACE PROCEDURE UPDATE_ORDER_ITEM(
    p_order_id IN NUMBER,
    p_line_item_id IN NUMBER,
    p_product_id IN NUMBER,
    p_unit_price IN NUMBER,
    p_quantity IN NUMBER
) AS
BEGIN
    UPDATE ORDER_ITEMS SET
        PRODUCT_ID = p_product_id,
        UNIT_PRICE = p_unit_price,
        QUANTITY = p_quantity
    WHERE ORDER_ID = p_order_id AND LINE_ITEM_ID = p_line_item_id;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No se encontró el ítem de orden con ORDER_ID: ' || p_order_id || ' y LINE_ITEM_ID: ' || p_line_item_id);
    ELSE
        COMMIT;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error al actualizar ítem de orden: ' || SQLERRM);
END;
/
--EJEMPLO DE ACTUALIZAR 
BEGIN
    UPDATE_ORDER_ITEM(
        p_order_id => 1001,
        p_line_item_id => 1,
        p_product_id => 501,
        p_unit_price => 209.99,  -- Nuevo precio unitario
        p_quantity => 3          -- Nueva cantidad
    );
    COMMIT; -- Confirmar la transacción si se realizan cambios
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al actualizar ítem de orden: ' || SQLERRM);
        ROLLBACK;
END;
/

CREATE OR REPLACE PROCEDURE DELETE_ORDER_ITEM(
    p_order_id IN NUMBER,
    p_line_item_id IN NUMBER
) AS
BEGIN
    DELETE FROM ORDER_ITEMS WHERE ORDER_ID = p_order_id AND LINE_ITEM_ID = p_line_item_id;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No se encontró el ítem de orden con ORDER_ID: ' || p_order_id || ' y LINE_ITEM_ID: ' || p_line_item_id);
    ELSE
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Ítem de orden eliminado exitosamente con ORDER_ID: ' || p_order_id || ' y LINE_ITEM_ID: ' || p_line_item_id);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error al eliminar ítem de orden: ' || SQLERRM);
END;
/
--EJEMPLO DE ELIMINAR 
BEGIN
    DELETE_ORDER_ITEM(
        p_order_id => 1001,
        p_line_item_id => 1
    );
    COMMIT; -- Confirmar la eliminación
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al eliminar ítem de orden: ' || SQLERRM);
        ROLLBACK;
END;
/







--PROCESAMIENTO ALMACENADOS(ORDENES)
CREATE OR REPLACE PROCEDURE INSERT_ORDER(
    p_order_id IN NUMBER,
    p_order_date IN TIMESTAMP,
    p_order_mode IN VARCHAR2,
    p_customer_id IN NUMBER,
    p_order_status IN NUMBER,
    p_order_total IN NUMBER,
    p_sales_rep_id IN NUMBER,
    p_promotion_id IN NUMBER
) AS
BEGIN
    INSERT INTO ORDERS (
        ORDER_ID, 
        ORDER_DATE, 
        ORDER_MODE, 
        CUSTOMER_ID, 
        ORDER_STATUS, 
        ORDER_TOTAL, 
        SALES_REP_ID, 
        PROMOTION_ID
    ) VALUES (
        p_order_id, 
        p_order_date, 
        p_order_mode, 
        p_customer_id, 
        p_order_status, 
        p_order_total, 
        p_sales_rep_id, 
        p_promotion_id
    );
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error al insertar la orden: ' || SQLERRM);
END;
/
--EJEMPLO DE  INSERTAR 
BEGIN
    INSERT_ORDER(
        p_order_id => 5001,
        p_order_date => SYSTIMESTAMP,
        p_order_mode => 'Online',
        p_customer_id => 123456,
        p_order_status => 1,
        p_order_total => 299.99,
        p_sales_rep_id => 789,
        p_promotion_id => 101
    );
    COMMIT; -- Esta línea es opcional, ya que el procedimiento maneja la transacción.
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al insertar la orden: ' || SQLERRM);
        ROLLBACK;
END;
/


CREATE OR REPLACE PROCEDURE UPDATE_ORDER(
    p_order_id IN NUMBER,
    p_order_date IN TIMESTAMP,
    p_order_mode IN VARCHAR2,
    p_customer_id IN NUMBER,
    p_order_status IN NUMBER,
    p_order_total IN NUMBER,
    p_sales_rep_id IN NUMBER,
    p_promotion_id IN NUMBER
) AS
BEGIN
    UPDATE ORDERS SET
        ORDER_DATE = p_order_date,
        ORDER_MODE = p_order_mode,
        CUSTOMER_ID = p_customer_id,
        ORDER_STATUS = p_order_status,
        ORDER_TOTAL = p_order_total,
        SALES_REP_ID = p_sales_rep_id,
        PROMOTION_ID = p_promotion_id
    WHERE ORDER_ID = p_order_id;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No se encontró la orden con ORDER_ID: ' || p_order_id);
    ELSE
        COMMIT;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error al actualizar la orden: ' || SQLERRM);
END;
/
--EJEMPLO DE ACTUALIZAR 
BEGIN
    UPDATE_ORDER(
        p_order_id => 5001,
        p_order_date => SYSTIMESTAMP,
        p_order_mode => 'In-Store',
        p_customer_id => 123456,
        p_order_status => 2,
        p_order_total => 359.99,
        p_sales_rep_id => 789,
        p_promotion_id => 102
    );
    COMMIT; -- Esta línea es opcional, ya que el procedimiento maneja la transacción.
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al actualizar la orden: ' || SQLERRM);
        ROLLBACK;
END;
/


CREATE OR REPLACE PROCEDURE DELETE_ORDER(
    p_order_id IN NUMBER
) AS
BEGIN
    DELETE FROM ORDERS WHERE ORDER_ID = p_order_id;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No se encontró la orden con ORDER_ID: ' || p_order_id);
    ELSE
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Orden eliminada exitosamente con ORDER_ID: ' || p_order_id);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error al eliminar la orden: ' || SQLERRM);
END;
/
--EJEMPLO DE ELIMINAR 
BEGIN
    DELETE_ORDER(
        p_order_id => 5001
    );
    COMMIT; -- Esta línea es opcional, ya que el procedimiento maneja la transacción.
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al eliminar la orden: ' || SQLERRM);
        ROLLBACK;
END;
/










--PROCESAMIENTO ALMACENADOS(INFORMACION DE PRODUCTOS)

CREATE OR REPLACE PROCEDURE MANIPULATE_PRODUCT_INFORMATION(
    p_product_id IN NUMBER,
    p_product_name IN VARCHAR2,
    p_product_description IN VARCHAR2,
    p_category_id IN NUMBER,
    p_weight_class IN NUMBER,
    p_warranty_period IN INTERVAL YEAR TO MONTH,
    p_supplier_id IN NUMBER,
    p_product_status IN VARCHAR2,
    p_list_price IN NUMBER,
    p_min_price IN NUMBER,
    p_catalog_url IN VARCHAR2
) AS
BEGIN
    -- Insertar un nuevo producto en la tabla PRODUCT_INFORMATION
    INSERT INTO PRODUCT_INFORMATION (
        PRODUCT_ID, 
        PRODUCT_NAME, 
        PRODUCT_DESCRIPTION, 
        CATEGORY_ID, 
        WEIGHT_CLASS, 
        WARRANTY_PERIOD, 
        SUPPLIER_ID, 
        PRODUCT_STATUS, 
        LIST_PRICE, 
        MIN_PRICE, 
        CATALOG_URL
    ) VALUES (
        p_product_id, 
        p_product_name, 
        p_product_description, 
        p_category_id, 
        p_weight_class, 
        p_warranty_period, 
        p_supplier_id, 
        p_product_status, 
        p_list_price, 
        p_min_price, 
        p_catalog_url
    );
    -- Confirma la inserción
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- Manejo de excepciones, por ejemplo, en caso de error en la inserción
        ROLLBACK; -- Deshace la inserción si ocurre un error
        DBMS_OUTPUT.PUT_LINE('Error al insertar el producto: ' || SQLERRM);
END;
/
--EJEMPLO PARA MANIPULATE  PRODUCT_INFORMACION 
BEGIN
    MANIPULATE_PRODUCT_INFORMATION(
        101, 
        'Laptop Pro', 
        'High-end gaming laptop', 
        1, 
        2, 
        INTERVAL '1' YEAR, 
        300, 
        'Available', 
        1500, 
        1400, 
        'http://example.com/laptop'
    );
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al ejecutar la inserción: ' || SQLERRM);
        ROLLBACK;
END;
/

CREATE OR REPLACE PROCEDURE UPDATE_PRODUCT_INFORMATION(
    p_product_id IN NUMBER,
    p_product_name IN VARCHAR2,
    p_product_description IN VARCHAR2,
    p_category_id IN NUMBER,
    p_weight_class IN NUMBER,
    p_warranty_period IN INTERVAL YEAR TO MONTH,
    p_supplier_id IN NUMBER,
    p_product_status IN VARCHAR2,
    p_list_price IN NUMBER,
    p_min_price IN NUMBER,
    p_catalog_url IN VARCHAR2
) AS
BEGIN
    -- Actualizar el producto con los datos proporcionados
    UPDATE PRODUCT_INFORMATION
    SET
        PRODUCT_NAME = p_product_name,
        PRODUCT_DESCRIPTION = p_product_description,
        CATEGORY_ID = p_category_id,
        WEIGHT_CLASS = p_weight_class,
        WARRANTY_PERIOD = p_warranty_period,
        SUPPLIER_ID = p_supplier_id,
        PRODUCT_STATUS = p_product_status,
        LIST_PRICE = p_list_price,
        MIN_PRICE = p_min_price,
        CATALOG_URL = p_catalog_url
    WHERE PRODUCT_ID = p_product_id;

    -- Verificar si la fila fue actualizada
    IF SQL%ROWCOUNT = 0 THEN
        -- Si ninguna fila es actualizada, imprimir un mensaje
        DBMS_OUTPUT.PUT_LINE('No se encontró el producto con PRODUCT_ID ' || p_product_id || ' para actualizar.');
    ELSE
        -- Si la actualización fue exitosa, confirmar los cambios
        COMMIT;
    END IF;
EXCEPTION
    -- Captura cualquier excepción que pueda ocurrir durante la actualización
    WHEN OTHERS THEN
        -- Si ocurre un error, deshace los cambios
        ROLLBACK;
        -- Imprime el error para el usuario
        DBMS_OUTPUT.PUT_LINE('Error al actualizar el producto: ' || SQLERRM);
END;
/
--Ejemplo de actualizar 
BEGIN
    UPDATE_PRODUCT_INFORMATION(
        101, 'Laptop Pro Plus', 'Updated version of our high-end gaming laptop', 1, 2,
        INTERVAL '2' YEAR, 301, 'Available', 1600, 1500, 'http://example.com/laptoppro'
    );
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Producto no encontrado para actualizar.');
    ELSE
        COMMIT; -- Confirmar la transacción si se actualizó correctamente
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK; -- Revertir en caso de error
        DBMS_OUTPUT.PUT_LINE('Error al actualizar: ' || SQLERRM);
END;
/


CREATE OR REPLACE PROCEDURE DELETE_PRODUCT_INFORMATION(
    p_product_id IN NUMBER
) AS
BEGIN
    -- Intenta eliminar el producto de la tabla PRODUCT_INFORMATION
    DELETE FROM PRODUCT_INFORMATION WHERE PRODUCT_ID = p_product_id;

    -- Verificar si la fila fue eliminada
    IF SQL%ROWCOUNT = 0 THEN
        -- Si ninguna fila es eliminada, imprimir un mensaje indicando que el producto no existe
        DBMS_OUTPUT.PUT_LINE('No se encontró el producto con PRODUCT_ID ' || p_product_id || ' para eliminar.');
    ELSE
        -- Si la eliminación fue exitosa, confirmar los cambios
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Producto eliminado exitosamente con PRODUCT_ID ' || p_product_id);
    END IF;
EXCEPTION
    -- Captura cualquier excepción que pueda ocurrir durante la eliminación
    WHEN OTHERS THEN
        -- Si ocurre un error, deshace los cambios
        ROLLBACK;
        -- Imprime el error para el usuario
        DBMS_OUTPUT.PUT_LINE('Error al eliminar el producto: ' || SQLERRM);
END;
/

--Ejemplo de eliminar 
BEGIN
    DELETE_PRODUCT_INFORMATION(101);
    -- Verificar la acción después de intentar eliminar
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Producto no encontrado para eliminar.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Producto eliminado exitosamente.');
        COMMIT; -- Confirmar la transacción solo si se ha eliminado algún producto
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al eliminar: ' || SQLERRM);
        ROLLBACK; -- Revertir en caso de error
END;
/


--Visatas Materalizadas
-- Creación de una vista materializada global para CUSTOMERS
CREATE MATERIALIZED VIEW mv_customers_global
REFRESH ON DEMAND
AS
SELECT * FROM CUSTOMERS
UNION ALL
SELECT * FROM CUSTOMERS_T2;

SELECT * FROM mv_customers_global


-- Creación de una vista materializada global para ORDER_ITEMS
CREATE MATERIALIZED VIEW mv_order_items_global
REFRESH ON DEMAND
AS
SELECT * FROM ORDER_ITEMS
UNION ALL
SELECT * FROM ORDER_ITEMS_T2;

SELECT * FROM mv_order_items_global

-- Creación de una vista materializada global para ORDERS
CREATE MATERIALIZED VIEW mv_orders_global
REFRESH ON DEMAND
AS
SELECT * FROM ORDERS
UNION ALL
SELECT * FROM ORDERS_T2;

SELECT * FROM mv_orders_global

-- Creación de una vista materializada global para PRODUCT_INFORMATION
--CREATE MATERIALIZED VIEW mv_product_information_global
--REFRESH ON DEMAND
--AS
--SELECT * FROM PRODUCT_INFORMATION
--UNION ALL
--SELECT * FROM PRODUCT_INFORMATION_T2;








--FRAGMENTACION POR BASE DE DATOS REGION A Y B TIENDA1



Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('931','Buster','Edwards','900','Buster.Edwards@KINGLET.COM','F: 110,000 - 129,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('934','C. Thomas','Nolte','600','C.Thomas.Nolte@PHOEBE.COM','H: 150,000 - 169,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('980','Daniel','Loren','200','Daniel.Loren@REDSTART.COM','F: 110,000 - 129,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('981','Daniel','Gueney','200','Daniel.Gueney@REDPOLL.COM','K: 250,000 - 299,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('119','Maurice','Hasan','200','Maurice.Hasan@STILT.COM','G: 130,000 - 149,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('124','Diane','Mason','200','Diane.Mason@TROGON.COM','K: 250,000 - 299,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('128','Isabella','Reed','300','Isabella.Reed@BRANT.COM','J: 190,000 - 249,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('133','Kristin','Malden','400','Kristin.Malden@GODWIT.COM','C: 50,000 - 69,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('137','Elia','Brando','500','Elia.Brando@JUNCO.COM','H: 150,000 - 169,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('142','Sachin','Spielberg','500','Sachin.Spielberg@GADWALL.COM','C: 50,000 - 69,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('146','Elia','Fawcett','500','Elia.Fawcett@JACANA.COM','L: 300,000 and above','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('168','Hema','Voight','1200','Hema.Voight@PHALAROPE.COM','H: 150,000 - 169,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('264','George','Adjani','3600','George.Adjani@WILLET.COM','F: 110,000 - 129,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('265','Irene','Laughton','3600','Irene.Laughton@ANHINGA.COM','J: 190,000 - 249,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('267','Prem','Walken','3700','Prem.Walken@BRANT.COM','G: 130,000 - 149,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('268','Kyle','Schneider','3700','Kyle.Schneider@DUNLIN.COM','G: 130,000 - 149,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('269','Kyle','Martin','3700','Kyle.Martin@EIDER.COM','D: 70,000 - 89,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('271','Shelley','Peckinpah','3700','Shelley.Peckinpah@GODWIT.COM','D: 70,000 - 89,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('272','Prem','Garcia','3700','Prem.Garcia@JACANA.COM','I: 170,000 - 189,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('273','Bo','Hitchcock','5000','Bo.Hitchcock@ANHINGA.COM','E: 90,000 - 109,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('274','Bob','McCarthy','5000','Bob.McCarthy@ANI.COM','A: Below 30,000','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('276','Dom','Hoskins','5000','Dom.Hoskins@AVOCET.COM','E: 90,000 - 109,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('380','Meryl','Holden','3700','Meryl.Holden@DIPPER.COM','H: 150,000 - 169,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('447','Richard','Coppola','500','Richard.Coppola@SISKIN.COM','C: 50,000 - 69,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('449','Rick','Romero','1500','Rick.Romero@LONGSPUR.COM','B: 30,000 - 49,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('450','Rick','Lyon','1500','Rick.Lyon@MERGANSER.COM','F: 110,000 - 129,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('451','Ridley','Hackman','700','Ridley.Hackman@ANHINGA.COM','H: 150,000 - 169,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('453','Ridley','Young','700','Ridley.Young@CHUKAR.COM','F: 110,000 - 129,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('454','Rob','Russell','5000','Rob.Russell@VERDIN.COM','E: 90,000 - 109,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('458','Robert','de Niro','3700','Robert.deNiro@DOWITCHER.COM','H: 150,000 - 169,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('466','Rodolfo','Hershey','5000','Rodolfo.Hershey@VIREO.COM','F: 110,000 - 129,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('467','Rodolfo','Dench','5000','Rodolfo.Dench@SCOTER.COM','F: 110,000 - 129,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('120','Diane','Higgins','200','Diane.Higgins@TANAGER.COM','H: 150,000 - 169,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('121','Dianne','Sen','200','Dianne.Sen@TATTLER.COM','H: 150,000 - 169,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('122','Maurice','Daltrey','200','Maurice.Daltrey@TEAL.COM','A: Below 30,000','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('123','Elizabeth','Brown','200','Elizabeth.Brown@THRASHER.COM','F: 110,000 - 129,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('125','Dianne','Andrews','200','Dianne.Andrews@TURNSTONE.COM','F: 110,000 - 129,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('126','Charles','Field','300','Charles.Field@BECARD.COM','F: 110,000 - 129,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('127','Charles','Broderick','300','Charles.Broderick@BITTERN.COM','B: 30,000 - 49,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('129','Louis','Jackson','400','Louis.Jackson@CARACARA.COM','D: 70,000 - 89,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('130','Louis','Edwards','400','Louis.Edwards@CHACHALACA.COM','C: 50,000 - 69,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('131','Doris','Dutt','400','Doris.Dutt@CHUKAR.COM','C: 50,000 - 69,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('166','Dheeraj','Alexander','1200','Dheeraj.Alexander@NUTHATCH.COM','G: 130,000 - 149,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('167','Gerard','Hershey','1200','Gerard.Hershey@PARULA.COM','D: 70,000 - 89,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('169','Dheeraj','Davis','1200','Dheeraj.Davis@PIPIT.COM','F: 110,000 - 129,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('170','Harry Dean','Fonda','1200','HarryDean.Fonda@PLOVER.COM','G: 130,000 - 149,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('171','Hema','Powell','1200','Hema.Powell@SANDERLING.COM','D: 70,000 - 89,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('173','Kathleen','Walken','1200','Kathleen.Walken@VIREO.COM','E: 90,000 - 109,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('174','Blake','Seignier','1200','Blake.Seignier@GALLINULE.COM','H: 150,000 - 169,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('175','Claude','Powell','1200','Claude.Powell@GODWIT.COM','F: 110,000 - 129,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('176','Faye','Glenn','1200','Faye.Glenn@GREBE.COM','B: 30,000 - 49,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('178','Grace','Belushi','1200','Grace.Belushi@KILLDEER.COM','H: 150,000 - 169,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('212','Luchino','Falk','1500','Luchino.Falk@OVENBIRD.COM','L: 300,000 and above','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('214','Robin','Danson','1500','Robin.Danson@PHAINOPEPLA.COM','F: 110,000 - 129,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('215','Orson','Perkins','1900','Orson.Perkins@PINTAIL.COM','E: 90,000 - 109,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('216','Orson','Koirala','1900','Orson.Koirala@PIPIT.COM','J: 190,000 - 249,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('218','Bryan','Dvrrie','2300','Bryan.Dvrrie@REDPOLL.COM','G: 130,000 - 149,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('219','Ajay','Sen','2300','Ajay.Sen@TROGON.COM','K: 250,000 - 299,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('220','Carol','Jordan','2300','Carol.Jordan@TURNSTONE.COM','I: 170,000 - 189,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('221','Carol','Bradford','2300','Carol.Bradford@VERDIN.COM','G: 130,000 - 149,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('223','Cary','Olin','2300','Cary.Olin@WATERTHRUSH.COM','D: 70,000 - 89,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('224','Clara','Krige','2300','Clara.Krige@WHIMBREL.COM','H: 150,000 - 169,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('483','Roy','Bates','5000','Roy.Bates@WIGEON.COM','G: 130,000 - 149,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('731','Margaux','Capshaw','2400','Margaux.Capshaw@EIDER.COM','B: 30,000 - 49,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('757','Kiefer','Reynolds','700','Kiefer.Reynolds@AVOCET.COM','F: 110,000 - 129,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('769','Kris','Harris','400','Kris.Harris@DIPPER.COM','G: 130,000 - 149,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('772','Kristin','Savage','400','Kristin.Savage@CURLEW.COM','F: 110,000 - 129,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('827','Alain','Siegel','500','Alain.Siegel@VIREO.COM','I: 170,000 - 189,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('831','Albert','Bel Geddes','3500','Albert.BelGeddes@DIPPER.COM','E: 90,000 - 109,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('835','Alexander','Eastwood','1200','Alexander.Eastwood@AVOCET.COM','E: 90,000 - 109,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('839','Alfred','Johnson','3500','Alfred.Johnson@FLICKER.COM','J: 190,000 - 249,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('843','Alice','Oates','700','Alice.Oates@BECARD.COM','D: 70,000 - 89,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('828','Alan','Minnelli','2300','Alan.Minnelli@TANAGER.COM','D: 70,000 - 89,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('829','Alan','Hunter','2300','Alan.Hunter@TATTLER.COM','I: 170,000 - 189,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('830','Albert','Dutt','3500','Albert.Dutt@CURLEW.COM','F: 110,000 - 129,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('832','Albert','Spacek','3500','Albert.Spacek@DOWITCHER.COM','F: 110,000 - 129,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('833','Alec','Moranis','3500','Alec.Moranis@DUNLIN.COM','D: 70,000 - 89,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('834','Alec','Idle','3500','Alec.Idle@EIDER.COM','F: 110,000 - 129,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('836','Alexander','Berenger','1200','Alexander.Berenger@BECARD.COM','C: 50,000 - 69,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('837','Alexander','Stanton','1200','Alexander.Stanton@AUKLET.COM','D: 70,000 - 89,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('838','Alfred','Nicholson','3500','Alfred.Nicholson@CREEPER.COM','F: 110,000 - 129,999','A');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('840','Ali','Elliott','1400','Ali.Elliott@ANHINGA.COM','G: 130,000 - 149,999','A');

INSERT INTO orders VALUES (2379
	,TO_TIMESTAMP('16-MAY-07 01.22.24.234567 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,146
	,8
	,17848.2
	,161
	,NULL);
INSERT INTO orders VALUES (2365
	,TO_TIMESTAMP('28-AUG-07 06.03.34.003399 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'online'
	,146
	,9
	,27455.3
	,NULL
	,NULL);
INSERT INTO orders VALUES (2372
	,TO_TIMESTAMP('27-FEB-07 01.22.33.356789 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'online'
	,119
	,9
	,16447.2
	,NULL
	,NULL);
INSERT INTO orders VALUES (2373
	,TO_TIMESTAMP('27-FEB-08 02.34.51.220065 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'online'
	,120
	,4
	,416
	,NULL
	,NULL); 
INSERT INTO orders VALUES (2374
	,TO_TIMESTAMP('27-FEB-08 03.41.45.109654 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'online'
	,121
	,0
	,4797
	,NULL
	,NULL); 
INSERT INTO orders VALUES (2375
	,TO_TIMESTAMP('26-FEB-07 04.49.50.459233 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'online'
	,122
	,2
	,103834.4
	,NULL
	,NULL); 
INSERT INTO orders VALUES (2376
	,TO_TIMESTAMP('07-JUN-07 05.18.08.883310 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'online'
	,123
	,6
	,11006.2
	,NULL
	,NULL);
INSERT INTO orders VALUES (2378
	,TO_TIMESTAMP('24-MAY-07 07.59.10.010101 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'online'
	,142
	,5
	,25691.3
	,NULL
	,NULL);
INSERT INTO orders VALUES (2384
	,TO_TIMESTAMP('12-MAY-08 11.22.34.525972 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'online'
	,146
	,3
	,29249.1
	,NULL
	,NULL);
INSERT INTO orders VALUES (2408
	,TO_TIMESTAMP('29-JUN-07 07.59.31.333617 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,166
	,1
	,309
	,158
	,NULL); 
INSERT INTO orders VALUES (2409
	,TO_TIMESTAMP('29-JUN-07 08.53.41.984501 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,167
	,2
	,48
	,154
	,NULL);  
INSERT INTO orders VALUES (2411
	,TO_TIMESTAMP('24-MAY-07 10.22.10.548639 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,169
	,8
	,15760.5
	,156
	,NULL); 
INSERT INTO orders VALUES (2412
	,TO_TIMESTAMP('29-MAR-06 11.22.09.509801 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,170
	,9
	,66816
	,158
	,NULL);
INSERT INTO orders VALUES (2410
	,TO_TIMESTAMP('24-MAY-08 09.19.51.985501 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,168
	,6
	,45175
	,156
	,NULL);
INSERT INTO orders VALUES (2424
	,TO_TIMESTAMP('21-NOV-07 11.22.33.263332 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,146
	,4
	,13824
	,153
	,NULL);
INSERT INTO orders VALUES (2449
	,TO_TIMESTAMP('13-JUN-07 04.49.07.162632 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,146
	,6
	,86
	,155
	,NULL);

Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2365,1,2289,48,92);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2372,1,3106,48,6);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2373,1,1820,49,8);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2374,1,2422,150,10);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2375,1,3106,42,140);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2376,1,2270,60,14);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2378,1,2403,113.3,20);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2379,1,3106,42,92);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2384,1,2289,43,95);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2408,1,2751,61,3);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2409,1,2810,6,8);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2410,1,2976,46,10);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2411,1,3082,81,2);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2412,1,3106,46,170);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2424,1,3350,693,11);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2449,1,2522,43,2);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2365,2,2293,99,28);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2372,2,3108,74,2);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2373,2,1825,24,1);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2374,2,2423,78,6);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2375,2,3112,71,84);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2376,2,2276,236.5,4);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2378,2,2412,95,2);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2384,2,2299,71,48);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2408,2,2761,26,1);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2411,2,3086,208,2);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2412,2,3114,98,68);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2424,2,3354,541,9);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2365,3,2302,133.1,29);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2372,3,3110,42,7);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2375,3,3117,38,85);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2378,3,2414,438.9,7);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2410,2,2982,40,5);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2411,3,3097,2.2,6);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2412,3,3123,71.5,68);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2424,3,3359,111,12);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2365,4,2308,56,29);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2375,4,3127,488.4,86);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2378,4,2417,27,11);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2379,2,3114,98,14);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2410,3,2986,120,6);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2411,4,3099,3.3,7);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2412,4,3127,492,72);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2365,5,2311,95,29);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2372,4,3123,81,10);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2374,3,2449,78,15);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2375,5,3133,45,88);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2376,3,2293,99,13);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2378,5,2423,79,11);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2408,3,2783,10,10);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2410,4,2995,68,8);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2411,5,3101,73,8);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2412,5,3134,18,75);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2365,6,2316,22,34);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2372,5,3127,496,13);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2375,6,3134,17,90);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2376,4,2299,73,17);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2378,6,2424,217.8,15);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2384,3,2316,21,58);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2411,6,3106,45,11);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2412,6,3139,20,79);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2365,7,2319,24,38);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2372,6,3134,17,17);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2375,7,3143,15,93);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2376,5,2302,133.1,21);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2379,3,3127,488.4,23);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2384,4,2322,22,59);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2412,7,3143,16,80);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2365,8,2322,19,43);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2372,7,3143,15,21);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2374,4,2467,79,21);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2375,8,3150,17,93);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2376,6,2311,95,25);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2384,5,2330,1.1,61);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2411,7,3112,72,17);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2365,9,2326,1.1,44);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2375,9,3155,45,98);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2376,7,2316,21,27);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2365,10,2335,97,45);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2375,10,3163,30,99);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2376,8,2319,25,32);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2379,4,3139,21,34);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2411,9,3124,84,17);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2365,11,2339,25,50);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2372,8,3163,30,30);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2375,11,3165,36,103);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2376,9,2326,1.1,33);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2379,5,3140,19,35);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2411,10,3127,488.4,18);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2365,12,2340,72,54);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2372,9,3167,54,32);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2375,12,3171,132,107);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2376,10,2334,3.3,36);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2378,7,2457,4.4,25);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2410,6,3051,12,21);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2411,11,3133,43,23);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2412,8,3163,30,92);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2372,10,3170,145.2,36);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2375,13,3176,120,109);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2378,8,2459,624.8,25);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2384,6,2359,249,77);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2411,12,3143,15,24);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2412,9,3167,54,94);

Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('172','Harry Mean','Peckinpah','1200','HarryMean.Peckinpah@VERDIN.COM','I: 170,000 - 189,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('177','Gerhard','Seignier','1200','Gerhard.Seignier@JACANA.COM','E: 90,000 - 109,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('181','Lauren','Hershey','1200','Lauren.Hershey@LIMPKIN.COM','H: 150,000 - 169,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('186','Meena','Alexander','1200','Meena.Alexander@PARULA.COM','K: 250,000 - 299,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('190','Gena','Curtis','1200','Gena.Curtis@PLOVER.COM','J: 190,000 - 249,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('213','Luchino','Bradford','1500','Luchino.Bradford@PARULA.COM','A: Below 30,000','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('217','Bryan','Huston','2300','Bryan.Huston@PYRRHULOXIA.COM','B: 30,000 - 49,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('240','Malcolm','Kanth','2400','Malcolm.Kanth@PIPIT.COM','H: 150,000 - 169,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('241','Malcolm','Broderick','2400','Malcolm.Broderick@PLOVER.COM','F: 110,000 - 129,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('242','Mary','Lemmon','2400','Mary.Lemmon@PUFFIN.COM','K: 250,000 - 299,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('277','Don','Siegel','5000','Don.Siegel@BITTERN.COM','B: 30,000 - 49,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('278','Gvtz','Bradford','5000','Gvtz.Bradford@BULBUL.COM','K: 250,000 - 299,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('280','Rob','MacLaine','5000','Rob.MacLaine@COOT.COM','B: 30,000 - 49,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('281','Don','Barkin','5000','Don.Barkin@CORMORANT.COM','I: 170,000 - 189,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('282','Kurt','Danson','5000','Kurt.Danson@COWBIRD.COM','H: 150,000 - 169,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('308','Glenda','Dunaway','1200','Glenda.Dunaway@DOWITCHER.COM','C: 50,000 - 69,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('309','Glenda','Bates','1200','Glenda.Bates@DIPPER.COM','F: 110,000 - 129,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('323','Goetz','Falk','5000','Goetz.Falk@VEERY.COM','G: 130,000 - 149,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('326','Hal','Olin','2400','Hal.Olin@FLICKER.COM','H: 150,000 - 169,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('327','Hannah','Kanth','2400','Hannah.Kanth@GADWALL.COM','F: 110,000 - 129,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('470','Roger','Mastroianni','3700','Roger.Mastroianni@CREEPER.COM','L: 300,000 and above','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('473','Rolf','Ashby','5000','Rolf.Ashby@WATERTHRUSH.COM','G: 130,000 - 149,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('474','Romy','Sharif','5000','Romy.Sharif@SNIPE.COM','F: 110,000 - 129,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('476','Rosanne','Hopkins','300','Rosanne.Hopkins@ANI.COM','D: 70,000 - 89,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('477','Rosanne','Douglas','300','Rosanne.Douglas@ANHINGA.COM','F: 110,000 - 129,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('478','Rosanne','Baldwin','300','Rosanne.Baldwin@AUKLET.COM','A: Below 30,000','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('480','Roxanne','Michalkow','1200','Roxanne.Michalkow@EIDER.COM','L: 300,000 and above','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('481','Roy','Hulce','5000','Roy.Hulce@SISKIN.COM','E: 90,000 - 109,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('482','Roy','Dunaway','5000','Roy.Dunaway@WHIMBREL.COM','F: 110,000 - 129,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('487','Rufus','Dvrrie','1900','Rufus.Dvrrie@PLOVER.COM','J: 190,000 - 249,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('132','Doris','Spacek','400','Doris.Spacek@FLICKER.COM','H: 150,000 - 169,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('134','Sissy','Puri','400','Sissy.Puri@GREBE.COM','F: 110,000 - 129,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('135','Doris','Bel Geddes','400','Doris.BelGeddes@GROSBEAK.COM','B: 30,000 - 49,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('136','Sissy','Warden','400','Sissy.Warden@JACANA.COM','F: 110,000 - 129,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('138','Mani','Fonda','500','Mani.Fonda@KINGLET.COM','F: 110,000 - 129,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('139','Placido','Kubrick','500','Placido.Kubrick@SCOTER.COM','F: 110,000 - 129,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('140','Claudia','Kurosawa','500','Claudia.Kurosawa@CHUKAR.COM','E: 90,000 - 109,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('141','Maximilian','Henner','500','Maximilian.Henner@DUNLIN.COM','H: 150,000 - 169,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('143','Sachin','Neeson','500','Sachin.Neeson@GALLINULE.COM','F: 110,000 - 129,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('144','Sivaji','Landis','500','Sivaji.Landis@GOLDENEYE.COM','F: 110,000 - 129,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('179','Harry dean','Forrest','1200','Harrydean.Forrest@KISKADEE.COM','G: 130,000 - 149,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('180','Harry dean','Cage','1200','Harrydean.Cage@LAPWING.COM','F: 110,000 - 129,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('182','Lauren','Dench','1200','Lauren.Dench@LONGSPUR.COM','K: 250,000 - 299,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('183','Lauren','Altman','1200','Lauren.Altman@MERGANSER.COM','C: 50,000 - 69,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('184','Mary Beth','Roberts','1200','MaryBeth.Roberts@NUTHATCH.COM','A: Below 30,000','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('185','Matthew','Wright','1200','Matthew.Wright@OVENBIRD.COM','G: 130,000 - 149,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('187','Grace','Dvrrie','1200','Grace.Dvrrie@PHOEBE.COM','E: 90,000 - 109,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('188','Charlotte','Buckley','1200','Charlotte.Buckley@PINTAIL.COM','F: 110,000 - 129,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('189','Gena','Harris','1200','Gena.Harris@PIPIT.COM','F: 110,000 - 129,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('191','Maureen','Sanders','1200','Maureen.Sanders@PUFFIN.COM','A: Below 30,000','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('225','Clara','Ganesan','2300','Clara.Ganesan@WIGEON.COM','I: 170,000 - 189,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('227','Kathy','Prashant','2400','Kathy.Prashant@ANI.COM','J: 190,000 - 249,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('228','Graham','Neeson','2400','Graham.Neeson@AUKLET.COM','E: 90,000 - 109,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('229','Ian','Chapman','2400','Ian.Chapman@AVOCET.COM','D: 70,000 - 89,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('230','Danny','Wright','2400','Danny.Wright@BITTERN.COM','F: 110,000 - 129,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('232','Donald','Hunter','2400','Donald.Hunter@CHACHALACA.COM','G: 130,000 - 149,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('233','Graham','Spielberg','2400','Graham.Spielberg@CHUKAR.COM','D: 70,000 - 89,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('234','Dan','Roberts','2400','Dan.Roberts@NUTHATCH.COM','I: 170,000 - 189,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('235','Edward','Oates','2400','Edward.Oates@OVENBIRD.COM','E: 90,000 - 109,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('237','Farrah','Quinlan','2400','Farrah.Quinlan@PHAINOPEPLA.COM','A: Below 30,000','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('846','Ally','Brando','5000','Ally.Brando@PINTAIL.COM','L: 300,000 and above','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('928','Burt','Spielberg','5000','Burt.Spielberg@TROGON.COM','E: 90,000 - 109,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('932','Buster','Bogart','900','Buster.Bogart@KISKADEE.COM','H: 150,000 - 169,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('496','Scott','Jordan','5000','Scott.Jordan@WILLET.COM','G: 130,000 - 149,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('605','Shammi','Pacino','500','Shammi.Pacino@BITTERN.COM','B: 30,000 - 49,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('606','Sharmila','Kazan','500','Sharmila.Kazan@BRANT.COM','D: 70,000 - 89,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('607','Sharmila','Fonda','500','Sharmila.Fonda@BUFFLEHEAD.COM','H: 150,000 - 169,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('609','Shelley','Taylor','3700','Shelley.Taylor@CURLEW.COM','I: 170,000 - 189,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('615','Shyam','Plummer','2500','Shyam.Plummer@VEERY.COM','J: 190,000 - 249,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('621','Silk','Kurosawa','1500','Silk.Kurosawa@NUTHATCH.COM','G: 130,000 - 149,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('841','Ali','Boyer','1400','Ali.Boyer@WILLET.COM','F: 110,000 - 129,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('842','Ali','Stern','1400','Ali.Stern@YELLOWTHROAT.COM','E: 90,000 - 109,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('844','Alice','Julius','700','Alice.Julius@BITTERN.COM','D: 70,000 - 89,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('845','Ally','Fawcett','5000','Ally.Fawcett@PLOVER.COM','A: Below 30,000','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('847','Ally','Streep','5000','Ally.Streep@PIPIT.COM','A: Below 30,000','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('848','Alonso','Olmos','1800','Alonso.Olmos@PHALAROPE.COM','F: 110,000 - 129,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('849','Alonso','Kaurusmdki','1800','Alonso.Kaurusmdki@PHOEBE.COM','E: 90,000 - 109,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('850','Amanda','Finney','2300','Amanda.Finney@STILT.COM','J: 190,000 - 249,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('851','Amanda','Brown','2300','Amanda.Brown@THRASHER.COM','B: 30,000 - 49,999','B');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('852','Amanda','Tanner','2300','Amanda.Tanner@TEAL.COM','G: 130,000 - 149,999','B');

INSERT INTO orders VALUES (2435
	,TO_TIMESTAMP('02-SEP-07 10.22.53.134567 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,144
	,6
	,62303
	,159
	,NULL);
INSERT INTO orders VALUES (2363
	,TO_TIMESTAMP('23-OCT-07 04.49.56.346122 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'online'
	,144
	,0
	,10082.3
	,NULL
	,NULL);
INSERT INTO orders VALUES (2377
	,TO_TIMESTAMP('07-JUN-07 06.03.01.001100 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'online'
	,141
	,5
	,38017.8
	,NULL
	,NULL);
INSERT INTO orders VALUES (2380
	,TO_TIMESTAMP('16-MAY-07 08.53.02.909090 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'online'
	,143
	,3
	,27132.6
	,NULL
	,NULL); 
INSERT INTO orders VALUES (2382
	,TO_TIMESTAMP('14-MAY-08 09.19.03.828321 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'online'
	,144
	,8
	,71173
	,NULL
	,NULL);
INSERT INTO orders VALUES (2422
	,TO_TIMESTAMP('16-DEC-07 09.19.55.462332 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,144
	,2
	,11188.5
	,153
	,NULL);
INSERT INTO orders VALUES (2445
	,TO_TIMESTAMP('27-JUL-06 02.34.38.362632 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,144
	,8
	,5537.8
	,158
	,NULL);

Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2363,1,2264,199.1,9);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2377,1,2289,42,130);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2380,1,3106,42,26);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2382,1,3106,42,160);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2422,1,3106,46,18);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2435,1,2289,48,35);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2445,1,2270,66,5);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2363,2,2272,129,7);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2380,2,3108,75,18);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2382,2,3110,43,64);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2422,2,3117,41,5);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2435,2,2299,75,4);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2445,2,2278,49,3);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2380,3,3117,38,23);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2382,3,3114,100,65);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2422,3,3123,71.5,5);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2377,2,2302,147,119);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2380,4,3127,488.4,24);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2382,4,3117,35,66);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2377,3,2311,95,121);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2380,5,3133,46,28);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2382,5,3123,79,71);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2422,4,3127,496,9);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2435,3,2311,86.9,8);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2380,6,3140,20,30);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2382,6,3127,496,71);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2422,5,3133,46,11);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2435,4,2316,21,10);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2445,3,2293,97,11);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2363,3,2299,74,25);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2380,7,3143,15,31);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2382,7,3129,42,76);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2435,5,2323,18,12);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2445,4,2299,72,14);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2363,4,2308,57,26);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2380,8,3150,17,33);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2382,8,3139,21,79);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2435,6,2334,3.3,14);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2363,5,2311,86.9,29);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2377,4,2319,25,131);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2380,9,3155,45,33);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2382,9,3143,15,82);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2410,5,3003,2866.6,15);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2411,8,3123,75,17);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2422,6,3150,17,25);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2435,7,2339,25,19);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2363,6,2319,24,31);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2377,5,2326,1.1,132);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2380,10,3163,32,36);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2422,7,3155,43,29);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2435,8,2350,2341.9,24);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2445,5,2311,95,24);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2363,7,2323,18,34);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2377,6,2330,1.1,136);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2380,11,3167,52,37);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2445,6,2319,25,27);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2363,8,2326,1.1,37);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2380,12,3176,113.3,40);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2382,10,3163,29,89);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2422,8,3163,30,35);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2445,7,2326,1.1,28);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2363,9,2334,3.3,42);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2380,13,3187,2.2,40);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2382,11,3165,37,92);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2422,9,3167,54,39);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2435,9,2365,75,33);
