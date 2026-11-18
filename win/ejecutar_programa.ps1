param(
    [string]$Ruta = ".\drove-runtime\programa.exe"
)

if (-not (Test-Path -Path $Ruta -PathType Leaf)) {
    Write-Error "No se encontro el ejecutable: $Ruta"
    exit 1
}

Write-Host "Ejecutando: $Ruta"
$proceso = Start-Process -FilePath $Ruta -WorkingDirectory (Split-Path -Parent $Ruta) -PassThru -Wait -NoNewWindow

if ($proceso.ExitCode -ne 0) {
    Write-Host "Finalizo con codigo de salida: $($proceso.ExitCode)"
    exit $proceso.ExitCode
}

Write-Host "Finalizado correctamente."
