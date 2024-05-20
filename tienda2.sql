DROP TABLE  product_information   CASCADE CONSTRAINTS;
DROP TABLE  customers             CASCADE CONSTRAINTS;
DROP TABLE  order_items           CASCADE CONSTRAINTS;
DROP TABLE  orders                CASCADE CONSTRAINTS;


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
    
    
SELECT * FROM ORDER_ITEMS 

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
    
    
CREATE DATABASE LINK tienda1 CONNECT TO SYSTEM IDENTIFIED BY "12345" USING
'(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=172.17.0.2)(PORT=1521))
(CONNECT_DATA=(SERVER=dedicated)(SID=XE)))';

SELECT * FROM CUSTOMERS@TIENDA1
SELECT * FROM ORDER_ITEMS@TIENDA1
SELECT * FROM ORDERS @TIENDA1
SELECT * FROM PRODUCT_INFORMATION_1@TIENDA1

--Sinonimos 

-- Sinónimos en Tienda1 para acceder a Tienda2
CREATE SYNONYM CUSTOMERS_1 FOR CUSTOMERS@TIENDA1;
--CREATE SYNONYM ORDERS_1 FOR ORDERS@TIENDA1;
CREATE SYNONYM ORDER_ITEMS_1 FOR ORDER_ITEMS@TIENDA1;
CREATE SYNONYM PRODUCT_INFORMATION_1 FOR PRODUCT_INFORMATION@TIENDA1;

SELECT * FROM CUSTOMERS_1
SELECT * FROM PRODUCT_INFORMATION_1






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
        p_customer_id => 654321,
        p_first_name => 'Jane',
        p_last_name => 'Smith',
        p_credit_limit => 7500,
        p_cust_email => 'jane.smith@example.com',
        p_income_level => 'Medium',
        p_region => 'S'
    );
    COMMIT; -- Este COMMIT está aquí por claridad, el manejo de la transacción puede ser interno
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
        p_customer_id => 654321,
        p_first_name => 'Jane',
        p_last_name => 'Smith',
        p_credit_limit => 8500,  -- Aumentamos su límite de crédito
        p_cust_email => 'jane.newemail@example.com',  -- Cambiamos su correo electrónico
        p_income_level => 'High',  -- Actualizamos su nivel de ingresos
        p_region => 'D'
    );
    COMMIT; -- Confirmar la transacción si se realizan cambios
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
        p_customer_id => 654321  -- ID de Jane Smith
    );
    COMMIT; -- Confirmar la transacción si la eliminación es exitosa
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
        p_order_id => 1002,
        p_line_item_id => 2,
        p_product_id => 502,
        p_unit_price => 299.99,
        p_quantity => 1
    );
    COMMIT; -- Asegura que la inserción se confirme si no hay errores.
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al insertar ítem de orden: ' || SQLERRM);
        ROLLBACK; -- Revierte la transacción en caso de error.
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
        p_order_id => 1002,
        p_line_item_id => 2,
        p_product_id => 502,
        p_unit_price => 279.99,  -- Se aplica un descuento al precio.
        p_quantity => 2          -- El cliente ha decidido comprar una cantidad adicional.
    );
    COMMIT; -- Confirma los cambios si la actualización es exitosa.
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al actualizar ítem de orden: ' || SQLERRM);
        ROLLBACK; -- Revierte la transacción en caso de error.
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
        p_order_id => 1002,
        p_line_item_id => 2
    );
    COMMIT; -- Confirma la eliminación si se ha llevado a cabo correctamente.
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al eliminar ítem de orden: ' || SQLERRM);
        ROLLBACK; -- Revierte la transacción en caso de error.
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
        p_order_id => 5002,
        p_order_date => SYSTIMESTAMP, -- Uso de la hora actual del sistema
        p_order_mode => 'Phone',
        p_customer_id => 654321,
        p_order_status => 1, -- Supongamos que '1' indica una orden nueva
        p_order_total => 1200.00,
        p_sales_rep_id => 790,
        p_promotion_id => 103
    );
    COMMIT; -- Confirmar la inserción
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al insertar la orden: ' || SQLERRM);
        ROLLBACK; -- Revertir en caso de error
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
        p_order_id => 5002,
        p_order_date => SYSTIMESTAMP, -- Actualizar a la fecha y hora actuales
        p_order_mode => 'Online', -- Cambio de 'Phone' a 'Online'
        p_customer_id => 654321,
        p_order_status => 2, -- Supongamos que '2' indica que la orden está en proceso
        p_order_total => 1300.00, -- Ajuste en el total de la orden
        p_sales_rep_id => 790,
        p_promotion_id => 104
    );
    COMMIT; -- Confirmar la actualización
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al actualizar la orden: ' || SQLERRM);
        ROLLBACK; -- Revertir en caso de error
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
        p_order_id => 5002 -- ID de la orden que fue cancelada
    );
    COMMIT; -- Confirmar la eliminación
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al eliminar la orden: ' || SQLERRM);
        ROLLBACK; -- Revertir en caso de error
END;
/
















--PROCESAMIENTO ALMACENADOS

