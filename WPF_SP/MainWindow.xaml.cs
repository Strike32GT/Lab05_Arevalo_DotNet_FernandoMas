using System.Data;
using System.Windows;
using System.Windows.Controls;
using Microsoft.Data.SqlClient;
using WPF_SP.Data;

namespace WPF_SP;

public partial class MainWindow : Window
{
    private int? _productoId, _categoriaId, _proveedorId, _pedidoId;
    public MainWindow()
    {
        InitializeComponent(); PedidoFecha.SelectedDate = DateTime.Today;
        ReporteInicio.SelectedDate = DateTime.Today.AddMonths(-1); ReporteFin.SelectedDate = DateTime.Today;
        Loaded += async (_, _) => await CargarActualAsync();
    }

    private async Task<DataTable> ConsultaAsync(string sp, params SqlParameter[] ps)
    { await using var cn = new SqlConnection(DbConfig.ConnectionString); await using var cmd = new SqlCommand(sp, cn) { CommandType = CommandType.StoredProcedure }; cmd.Parameters.AddRange(ps); await cn.OpenAsync(); await using var rd = await cmd.ExecuteReaderAsync(); var t = new DataTable(); t.Load(rd); return t; }
    private async Task<DataTable> ConsultaSqlAsync(string sql)
    { await using var cn = new SqlConnection(DbConfig.ConnectionString); await using var cmd = new SqlCommand(sql, cn); await cn.OpenAsync(); await using var rd = await cmd.ExecuteReaderAsync(); var t = new DataTable(); t.Load(rd); return t; }
    private async Task<DataTable> ConsultaReporteAsync(DateTime inicio, DateTime fin)
    {
        return await ConsultaAsync("usp_Reporte_DetallePedidosPorFechas", P("@FechaInicio", inicio.Date), P("@FechaFin", fin.Date));
    }
    private async Task EjecutarAsync(string sp, params SqlParameter[] ps)
    { await using var cn = new SqlConnection(DbConfig.ConnectionString); await using var cmd = new SqlCommand(sp, cn) { CommandType = CommandType.StoredProcedure }; cmd.Parameters.AddRange(ps); await cn.OpenAsync(); await cmd.ExecuteNonQueryAsync(); }
    private static SqlParameter P(string n, object? v) => new(n, v ?? DBNull.Value);
    private static decimal? Dec(string s) => decimal.TryParse(s, out var n) ? n : null;
    private static int? Id(ComboBox combo) => combo.SelectedValue is int id ? id : null;
    private static string? Texto(DataRowView r, string columna) => r[columna] is DBNull ? null : r[columna].ToString();
    private void Error(Exception e) => Estado.Text = e.Message;

    private async Task CargarActualAsync()
    {
        try
        {
            Estado.Text = "";
            switch (Tabs.SelectedIndex)
            {
                case 0: await CargarCatalogosProductoAsync(); ProductosGrid.ItemsSource = (await ConsultaAsync("usp_Producto_Listar")).DefaultView; break;
                case 1: CategoriasGrid.ItemsSource = (await ConsultaAsync("usp_Categoria_Listar")).DefaultView; break;
                case 2: await CargarProveedoresAsync(); break;
                case 3: await CargarCatalogosPedidoAsync(); PedidosGrid.ItemsSource = (await ConsultaAsync("usp_Pedido_Listar")).DefaultView; break;
            }
        }
        catch (Exception e) { Error(e); }
    }
    private async Task CargarCatalogosProductoAsync()
    { ProductoProveedor.ItemsSource = (await ConsultaAsync("usp_Proveedor_Listar")).DefaultView; ProductoCategoria.ItemsSource = (await ConsultaAsync("usp_Categoria_Listar")).DefaultView; }
    private async Task CargarCatalogosPedidoAsync()
    {
        PedidoCliente.ItemsSource = (await ConsultaSqlAsync("SELECT ClienteID, Empresa FROM dbo.Clientes ORDER BY Empresa")).DefaultView;
        PedidoEmpleado.ItemsSource = (await ConsultaSqlAsync("SELECT EmpleadoID, CONCAT(Nombre, N' ', Apellidos) AS NombreCompleto FROM dbo.Empleados ORDER BY Nombre, Apellidos")).DefaultView;
        PedidoTransportista.ItemsSource = (await ConsultaSqlAsync("SELECT TransportistaID, CompaniaNombre FROM dbo.Transportistas ORDER BY CompaniaNombre")).DefaultView;
    }
    private async Task CargarProveedoresAsync()
    { ProveedoresGrid.ItemsSource = (await ConsultaAsync("usp_Proveedor_Buscar", P("@NombreContacto", FiltroContacto.Text), P("@Ciudad", FiltroCiudad.Text))).DefaultView; }
    private async void Actualizar_Click(object s, RoutedEventArgs e) => await CargarActualAsync();
    private async void Tabs_SelectionChanged(object s, SelectionChangedEventArgs e) { if (e.Source == Tabs) await CargarActualAsync(); }

