/* Ejecutar este archivo DESPUÉS de NeptunoDB.sql, en SQL Server Management Studio. */
USE NeptunoDB;
GO

-- ============================================================
-- CATEGORÍAS
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.usp_Categoria_Listar
AS
    SELECT CategoriaID, NombreCategoria, Descripcion, Activo
    FROM dbo.Categorias
    WHERE Activo = 1
    ORDER BY CategoriaID;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Categoria_Obtener
    @CategoriaID INT
AS
    SELECT CategoriaID, NombreCategoria, Descripcion, Activo
    FROM dbo.Categorias
    WHERE CategoriaID = @CategoriaID AND Activo = 1;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Categoria_Insertar
    @CategoriaID INT = NULL,
    @NombreCategoria NVARCHAR(30),
    @Descripcion NVARCHAR(200) = NULL
AS
    INSERT INTO dbo.Categorias (NombreCategoria, Descripcion, Activo)
    VALUES (@NombreCategoria, @Descripcion, 1);
GO

CREATE OR ALTER PROCEDURE dbo.usp_Categoria_Actualizar
    @CategoriaID INT,
    @NombreCategoria NVARCHAR(30),
    @Descripcion NVARCHAR(200) = NULL
AS
    UPDATE dbo.Categorias
    SET NombreCategoria = @NombreCategoria,
        Descripcion = @Descripcion
    WHERE CategoriaID = @CategoriaID;
GO

-- Eliminación Lógica
CREATE OR ALTER PROCEDURE dbo.usp_Categoria_Eliminar
    @CategoriaID INT
AS
    UPDATE dbo.Categorias
    SET Activo = 0
    WHERE CategoriaID = @CategoriaID;
GO

-- ============================================================
-- PROVEEDORES
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.usp_Proveedor_Listar
AS
    SELECT ProveedorID, CompaniaNombre, NombreContacto, CargoContacto, Direccion, Ciudad, CodigoPostal, Pais, Telefono, Fax, Activo
    FROM dbo.Proveedores
    WHERE Activo = 1
    ORDER BY ProveedorID;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Proveedor_Obtener
    @ProveedorID INT
AS
    SELECT ProveedorID, CompaniaNombre, NombreContacto, CargoContacto, Direccion, Ciudad, CodigoPostal, Pais, Telefono, Fax, Activo
    FROM dbo.Proveedores
    WHERE ProveedorID = @ProveedorID AND Activo = 1;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Proveedor_Buscar
    @NombreContacto NVARCHAR(40) = NULL,
    @Ciudad NVARCHAR(30) = NULL
AS
    SELECT ProveedorID, CompaniaNombre, NombreContacto, CargoContacto, Direccion, Ciudad, CodigoPostal, Pais, Telefono, Fax, Activo
    FROM dbo.Proveedores
    WHERE Activo = 1
      AND (NULLIF(@NombreContacto, N'') IS NULL OR NombreContacto LIKE N'%' + @NombreContacto + N'%')
      AND (NULLIF(@Ciudad, N'') IS NULL OR Ciudad LIKE N'%' + @Ciudad + N'%')
    ORDER BY CompaniaNombre;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Proveedor_Insertar
    @ProveedorID INT = NULL,
    @CompaniaNombre NVARCHAR(60),
    @NombreContacto NVARCHAR(40) = NULL,
    @Ciudad NVARCHAR(30) = NULL,
    @CargoContacto NVARCHAR(40) = NULL,
    @Direccion NVARCHAR(80) = NULL,
    @CodigoPostal NVARCHAR(10) = NULL,
    @Pais NVARCHAR(30) = NULL,
    @Telefono NVARCHAR(24) = NULL,
    @Fax NVARCHAR(24) = NULL
AS
    INSERT INTO dbo.Proveedores (CompaniaNombre, NombreContacto, Ciudad, CargoContacto, Direccion, CodigoPostal, Pais, Telefono, Fax, Activo)
    VALUES (@CompaniaNombre, @NombreContacto, @Ciudad, @CargoContacto, @Direccion, @CodigoPostal, @Pais, @Telefono, @Fax, 1);
GO

