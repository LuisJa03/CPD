const express = require('express');
const oracledb = require('oracledb');
const bodyParser = require('body-parser');
const app = express();

app.use(bodyParser.urlencoded({ extended: true }));

// Configuración de la conexión
async function openConnection() {
    try {
        // Cambia estos parámetros según tu configuración específica de Oracle
        const connection = await oracledb.getConnection({
            user: 'system',
            password: '12345',
            connectString: 'localhost:1521/xe' // Ejemplo: localhost/XEPDB1
        });

        return connection;
    } catch (err) {
        console.error(err);
        return null;
    }
}

// Ruta para obtener datos
app.get('/data', async (req, res) => {
    const connection = await openConnection();
    if (connection) {
        try {
            const result = await connection.execute(`SELECT * FROM ORDERS`);
            res.json(result.rows);
        } catch (err) {
            res.status(500).send('Error al obtener datos');
            console.error(err);
        } finally {
            try {
                await connection.close();
            } catch (err) {
                console.error(err);
            }
        }
    } else {
        res.status(500).send('Error al conectar con la base de datos');
    }
});



app.get('/', (req, res) => {
    res.send(`<!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Menú Principal</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 40px;
                display: flex;
                flex-direction: column;
                align-items: center;
                gap: 20px;
            }
            .section {
                background-color: #f2f2f2;
                border: 1px solid #ccc;
                padding: 20px;
                width: 300px;
                display: flex;
                flex-direction: column;
                gap: 10px;
            }
            button {
                padding: 10px 20px;
                font-size: 16px;
                cursor: pointer;
                background-color: #007bff;
                color: white;
                border: none;
                border-radius: 5px;
            }
            button:hover {
                background-color: #0056b3;
            }
        </style>
    </head>
    <body>
        <h1>Menú de Operaciones</h1>
        <div class="section">
            <h2>Clientes</h2>
            <button onclick="window.location.href='/insertar_cliente'">Insertar Cliente</button>
            <button onclick="window.location.href='/eliminar_cliente'">Eliminar Cliente</button>
            <button onclick="window.location.href='/actualizar_cliente'">Actualizar Cliente</button>
            <button onclick="window.location.href='/ver_cliente'">Ver Cliente</button>
            <button onclick="window.location.href='/ver_todos_los_clientes'">Ver Todos los Clientes</button>
        </div>
    
        <div class="section">
            <h2>Órdenes</h2>
            <button onclick="window.location.href='/insertar_orden'">Insertar Orden</button>
            <button onclick="window.location.href='/eliminar_orden'">Eliminar Orden</button>
            <button onclick="window.location.href='/actualizar_orden'">Actualizar Orden</button>
            <button onclick="window.location.href='/ver_orden'">Ver Orden</button>
            <button onclick="window.location.href='/ver_todas_las_ordenes'">Ver Todas las Órdenes</button>
        </div>
    
        <div class="section">
            <h2>Ítems de Órdenes</h2>
            <button onclick="window.location.href='/insertar_item_orden'">Insertar Ítem de Orden</button>
            <button onclick="window.location.href='/eliminar_item_orden'">Eliminar Ítem de Orden</button>
            <button onclick="window.location.href='/actualizar_item_orden'">Actualizar Ítem de Orden</button>
            <button onclick="window.location.href='/ver_item_orden'">Ver Ítem de Orden</button>
            <button onclick="window.location.href='/ver_todos_los_items_orden'">Ver Todos los Ítems de Órdenes</button>
        </div>
    
        <div class="section">
            <h2>Información de Productos</h2>
            <button onclick="window.location.href='/insertar_producto'">Insertar Producto</button>
            <button onclick="window.location.href='/eliminar_producto'">Eliminar Producto</button>
            <button onclick="window.location.href='/actualizar_producto'">Actualizar Producto</button>
            <button onclick="window.location.href='/ver_producto'">Ver Producto</button>
            <button onclick="window.location.href='/ver_todos_los_productos'">Ver Todos los Productos</button>
        </div>
    </body>
    </html>
    `);
});

app.get('/insertar_cliente', (req, res) => {
    res.send(`<!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Formulario para Crear Cliente</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 40px;
            }
            form {
                display: flex;
                flex-direction: column;
                width: 300px;
                gap: 10px;
            }
            label {
                font-weight: bold;
            }
            input, select {
                padding: 8px;
                border: 1px solid #ccc;
                border-radius: 4px;
            }
            button {
                padding: 10px;
                background-color: #007bff;
                color: white;
                border: none;
                border-radius: 5px;
                cursor: pointer;
            }
            button:hover {
                background-color: #0056b3;
            }
            .back-button {
                background-color: #6c757d; /* Different color for the back button */
            }
            .back-button:hover {
                background-color: #545b62;
            }
        </style>
    </head>
    <body>
        <h1>Crear Nuevo Cliente</h1>
        <form action="/crear_usuario" method="post">
            <label for="firstName">Primer Nombre:</label>
            <input type="text" id="firstName" name="firstName" required>
    
            <label for="lastName">Apellido:</label>
            <input type="text" id="lastName" name="lastName" required>
    
            <label for="creditLimit">Límite de Crédito:</label>
            <input type="number" id="creditLimit" name="creditLimit" required>
    
            <label for="email">Email:</label>
            <input type="email" id="email" name="email" required>
    
            <label for="incomeLevel">Ingresos:</label>
            <input type="text" id="incomeLevel" name="incomeLevel" required>
    
            <label for="region">Región:</label>
            <select id="region" name="region" required>
                <option value="A">A</option>
                <option value="B">B</option>
                <option value="C">C</option>
                <option value="D">D</option>
            </select>
    
            <button type="submit">Crear Cliente</button>
            <button type="button" class="back-button" onclick="window.location.href='/';">Volver al Inicio</button>
        </form>
    </body>
    </html>
    `);
});


app.post('/crear_usuario', async (req, res) => {
    const { firstName, lastName, creditLimit, email, incomeLevel, region } = req.body;
    // Aquí agregarías el código para insertar estos datos en tu base de datos.
    console.log('Creando usuario:', firstName, lastName, email);
    const connection = await openConnection();
    if (connection) {
        try {
            const result = await connection.execute(`BEGIN
            INSERT_CUSTOMER(
                p_customer_id => 3,
                p_first_name =>  '${firstName}',
                p_last_name => '${lastName}',
                p_credit_limit => ${parseInt(creditLimit)},
                p_cust_email => '${email}',
                p_income_level => 'High',
                p_region => '${region}'
            );
            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error al insertar cliente: ' || SQLERRM);
                ROLLBACK;
        END;`);
        res.send('Usuario creado con éxito');
        } catch (err) {
            res.status(500).send('Error al obtener datos');
            console.error(err);
        } finally {
            try {
                await connection.close();
            } catch (err) {
                console.error(err);
            }
        }
    } else {
        res.status(500).send('Error al conectar con la base de datos');
    }
    
});

