# Explicación del Proyecto

### 1. Implementación de `ExecuteNonQuery`
Para todas las operaciones de escritura (crear, editar y dar de baja), creé un método centralizado llamado `EjecutarAsync` en `MainWindow.xaml.cs`. Este método abre la conexión con SQL Server, recibe el nombre del Stored Procedure y sus parámetros, y ejecuta `await cmd.ExecuteNonQueryAsync()`. 

Lo utilicé directamente en:
* **Insertar (Crear):** Al presionar "Guardar" cuando no hay un registro seleccionado, llama a los procedimientos `usp_*_Insertar` con `ExecuteNonQuery`.
* **Actualizar (Editar):** Cuando se selecciona un registro existente y se pulsa "Guardar", invoca a `usp_*_Actualizar` enviando el ID y los campos modificados con `ExecuteNonQuery`.
* **Eliminar (Baja Lógica):** Al presionar "Eliminar", no se borra la fila, sino que llama a `usp_*_Eliminar` ejecutando un `UPDATE` mediante `ExecuteNonQuery`.

### 2. Solución de la Eliminación Lógica
* **En la Base de Datos:** Agregué a las tablas `Productos`, `Categorias`, `Proveedores` y `Pedidos` la columna `Activo BIT NOT NULL DEFAULT 1`.
* **En los Stored Procedures de eliminación:** Cambié las sentencias `DELETE` por `UPDATE dbo.[Tabla] SET Activo = 0 WHERE [ID] = @ID`. De esta manera, el registro se mantiene en la base de datos para no romper claves foráneas ni perder historial, pero queda marcado como inactivo.
* **En los Listados y Reportes:** En todas las consultas de lectura (`usp_*_Listar`, `usp_Proveedor_Buscar` y `usp_Reporte_DetallePedidosPorFechas`), agregué el filtro `WHERE Activo = 1` (o `WHERE p.Activo = 1` en el JOIN), asegurando que la interfaz de usuario y los reportes solo muestren la información vigente.