CREATE OR ALTER PROCEDURE dbo.usp_Proveedor_Actualizar
    @ProveedorID INT,
    @CompaniaNombre NVARCHAR(60),
    @NombreContacto NVARCHAR(40) = NULL,
    @Ciudad NVARCHAR(30) = NULL,
    @CargoContacto NVARCHAR(40) = NULL,
    @Direccion NVARCHAR(80) = NULL,
    @CodigoPostal NVARCHAR(10) = NULL,
    @Pais NVARCHAR(30) = NULL,
    @Telefono NVARCHAR(24) = NULL,
    @Fax NVARCHAR(24) = NULL
AS
    UPDATE dbo.Proveedores
    SET CompaniaNombre = @CompaniaNombre,
        NombreContacto = @NombreContacto,
        Ciudad = @Ciudad,
        CargoContacto = @CargoContacto,
        Direccion = @Direccion,
        CodigoPostal = @CodigoPostal,
        Pais = @Pais,
        Telefono = @Telefono,
        Fax = @Fax
    WHERE ProveedorID = @ProveedorID;
GO

-- Eliminación Lógica
CREATE OR ALTER PROCEDURE dbo.usp_Proveedor_Eliminar
    @ProveedorID INT
AS
    UPDATE dbo.Proveedores
    SET Activo = 0
    WHERE ProveedorID = @ProveedorID;
GO

-- ============================================================
-- PRODUCTOS
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.usp_Producto_Listar
AS
    SELECT ProductoID, NombreProducto, ProveedorID, CategoriaID, CantidadPorUnidad, PrecioUnidad, UnidadesEnExistencia, UnidadesEnPedido, NivelDeReorden, Descontinuado, Activo
    FROM dbo.Productos
    WHERE Activo = 1
    ORDER BY ProductoID;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Producto_Obtener
    @ProductoID INT
AS
    SELECT ProductoID, NombreProducto, ProveedorID, CategoriaID, CantidadPorUnidad, PrecioUnidad, UnidadesEnExistencia, UnidadesEnPedido, NivelDeReorden, Descontinuado, Activo
    FROM dbo.Productos
    WHERE ProductoID = @ProductoID AND Activo = 1;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Producto_Insertar
    @ProductoID INT = NULL,
    @NombreProducto NVARCHAR(60),
    @ProveedorID INT = NULL,
    @CategoriaID INT = NULL,
    @CantidadPorUnidad NVARCHAR(30) = NULL,
    @PrecioUnidad DECIMAL(10,2),
    @UnidadesEnExistencia SMALLINT = 0,
    @UnidadesEnPedido SMALLINT = 0,
    @NivelDeReorden SMALLINT = 0,
    @Descontinuado BIT = 0
AS
    INSERT INTO dbo.Productos (NombreProducto, ProveedorID, CategoriaID, CantidadPorUnidad, PrecioUnidad, UnidadesEnExistencia, UnidadesEnPedido, NivelDeReorden, Descontinuado, Activo)
    VALUES (@NombreProducto, @ProveedorID, @CategoriaID, @CantidadPorUnidad, @PrecioUnidad, @UnidadesEnExistencia, @UnidadesEnPedido, @NivelDeReorden, @Descontinuado, 1);
GO

CREATE OR ALTER PROCEDURE dbo.usp_Producto_Actualizar
    @ProductoID INT,
    @NombreProducto NVARCHAR(60),
    @ProveedorID INT = NULL,
    @CategoriaID INT = NULL,
    @CantidadPorUnidad NVARCHAR(30) = NULL,
    @PrecioUnidad DECIMAL(10,2),
    @UnidadesEnExistencia SMALLINT = 0,
    @UnidadesEnPedido SMALLINT = 0,
    @NivelDeReorden SMALLINT = 0,
    @Descontinuado BIT = 0
AS
    UPDATE dbo.Productos
    SET NombreProducto = @NombreProducto,
        ProveedorID = @ProveedorID,
        CategoriaID = @CategoriaID,
        CantidadPorUnidad = @CantidadPorUnidad,
        PrecioUnidad = @PrecioUnidad,
        UnidadesEnExistencia = @UnidadesEnExistencia,
        UnidadesEnPedido = @UnidadesEnPedido,
        NivelDeReorden = @NivelDeReorden,
        Descontinuado = @Descontinuado
    WHERE ProductoID = @ProductoID;
GO