app.get('/actualizar_cliente', (req, res) => {
    res.send(`<!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Actualizar Cliente</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 40px;
                display: flex;
                flex-direction: column;
                align-items: center;
            }
            form {
                display: flex;
                flex-direction: column;
                width: 300px;
                gap: 10px;
            }
            label {
                font-weight: bold;
            }
            input, select {
                padding: 8px;
                border: 1px solid #ccc;
                border-radius: 4px;
            }
            button {
                padding: 10px 20px;
                font-size: 16px;
                cursor: pointer;
                background-color: #007bff;
                color: white;
                border: none;
                border-radius: 5px;
            }
            button:hover {
                background-color: #0056b3;
            }
            .back-button {
                background-color: #6c757d;
            }
            .back-button:hover {
                background-color: #545b62;
            }
        </style>
    </head>
    <body>
        <h1>Actualizar Datos del Cliente</h1>
        <form action="/actualizar_cliente" method="post">
            <label for="customerId">ID del Cliente:</label>
            <input type="number" id="customerId" name="customerId" required>
        
            <label for="firstName">Primer Nombre:</label>
            <input type="text" id="firstName" name="firstName" required>
            
            <label for="lastName">Apellido:</label>
            <input type="text" id="lastName" name="lastName" required>
            
            <label for="creditLimit">Límite de Crédito:</label>
            <input type="number" id="creditLimit" name="creditLimit" required>
            
            <label for="email">Email:</label>
            <input type="email" id="email" name="email" required>
            
            <label for="incomeLevel">Nivel de Ingresos:</label>
            <input type="text" id="incomeLevel" name="incomeLevel" required>
            
            <label for="region">Región:</label>
            <select id="region" name="region" required>
                <option value="A">A</option>
                <option value="B">B</option>
                <option value="C">C</option>
                <option value="D">D</option>
            </select>
            
            <button type="submit">Actualizar Cliente</button>
            <button type="button" class="back-button" onclick="window.location.href='/';">Volver al Inicio</button>
        </form>
    </body>
    </html>
    
    
    
    `);
});

app.post('/actualizar_cliente', async (req, res) => {
    const { customerId, firstName, lastName, creditLimit, email, incomeLevel, region } = req.body;
    const connection = await openConnection();
    if (connection) {
        try {
            const result = await connection.execute(`BEGIN
                UPDATE_CUSTOMER(
                    p_customer_id => :customerId,
                    p_first_name => :firstName,
                    p_last_name => :lastName,
                    p_credit_limit => :creditLimit,
                    p_cust_email => :email,
                    p_income_level => :incomeLevel,
                    p_region => :region
                );
                COMMIT;
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Error al actualizar cliente: ' || SQLERRM);
                    ROLLBACK;
            END;`, {
                customerId: customerId,
                firstName: firstName,
                lastName: lastName,
                creditLimit: parseInt(creditLimit),
                email: email,
                incomeLevel: incomeLevel,
                region: region
            });
            res.send('Cliente actualizado con éxito');
        } catch (err) {
            res.status(500).send('Error al actualizar datos');
            console.error(err);
        } finally {
            try {
                await connection.close();
            } catch (err) {
                console.error(err);
            }
        }
    } else {
        res.status(500).send('Error al conectar con la base de datos');
    }
});



app.get('/eliminar_cliente', (req, res) => {
    res.send(`<!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Eliminar Cliente</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 40px;
                display: flex;
                flex-direction: column;
                align-items: center;
            }
            form {
                display: flex;
                flex-direction: column;
                width: 300px;
                gap: 10px;
            }
            label {
                font-weight: bold;
            }
            input {
                padding: 8px;
                border: 1px solid #ccc;
                border-radius: 4px;
            }
            button {
                padding: 10px 20px;
                font-size: 16px;
                cursor: pointer;
                background-color: #dc3545;
                color: white;
                border: none;
                border-radius: 5px;
            }
            button:hover {
                background-color: #c82333;
            }
            .back-button {
                background-color: #6c757d;
                color: white;
            }
            .back-button:hover {
                background-color: #545b62;
            }
        </style>
    </head>
    <body>
        <h1>Eliminar Cliente</h1>
        <form action="/eliminar_cliente" method="post">
            <label for="customerId">ID del Cliente:</label>
            <input type="number" id="customerId" name="customerId" required>
            
            <button type="submit">Eliminar Cliente</button>
            <button type="button" class="back-button" onclick="window.location.href='/';">Volver al Inicio</button>
        </form>
    </body>
    </html>
    `);
});

app.post('/eliminar_cliente', async (req, res) => {
    const { customerId } = req.body;
    const connection = await openConnection();
    if (connection) {
        try {
            const result = await connection.execute(`BEGIN
                DELETE_CUSTOMER(p_customer_id => :customerId);
                COMMIT;
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Error al eliminar cliente: ' || SQLERRM);
                    ROLLBACK;
            END;`, { customerId: parseInt(customerId) });
            res.send('Cliente eliminado con éxito');
        } catch (err) {
            res.status(500).send('Error al eliminar cliente');
            console.error(err);
        } finally {
            await connection.close();
        }
    } else {
        res.status(500).send('Error al conectar con la base de datos');
    }
});




app.get('/ver_cliente', (req, res) => {
    res.send(`<!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Ver Clientes</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 40px;
                display: flex;
                flex-direction: column;
                align-items: center;
            }
            table {
                width: 100%;
                border-collapse: collapse;
            }
            th, td {
                padding: 8px;
                text-align: left;
                border-bottom: 1px solid #ddd;
            }
            th {
                background-color: #f2f2f2;
            }
        </style>
    </head>
    <body>
        <h1>Lista de Clientes</h1>
        <table id="customersTable">
            <thead>
                <tr>
                    <th>ID del Cliente</th>
                    <th>Nombre</th>
                    <th>Apellido</th>
                    <th>Límite de Crédito</th>
                    <th>Email</th>
                    <th>Nivel de Ingresos</th>
                    <th>Región</th>
                </tr>
            </thead>
            <tbody>
            </tbody>
        </table>
    
        <script>
            document.addEventListener('DOMContentLoaded', function() {
                fetch('/api/clientes')
                .then(response => response.json())
                .then(data => {
                    const table = document.getElementById('customersTable').getElementsByTagName('tbody')[0];
                    data.forEach(row => {
                        let newRow = table.insertRow();
                        Object.values(row).forEach(text => {
                            let newCell = newRow.insertCell();
                            let newText = document.createTextNode(text);
                            newCell.appendChild(newText);
                        });
                    });
                })
                .catch(error => console.error('Error fetching data:', error));
            });
        </script>
    </body>
    </html>
    `);
});


