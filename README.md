# WPF_SP — Mantenimiento Neptuno (WPF + ADO.NET + SQL Server)

Aplicación de escritorio WPF en C# para el **mantenimiento de la base de datos NeptunoDB** mediante **procedimientos almacenados**, desarrollada como parte del laboratorio **"ADO .NET – SEMANA04"**.

## Características

- **Productos**: CRUD completo sobre `dbo.Productos` con catálogos de proveedores y categorías.
- **Categorías**: CRUD completo sobre `dbo.Categorias`.
- **Proveedores**: CRUD completo sobre `dbo.Proveedores` y **búsqueda por nombre de contacto y ciudad** (filtros dinámicos).
- **Pedidos**: CRUD completo sobre `dbo.Pedidos` con catálogos de clientes, empleados y transportistas.
- **Reporte**: detalle de pedidos (JOIN con `DetallePedidos` y `Productos`) filtrado por **intervalo de fechas**, con cálculo de importe.
- **Módulo de tareas (MVVM)**: gestión de tareas con CommunityToolkit.Mvvm (crear, editar, filtrar por estado, marcar como completada y eliminar).

## Tecnologías

| Tecnología | Versión |
|---|---|
| .NET (WPF, target `net10.0-windows`) | 10.0 |
| CommunityToolkit.Mvvm | 8.4.2 |
| Microsoft.Data.SqlClient | 7.0.2 |
| SQL Server Express | — |

## Estructura del proyecto

```
WPF_SP/
├── App.xaml / App.xaml.cs          # Punto de entrada de la aplicación
├── MainWindow.xaml(.cs)            # Ventana principal: mantenimientos y reporte
├── Data/
│   ├── DbConfig.cs                 # Cadena de conexión
│   ├── ITareaRepository.cs         # Contrato del repositorio de tareas
│   └── TareaRepository.cs          # Implementación ADO.NET (stored procedures)
├── Models/
│   ├── Tarea.cs                    # Modelo observable de tarea
│   └── EstadoFiltro.cs             # Filtros: Todas / Pendientes / Completadas
├── ViewModels/
│   ├── MainViewModel.cs            # ViewModel principal del módulo de tareas
│   └── TareaEditViewModel.cs       # ViewModel de creación/edición de tareas
├── Views/
│   └── TareaEditWindow.xaml(.cs)   # Diálogo de crear/editar tarea
├── Converters/                     # Conversores para bindings (visibilidad, tachado, etc.)
├── Themes/Theme.xaml               # Estilos y recursos visuales
├── NeptunoDB.sql                   # Creación de la base de datos y datos base
└── StoredProcedures.sql            # Procedimientos almacenados (Categorías, Proveedores, Productos, Pedidos, Reporte)
```

## Requisitos previos

- SDK de .NET 10 (Windows)
- SQL Server Express (o edición similar) con autenticación por Windows
- Visual Studio 2022 o superior para abrir `WPF_SP.slnx`
- SQL Server Management Studio (SSMS) para ejecutar los scripts

## Configuración

1. **Crear la base de datos**: ejecuta `WPF_SP/NeptunoDB.sql` en SSMS (crea `NeptunoDB` e inserta datos base).
2. **Crear los procedimientos almacenados**: ejecuta `WPF_SP/StoredProcedures.sql` después del script anterior.
3. **Ajustar la cadena de conexión** en `WPF_SP/Data/DbConfig.cs` según tu instancia:

   ```csharp
   Server=.\SQLEXPRESO;Database=NeptunoDB;Trusted_Connection=True;Encrypt=False;TrustServerCertificate=True;
   ```

4. Compilar y ejecutar con `dotnet run --project WPF_SP`.

> **Nota:** el módulo de tareas consume los procedimientos `dbo.usp_Tarea_*` y una tabla `Tareas`, que no están incluidos en los scripts SQL de este repositorio; deben crearse aparte.

## Uso

Inicia la aplicación y navega entre las pestañas de **Productos**, **Categorías**, **Proveedores** y **Pedidos y reporte**. Selecciona una fila del grid para cargar los datos en el formulario, guarda los cambios con **Guardar** o elimina el registro seleccionado. En **Proveedores** digita los filtros de búsqueda; en **Pedidos y reporte** selecciona el rango de fechas y presiona **Generar reporte**.