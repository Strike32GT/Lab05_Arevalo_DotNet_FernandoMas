# Observaciones

1. **Protección de la integridad de datos:** Aplicar eliminación lógica en lugar de borrado físico evita errores por claves foráneas (FK), permitiendo que pedidos antiguos sigan referenciando productos o proveedores sin romper la consistencia de la base de datos.
2. **Importancia del filtro en consultas:** Al usar eliminación lógica es fundamental no olvidar el filtro `WHERE Activo = 1` en todos los listados, búsquedas y reportes para evitar mostrar registros dados de baja al usuario final.
3. **Eficiencia en la escritura:** `ExecuteNonQuery` es el método más directo y rápido para sentencias DML (INSERT, UPDATE) porque no gasta recursos procesando tablas o cursores de retorno.
4. **Manejo de asincronía en WPF:** Trabajar con métodos asíncronos (`ExecuteNonQueryAsync`, `ExecuteReaderAsync`) evita que la interfaz gráfica se congele mientras se realizan las consultas a SQL Server.