app.get('/api/clientes', async (req, res) => {
    let connection;
    try {
        connection = await openConnection();
        const result = await connection.execute(`SELECT * FROM CUSTOMERS`);
        res.json(result.rows.map(row => {
            return {
                customerId: row[0],
                firstName: row[1],
                lastName: row[2],
                creditLimit: row[3],
                email: row[4],
                incomeLevel: row[5],
                region: row[6]
            };
        }));
    } catch (err) {
        res.status(500).send('Error fetching customers');
        console.error(err);
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (err) {
                console.error(err);
            }
        }
    }
});


app.get('/ver_todos_los_clientes', (req, res) => {
    res.send(`<!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Ver Todos los Clientes</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 40px;
                display: flex;
                flex-direction: column;
                align-items: center;
            }
            table {
                width: 100%;
                border-collapse: collapse;
            }
            th, td {
                padding: 8px;
                text-align: left;
                border-bottom: 1px solid #ddd;
            }
            th {
                background-color: #f2f2f2;
            }
        </style>
    </head>
    <body>
        <h1>Lista de Todos los Clientes</h1>
        <table id="customersTable">
            <thead>
                <tr>
                    <th>ID del Cliente</th>
                    <th>Nombre</th>
                    <th>Apellido</th>
                    <th>Límite de Crédito</th>
                    <th>Email</th>
                    <th>Nivel de Ingresos</th>
                    <th>Región</th>
                </tr>
            </thead>
            <tbody>
            </tbody>
        </table>
    
        <script>
            document.addEventListener('DOMContentLoaded', function() {
                fetch('/api/todos_los_clientes')
                .then(response => response.json())
                .then(data => {
                    const table = document.getElementById('customersTable').getElementsByTagName('tbody')[0];
                    data.forEach(row => {
                        let newRow = table.insertRow();
                        Object.values(row).forEach(text => {
                            let newCell = newRow.insertCell();
                            let newText = document.createTextNode(text);
                            newCell.appendChild(newText);
                        });
                    });
                })
                .catch(error => console.error('Error fetching data:', error));
            });
        </script>
    </body>
    </html>
    `);
});

app.get('/api/todos_los_clientes', async (req, res) => {
    let connection;
    try {
        connection = await openConnection();
        const result = await connection.execute(`SELECT * FROM mv_customers_global`);
        res.json(result.rows.map(row => {
            return {
                customerId: row[0],
                firstName: row[1],
                lastName: row[2],
                creditLimit: row[3],
                email: row[4],
                incomeLevel: row[5],
                region: row[6]
            };
        }));
    } catch (err) {
        res.status(500).send('Error fetching customers');
        console.error(err);
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (err) {
                console.error(err);
            }
        }
    }
});





app.get('/insertar_orden', (req, res) => {
    res.send(`<!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Insertar Orden</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 40px;
                display: flex;
                flex-direction: column;
                align-items: center;
            }
            form {
                display: flex;
                flex-direction: column;
                width: 300px;
                gap: 10px;
            }
            label {
                font-weight: bold;
            }
            input, select {
                padding: 8px;
                border: 1px solid #ccc;
                border-radius: 4px;
            }
            button {
                padding: 10px 20px;
                font-size: 16px;
                cursor: pointer;
                background-color: #007bff;
                color: white;
                border: none;
                border-radius: 5px;
            }
            button:hover {
                background-color: #0056b3;
            }
        </style>
    </head>
    <body>
        <h1>Insertar Nueva Orden</h1>
        <form action="/insertar_orden" method="post">
            <label for="orderId">ID de la Orden:</label>
            <input type="number" id="orderId" name="orderId" required>
    
            <label for="orderMode">Modo de la Orden:</label>
            <select id="orderMode" name="orderMode" required>
                <option value="Online">Online</option>
                <option value="InStore">En Tienda</option>
                <option value="Phone">Por Teléfono</option>
            </select>
    
            <label for="customerId">ID del Cliente:</label>
            <input type="number" id="customerId" name="customerId" required>
    
            <label for="orderStatus">Estado de la Orden:</label>
            <input type="number" id="orderStatus" name="orderStatus" required>
    
            <label for="orderTotal">Total de la Orden ($):</label>
            <input type="number" step="0.01" id="orderTotal" name="orderTotal" required>
    
            <label for="salesRepId">ID del Representante de Ventas:</label>
            <input type="number" id="salesRepId" name="salesRepId" required>
    
            <label for="promotionId">ID de la Promoción:</label>
            <input type="number" id="promotionId" name="promotionId" required>
    
            <button type="submit">Insertar Orden</button>
        </form>
    </body>
    </html>
    `);
});

app.post('/insertar_orden', async (req, res) => {
    const { orderId, orderMode, customerId, orderStatus, orderTotal, salesRepId, promotionId } = req.body;
    const connection = await openConnection();
    if (connection) {
        try {
            await connection.execute(`BEGIN
                INSERT_ORDER(
                    p_order_id => :orderId,
                    p_order_date => SYSTIMESTAMP,
                    p_order_mode => :orderMode,
                    p_customer_id => :customerId,
                    p_order_status => :orderStatus,
                    p_order_total => :orderTotal,
                    p_sales_rep_id => :salesRepId,
                    p_promotion_id => :promotionId
                );
                COMMIT;
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Error al insertar la orden: ' || SQLERRM);
                    ROLLBACK;
            END;`, {
                orderId, orderMode, customerId, orderStatus, orderTotal, salesRepId, promotionId
            });
            res.send('Orden insertada con éxito');
        } catch (err) {
            res.status(500).send('Error al insertar la orden');
            console.error(err);
        } finally {
            await connection.close();
        }
    } else {
        res.status(500).send('Error al conectar con la base de datos');
    }
});




