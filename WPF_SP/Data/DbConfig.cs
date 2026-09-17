namespace WPF_SP.Data;

public static class DbConfig
{
    // Instancia local: el prefijo . fuerza la conexión local (Shared Memory).
    public const string ConnectionString =
        @"Server=.\SQLEXPRESO;Database=NeptunoDB;Trusted_Connection=True;Encrypt=False;TrustServerCertificate=True;";
}
