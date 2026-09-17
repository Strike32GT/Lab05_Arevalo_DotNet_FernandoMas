# Desarrollo de Aplicaciones Empresariales Avanzado

**Semana 05**

Arévalo Sermeño, Edwin William

Desarrollo de aplicaciones Web avanzado

6 - C24 - Sección C - D

## EXECUTE NONQUERY SEMANA05

En este desafío, se te pide que diseñes e implementes un programa con las siguientes partes:

### Base de Datos

1. Descarga el archivo NeptunoDB.
2. Ejecuta el script de la base de datos. **Agrega a las tablas Productos, Categorías, Proveedores y Pedidos un campo de estado (por ejemplo, Activo BIT, valor por defecto 1) que permita implementar eliminación lógica en lugar de eliminación física.**

### Procedimientos Almacenados

Crea los siguientes procedimientos almacenados:

3. CRUD de productos. **El procedimiento de eliminación debe realizar eliminación lógica (actualizar Activo = 0), nunca un DELETE físico.**
4. CRUD de categorías. **Misma regla: eliminar = actualizar Activo = 0.**
5. CRUD de proveedores. **Misma regla: eliminar = actualizar Activo = 0.**
6. CRUD de pedidos. **Misma regla: eliminar = actualizar Activo = 0.**
7. Listado de proveedores buscando por nombreContacto y ciudad. **El listado solo debe mostrar registros con Activo = 1.**
8. Listado de detalles de pedidos haciendo un inner join con pedidos, filtrando por un intervalo de fechas. **Excluir pedidos con Activo = 0.**

### WPF + ADO .NET

9. Implementar el mantenimiento de productos. **Insertar, actualizar y eliminar (lógicamente) usando ExecuteNonQuery; el botón "Eliminar" debe invocar el procedimiento de baja lógica, no un borrado físico.**
10. Implementar el mantenimiento de categorías. **Mismo criterio: ExecuteNonQuery para alta/edición/baja lógica.**
11. Implementar el mantenimiento de proveedores. **Mismo criterio: ExecuteNonQuery para alta/edición/baja lógica.**
    a. Búsqueda de proveedores usando filtros de búsqueda.
12. Implementar el mantenimiento de pedidos. **Mismo criterio: ExecuteNonQuery para alta/edición/baja lógica.**
    a. Implementar reportes usando los filtros de fecha.

---

Adjuntas scripts con la entrega de este documento.

**Repositorio:**

<!-- Agrega aquí el enlace a tu repositorio de GitHub / GitLab -->

**Capturas de las vistas:**

<!-- Inserta aquí las capturas de pantalla de la aplicación ejecutándose -->

**Explicación:** 

### 1. Implementación de `ExecuteNonQuery` en operaciones de escritura
En la capa de acceso a datos (`ADO.NET` en [MainWindow.xaml.cs](file:///c:/Users/Fernando/Desktop/TECSUP2026/Ciclo6/Csharp_DotNet_Arevalo/Lab05/WPFMMVMSP/WPF_SP/MainWindow.xaml.cs)), todas las operaciones que modifican el estado de la base de datos (Inserción, Actualización y Baja Lógica) se canalizan a través del método asíncrono `EjecutarAsync`:

```csharp
private async Task EjecutarAsync(string sp, params SqlParameter[] ps)
{
    await using var cn = new SqlConnection(DbConfig.ConnectionString);
    await using var cmd = new SqlCommand(sp, cn) { CommandType = CommandType.StoredProcedure };
    cmd.Parameters.AddRange(ps);
    await cn.OpenAsync();
    await cmd.ExecuteNonQueryAsync(); // <- Ejecución de escritura con ExecuteNonQuery
}
```

* **Insertar**: Invoca a los procedimientos almacenados correspondientes (`usp_Producto_Insertar`, `usp_Categoria_Insertar`, `usp_Proveedor_Insertar`, `usp_Pedido_Insertar`) usando `ExecuteNonQueryAsync()`.
* **Actualizar**: Invoca a los procedimientos almacenados (`usp_Producto_Actualizar`, etc.) actualizando los campos mediante `ExecuteNonQueryAsync()`.
* **Eliminar (Baja Lógica)**: Invoca a `usp_Producto_Eliminar`, `usp_Categoria_Eliminar`, `usp_Proveedor_Eliminar`, `usp_Pedido_Eliminar` que ejecutan un `UPDATE ... SET Activo = 0` usando `ExecuteNonQueryAsync()`.

### 2. Resolución de la Eliminación Lógica
* **Estructura de la Base de Datos ([NeptunoDB.sql](file:///c:/Users/Fernando/Desktop/TECSUP2026/Ciclo6/Csharp_DotNet_Arevalo/Lab05/WPFMMVMSP/WPF_SP/NeptunoDB.sql))**:
  Se agregó el campo `Activo BIT NOT NULL DEFAULT 1` a las 4 tablas principales:
  * `dbo.Categorias` (`Activo BIT NOT NULL DEFAULT 1`)
  * `dbo.Proveedores` (`Activo BIT NOT NULL DEFAULT 1`)
  * `dbo.Productos` (`Activo BIT NOT NULL DEFAULT 1`)
  * `dbo.Pedidos` (`Activo BIT NOT NULL DEFAULT 1`)

* **Procedimientos Almacenados de Eliminación ([StoredProcedures.sql](file:///c:/Users/Fernando/Desktop/TECSUP2026/Ciclo6/Csharp_DotNet_Arevalo/Lab05/WPFMMVMSP/WPF_SP/StoredProcedures.sql))**:
  En lugar de sentencias `DELETE`, se modificaron para ejecutar `UPDATE`:
  ```sql
  CREATE OR ALTER PROCEDURE dbo.usp_Producto_Eliminar
      @ProductoID INT
  AS
      UPDATE dbo.Productos
      SET Activo = 0
      WHERE ProductoID = @ProductoID;
  ```

* **Verificación y Filtros en Listados y Consultas**:
  * En los procedimientos de listado general (`usp_Categoria_Listar`, `usp_Proveedor_Listar`, `usp_Producto_Listar`, `usp_Pedido_Listar`) y búsquedas por ID (`usp_*_Obtener`), se agregó la cláusula `WHERE Activo = 1`.
  * En la búsqueda con filtros de proveedores (`usp_Proveedor_Buscar`), se incluyó la condición `WHERE Activo = 1 AND (...)`.
  * En el reporte de detalles de pedidos (`usp_Reporte_DetallePedidosPorFechas`), se excluyen los pedidos con baja lógica mediante `WHERE p.Activo = 1 AND p.FechaPedido BETWEEN @FechaInicio AND @FechaFin`.

**Observaciones y Conclusiones:**

* **Observaciones:**
  1. La eliminación lógica previene la pérdida irreversible de información y evita problemas de integridad referencial con claves foráneas (por ejemplo, pedidos asociados a productos o clientes históricos).
  2. Los índices y consultas deben considerar el campo `Activo` para no procesar ni mostrar registros dados de baja de manera innecesaria.
  3. El uso de Stored Procedures desacopla la lógica de persistencia de la interfaz de usuario en WPF y optimiza la seguridad evitando ataques de inyección SQL.

* **Conclusiones:**
  1. `ExecuteNonQuery` (y su variante `ExecuteNonQueryAsync`) es el método idóneo en ADO.NET para sentencias DML (`INSERT`, `UPDATE`, `DELETE`) al no devolver conjuntos de resultados tabulares, maximizando el rendimiento.
  2. La separación de responsabilidades con Stored Procedures parametrizados y el enlace de datos en WPF permite construir interfaces limpias y reactivas ante operaciones asíncronas.