app.get('/actualizar_orden', (req, res) => {
    res.send(`<!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Actualizar Orden</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 40px;
                display: flex;
                flex-direction: column;
                align-items: center;
            }
            form {
                display: flex;
                flex-direction: column;
                width: 300px;
                gap: 10px;
            }
            label {
                font-weight: bold;
            }
            input, select {
                padding: 8px;
                border: 1px solid #ccc;
                border-radius: 4px;
            }
            button {
                padding: 10px 20px;
                font-size: 16px;
                cursor: pointer;
                background-color: #007bff;
                color: white;
                border: none;
                border-radius: 5px;
            }
            button:hover {
                background-color: #0056b3;
            }
        </style>
    </head>
    <body>
        <h1>Actualizar Orden</h1>
        <form action="/actualizar_orden" method="post">
            <label for="orderId">ID de la Orden:</label>
            <input type="number" id="orderId" name="orderId" required>
    
            <label for="orderMode">Modo de la Orden:</label>
            <select id="orderMode" name="orderMode" required>
                <option value="Online">Online</option>
                <option value="In-Store" selected>En Tienda</option>
                <option value="Phone">Por Teléfono</option>
            </select>
    
            <label for="customerId">ID del Cliente:</label>
            <input type="number" id="customerId" name="customerId" required>
    
            <label for="orderStatus">Estado de la Orden:</label>
            <input type="number" id="orderStatus" name="orderStatus" required>
    
            <label for="orderTotal">Total de la Orden ($):</label>
            <input type="number" step="0.01" id="orderTotal" name="orderTotal" required>
    
            <label for="salesRepId">ID del Representante de Ventas:</label>
            <input type="number" id="salesRepId" name="salesRepId" required>
    
            <label for="promotionId">ID de la Promoción:</label>
            <input type="number" id="promotionId" name="promotionId" required>
    
            <button type="submit">Actualizar Orden</button>
        </form>
    </body>
    </html>
    `);
});

app.post('/actualizar_orden', async (req, res) => {
    const { orderId, orderMode, customerId, orderStatus, orderTotal, salesRepId, promotionId } = req.body;
    const connection = await openConnection();
    if (connection) {
        try {
            await connection.execute(`BEGIN
                UPDATE_ORDER(
                    p_order_id => :orderId,
                    p_order_date => SYSTIMESTAMP,
                    p_order_mode => :orderMode,
                    p_customer_id => :customerId,
                    p_order_status => :orderStatus,
                    p_order_total => :orderTotal,
                    p_sales_rep_id => :salesRepId,
                    p_promotion_id => :promotionId
                );
                COMMIT;
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Error al actualizar la orden: ' || SQLERRM);
                    ROLLBACK;
            END;`, {
                orderId, orderMode, customerId, orderStatus, orderTotal, salesRepId, promotionId
            });
            res.send('Orden actualizada con éxito');
        } catch (err) {
            res.status(500).send('Error al actualizar la orden');
            console.error(err);
        } finally {
            await connection.close();
        }
    } else {
        res.status(500).send('Error al conectar con la base de datos');
    }
});




app.get('/eliminar_orden', (req, res) => {
    res.send(`<!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Eliminar Orden</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 40px;
                display: flex;
                flex-direction: column;
                align-items: center;
            }
            form {
                display: flex;
                flex-direction: column;
                width: 300px;
                gap: 10px;
            }
            label {
                font-weight: bold;
            }
            input {
                padding: 8px;
                border: 1px solid #ccc;
                border-radius: 4px;
            }
            button {
                padding: 10px 20px;
                font-size: 16px;
                cursor: pointer;
                background-color: #dc3545;
                color: white;
                border: none;
                border-radius: 5px;
            }
            button:hover {
                background-color: #c82333;
            }
        </style>
    </head>
    <body>
        <h1>Eliminar Orden</h1>
        <form action="/eliminar_orden" method="post">
            <label for="orderId">ID de la Orden:</label>
            <input type="number" id="orderId" name="orderId" required>
            
            <button type="submit">Eliminar Orden</button>
        </form>
    </body>
    </html>
    `);
});


app.post('/eliminar_orden', async (req, res) => {
    const { orderId } = req.body;
    const connection = await openConnection();
    if (connection) {
        try {
            await connection.execute(`BEGIN
                DELETE_ORDER(p_order_id => :orderId);
                COMMIT;
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Error al eliminar la orden: ' || SQLERRM);
                    ROLLBACK;
            END;`, { orderId: parseInt(orderId) });
            res.send('Orden eliminada con éxito');
        } catch (err) {
            res.status(500).send('Error al eliminar la orden');
            console.error(err);
        } finally {
            await connection.close();
        }
    } else {
        res.status(500).send('Error al conectar con la base de datos');
    }
});




app.get('/ver_orden', (req, res) => {
    res.send(`<!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Ver Órdenes</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 40px;
                display: flex;
                flex-direction: column;
                align-items: center;
            }
            table {
                width: 100%;
                border-collapse: collapse;
            }
            th, td {
                padding: 8px;
                text-align: left;
                border-bottom: 1px solid #ddd;
            }
            th {
                background-color: #f2f2f2;
            }
        </style>
    </head>
    <body>
        <h1>Lista de Órdenes</h1>
        <table id="ordersTable">
            <thead>
                <tr>
                    <th>ID de Orden</th>
                    <th>Fecha de Orden</th>
                    <th>Modo de Orden</th>
                    <th>ID de Cliente</th>
                    <th>Estado de Orden</th>
                    <th>Total de Orden</th>
                    <th>ID de Rep. de Ventas</th>
                    <th>ID de Promoción</th>
                </tr>
            </thead>
            <tbody>
            </tbody>
        </table>
    
        <script>
    document.addEventListener('DOMContentLoaded', function() {
        fetch('/api/ordenes')
        .then(response => response.json())
        .then(data => {
            const table = document.getElementById('ordersTable').getElementsByTagName('tbody')[0];
            data.forEach(row => {
                let newRow = table.insertRow();
                Object.values(row).forEach(text => { // Usa Object.values(row) para acceder a los valores de cada propiedad del objeto row.
                    let newCell = newRow.insertCell();
                    let newText = document.createTextNode(text);
                    newCell.appendChild(newText);
                });
            });
        })
        .catch(error => console.error('Error fetching data:', error));
    });
</script>

    </body>
    </html>
    `);
});


app.get('/api/ordenes', async (req, res) => {
    let connection;
    try {
        console.log(`llamando a ordenes`)
        connection = await openConnection();
        const result = await connection.execute(`SELECT * FROM ORDERS`);
        res.json(result.rows.map(row => {
            return {
                orderId: row[0],
                orderDate: row[1],
                orderMode: row[2],
                customerId: row[3],
                orderStatus: row[4],
                orderTotal: row[5],
                salesRepId: row[6],
                promotionId: row[7]
            };
        }));
    } catch (err) {
        res.status(500).send('Error fetching orders');
        console.error(err);
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (err) {
                console.error(err);
            }
        }
    }
});


