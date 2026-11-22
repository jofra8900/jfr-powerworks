# Lanza OpenCode con un tablero visible (progreso, archivos, acciones y teclas) para que JFR siga el trabajo.
# Deja el log (UTF-8) en <Log> y, al terminar, <Log>.fin con el código de salida (Claude espera ese archivo).
# Uso: powershell -File delegar.ps1 -Dir <carpeta> -Plan <plan.md> [-Modelo <id>] [-Extra "..."] [-Log <ruta>] [-Titulo "..."]
# Sin -Modelo elige el primero disponible de $Preferencia (OpenCode Go de pago primero, luego gratis que no entrenan).
# Comprobar la eleccion sin lanzar nada: -SoloModelo
param(
    [Parameter(Mandatory)] [string]$Dir,
    [Parameter(Mandatory)] [string]$Plan,
    [string]$Modelo = "",
    [string]$Extra = "",
    [string]$Log = (Join-Path $env:TEMP ("opencode_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".log")),
    [string]$Titulo = "",
    [switch]$SoloModelo,
    [string]$Excluir = ""   # regex de modelos a saltar; tras un LIMITE de Go usar '^opencode-go/(?!.*free)' para pasar a los gratis
)
$ErrorActionPreference = "Stop"
if (-not (Test-Path $Plan)) { throw "No existe el plan: $Plan" }
Remove-Item "$Log.fin" -ErrorAction SilentlyContinue
if (-not $Titulo) { $Titulo = [IO.Path]::GetFileNameWithoutExtension($Plan) }

# Orden de preferencia (regex sobre `opencode models`). Editar aqui cuando cambie el roster.
$Preferencia = @(
    '^opencode-go/glm-', '^opencode-go/kimi-', '^opencode-go/deepseek-', '^opencode-go/qwen', '^opencode-go/minimax-',
    '^opencode-go/(hy4-flash|longcat-2\.5)-free$',
    '^opencode/glm-.*-free$', '^opencode/deepseek-.*-free$', '^opencode/minimax-.*-free$', '^opencode/longcat-.*-free$'
)
if (-not $Modelo) {
    $disponibles = @(& opencode models 2>$null | ForEach-Object { "$_".Trim() })
    if ($Excluir) { $disponibles = @($disponibles | Where-Object { $_ -notmatch $Excluir }) }
    foreach ($p in $Preferencia) {
        $Modelo = $disponibles | Where-Object { $_ -match $p } | Select-Object -First 1
        if ($Modelo) { break }
    }
    if (-not $Modelo) { throw "Ningun modelo de la lista de preferencia esta disponible. Revisa 'opencode models' o delega a agy." }
}
Write-Output "Modelo: $Modelo"
if ($SoloModelo) { return }

$prompt = "Usa la skill executing-plans para ejecutar el plan $Plan. Sigue la skill ponytail: solo el codigo necesario. No hagas commits. $Extra Al terminar ejecuta las pruebas del plan y responde con: archivos cambiados, resultado de las pruebas y cualquier punto que no pudiste completar."
$utf8 = New-Object Text.UTF8Encoding $false
[IO.File]::WriteAllText("$Log.prompt.txt", $prompt, $utf8)
$cfg = @{ Dir = $Dir; Plan = $Plan; Modelo = $Modelo; Log = $Log; Titulo = $Titulo } | ConvertTo-Json -Compress
[IO.File]::WriteAllText("$Log.cfg.json", $cfg, $utf8)

$monitor = Join-Path $PSScriptRoot "monitor.ps1"
Start-Process powershell.exe -ArgumentList "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$monitor`"", "-Cfg", "`"$Log.cfg.json`""
Write-Output "Tablero abierto. Log: $Log  | Fin: $Log.fin"