-- Eliminación Lógica
CREATE OR ALTER PROCEDURE dbo.usp_Producto_Eliminar
    @ProductoID INT
AS
    UPDATE dbo.Productos
    SET Activo = 0
    WHERE ProductoID = @ProductoID;
GO

-- ============================================================
-- PEDIDOS
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.usp_Pedido_Listar
AS
    SELECT PedidoID, ClienteID, EmpleadoID, FechaPedido, FechaRequerida, FechaEnvio, TransportistaID, Destinatario, CiudadDestino, PaisDestino, Activo
    FROM dbo.Pedidos
    WHERE Activo = 1
    ORDER BY PedidoID DESC;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Pedido_Obtener
    @PedidoID INT
AS
    SELECT PedidoID, ClienteID, EmpleadoID, FechaPedido, FechaRequerida, FechaEnvio, TransportistaID, Destinatario, CiudadDestino, PaisDestino, Activo
    FROM dbo.Pedidos
    WHERE PedidoID = @PedidoID AND Activo = 1;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Pedido_Insertar
    @PedidoID INT = NULL,
    @ClienteID INT = NULL,
    @EmpleadoID INT = NULL,
    @FechaPedido DATE,
    @Destinatario NVARCHAR(60) = NULL,
    @FechaRequerida DATE = NULL,
    @FechaEnvio DATE = NULL,
    @TransportistaID INT = NULL,
    @CiudadDestino NVARCHAR(30) = NULL,
    @PaisDestino NVARCHAR(30) = NULL
AS
    INSERT INTO dbo.Pedidos (ClienteID, EmpleadoID, FechaPedido, Destinatario, FechaRequerida, FechaEnvio, TransportistaID, CiudadDestino, PaisDestino, Activo)
    VALUES (@ClienteID, @EmpleadoID, @FechaPedido, @Destinatario, @FechaRequerida, @FechaEnvio, @TransportistaID, @CiudadDestino, @PaisDestino, 1);
GO

CREATE OR ALTER PROCEDURE dbo.usp_Pedido_Actualizar
    @PedidoID INT,
    @ClienteID INT = NULL,
    @EmpleadoID INT = NULL,
    @FechaPedido DATE,
    @Destinatario NVARCHAR(60) = NULL,
    @FechaRequerida DATE = NULL,
    @FechaEnvio DATE = NULL,
    @TransportistaID INT = NULL,
    @CiudadDestino NVARCHAR(30) = NULL,
    @PaisDestino NVARCHAR(30) = NULL
AS
    UPDATE dbo.Pedidos
    SET ClienteID = @ClienteID,
        EmpleadoID = @EmpleadoID,
        FechaPedido = @FechaPedido,
        Destinatario = @Destinatario,
        FechaRequerida = @FechaRequerida,
        FechaEnvio = @FechaEnvio,
        TransportistaID = @TransportistaID,
        CiudadDestino = @CiudadDestino,
        PaisDestino = @PaisDestino
    WHERE PedidoID = @PedidoID;
GO

-- Eliminación Lógica
CREATE OR ALTER PROCEDURE dbo.usp_Pedido_Eliminar
    @PedidoID INT
AS
    UPDATE dbo.Pedidos
    SET Activo = 0
    WHERE PedidoID = @PedidoID;
GO

-- ============================================================
-- REPORTES (Excluir pedidos con Activo = 0)
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.usp_Reporte_DetallePedidosPorFechas
    @FechaInicio DATE,
    @FechaFin DATE
AS
    SELECT p.PedidoID,
           p.FechaPedido,
           p.Destinatario,
           dp.ProductoID,
           pr.NombreProducto,
           dp.PrecioUnidad,
           dp.Cantidad,
           dp.Descuento,
           CAST(dp.PrecioUnidad * dp.Cantidad * (1 - dp.Descuento) AS DECIMAL(12,2)) AS Importe
    FROM dbo.DetallePedidos dp
    INNER JOIN dbo.Pedidos p ON p.PedidoID = dp.PedidoID
    INNER JOIN dbo.Productos pr ON pr.ProductoID = dp.ProductoID
    WHERE p.Activo = 1
      AND p.FechaPedido BETWEEN @FechaInicio AND @FechaFin
    ORDER BY p.FechaPedido, p.PedidoID;
GO