app.get('/ver_todas_las_ordenes', (req, res) => {
    res.send(`<!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Ver Todas las Órdenes</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 40px;
                display: flex;
                flex-direction: column;
                align-items: center;
            }
            table {
                width: 100%;
                border-collapse: collapse;
            }
            th, td {
                padding: 8px;
                text-align: left;
                border-bottom: 1px solid #ddd;
            }
            th {
                background-color: #f2f2f2;
            }
        </style>
    </head>
    <body>
        <h1>Lista de Todas las Órdenes</h1>
        <table id="ordersTable">
            <thead>
                <tr>
                    <th>ID de Orden</th>
                    <th>Fecha de Orden</th>
                    <th>Modo de Orden</th>
                    <th>ID de Cliente</th>
                    <th>Estado de Orden</th>
                    <th>Total de Orden</th>
                    <th>ID de Rep. de Ventas</th>
                    <th>ID de Promoción</th>
                </tr>
            </thead>
            <tbody>
            </tbody>
        </table>
    
        <script>
            document.addEventListener('DOMContentLoaded', function() {
                fetch('/api/ordenes_globales')
                .then(response => response.json())
                .then(data => {
                    const table = document.getElementById('ordersTable').getElementsByTagName('tbody')[0];
                    data.forEach(row => {
                        let newRow = table.insertRow();
                        Object.values(row).forEach(text => {
                            let newCell = newRow.insertCell();
                            let newText = document.createTextNode(text);
                            newCell.appendChild(newText);
                        });
                    });
                })
                .catch(error => console.error('Error fetching data:', error));
            });
        </script>
    </body>
    </html>
    `);
});

app.get('/api/ordenes_globales', async (req, res) => {
    let connection;
    try {
        connection = await openConnection();
        const result = await connection.execute(`SELECT * FROM mv_orders_global`);
        res.json(result.rows.map(row => {
            return {
                orderId: row[0],
                orderDate: row[1],
                orderMode: row[2],
                customerId: row[3],
                orderStatus: row[4],
                orderTotal: row[5],
                salesRepId: row[6],
                promotionId: row[7]
            };
        }));
    } catch (err) {
        res.status(500).send('Error fetching orders');
        console.error(err);
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (err) {
                console.error(err);
            }
        }
    }
});



app.get('/insertar_item_orden', (req, res) => {
    res.send(`<!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Insertar Ítem de Orden</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 40px;
                display: flex;
                flex-direction: column;
                align-items: center;
            }
            form {
                display: flex;
                flex-direction: column;
                width: 300px;
                gap: 10px;
            }
            label {
                font-weight: bold;
            }
            input {
                padding: 8px;
                border: 1px solid #ccc;
                border-radius: 4px;
            }
            button {
                padding: 10px 20px;
                font-size: 16px;
                cursor: pointer;
                background-color: #007bff;
                color: white;
                border: none;
                border-radius: 5px;
            }
            button:hover {
                background-color: #0056b3;
            }
        </style>
    </head>
    <body>
        <h1>Insertar Ítem de Orden</h1>
        <form action="/insertar_item_orden" method="post">
            <label for="orderId">ID de la Orden:</label>
            <input type="number" id="orderId" name="orderId" required>
    
            <label for="lineItemId">ID del Ítem de Línea:</label>
            <input type="number" id="lineItemId" name="lineItemId" required>
    
            <label for="productId">ID del Producto:</label>
            <input type="number" id="productId" name="productId" required>
    
            <label for="unitPrice">Precio Unitario:</label>
            <input type="number" step="0.01" id="unitPrice" name="unitPrice" required>
    
            <label for="quantity">Cantidad:</label>
            <input type="number" id="quantity" name="quantity" required>
    
            <button type="submit">Insertar Ítem</button>
        </form>
    </body>
    </html>
    `);
});

app.post('/insertar_item_orden', async (req, res) => {
    const { orderId, lineItemId, productId, unitPrice, quantity } = req.body;
    const connection = await openConnection();
    if (connection) {
        try {
            await connection.execute(`BEGIN
                INSERT_ORDER_ITEM(
                    p_order_id => :orderId,
                    p_line_item_id => :lineItemId,
                    p_product_id => :productId,
                    p_unit_price => :unitPrice,
                    p_quantity => :quantity
                );
                COMMIT;
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Error al insertar ítem de orden: ' || SQLERRM);
                    ROLLBACK;
            END;`, {
                orderId, lineItemId, productId, unitPrice, quantity
            });
            res.send('Ítem de orden insertado con éxito');
        } catch (err) {
            res.status(500).send('Error al insertar ítem de orden');
            console.error(err);
        } finally {
            await connection.close();
        }
    } else {
        res.status(500).send('Error al conectar con la base de datos');
    }
});





app.get('/actualizar_item_orden', (req, res) => {
    res.send(`<!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Actualizar Ítem de Orden</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 40px;
                display: flex;
                flex-direction: column;
                align-items: center;
            }
            form {
                display: flex;
                flex-direction: column;
                width: 300px;
                gap: 10px;
            }
            label {
                font-weight: bold;
            }
            input, select {
                padding: 8px;
                border: 1px solid #ccc;
                border-radius: 4px;
            }
            button {
                padding: 10px 20px;
                font-size: 16px;
                cursor: pointer;
                background-color: #007bff;
                color: white;
                border: none;
                border-radius: 5px;
            }
            button:hover {
                background-color: #0056b3;
            }
        </style>
    </head>
    <body>
        <h1>Actualizar Ítem de Orden</h1>
        <form action="/actualizar_item_orden" method="post">
            <label for="orderId">ID de la Orden:</label>
            <input type="number" id="orderId" name="orderId" required>
    
            <label for="lineItemId">ID del Ítem de Línea:</label>
            <input type="number" id="lineItemId" name="lineItemId" required>
    
            <label for="productId">ID del Producto:</label>
            <input type="number" id="productId" name="productId" required>
    
            <label for="unitPrice">Nuevo Precio Unitario:</label>
            <input type="number" step="0.01" id="unitPrice" name="unitPrice" required>
    
            <label for="quantity">Nueva Cantidad:</label>
            <input type="number" id="quantity" name="quantity" required>
    
            <button type="submit">Actualizar Ítem</button>
        </form>
    </body>
    </html>
    `);
});