CREATE OR REPLACE PROCEDURE MANIPULATE_PRODUCT_INFORMATION_1(
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
    -- Insertar un nuevo producto en la tabla PRODUCT_INFORMATION_1
    INSERT INTO PRODUCT_INFORMATION_1 (
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
--Ejemplo de insertar 
BEGIN
    MANIPULATE_PRODUCT_INFORMATION_1(
        102, 'Laptop Pro', 'High-end gaming laptop', 1, 2, INTERVAL '1' YEAR,
        300, 'Available', 1500, 1400, 'http://example.com/laptop'
    );
    COMMIT; -- Confirmar la transacción después de la inserción
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK; -- Revertir en caso de error
        DBMS_OUTPUT.PUT_LINE('Error al insertar: ' || SQLERRM);
END;
/


CREATE OR REPLACE PROCEDURE UPDATE_PRODUCT_INFORMATION_1(
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
    UPDATE PRODUCT_INFORMATION_1
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
    UPDATE_PRODUCT_INFORMATION_1(
        102, 'Laptop Pro Plus', 'Updated version of our high-end gaming laptop', 1, 2,
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



CREATE OR REPLACE PROCEDURE DELETE_PRODUCT_INFORMATION_1(
    p_product_id IN NUMBER
) AS
BEGIN
    -- Intenta eliminar el producto de la tabla PRODUCT_INFORMATION_1
    DELETE FROM PRODUCT_INFORMATION_1 WHERE PRODUCT_ID = p_product_id;

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
    DELETE_PRODUCT_INFORMATION_1(102);
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Producto no encontrado para eliminar.');
    ELSE
        COMMIT; -- Confirmar la transacción si la eliminación fue exitosa
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK; -- Revertir en caso de error
        DBMS_OUTPUT.PUT_LINE('Error al eliminar: ' || SQLERRM);
END;
/


--FRAGMENTACION POR REGION C Y D EN BASE DE DATOS TIENDA2

Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('243','Mary','Collins','2400','Mary.Collins@PYRRHULOXIA.COM','F: 110,000 - 129,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('244','Matt','Gueney','2400','Matt.Gueney@REDPOLL.COM','G: 130,000 - 149,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('245','Max','von Sydow','2400','Max.vonSydow@REDSTART.COM','K: 250,000 - 299,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('246','Max','Schell','2400','Max.Schell@SANDERLING.COM','F: 110,000 - 129,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('247','Cynda','Whitcraft','2400','Cynda.Whitcraft@SANDPIPER.COM','B: 30,000 - 49,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('248','Donald','Minnelli','2400','Donald.Minnelli@SCAUP.COM','F: 110,000 - 129,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('249','Hannah','Broderick','2400','Hannah.Broderick@SHRIKE.COM','D: 70,000 - 89,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('250','Dan','Williams','2400','Dan.Williams@SISKIN.COM','A: Below 30,000','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('251','Raul','Wilder','2500','Raul.Wilder@STILT.COM','E: 90,000 - 109,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('252','Shah Rukh','Field','2500','ShahRukh.Field@WHIMBREL.COM','I: 170,000 - 189,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('328','Hannah','Field','2400','Hannah.Field@GALLINULE.COM','G: 130,000 - 149,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('333','Margret','Powell','1200','Margret.Powell@ANI.COM','G: 130,000 - 149,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('334','Harry Mean','Taylor','1200','HarryMean.Taylor@REDPOLL.COM','I: 170,000 - 189,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('335','Margrit','Garner','500','Margrit.Garner@STILT.COM','H: 150,000 - 169,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('337','Maria','Warden','500','Maria.Warden@TANAGER.COM','B: 30,000 - 49,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('339','Marilou','Landis','500','Marilou.Landis@TATTLER.COM','A: Below 30,000','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('361','Marilou','Chapman','500','Marilou.Chapman@TEAL.COM','D: 70,000 - 89,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('363','Kathy','Lambert','2400','Kathy.Lambert@COOT.COM','C: 50,000 - 69,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('360','Helmut','Capshaw','3600','Helmut.Capshaw@TROGON.COM','J: 190,000 - 249,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('341','Keir','George','700','Keir.George@VIREO.COM','E: 90,000 - 109,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('488','Rufus','Belushi','1900','Rufus.Belushi@PUFFIN.COM','G: 130,000 - 149,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('492','Sally','Edwards','2500','Sally.Edwards@TURNSTONE.COM','K: 250,000 - 299,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('101','Constantin','Welles','100','Constantin.Welles@ANHINGA.COM','B: 30,000 - 49,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('102','Harrison','Pacino','100','Harrison.Pacino@ANI.COM','I: 170,000 - 189,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('103','Manisha','Taylor','100','Manisha.Taylor@AUKLET.COM','H: 150,000 - 169,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('104','Harrison','Sutherland','100','Harrison.Sutherland@GODWIT.COM','H: 150,000 - 169,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('105','Matthias','MacGraw','100','Matthias.MacGraw@GOLDENEYE.COM','C: 50,000 - 69,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('106','Matthias','Hannah','100','Matthias.Hannah@GREBE.COM','F: 110,000 - 129,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('107','Matthias','Cruise','100','Matthias.Cruise@GROSBEAK.COM','G: 130,000 - 149,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('108','Meenakshi','Mason','100','Meenakshi.Mason@JACANA.COM','H: 150,000 - 169,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('145','Mammutti','Pacino','500','Mammutti.Pacino@GREBE.COM','F: 110,000 - 129,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('147','Ishwarya','Roberts','600','Ishwarya.Roberts@LAPWING.COM','G: 130,000 - 149,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('148','Gustav','Steenburgen','600','Gustav.Steenburgen@PINTAIL.COM','F: 110,000 - 129,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('149','Markus','Rampling','600','Markus.Rampling@PUFFIN.COM','D: 70,000 - 89,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('150','Goldie','Slater','700','Goldie.Slater@PYRRHULOXIA.COM','D: 70,000 - 89,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('151','Divine','Aykroyd','700','Divine.Aykroyd@REDSTART.COM','F: 110,000 - 129,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('152','Dieter','Matthau','700','Dieter.Matthau@VERDIN.COM','A: Below 30,000','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('153','Divine','Sheen','700','Divine.Sheen@COWBIRD.COM','I: 170,000 - 189,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('154','Frederic','Grodin','700','Frederic.Grodin@CREEPER.COM','L: 300,000 and above','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('155','Frederico','Romero','700','Frederico.Romero@CURLEW.COM','E: 90,000 - 109,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('192','Sean','Stockwell','1200','Sean.Stockwell@PYRRHULOXIA.COM','I: 170,000 - 189,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('193','Harry dean','Kinski','1200','Harrydean.Kinski@REDPOLL.COM','D: 70,000 - 89,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('194','Kathleen','Garcia','1200','Kathleen.Garcia@REDSTART.COM','I: 170,000 - 189,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('195','Sean','Olin','1200','Sean.Olin@SCAUP.COM','F: 110,000 - 129,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('196','Gerard','Dench','1200','Gerard.Dench@SCOTER.COM','E: 90,000 - 109,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('197','Gerard','Altman','1200','Gerard.Altman@SHRIKE.COM','F: 110,000 - 129,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('198','Maureen','de Funes','1200','Maureen.deFunes@SISKIN.COM','D: 70,000 - 89,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('199','Clint','Chapman','1400','Clint.Chapman@SNIPE.COM','F: 110,000 - 129,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('200','Clint','Gielgud','1400','Clint.Gielgud@STILT.COM','E: 90,000 - 109,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('201','Eric','Prashant','1400','Eric.Prashant@TATTLER.COM','C: 50,000 - 69,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('238','Farrah','Lange','2400','Farrah.Lange@PHALAROPE.COM','F: 110,000 - 129,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('239','Hal','Stockwell','2400','Hal.Stockwell@PHOEBE.COM','H: 150,000 - 169,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('222','Cary','Stockwell','2300','Cary.Stockwell@VIREO.COM','I: 170,000 - 189,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('226','Ajay','Andrews','2300','Ajay.Andrews@YELLOWTHROAT.COM','F: 110,000 - 129,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('231','Danny','Rourke','2400','Danny.Rourke@BRANT.COM','F: 110,000 - 129,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('236','Edward','Julius','2400','Edward.Julius@PARULA.COM','F: 110,000 - 129,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('261','Emmet','Garcia','3600','Emmet.Garcia@VIREO.COM','H: 150,000 - 169,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('266','Prem','Cardinale','3700','Prem.Cardinale@BITTERN.COM','L: 300,000 and above','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('270','Meg','Derek','3700','Meg.Derek@FLICKER.COM','F: 110,000 - 129,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('275','Dom','McQueen','5000','Dom.McQueen@AUKLET.COM','G: 130,000 - 149,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('627','Sivaji','Gielgud','500','Sivaji.Gielgud@BULBUL.COM','D: 70,000 - 89,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('712','M. Emmet','Stockwell','3700','M.Emmet.Stockwell@COOT.COM','H: 150,000 - 169,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('713','M. Emmet','Olin','3700','M.Emmet.Olin@CORMORANT.COM','F: 110,000 - 129,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('715','Malcolm','Field','2400','Malcolm.Field@DOWITCHER.COM','G: 130,000 - 149,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('717','Mammutti','Sutherland','500','Mammutti.Sutherland@TOWHEE.COM','D: 70,000 - 89,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('719','Mani','Kazan','500','Mani.Kazan@TROGON.COM','I: 170,000 - 189,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('721','Mani','Buckley','500','Mani.Buckley@TURNSTONE.COM','E: 90,000 - 109,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('727','Margaret','Ustinov','1200','Margaret.Ustinov@ANHINGA.COM','H: 150,000 - 169,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('729','Margaux','Krige','2400','Margaux.Krige@DUNLIN.COM','F: 110,000 - 129,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('754','Kevin','Goodman','700','Kevin.Goodman@WIGEON.COM','E: 90,000 - 109,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('853','Amrish','Palin','400','Amrish.Palin@EIDER.COM','I: 170,000 - 189,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('905','Billy','Hershey','1400','Billy.Hershey@BULBUL.COM','G: 130,000 - 149,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('906','Billy','Dench','1400','Billy.Dench@CARACARA.COM','I: 170,000 - 189,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('909','Blake','Mastroianni','1200','Blake.Mastroianni@FLICKER.COM','D: 70,000 - 89,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('911','Bo','Dickinson','5000','Bo.Dickinson@TANAGER.COM','H: 150,000 - 169,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('912','Bo','Ashby','5000','Bo.Ashby@TATTLER.COM','I: 170,000 - 189,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('913','Bob','Sharif','5000','Bob.Sharif@TEAL.COM','F: 110,000 - 129,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('916','Brian','Douglas','500','Brian.Douglas@AVOCET.COM','J: 190,000 - 249,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('917','Brian','Baldwin','500','Brian.Baldwin@BECARD.COM','E: 90,000 - 109,999','C');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('919','Brooke','Michalkow','3500','Brooke.Michalkow@GROSBEAK.COM','D: 70,000 - 89,999','C');

INSERT INTO orders VALUES (2458
	,TO_TIMESTAMP('16-AUG-07 02.34.12.234359 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,101
	,0
	,78279.6
	,153
	,NULL); 
INSERT INTO orders VALUES (2397
	,TO_TIMESTAMP('19-NOV-07 03.41.54.696211 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,102
	,1
	,42283.2
	,154
	,NULL); 
INSERT INTO orders VALUES (2454
	,TO_TIMESTAMP('02-OCT-07 04.49.34.678340 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,103
	,1
	,6653.4
	,154
	,NULL); 
INSERT INTO orders VALUES (2354
	,TO_TIMESTAMP('14-JUL-08 05.18.23.234567 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,104
	,0
	,46257
	,155
	,NULL); 
INSERT INTO orders VALUES (2358
	,TO_TIMESTAMP('08-JAN-08 06.03.12.654278 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,105
	,2
	,7826
	,155
	,NULL); 
INSERT INTO orders VALUES (2381
	,TO_TIMESTAMP('14-MAY-08 07.59.08.843679 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,106
	,3
	,23034.6
	,156
	,NULL); 
INSERT INTO orders VALUES (2440
	,TO_TIMESTAMP('31-AUG-07 08.53.06.008765 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,107
	,3
	,70576.9
	,156
	,NULL); 
INSERT INTO orders VALUES (2357
	,TO_TIMESTAMP('08-JAN-06 09.19.44.123456 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,108
	,5
	,59872.4
	,158
	,NULL);
INSERT INTO orders VALUES (2455
	,TO_TIMESTAMP('20-SEP-07 10.34.11.456789 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,145
	,7
	,14087.5
	,160
	,NULL);
INSERT INTO orders VALUES (2396
	,TO_TIMESTAMP('02-FEB-06 02.34.56.345678 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,147
	,8
	,34930
	,161
	,NULL); 
INSERT INTO orders VALUES (2406
	,TO_TIMESTAMP('29-JUN-07 03.41.20.098765 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,148
	,8
	,2854.2
	,161
	,NULL); 
INSERT INTO orders VALUES (2434
	,TO_TIMESTAMP('13-SEP-07 04.49.30.647893 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,149
	,8
	,268651.8
	,161
	,NULL);
INSERT INTO orders VALUES (2447
	,TO_TIMESTAMP('27-JUL-08 07.59.10.223344 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,101
	,8
	,33893.6
	,161
	,NULL); 
INSERT INTO orders VALUES (2432
	,TO_TIMESTAMP('14-SEP-07 08.53.40.223345 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,102
	,10
	,10523
	,163
	,NULL); 
INSERT INTO orders VALUES (2433
	,TO_TIMESTAMP('13-SEP-07 09.19.00.654279 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,103
	,10
	,78
	,163
	,NULL); 
INSERT INTO orders VALUES (2355
	,TO_TIMESTAMP('26-JAN-06 10.22.51.962632 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'online'
	,104
	,8
	,94513.5
	,NULL
	,NULL); 
INSERT INTO orders VALUES (2356
	,TO_TIMESTAMP('26-JAN-08 10.22.41.934562 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'online'
	,105
	,5
	,29473.8
	,NULL
	,NULL); 
INSERT INTO orders VALUES (2359
	,TO_TIMESTAMP('08-JAN-06 10.34.13.112233 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'online'
	,106
	,9
	,5543.1
	,NULL
	,NULL); 
INSERT INTO orders VALUES (2360
	,TO_TIMESTAMP('14-NOV-07 01.22.31.223344 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'online'
	,107
	,4
	,990.4
	,NULL
	,NULL); 
INSERT INTO orders VALUES (2361
	,TO_TIMESTAMP('13-NOV-07 02.34.21.986210 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'online'
	,108
	,8
	,120131.3
	,NULL
	,NULL);
INSERT INTO orders VALUES (2364
	,TO_TIMESTAMP('28-AUG-07 05.18.45.942399 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'online'
	,145
	,4
	,9500
	,NULL
	,NULL);
INSERT INTO orders VALUES (2366
	,TO_TIMESTAMP('28-AUG-07 07.59.23.144778 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'online'
	,147
	,5
	,37319.4
	,NULL
	,NULL); 
INSERT INTO orders VALUES (2367
	,TO_TIMESTAMP('27-JUN-08 08.53.32.335522 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'online'
	,148
	,10
	,144054.8
	,NULL
	,NULL); 
INSERT INTO orders VALUES (2368
	,TO_TIMESTAMP('26-JUN-08 09.19.43.190089 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'online'
	,149
	,10
	,60065
	,NULL
	,NULL);
INSERT INTO orders VALUES (2383
	,TO_TIMESTAMP('12-MAY-08 10.22.30.545103 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'online'
	,145
	,8
	,36374.7
	,NULL
	,NULL);
INSERT INTO orders VALUES (2385
	,TO_TIMESTAMP('08-DEC-07 12.34.11.331392 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'online'
	,147
	,4
	,295892
	,NULL
	,NULL); 
INSERT INTO orders VALUES (2386
	,TO_TIMESTAMP('06-DEC-07 01.22.34.225609 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'online'
	,148
	,10
	,21116.9
	,NULL
	,NULL); 
INSERT INTO orders VALUES (2387
	,TO_TIMESTAMP('11-MAR-07 02.34.56.536966 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'online'
	,149
	,5
	,52758.9
	,NULL
	,NULL); 
INSERT INTO orders VALUES (2388
	,TO_TIMESTAMP('04-JUN-07 03.41.12.554435 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'online'
	,150
	,4
	,282694.3
	,NULL
	,NULL); 
INSERT INTO orders VALUES (2389
	,TO_TIMESTAMP('04-JUN-08 04.49.43.546954 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'online'
	,151
	,4
	,17620
	,NULL
	,NULL); 
INSERT INTO orders VALUES (2390
	,TO_TIMESTAMP('18-NOV-07 05.18.50.546851 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'online'
	,152
	,9
	,7616.8
	,NULL
	,NULL); 
INSERT INTO orders VALUES (2391
	,TO_TIMESTAMP('27-FEB-06 06.03.03.828330 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,153
	,2
	,48070.6
	,156
	,NULL); 
INSERT INTO orders VALUES (2392
	,TO_TIMESTAMP('21-JUL-07 07.59.57.571057 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,154
	,9
	,26632
	,161
	,NULL); 
INSERT INTO orders VALUES (2393
	,TO_TIMESTAMP('10-FEB-08 08.53.19.528202 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,155
	,4
	,23431.9
	,161
	,NULL);
INSERT INTO orders VALUES (2413
	,TO_TIMESTAMP('29-MAR-08 12.34.04.525934 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,101
	,5
	,48552
	,161
	,NULL); 
INSERT INTO orders VALUES (2414
	,TO_TIMESTAMP('29-MAR-07 01.22.40.536996 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,102
	,8
	,10794.6
	,153
	,NULL); 
INSERT INTO orders VALUES (2415
	,TO_TIMESTAMP('29-MAR-06 02.34.50.545196 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,103
	,6
	,310
	,161
	,NULL); 
INSERT INTO orders VALUES (2416
	,TO_TIMESTAMP('29-MAR-07 03.41.20.945676 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,104
	,6
	,384
	,160
	,NULL); 
INSERT INTO orders VALUES (2417
	,TO_TIMESTAMP('20-MAR-07 04.49.10.974352 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,105
	,5
	,1926.6
	,163
	,NULL); 
INSERT INTO orders VALUES (2418
	,TO_TIMESTAMP('20-MAR-04 05.18.21.862632 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,106
	,4
	,5546.6
	,163
	,NULL); 
INSERT INTO orders VALUES (2419
	,TO_TIMESTAMP('20-MAR-07 06.03.32.764632 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,107
	,3
	,31574
	,160
	,NULL); 
INSERT INTO orders VALUES (2420
	,TO_TIMESTAMP('13-MAR-07 07.59.43.666320 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,108
	,2
	,29750
	,160
	,NULL);
INSERT INTO orders VALUES (2423
	,TO_TIMESTAMP('21-NOV-07 11.22.33.362632 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,145
	,3
	,10367.7
	,160
	,NULL);
INSERT INTO orders VALUES (2425
	,TO_TIMESTAMP('17-NOV-06 12.34.22.162552 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,147
	,5
	,1500.8
	,163
	,NULL); 
INSERT INTO orders VALUES (2426
	,TO_TIMESTAMP('17-NOV-06 01.22.11.262552 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,148
	,6
	,7200
	,NULL
	,NULL); 
INSERT INTO orders VALUES (2427
	,TO_TIMESTAMP('10-NOV-07 02.34.22.362124 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,149
	,7
	,9055
	,163
	,NULL);
INSERT INTO orders VALUES (2430
	,TO_TIMESTAMP('02-OCT-07 05.18.36.663332 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,101
	,8
	,29669.9
	,159
	,NULL); 
INSERT INTO orders VALUES (2431
	,TO_TIMESTAMP('14-SEP-06 06.03.04.763452 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,102
	,1
	,5610.6
	,163
	,NULL); 
INSERT INTO orders VALUES (2437
	,TO_TIMESTAMP('01-SEP-06 07.59.15.826132 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,103
	,4
	,13550
	,163
	,NULL); 
INSERT INTO orders VALUES (2438
	,TO_TIMESTAMP('01-SEP-07 08.53.26.934626 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,104
	,0
	,5451
	,154
	,NULL); 
INSERT INTO orders VALUES (2439
	,TO_TIMESTAMP('31-AUG-07 09.19.37.811132 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,105
	,1
	,22150.1
	,159
	,NULL); 
INSERT INTO orders VALUES (2441
	,TO_TIMESTAMP('01-AUG-08 10.22.48.734526 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,106
	,5
	,2075.2
	,160
	,NULL); 
INSERT INTO orders VALUES (2442
	,TO_TIMESTAMP('27-JUL-06 11.22.59.662632 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,107
	,9
	,52471.9
	,154
	,NULL); 
INSERT INTO orders VALUES (2443
	,TO_TIMESTAMP('27-JUL-06 12.34.16.562632 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,108
	,0
	,3646
	,154
	,NULL);
INSERT INTO orders VALUES (2448
	,TO_TIMESTAMP('18-JUN-07 03.41.49.262632 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,145
	,5
	,1388
	,158
	,NULL);
INSERT INTO orders VALUES (2450
	,TO_TIMESTAMP('11-APR-07 05.18.10.362632 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,147
	,3
	,1636
	,159
	,NULL); 
INSERT INTO orders VALUES (2451
	,TO_TIMESTAMP('17-DEC-07 06.03.52.562632 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,148
	,7
	,10474.6
	,154
	,NULL); 
INSERT INTO orders VALUES (2452
	,TO_TIMESTAMP('06-OCT-07 07.59.43.462632 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,149
	,5
	,12589
	,159
	,NULL);

Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2354,1,3106,48,61);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2355,1,2289,46,200);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2356,1,2264,199.1,38);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2357,1,2211,3.3,140);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2358,1,1781,226.6,9);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2359,1,2337,270.6,1);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2360,1,2058,23,29);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2361,1,2289,46,180);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2364,1,1910,14,6);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2366,1,2359,226.6,8);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2367,1,2289,48,99);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2368,1,3106,48,150);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2381,1,3117,38,110);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2383,1,2409,194.7,37);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2385,1,2289,43,200);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2386,1,2330,1.1,7);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2387,1,2211,3.3,52);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2388,1,2289,43,150);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2389,1,3106,43,180);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2390,1,1910,14,4);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2391,1,1787,101,5);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2392,1,3106,43,63);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2393,1,3051,12,10);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2396,1,3106,44,150);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2397,1,2976,52,2);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2406,1,2721,85,5);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2413,1,3108,77,200);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2414,1,3208,1.1,8);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2415,1,2751,62,5);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2416,1,2870,4.4,10);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2417,1,2870,4.4,9);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2418,1,3082,75,15);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2419,1,3106,46,150);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2420,1,3106,46,110);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2423,1,3220,39,8);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2425,1,3501,492.8,3);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2426,1,3193,2.2,6);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2427,1,2430,173,12);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2430,1,3350,693,6);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2431,1,3097,2.2,3);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2432,1,2976,49,3);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2433,1,1910,13,6);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2434,1,2211,3.3,81);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2437,1,2423,83,8);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2438,1,2995,69,3);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2439,1,1797,316.8,9);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2440,1,2289,48,19);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2441,1,2536,80,9);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2442,1,2402,127,26);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2443,1,3106,44,3);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2447,1,2264,199.1,29);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2448,1,3106,44,3);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2450,1,3191,1.1,4);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2451,1,1910,13,9);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2452,1,3117,38,140);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2454,1,2289,43,120);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2455,1,2471,482.9,3);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2458,1,3117,38,140);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2354,2,3114,96.8,43);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2356,2,2274,148.5,34);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2358,2,1782,125,4);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2361,2,2299,76,180);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2368,2,3110,42,60);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2381,2,3124,77,44);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2386,2,2334,3.3,5);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2388,2,2293,94,90);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2389,2,3112,73,18);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2390,2,1912,14,2);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2391,2,1791,262.9,3);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2392,2,3112,73,57);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2393,2,3060,295,2);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2396,2,3108,76,75);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2406,2,2725,3.3,4);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2413,2,3112,75,40);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2414,2,3216,30,7);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2416,2,2878,340,1);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2418,2,3090,187,12);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2419,2,3114,99,45);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2420,2,3110,46,11);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2423,2,3224,32,3);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2425,2,3511,9,2);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2427,2,2439,121,1);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2430,2,3353,454.3,5);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2431,2,3106,48,1);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2432,2,2982,43,2);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2437,2,2430,157.3,4);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2438,2,3000,1748,3);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2439,2,1806,45,4);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2440,2,2293,98,2);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2441,2,2537,193.6,7);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2442,2,2410,350.9,21);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2443,2,3114,101,2);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2447,2,2266,297,23);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2448,2,3114,99,0);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2450,2,3193,2.2,3);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2454,2,2293,99,0);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2458,2,3123,79,112);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2354,3,3123,79,47);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2361,3,2308,53,182);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2368,3,3117,38,62);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2381,3,3133,44,44);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2389,3,3123,80,21);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2391,3,1797,348,7);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2392,3,3117,38,58);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2393,3,3064,1017,5);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2396,3,3110,44,79);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2413,3,3117,35,44);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2414,3,3220,41,9);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2418,3,3097,2.2,13);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2419,3,3123,71.5,48);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2420,3,3114,101,15);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2425,3,3515,1.1,4);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2430,3,3359,111,10);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2431,3,3114,101,3);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2439,3,1820,54,9);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2440,3,2302,150,2);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2442,3,2418,60,23);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2450,3,3197,44,5);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2454,3,2299,71,3);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2458,3,3127,488.4,114);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2354,4,3129,41,47);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2361,4,2311,86.9,185);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2366,2,2373,6,7);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2367,2,2302,147,32);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2381,4,3139,20,45);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2383,2,2418,56,45);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2386,3,2340,71,14);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2389,4,3129,46,22);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2391,4,1799,961.4,10);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2393,4,3069,385,8);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2396,4,3114,100,83);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2397,2,2986,120,8);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2413,4,3127,492,44);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2414,4,3234,39,11);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2420,4,3123,79,20);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2426,2,3216,30,11);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2430,4,3362,94,10);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2431,4,3117,41,7);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2432,3,2986,122,5);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2439,4,1822,1433.3,13);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2442,4,2422,144,25);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2443,3,3124,82,6);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2447,3,2272,121,24);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2458,4,3134,17,115);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2354,5,3139,21,48);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2355,2,2308,57,185);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2356,3,2293,98,40);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2358,3,1797,316.8,12);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2359,2,2359,249,1);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2361,5,2316,22,187);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2366,3,2382,804.1,10);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2368,4,3123,81,70);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2381,5,3143,15,48);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2383,3,2422,146,46);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2385,2,2302,133.1,87);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2388,3,2308,56,96);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2391,5,1808,55,15);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2393,5,3077,260.7,8);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2413,5,3129,46,45);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2420,5,3127,496,22);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2427,3,2457,4.4,6);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2431,5,3127,498,9);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2442,5,2430,173,28);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2447,4,2278,50,25);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2354,6,3143,16,53);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2355,3,2311,86.9,188);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2356,4,2299,72,44);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2358,4,1803,55,13);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2366,4,2394,116.6,11);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2367,3,2308,54,39);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2368,5,3127,496,70);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2383,4,2430,174,50);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2391,6,1820,52,18);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2392,4,3124,77,63);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2393,6,3082,78,10);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2418,4,3110,45,20);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2419,4,3129,43,57);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2423,3,3245,214.5,13);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2427,4,2464,66,6);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2431,6,3129,44,11);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2434,2,2236,949.3,84);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2440,4,2311,86.9,7);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2442,6,2439,115.5,30);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2448,3,3133,42,11);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2452,2,3139,20,10);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2354,7,3150,17,58);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2355,4,2322,19,188);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2356,5,2308,58,47);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2357,2,2245,462,26);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2358,5,1808,55,14);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2366,5,2395,120,12);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2368,6,3129,42,72);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2383,5,2439,115.5,54);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2387,2,2243,332.2,20);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2391,7,1822,1433.3,23);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2392,5,3133,45,66);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2393,7,3086,211,13);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2397,3,2999,880,16);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2414,5,3246,212.3,18);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2419,5,3133,45,61);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2420,6,3133,48,29);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2423,4,3246,212.3,14);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2427,5,2470,76,6);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2432,4,2999,880,11);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2434,3,2245,462,86);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2437,3,2457,4.4,17);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2440,5,2322,23,10);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2443,4,3139,20,12);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2448,4,3134,17,14);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2450,4,3216,29,11);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2452,3,3143,15,12);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2454,4,2308,55,12);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2455,2,2496,268.4,32);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2354,8,3163,30,61);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2355,5,2323,17,190);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2356,6,2311,95,51);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2357,3,2252,788.7,26);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2361,6,2326,1.1,194);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2366,6,2400,418,16);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2385,3,2311,86.9,96);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2387,3,2245,462,22);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2389,5,3143,15,30);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2390,3,1948,470.8,16);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2392,6,3139,21,68);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2393,8,3087,108.9,14);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2397,4,3000,1696.2,16);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2414,6,3253,206.8,23);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2420,7,3140,19,34);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2423,5,3251,26,16);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2426,3,3234,34,18);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2434,4,2252,788.7,87);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2437,4,2462,76,19);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2440,6,2330,1.1,13);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2443,5,3143,15,17);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2448,5,3139,20,15);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2450,5,3220,41,14);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2451,2,1948,470.8,22);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2452,4,3150,17,13);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2454,5,2316,21,13);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2458,5,3143,15,129);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2354,9,3165,37,64);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2355,6,2326,1.1,192);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2356,7,2316,22,55);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2357,4,2257,371.8,29);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2360,2,2093,7.7,42);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2361,7,2334,3.3,198);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2364,2,1948,470.8,20);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2366,7,2406,195.8,20);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2367,4,2322,22,45);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2381,6,3163,35,55);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2385,4,2319,25,97);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2386,4,2365,77,27);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2387,4,2252,788.7,27);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2389,6,3155,46,33);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2392,7,3150,18,72);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2393,9,3091,278,19);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2396,5,3140,19,93);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2406,3,2761,26,19);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2414,7,3260,50,24);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2420,8,3143,15,39);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2423,6,3258,78,21);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2434,5,2254,408.1,92);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2437,5,2464,64,21);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2440,7,2334,3.3,15);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2442,7,2459,624.8,40);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2443,6,3150,18,17);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2447,5,2293,97,34);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2448,6,3143,16,16);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2450,6,3224,32,16);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2452,5,3155,44,13);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2454,6,2323,18,16);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2354,10,3167,51,68);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2355,7,2330,1.1,197);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2356,8,2323,18,55);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2357,5,2262,95,29);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2359,3,2370,91,17);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2366,8,2409,194.7,22);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2367,5,2326,1.1,48);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2368,7,3143,16,75);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2383,6,2457,4.4,62);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2386,5,2370,90,28);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2387,5,2253,354.2,32);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2388,4,2330,1.1,105);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2392,8,3155,49,77);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2393,10,3099,3.3,19);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2396,6,3150,17,93);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2419,6,3150,17,69);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2434,6,2257,371.8,94);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2440,8,2337,270.6,19);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2442,8,2467,80,44);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2443,7,3155,43,21);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2447,6,2299,76,35);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2452,6,3165,34,18);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2454,7,2334,3.3,18);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2354,11,3170,145.2,70);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2355,8,2339,25,199);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2357,6,2268,75,32);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2359,4,2373,6,17);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2366,9,2415,339.9,24);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2367,6,2330,1.1,52);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2368,8,3155,45,75);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2383,7,2462,75,63);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2386,6,2375,73,32);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2396,7,3155,47,98);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2413,6,3155,47,62);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2418,5,3140,20,31);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2419,7,3155,47,72);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2440,9,2339,25,23);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2447,7,2302,133.1,37);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2452,7,3170,145.2,20);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2354,12,3176,113.3,72);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2359,5,2377,96,17);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2366,10,2419,69,24);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2367,7,2335,91.3,54);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2381,7,3176,113.3,62);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2385,5,2335,91.3,106);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2386,7,2378,271.7,33);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2389,7,3165,34,43);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2396,8,3163,29,100);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2413,7,3163,30,66);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2419,8,3165,35,76);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2420,9,3163,30,45);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2426,4,3248,212.3,26);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2427,6,2496,268.4,19);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2440,10,2350,2341.9,24);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2447,8,2308,54,40);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2452,8,3172,37,20);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2354,13,3182,61,77);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2357,7,2276,236.5,38);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2359,6,2380,5.5,17);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2361,8,2359,248,208);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2367,8,2350,2341.9,54);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2381,8,3183,47,63);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2385,6,2350,2341.9,109);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2386,8,2394,116.6,36);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2387,6,2268,75,42);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2388,5,2350,2341.9,112);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2389,8,3167,52,47);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2392,9,3165,40,81);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2393,11,3108,69.3,30);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2406,4,2782,62,31);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2417,2,2976,51,37);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2418,6,3150,17,37);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2419,9,3167,54,81);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2420,10,3171,132,47);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2423,7,3290,65,33);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2426,5,3252,25,29);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2427,7,2522,40,22);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2430,5,3501,492.8,43);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2434,7,2268,75,104);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2437,6,2496,268.4,35);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2440,11,2359,226.6,28);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2443,8,3165,36,31);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2447,9,2311,93,44);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2452,9,3173,80,23);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2455,3,2536,75,54);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2458,6,3163,32,142);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2355,9,2359,226.6,204);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2357,8,2289,48,41);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2359,7,2381,97,17);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2361,9,2365,76,209);

Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('253','Sally','Bogart','2500','Sally.Bogart@WILLET.COM','H: 150,000 - 169,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('254','Bruce','Bates','3500','Bruce.Bates@COWBIRD.COM','D: 70,000 - 89,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('255','Brooke','Shepherd','3500','Brooke.Shepherd@KILLDEER.COM','C: 50,000 - 69,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('256','Ben','de Niro','3500','Ben.deNiro@KINGLET.COM','I: 170,000 - 189,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('257','Emmet','Walken','3600','Emmet.Walken@LIMPKIN.COM','B: 30,000 - 49,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('258','Ellen','Palin','3600','Ellen.Palin@LONGSPUR.COM','H: 150,000 - 169,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('259','Denholm','von Sydow','3600','Denholm.vonSydow@MERGANSER.COM','D: 70,000 - 89,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('260','Ellen','Khan','3600','Ellen.Khan@VERDIN.COM','F: 110,000 - 129,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('262','Fred','Reynolds','3600','Fred.Reynolds@WATERTHRUSH.COM','F: 110,000 - 129,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('263','Fred','Lithgow','3600','Fred.Lithgow@WHIMBREL.COM','D: 70,000 - 89,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('342','Marlon','Laughton','2400','Marlon.Laughton@CORMORANT.COM','F: 110,000 - 129,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('343','Keir','Chandar','700','Keir.Chandar@WATERTHRUSH.COM','G: 130,000 - 149,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('344','Marlon','Godard','2400','Marlon.Godard@MOORHEN.COM','H: 150,000 - 169,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('345','Keir','Weaver','700','Keir.Weaver@WHIMBREL.COM','H: 150,000 - 169,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('346','Marlon','Clapton','2400','Marlon.Clapton@COWBIRD.COM','K: 250,000 - 299,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('347','Kelly','Quinlan','3600','Kelly.Quinlan@PYRRHULOXIA.COM','A: Below 30,000','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('348','Kelly','Lange','3600','Kelly.Lange@SANDPIPER.COM','F: 110,000 - 129,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('349','Ken','Glenn','3600','Ken.Glenn@SAW-WHET.COM','K: 250,000 - 299,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('350','Ken','Chopra','3600','Ken.Chopra@SCAUP.COM','F: 110,000 - 129,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('351','Ken','Wenders','3600','Ken.Wenders@REDPOLL.COM','F: 110,000 - 129,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('109','Christian','Cage','100','Christian.Cage@KINGLET.COM','F: 110,000 - 129,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('110','Charlie','Sutherland','200','Charlie.Sutherland@LIMPKIN.COM','G: 130,000 - 149,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('111','Charlie','Pacino','200','Charlie.Pacino@LONGSPUR.COM','G: 130,000 - 149,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('112','Guillaume','Jackson','200','Guillaume.Jackson@MOORHEN.COM','I: 170,000 - 189,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('113','Daniel','Costner','200','Daniel.Costner@PARULA.COM','I: 170,000 - 189,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('114','Dianne','Derek','200','Dianne.Derek@SAW-WHET.COM','H: 150,000 - 169,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('115','Geraldine','Schneider','200','Geraldine.Schneider@SCAUP.COM','B: 30,000 - 49,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('116','Geraldine','Martin','200','Geraldine.Martin@SCOTER.COM','A: Below 30,000','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('117','Guillaume','Edwards','200','Guillaume.Edwards@SHRIKE.COM','E: 90,000 - 109,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('118','Maurice','Mahoney','200','Maurice.Mahoney@SNIPE.COM','F: 110,000 - 129,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('156','Goldie','Montand','700','Goldie.Montand@DIPPER.COM','F: 110,000 - 129,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('157','Sidney','Capshaw','700','Sidney.Capshaw@DUNLIN.COM','G: 130,000 - 149,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('158','Frederico','Lyon','700','Frederico.Lyon@FLICKER.COM','J: 190,000 - 249,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('159','Eddie','Boyer','700','Eddie.Boyer@GALLINULE.COM','G: 130,000 - 149,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('160','Eddie','Stern','700','Eddie.Stern@GODWIT.COM','G: 130,000 - 149,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('161','Ernest','Weaver','900','Ernest.Weaver@GROSBEAK.COM','B: 30,000 - 49,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('162','Ernest','George','900','Ernest.George@LAPWING.COM','D: 70,000 - 89,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('163','Ernest','Chandar','900','Ernest.Chandar@LIMPKIN.COM','H: 150,000 - 169,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('164','Charlotte','Kazan','1200','Charlotte.Kazan@MERGANSER.COM','I: 170,000 - 189,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('165','Charlotte','Fonda','1200','Charlotte.Fonda@MOORHEN.COM','J: 190,000 - 249,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('202','Ingrid','Welles','1400','Ingrid.Welles@TEAL.COM','D: 70,000 - 89,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('203','Ingrid','Rampling','1400','Ingrid.Rampling@WIGEON.COM','F: 110,000 - 129,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('204','Cliff','Puri','1400','Cliff.Puri@CORMORANT.COM','J: 190,000 - 249,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('205','Emily','Pollack','1400','Emily.Pollack@DIPPER.COM','L: 300,000 and above','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('206','Fritz','Hackman','1400','Fritz.Hackman@DUNLIN.COM','G: 130,000 - 149,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('207','Cybill','Laughton','1400','Cybill.Laughton@EIDER.COM','F: 110,000 - 129,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('208','Cyndi','Griem','1400','Cyndi.Griem@GALLINULE.COM','E: 90,000 - 109,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('209','Cyndi','Collins','1400','Cyndi.Collins@GODWIT.COM','D: 70,000 - 89,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('210','Cybill','Clapton','1400','Cybill.Clapton@GOLDENEYE.COM','D: 70,000 - 89,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('211','Luchino','Jordan','1500','Luchino.Jordan@GREBE.COM','A: Below 30,000','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('279','Holly','Kurosawa','5000','Holly.Kurosawa@CARACARA.COM','I: 170,000 - 189,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('283','Kurt','Heard','5000','Kurt.Heard@CURLEW.COM','H: 150,000 - 169,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('352','Kenneth','Redford','3600','Kenneth.Redford@REDSTART.COM','B: 30,000 - 49,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('378','Meg','Sen','3700','Meg.Sen@COWBIRD.COM','C: 50,000 - 69,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('448','Richard','Winters','500','Richard.Winters@SNIPE.COM','F: 110,000 - 129,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('452','Ridley','Coyote','700','Ridley.Coyote@ANI.COM','F: 110,000 - 129,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('463','Robin','Adjani','1500','Robin.Adjani@MOORHEN.COM','C: 50,000 - 69,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('468','Rodolfo','Altman','5000','Rodolfo.Altman@SHRIKE.COM','F: 110,000 - 129,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('475','Romy','McCarthy','5000','Romy.McCarthy@STILT.COM','D: 70,000 - 89,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('479','Roxanne','Shepherd','1200','Roxanne.Shepherd@DUNLIN.COM','I: 170,000 - 189,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('755','Kevin','Cleveland','700','Kevin.Cleveland@WILLET.COM','H: 150,000 - 169,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('756','Kevin','Wilder','700','Kevin.Wilder@AUKLET.COM','G: 130,000 - 149,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('766','Klaus','Young','600','Klaus.Young@OVENBIRD.COM','H: 150,000 - 169,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('767','Klaus Maria','Russell','100','KlausMaria.Russell@COOT.COM','C: 50,000 - 69,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('768','Klaus Maria','MacLaine','100','KlausMaria.MacLaine@CHUKAR.COM','A: Below 30,000','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('770','Kris','Curtis','400','Kris.Curtis@DOWITCHER.COM','K: 250,000 - 299,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('771','Kris','de Niro','400','Kris.deNiro@DUNLIN.COM','E: 90,000 - 109,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('782','Laurence','Seignier','1200','Laurence.Seignier@CREEPER.COM','F: 110,000 - 129,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('825','Alain','Dreyfuss','500','Alain.Dreyfuss@VEERY.COM','J: 190,000 - 249,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('826','Alain','Barkin','500','Alain.Barkin@VERDIN.COM','A: Below 30,000','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('920','Bruce','Hulce','3500','Bruce.Hulce@JACANA.COM','F: 110,000 - 129,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('921','Bruce','Dunaway','3500','Bruce.Dunaway@JUNCO.COM','F: 110,000 - 129,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('923','Bruno','Slater','5000','Bruno.Slater@THRASHER.COM','G: 130,000 - 149,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('924','Bruno','Montand','5000','Bruno.Montand@TOWHEE.COM','D: 70,000 - 89,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('927','Bryan','Belushi','2300','Bryan.Belushi@TOWHEE.COM','I: 170,000 - 189,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('929','Burt','Neeson','5000','Burt.Neeson@TURNSTONE.COM','F: 110,000 - 129,999','D');
Insert into CUSTOMERS (CUSTOMER_ID,CUST_FIRST_NAME,CUST_LAST_NAME,CREDIT_LIMIT,CUST_EMAIL,INCOME_LEVEL,REGION) values ('930','Buster','Jackson','900','Buster.Jackson@KILLDEER.COM','A: Below 30,000','D');

INSERT INTO orders VALUES (2456
	,TO_TIMESTAMP('07-NOV-06 08.53.25.989889 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,117
	,0
	,3878.4
	,163
	,NULL); 
INSERT INTO orders VALUES (2457
	,TO_TIMESTAMP('31-OCT-07 10.22.16.162632 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,118
	,5
	,21586.2
	,159
	,NULL);
INSERT INTO orders VALUES (2394
	,TO_TIMESTAMP('10-FEB-08 10.22.35.564789 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,109
	,5
	,21863
	,158
	,NULL);
INSERT INTO orders VALUES (2436
	,TO_TIMESTAMP('02-SEP-07 05.18.04.378034 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,116
	,8
	,6394.8
	,161
	,NULL); 
INSERT INTO orders VALUES (2446
	,TO_TIMESTAMP('27-JUL-07 06.03.08.302945 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,117
	,8
	,103679.3
	,161
	,NULL);
INSERT INTO orders VALUES (2362
	,TO_TIMESTAMP('13-NOV-07 03.41.10.619477 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'online'
	,109
	,4
	,92829.4
	,NULL
	,NULL);
INSERT INTO orders VALUES (2369
	,TO_TIMESTAMP('26-JUN-07 10.22.54.009932 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'online'
	,116
	,0
	,11097.4
	,NULL
	,NULL); 
INSERT INTO orders VALUES (2370
	,TO_TIMESTAMP('26-JUN-08 11.22.11.647398 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'online'
	,117
	,4
	,126
	,NULL
	,NULL); 
INSERT INTO orders VALUES (2371
	,TO_TIMESTAMP('16-MAY-07 12.34.56.113356 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'online'
	,118
	,6
	,79405.6
	,NULL
	,NULL);
INSERT INTO orders VALUES (2395
	,TO_TIMESTAMP('02-FEB-06 09.19.11.227550 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,156
	,3
	,68501
	,163
	,NULL); 
INSERT INTO orders VALUES (2398
	,TO_TIMESTAMP('19-NOV-07 10.22.53.224175 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,157
	,9
	,7110.3
	,163
	,NULL); 
INSERT INTO orders VALUES (2399
	,TO_TIMESTAMP('19-NOV-07 11.22.38.340990 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,158
	,0
	,25270.3
	,161
	,NULL); 
INSERT INTO orders VALUES (2400
	,TO_TIMESTAMP('10-JUL-07 12.34.29.559387 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,159
	,2
	,69286.4
	,161
	,NULL); 
INSERT INTO orders VALUES (2401
	,TO_TIMESTAMP('10-JUL-07 01.22.53.554822 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,160
	,3
	,969.2
	,163
	,NULL); 
INSERT INTO orders VALUES (2402
	,TO_TIMESTAMP('02-JUL-07 02.34.44.665170 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,161
	,8
	,600
	,154
	,NULL); 
INSERT INTO orders VALUES (2403
	,TO_TIMESTAMP('01-JUL-07 03.49.13.615512 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,162
	,0
	,220
	,154
	,NULL); 
INSERT INTO orders VALUES (2404
	,TO_TIMESTAMP('01-JUL-07 03.49.13.664085 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,163
	,6
	,510
	,158
	,NULL); 
INSERT INTO orders VALUES (2405
	,TO_TIMESTAMP('01-JUL-07 03.49.13.678123 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,164
	,5
	,1233
	,159
	,NULL); 
INSERT INTO orders VALUES (2407
	,TO_TIMESTAMP('29-JUN-07 06.03.21.526005 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,165
	,9
	,2519
	,155
	,NULL);
INSERT INTO orders VALUES (2421
	,TO_TIMESTAMP('12-MAR-07 08.53.54.562432 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,109
	,1
	,72836
	,NULL
	,NULL);
INSERT INTO orders VALUES (2428
	,TO_TIMESTAMP('10-NOV-07 03.41.34.463567 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,116
	,8
	,14685.8
	,NULL
	,NULL); 
INSERT INTO orders VALUES (2429
	,TO_TIMESTAMP('10-NOV-07 04.49.25.526321 AM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,117
	,9
	,50125
	,154
	,NULL);
INSERT INTO orders VALUES (2444
	,TO_TIMESTAMP('27-JUL-07 01.22.27.462632 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,109
	,1
	,77727.2
	,155
	,NULL);
INSERT INTO orders VALUES (2453
	,TO_TIMESTAMP('04-OCT-07 08.53.34.362632 PM'
	,'DD-MON-RR HH.MI.SS.FF AM'
	,'NLS_DATE_LANGUAGE=American')
	,'direct'
	,116
	,0
	,129
	,153
	,NULL);

Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2362,1,2289,48,200);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2369,1,3150,18,3);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2370,1,1910,14,9);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2371,1,2274,157,6);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2394,1,3117,41,90);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2395,1,2211,3.3,110);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2398,1,2471,482.9,5);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2399,1,2289,44,120);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2400,1,2976,52,4);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2401,1,2492,41,4);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2402,1,2536,75,8);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2403,1,2522,44,5);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2404,1,2721,85,6);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2405,1,2638,137,9);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2407,1,2721,85,5);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2421,1,3106,46,160);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2428,1,3106,42,7);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2429,1,3106,42,200);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2436,1,3208,1.1,8);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2444,1,3117,36,110);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2446,1,2289,48,47);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2453,1,2492,43,3);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2456,1,2522,40,5);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2457,1,3108,72,36);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2362,2,2299,76,160);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2369,2,3155,43,1);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2394,2,3123,77,36);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2399,2,2293,94,12);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2400,2,2982,41,1);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2401,2,2496,268.4,3);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2421,2,3108,78,160);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2428,2,3108,76,1);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2429,2,3108,76,40);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2436,2,3209,13,2);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2444,2,3127,488.4,88);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2457,2,3123,79,14);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2362,3,2311,93,164);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2369,3,3163,32,5);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2394,3,3124,82,39);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2399,3,2299,76,15);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2400,3,2986,123,4);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2421,3,3112,72,164);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2428,3,3114,101,5);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2429,3,3110,45,43);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2436,3,3216,30,3);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2444,3,3133,43,90);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2457,3,3127,488.4,17);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2362,4,2316,22,168);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2369,4,3165,34,10);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2371,2,2293,96,8);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2394,4,3129,46,41);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2399,4,2302,149,17);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2421,4,3117,41,165);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2428,4,3117,41,6);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2429,4,3123,79,46);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2436,4,3224,32,6);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2444,4,3139,21,93);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2394,5,3133,46,45);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2399,5,2308,56,17);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2421,5,3123,80,168);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2428,5,3123,80,8);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2429,5,3127,497,49);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2444,5,3140,19,95);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2371,3,2299,73,15);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2394,6,3134,18,45);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2399,6,2311,86.9,20);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2400,4,2999,880,16);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2421,6,3129,43,172);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2428,6,3127,498,12);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2429,6,3133,46,52);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2444,6,3143,15,97);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2362,5,2326,1.1,173);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2394,7,3140,19,48);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2395,2,2243,332.2,27);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2399,7,2316,22,24);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2400,5,3003,2866.6,19);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2428,7,3133,48,12);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2429,7,3139,21,54);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2436,5,3245,214.5,16);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2444,7,3150,17,100);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2456,2,2537,193.6,19);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2362,6,2334,3.3,177);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2369,5,3170,145.2,24);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2395,3,2252,788.7,30);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2399,8,2326,1.1,27);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2407,2,2752,86,18);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2428,8,3143,16,13);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2436,6,3250,27,18);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2444,8,3155,43,104);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2457,4,3150,17,27);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2362,7,2339,25,179);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2369,6,3176,113.3,24);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2371,4,2316,21,21);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2399,9,2330,1.1,28);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2407,3,2761,26,21);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2428,9,3150,17,16);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2429,8,3150,17,55);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2436,7,3256,36,18);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2457,5,3155,44,32);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2369,7,3187,2.2,24);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2371,5,2323,17,24);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2394,8,3155,49,61);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2395,4,2255,690.8,34);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2399,10,2335,100,33);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2421,7,3143,15,176);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2446,2,2326,1.1,34);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2369,8,3193,2.2,28);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2371,6,2334,3.3,26);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2395,5,2264,199.1,34);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2398,2,2537,193.6,23);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2421,8,3150,17,176);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2444,9,3165,37,112);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2446,3,2330,1.1,36);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2371,7,2339,25,29);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2395,6,2268,71,37);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2398,3,2594,9,27);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2428,10,3170,145.2,24);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2429,9,3163,30,63);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2444,10,3172,37,112);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2446,4,2337,270.6,37);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2457,6,3170,145.2,42);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2362,8,2359,248,189);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2369,9,3204,123,34);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2371,8,2350,2341.9,32);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2394,9,3167,52,68);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2395,7,2270,64,41);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2399,11,2359,226.6,38);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2404,2,2808,0,37);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2421,9,3155,43,185);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2428,11,3173,86,28);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2429,10,3165,36,67);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2436,8,3290,63,24);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2444,11,3182,63,115);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2446,5,2350,2341.9,39);
Insert into ORDER_ITEMS (ORDER_ID,LINE_ITEM_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY) values (2457,7,3172,36,45);


