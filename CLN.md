# Conclusiones

1. **Uso correcto de ExecuteNonQuery:** Se comprobó que `ExecuteNonQuery` (y `ExecuteNonQueryAsync`) es la herramienta ideal en ADO.NET para operaciones de inserción, modificación y baja lógica, ya que solo necesitamos saber si la operación afectó filas sin requerir un conjunto de datos devuelto.
2. **Ventaja de la eliminación lógica:** La baja lógica mediante el campo `Activo` es un estándar indispensable en sistemas empresariales, pues conserva la trazabilidad y auditoría de la información histórica sin riesgo de pérdida de datos.
3. **Seguridad y orden con Procedimientos Almacenados:** Centralizar las operaciones en Stored Procedures parametrizados evita la inyección SQL y facilita el mantenimiento, manteniendo limpio el código de la aplicación en WPF.
4. **Integración fluida con WPF y ADO.NET:** La combinación de controles WPF (DataGrid, ComboBox, DatePicker) con consultas asíncronas de ADO.NET permite construir mantenimientos y reportes rápidos, estables y cómodos para el usuario.