app.post('/actualizar_item_orden', async (req, res) => {
    const { orderId, lineItemId, productId, unitPrice, quantity } = req.body;
    const connection = await openConnection();
    if (connection) {
        try {
            await connection.execute(`BEGIN
                UPDATE_ORDER_ITEM(
                    p_order_id => :orderId,
                    p_line_item_id => :lineItemId,
                    p_product_id => :productId,
                    p_unit_price => :unitPrice,
                    p_quantity => :quantity
                );
                COMMIT;
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Error al actualizar ítem de orden: ' || SQLERRM);
                    ROLLBACK;
            END;`, {
                orderId, lineItemId, productId, unitPrice, quantity
            });
            res.send('Ítem de orden actualizado con éxito');
        } catch (err) {
            res.status(500).send('Error al actualizar ítem de orden');
            console.error(err);
        } finally {
            await connection.close();
        }
    } else {
        res.status(500).send('Error al conectar con la base de datos');
    }
});


app.get('/eliminar_item_orden', (req, res) => {
    res.send(`<!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Eliminar Ítem de Orden</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 40px;
                display: flex;
                flex-direction: column;
                align-items: center;
            }
            form {
                display: flex;
                flex-direction: column;
                width: 300px;
                gap: 10px;
            }
            label {
                font-weight: bold;
            }
            input {
                padding: 8px;
                border: 1px solid #ccc;
                border-radius: 4px;
            }
            button {
                padding: 10px 20px;
                font-size: 16px;
                cursor: pointer;
                background-color: #dc3545;
                color: white;
                border: none;
                border-radius: 5px;
            }
            button:hover {
                background-color: #c82333;
            }
        </style>
    </head>
    <body>
        <h1>Eliminar Ítem de Orden</h1>
        <form action="/eliminar_item_orden" method="post">
            <label for="orderId">ID de la Orden:</label>
            <input type="number" id="orderId" name="orderId" required>
    
            <label for="lineItemId">ID del Ítem de Línea:</label>
            <input type="number" id="lineItemId" name="lineItemId" required>
    
            <button type="submit">Eliminar Ítem</button>
        </form>
    </body>
    </html>
    `);
});

app.post('/eliminar_item_orden', async (req, res) => {
    const { orderId, lineItemId } = req.body;
    const connection = await openConnection();
    if (connection) {
        try {
            await connection.execute(`BEGIN
                DELETE_ORDER_ITEM(p_order_id => :orderId, p_line_item_id => :lineItemId);
                COMMIT;
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Error al eliminar ítem de orden: ' || SQLERRM);
                    ROLLBACK;
            END;`, {
                orderId: parseInt(orderId),
                lineItemId: parseInt(lineItemId)
            });
            res.send('Ítem de orden eliminado con éxito');
        } catch (err) {
            res.status(500).send('Error al eliminar ítem de orden');
            console.error(err);
        } finally {
            await connection.close();
        }
    } else {
        res.status(500).send('Error al conectar con la base de datos');
    }
});




app.get('/ver_item_orden', (req, res) => {
    res.send(`<!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Ver Ítems de Órdenes</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 40px;
                display: flex;
                flex-direction: column;
                align-items: center;
            }
            table {
                width: 100%;
                border-collapse: collapse;
            }
            th, td {
                padding: 8px;
                text-align: left;
                border-bottom: 1px solid #ddd;
            }
            th {
                background-color: #f2f2f2;
            }
        </style>
    </head>
    <body>
        <h1>Lista de Ítems de Órdenes</h1>
        <table id="orderItemsTable">
            <thead>
                <tr>
                    <th>ID de Orden</th>
                    <th>ID de Ítem de Línea</th>
                    <th>ID de Producto</th>
                    <th>Precio Unitario</th>
                    <th>Cantidad</th>
                </tr>
            </thead>
            <tbody>
            </tbody>
        </table>
    
        <script>
            document.addEventListener('DOMContentLoaded', function() {
                fetch('/api/order_items')
                .then(response => response.json())
                .then(data => {
                    const table = document.getElementById('orderItemsTable').getElementsByTagName('tbody')[0];
                    data.forEach(row => {
                        let newRow = table.insertRow();
                        row.forEach(text => {
                            let newCell = newRow.insertCell();
                            let newText = document.createTextNode(text);
                            newCell.appendChild(newText);
                        });
                    });
                })
                .catch(error => console.error('Error fetching data:', error));
            });
        </script>
    </body>
    </html>
    `);
});

app.get('/api/order_items', async (req, res) => {
    let connection;
    try {
        connection = await openConnection();
        const result = await connection.execute(`SELECT * FROM ORDER_ITEMS`);
        res.json(result.rows.map(row => {
            return [
                row[0], // ORDER_ID
                row[1], // LINE_ITEM_ID
                row[2], // PRODUCT_ID
                row[3].toFixed(2), // UNIT_PRICE
                row[4]  // QUANTITY
            ];
        }));
    } catch (err) {
        res.status(500).send('Error fetching order items');
        console.error(err);
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (err) {
                console.error(err);
            }
        }
    }
});




app.get('/ver_todos_los_items_orden', (req, res) => {
    res.send(`<!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Ver Todos los Ítems de Órdenes</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 40px;
                display: flex;
                flex-direction: column;
                align-items: center;
            }
            table {
                width: 100%;
                border-collapse: collapse;
            }
            th, td {
                padding: 8px;
                text-align: left;
                border-bottom: 1px solid #ddd;
            }
            th {
                background-color: #f2f2f2;
            }
        </style>
    </head>
    <body>
        <h1>Lista de Todos los Ítems de Órdenes Globales</h1>
        <table id="globalOrderItemsTable">
            <thead>
                <tr>
                    <th>ID de Orden</th>
                    <th>ID de Ítem de Línea</th>
                    <th>ID de Producto</th>
                    <th>Precio Unitario</th>
                    <th>Cantidad</th>
                </tr>
            </thead>
            <tbody>
            </tbody>
        </table>
    
        <script>
            document.addEventListener('DOMContentLoaded', function() {
                fetch('/api/global_order_items')
                .then(response => response.json())
                .then(data => {
                    const table = document.getElementById('globalOrderItemsTable').getElementsByTagName('tbody')[0];
                    data.forEach(row => {
                        let newRow = table.insertRow();
                        Object.values(row).forEach(text => {
                            let newCell = newRow.insertCell();
                            let newText = document.createTextNode(text);
                            newCell.appendChild(newText);
                        });
                    });
                })
                .catch(error => console.error('Error fetching data:', error));
            });
        </script>
    </body>
    </html>
    `);
});