    private async void GuardarProducto_Click(object s, RoutedEventArgs e)
    {
        if (string.IsNullOrWhiteSpace(ProductoNombre.Text) || Dec(ProductoPrecio.Text) is null) { Estado.Text = "Nombre y precio válido son obligatorios."; return; }
        try { await EjecutarAsync(_productoId is null ? "usp_Producto_Insertar" : "usp_Producto_Actualizar", P("@ProductoID", _productoId), P("@NombreProducto", ProductoNombre.Text), P("@ProveedorID", Id(ProductoProveedor)), P("@CategoriaID", Id(ProductoCategoria)), P("@CantidadPorUnidad", ProductoCantidad.Text), P("@PrecioUnidad", Dec(ProductoPrecio.Text))); _productoId = null; await CargarActualAsync(); } catch (Exception x) { Error(x); }
    }
    private async void EliminarProducto_Click(object s, RoutedEventArgs e) => await EliminarAsync(_productoId, "usp_Producto_Eliminar", () => _productoId = null);
    private void ProductoSeleccionado(object s, SelectionChangedEventArgs e)
    { if (ProductosGrid.SelectedItem is not DataRowView r) return; _productoId = (int)r["ProductoID"]; ProductoNombre.Text = Texto(r, "NombreProducto"); ProductoProveedor.SelectedValue = r["ProveedorID"] is DBNull ? null : r["ProveedorID"]; ProductoCategoria.SelectedValue = r["CategoriaID"] is DBNull ? null : r["CategoriaID"]; ProductoCantidad.Text = Texto(r, "CantidadPorUnidad"); ProductoPrecio.Text = Texto(r, "PrecioUnidad"); }

    private async void GuardarCategoria_Click(object s, RoutedEventArgs e)
    { if (string.IsNullOrWhiteSpace(CategoriaNombre.Text)) { Estado.Text = "El nombre es obligatorio."; return; } try { await EjecutarAsync(_categoriaId is null ? "usp_Categoria_Insertar" : "usp_Categoria_Actualizar", P("@CategoriaID", _categoriaId), P("@NombreCategoria", CategoriaNombre.Text), P("@Descripcion", CategoriaDescripcion.Text)); _categoriaId = null; await CargarActualAsync(); } catch (Exception x) { Error(x); } }
    private async void EliminarCategoria_Click(object s, RoutedEventArgs e) => await EliminarAsync(_categoriaId, "usp_Categoria_Eliminar", () => _categoriaId = null);
    private void CategoriaSeleccionada(object s, SelectionChangedEventArgs e) { if (CategoriasGrid.SelectedItem is not DataRowView r) return; _categoriaId = (int)r["CategoriaID"]; CategoriaNombre.Text = Texto(r, "NombreCategoria"); CategoriaDescripcion.Text = Texto(r, "Descripcion"); }

