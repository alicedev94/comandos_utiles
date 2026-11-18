Get-CimInstance Win32_Process | Where-Object 
{ 
$_.CommandLine -like "*drove-runtime*" -or $_.ExecutablePath -like "*drove-runtime*" } |
 ForEach-Object { 
    Write-Host "Cerrando: $($_.Name) (PID: $($_.ProcessId))"; Stop-Process -Id $_.ProcessId -Force 
}