app.get('/api/global_order_items', async (req, res) => {
    let connection;
    try {
        connection = await openConnection();
        const result = await connection.execute(`SELECT * FROM mv_order_items_global`);
        res.json(result.rows.map(row => {
            return {
                orderId: row[0], // ORDER_ID
                lineItemId: row[1], // LINE_ITEM_ID
                productId: row[2], // PRODUCT_ID
                unitPrice: row[3].toFixed(2), // UNIT_PRICE
                quantity: row[4]  // QUANTITY
            };
        }));
    } catch (err) {
        res.status(500).send('Error fetching global order items');
        console.error(err);
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (err) {
                console.error(err);
            }
        }
    }
});






app.get('/insertar_producto', (req, res) => {
    res.send(`<!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Insertar Producto</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 40px;
                display: flex;
                flex-direction: column;
                align-items: center;
            }
            form {
                display: flex;
                flex-direction: column;
                width: 300px;
                gap: 10px;
            }
            label {
                font-weight: bold;
            }
            input, select {
                padding: 8px;
                border: 1px solid #ccc;
                border-radius: 4px;
            }
            button {
                padding: 10px 20px;
                font-size: 16px;
                cursor: pointer;
                background-color: #007bff;
                color: white;
                border: none;
                border-radius: 5px;
            }
            button:hover {
                background-color: #0056b3;
            }
        </style>
    </head>
    <body>
        <h1>Insertar Nuevo Producto</h1>
        <form action="/insertar_producto" method="post">
            <label for="productId">ID del Producto:</label>
            <input type="number" id="productId" name="productId" required>
    
            <label for="productName">Nombre del Producto:</label>
            <input type="text" id="productName" name="productName" required>
    
            <label for="productDescription">Descripción del Producto:</label>
            <input type="text" id="productDescription" name="productDescription" required>
    
            <label for="categoryId">ID de Categoría:</label>
            <input type="number" id="categoryId" name="categoryId" required>
    
            <label for="weightClass">Clase de Peso:</label>
            <input type="number" id="weightClass" name="weightClass" required>
    
            <label for="warrantyPeriod">Período de Garantía:</label>
            <input type="text" id="warrantyPeriod" name="warrantyPeriod" placeholder="Ej: 1-0" required>
    
            <label for="supplierId">ID del Proveedor:</label>
            <input type="number" id="supplierId" name="supplierId" required>
    
            <label for="productStatus">Estado del Producto:</label>
            <input type="text" id="productStatus" name="productStatus" required>
    
            <label for="listPrice">Precio de Lista:</label>
            <input type="number" step="0.01" id="listPrice" name="listPrice" required>
    
            <label for="minPrice">Precio Mínimo:</label>
            <input type="number" step="0.01" id="minPrice" name="minPrice" required>
    
            <label for="catalogUrl">URL del Catálogo:</label>
            <input type="url" id="catalogUrl" name="catalogUrl" required>
    
            <button type="submit">Insertar Producto</button>
        </form>
    </body>
    </html>
    `);
});

app.post('/insertar_producto', async (req, res) => {
    const {
        productId, productName, productDescription, categoryId, weightClass,
        warrantyPeriod, supplierId, productStatus, listPrice, minPrice, catalogUrl
    } = req.body;
    const connection = await openConnection();
    if (connection) {
        try {
            await connection.execute(`BEGIN
                MANIPULATE_PRODUCT_INFORMATION(
                    p_product_id => :productId,
                    p_product_name => :productName,
                    p_product_description => :productDescription,
                    p_category_id => :categoryId,
                    p_weight_class => :weightClass,
                    p_warranty_period => INTERVAL '${warrantyPeriod}' YEAR TO MONTH,
                    p_supplier_id => :supplierId,
                    p_product_status => :productStatus,
                    p_list_price => :listPrice,
                    p_min_price => :minPrice,
                    p_catalog_url => :catalogUrl
                );
                COMMIT;
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Error al ejecutar la inserción: ' || SQLERRM);
                    ROLLBACK;
            END;`, {
                productId, productName, productDescription, categoryId, weightClass,
                warrantyPeriod, supplierId, productStatus, listPrice, minPrice, catalogUrl
            });
            res.send('Producto insertado con éxito');
        } catch (err) {
            res.status(500).send('Error al insertar producto');
            console.error(err);
        } finally {
            await connection.close();
        }
    } else {
        res.status(500).send('Error al conectar con la base de datos');
    }
});



app.get('/actualizar_producto', (req, res) => {
    res.send(`<!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Actualizar Producto</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 40px;
                display: flex;
                flex-direction: column;
                align-items: center;
            }
            form {
                display: flex;
                flex-direction: column;
                width: 300px;
                gap: 10px;
            }
            label {
                font-weight: bold;
            }
            input, select {
                padding: 8px;
                border: 1px solid #ccc;
                border-radius: 4px;
            }
            button {
                padding: 10px 20px;
                font-size: 16px;
                cursor: pointer;
                background-color: #007bff;
                color: white;
                border: none;
                border-radius: 5px;
            }
            button:hover {
                background-color: #0056b3;
            }
        </style>
    </head>
    <body>
        <h1>Actualizar Información del Producto</h1>
        <form action="/actualizar_producto" method="post">
            <label for="productId">ID del Producto:</label>
            <input type="number" id="productId" name="productId" required>
    
            <label for="productName">Nombre del Producto:</label>
            <input type="text" id="productName" name="productName" required>
    
            <label for="productDescription">Descripción del Producto:</label>
            <input type="text" id="productDescription" name="productDescription" required>
    
            <label for="categoryId">ID de Categoría:</label>
            <input type="number" id="categoryId" name="categoryId" required>
    
            <label for="weightClass">Clase de Peso:</label>
            <input type="number" id="weightClass" name="weightClass" required>
    
            <label for="warrantyPeriod">Período de Garantía:</label>
            <input type="text" id="warrantyPeriod" name="warrantyPeriod" placeholder="Ej: 2-0" required>
    
            <label for="supplierId">ID del Proveedor:</label>
            <input type="number" id="supplierId" name="supplierId" required>
    
            <label for="productStatus">Estado del Producto:</label>
            <input type="text" id="productStatus" name="productStatus" required>
    
            <label for="listPrice">Precio de Lista:</label>
            <input type="number" step="0.01" id="listPrice" name="listPrice" required>
    
            <label for="minPrice">Precio Mínimo:</label>
            <input type="number" step="0.01" id="minPrice" name="minPrice" required>
    
            <label for="catalogUrl">URL del Catálogo:</label>
            <input type="url" id="catalogUrl" name="catalogUrl" required>
    
            <button type="submit">Actualizar Producto</button>
        </form>
    </body>
    </html>
    `);
});