    private async void GuardarProveedor_Click(object s, RoutedEventArgs e)
    {
        if (string.IsNullOrWhiteSpace(ProveedorCompania.Text)) { Estado.Text = "La compañía es obligatoria."; return; }
        try { await EjecutarAsync(_proveedorId is null ? "usp_Proveedor_Insertar" : "usp_Proveedor_Actualizar", P("@ProveedorID", _proveedorId), P("@CompaniaNombre", ProveedorCompania.Text), P("@NombreContacto", ProveedorContacto.Text), P("@Ciudad", ProveedorCiudad.Text), P("@CargoContacto", ProveedorCargo.Text), P("@Direccion", ProveedorDireccion.Text), P("@CodigoPostal", ProveedorCodigoPostal.Text), P("@Pais", ProveedorPais.Text), P("@Telefono", ProveedorTelefono.Text), P("@Fax", ProveedorFax.Text)); _proveedorId = null; await CargarActualAsync(); } catch (Exception x) { Error(x); }
    }
    private async void EliminarProveedor_Click(object s, RoutedEventArgs e) => await EliminarAsync(_proveedorId, "usp_Proveedor_Eliminar", () => _proveedorId = null);
    private void ProveedorSeleccionado(object s, SelectionChangedEventArgs e)
    { if (ProveedoresGrid.SelectedItem is not DataRowView r) return; _proveedorId = (int)r["ProveedorID"]; ProveedorCompania.Text = Texto(r, "CompaniaNombre"); ProveedorContacto.Text = Texto(r, "NombreContacto"); ProveedorCargo.Text = Texto(r, "CargoContacto"); ProveedorDireccion.Text = Texto(r, "Direccion"); ProveedorCiudad.Text = Texto(r, "Ciudad"); ProveedorCodigoPostal.Text = Texto(r, "CodigoPostal"); ProveedorPais.Text = Texto(r, "Pais"); ProveedorTelefono.Text = Texto(r, "Telefono"); ProveedorFax.Text = Texto(r, "Fax"); }
    private async void BuscarProveedor_TextChanged(object s, TextChangedEventArgs e) { if (IsLoaded && Tabs.SelectedIndex == 2) try { await CargarProveedoresAsync(); } catch (Exception x) { Error(x); } }

    private async void GuardarPedido_Click(object s, RoutedEventArgs e)
    {
        if (PedidoFecha.SelectedDate is null) { Estado.Text = "La fecha es obligatoria."; return; }
        try { await EjecutarAsync(_pedidoId is null ? "usp_Pedido_Insertar" : "usp_Pedido_Actualizar", P("@PedidoID", _pedidoId), P("@ClienteID", Id(PedidoCliente)), P("@EmpleadoID", Id(PedidoEmpleado)), P("@FechaPedido", PedidoFecha.SelectedDate), P("@TransportistaID", Id(PedidoTransportista)), P("@Destinatario", PedidoDestinatario.Text), P("@CiudadDestino", PedidoCiudadDestino.Text), P("@PaisDestino", PedidoPaisDestino.Text)); _pedidoId = null; await CargarActualAsync(); } catch (Exception x) { Error(x); }
    }
    private async void EliminarPedido_Click(object s, RoutedEventArgs e) => await EliminarAsync(_pedidoId, "usp_Pedido_Eliminar", () => _pedidoId = null);
    private void PedidoSeleccionado(object s, SelectionChangedEventArgs e)
    { if (PedidosGrid.SelectedItem is not DataRowView r) return; _pedidoId = (int)r["PedidoID"]; PedidoCliente.SelectedValue = r["ClienteID"] is DBNull ? null : r["ClienteID"]; PedidoEmpleado.SelectedValue = r["EmpleadoID"] is DBNull ? null : r["EmpleadoID"]; PedidoTransportista.SelectedValue = r["TransportistaID"] is DBNull ? null : r["TransportistaID"]; PedidoFecha.SelectedDate = (DateTime)r["FechaPedido"]; PedidoDestinatario.Text = Texto(r, "Destinatario"); PedidoCiudadDestino.Text = Texto(r, "CiudadDestino"); PedidoPaisDestino.Text = Texto(r, "PaisDestino"); }
    private async void Reporte_Click(object s, RoutedEventArgs e) { if (ReporteInicio.SelectedDate is null || ReporteFin.SelectedDate is null) { Estado.Text = "Seleccione ambas fechas."; return; } if (ReporteInicio.SelectedDate > ReporteFin.SelectedDate) { Estado.Text = "La fecha inicial no puede ser posterior a la fecha final."; return; } try { Estado.Text = ""; PedidosGrid.ItemsSource = (await ConsultaReporteAsync(ReporteInicio.SelectedDate.Value, ReporteFin.SelectedDate.Value)).DefaultView; } catch (Exception x) { Error(x); } }
    private async Task EliminarAsync(int? id, string sp, Action limpiar) { if (id is null) { Estado.Text = "Seleccione un registro."; return; } if (MessageBox.Show("¿Eliminar el registro seleccionado?", "Confirmación", MessageBoxButton.YesNo, MessageBoxImage.Warning) != MessageBoxResult.Yes) return; var field = sp.Contains("Producto") ? "ProductoID" : sp.Contains("Categoria") ? "CategoriaID" : sp.Contains("Proveedor") ? "ProveedorID" : "PedidoID"; try { await EjecutarAsync(sp, P("@" + field, id)); limpiar(); await CargarActualAsync(); } catch (Exception x) { Error(x); } }
}