app.post('/actualizar_producto', async (req, res) => {
    const {
        productId, productName, productDescription, categoryId, weightClass,
        warrantyPeriod, supplierId, productStatus, listPrice, minPrice, catalogUrl
    } = req.body;
    const connection = await openConnection();
    if (connection) {
        try {
            await connection.execute(`BEGIN
                UPDATE_PRODUCT_INFORMATION(
                    p_product_id => :productId,
                    p_product_name => :productName,
                    p_product_description => :productDescription,
                    p_category_id => :categoryId,
                    p_weight_class => :weightClass,
                    p_warranty_period => INTERVAL '${warrantyPeriod}' YEAR TO MONTH,
                    p_supplier_id => :supplierId,
                    p_product_status => :productStatus,
                    p_list_price => :listPrice,
                    p_min_price => :minPrice,
                    p_catalog_url => :catalogUrl
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
            END;`, {
                productId, productName, productDescription, categoryId, weightClass,
                warrantyPeriod, supplierId, productStatus, listPrice, minPrice, catalogUrl
            });
            res.send('Producto actualizado con éxito');
        } catch (err) {
            res.status(500).send('Error al actualizar producto');
            console.error(err);
        } finally {
            await connection.close();
        }
    } else {
        res.status(500).send('Error al conectar con la base de datos');
    }
});





app.get('/eliminar_producto', (req, res) => {
    res.send(`<!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Eliminar Producto</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 40px;
                display: flex;
                flex-direction: column;
                align-items: center;
            }
            form {
                display: flex;
                flex-direction: column;
                width: 300px;
                gap: 10px;
            }
            label {
                font-weight: bold;
            }
            input {
                padding: 8px;
                border: 1px solid #ccc;
                border-radius: 4px;
            }
            button {
                padding: 10px 20px;
                font-size: 16px;
                cursor: pointer;
                background-color: #dc3545;
                color: white;
                border: none;
                border-radius: 5px;
            }
            button:hover {
                background-color: #c82333;
            }
        </style>
    </head>
    <body>
        <h1>Eliminar Producto</h1>
        <form action="/eliminar_producto" method="post">
            <label for="productId">ID del Producto:</label>
            <input type="number" id="productId" name="productId" required>
            
            <button type="submit">Eliminar Producto</button>
        </form>
    </body>
    </html>
    `);
});



app.post('/eliminar_producto', async (req, res) => {
    const { productId } = req.body;
    const connection = await openConnection();
    if (connection) {
        try {
            const result = await connection.execute(`BEGIN
                DELETE_PRODUCT_INFORMATION(:productId);
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
            END;`, { productId });
            if (result.rowsAffected === 0) {
                res.send('Producto no encontrado para eliminar.');
            } else {
                res.send('Producto eliminado exitosamente.');
            }
        } catch (err) {
            res.status(500).send('Error al eliminar producto');
            console.error(err);
        } finally {
            await connection.close();
        }
    } else {
        res.status(500).send('Error al conectar con la base de datos');
    }
});


app.get('/ver_producto', (req, res) => {
    res.send(`<!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Ver Información de Productos</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 40px;
                display: flex;
                flex-direction: column;
                align-items: center;
            }
            table {
                width: 100%;
                border-collapse: collapse;
            }
            th, td {
                padding: 8px;
                text-align: left;
                border-bottom: 1px solid #ddd;
            }
            th {
                background-color: #f2f2f2;
            }
        </style>
    </head>
    <body>
        <h1>Lista de Productos</h1>
        <table id="productsTable">
            <thead>
                <tr>
                    <th>ID del Producto</th>
                    <th>Nombre del Producto</th>
                    <th>Descripción del Producto</th>
                    <th>ID de Categoría</th>
                    <th>Clase de Peso</th>
                    <th>Período de Garantía</th>
                    <th>ID del Proveedor</th>
                    <th>Estado del Producto</th>
                    <th>Precio de Lista</th>
                    <th>Precio Mínimo</th>
                    <th>URL del Catálogo</th>
                </tr>
            </thead>
            <tbody>
            </tbody>
        </table>
    
        <script>
            document.addEventListener('DOMContentLoaded', function() {
                fetch('/api/products')
                .then(response => response.json())
                .then(data => {
                    const table = document.getElementById('productsTable').getElementsByTagName('tbody')[0];
                    data.forEach(product => {
                        let newRow = table.insertRow();
                        Object.values(product).forEach(value => {
                            let newCell = newRow.insertCell();
                            let newText = document.createTextNode(value);
                            newCell.appendChild(newText);
                        });
                    });
                })
                .catch(error => console.error('Error fetching data:', error));
            });
        </script>
    </body>
    </html>
    `);
});



app.get('/api/products', async (req, res) => {
    let connection;
    try {
        console.log(`Llamando la API de productos`);
        connection = await openConnection();
        const result = await connection.execute(`
            SELECT PRODUCT_ID,
                   PRODUCT_NAME,
                   PRODUCT_DESCRIPTION,
                   CATEGORY_ID,
                   WEIGHT_CLASS,
                   EXTRACT(YEAR FROM WARRANTY_PERIOD) || ' years ' || EXTRACT(MONTH FROM WARRANTY_PERIOD) || ' months' AS WARRANTY_PERIOD,
                   SUPPLIER_ID,
                   PRODUCT_STATUS,
                   LIST_PRICE,
                   MIN_PRICE,
                   CATALOG_URL
            FROM PRODUCT_INFORMATION
        `);
        res.json(result.rows.map(row => ({
            productId: row[0],
            productName: row[1],
            productDescription: row[2],
            categoryId: row[3],
            weightClass: row[4],
            warrantyPeriod: row[5],
            supplierId: row[6],
            productStatus: row[7],
            listPrice: row[8],
            minPrice: row[9],
            catalogUrl: row[10]
        })));
    } catch (err) {
        res.status(500).send('Error fetching product information');
        console.error(err);
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (err) {
                console.error(err);
            }
        }
    }
});

app.listen(8080, () => {
    console.log('Servidor ejecutándose en http://localhost:8080');
});



app.get('/HOLA', (req, res) => {
    res.send('<h1> Hola esta es mi web </h1>');
});