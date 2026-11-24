# Lanza OpenCode con un tablero visible (progreso, archivos, acciones y teclas) para que JFR siga el trabajo.
# Deja el log (UTF-8) en <Log> y, al terminar, <Log>.fin con el código de salida (Claude espera ese archivo).
# Uso: powershell -File delegar.ps1 -Dir <carpeta> -Plan <plan.md> [-Modelo <id>] [-Vision] [-Ligero] [-Extra "..."] [-Log <ruta>] [-Titulo "..."]
# Sin -Modelo elige segun el perfil (-Vision multimodal nativo, -Ligero flash economico, o estandar de codigo).
# Comprobar la eleccion sin lanzar nada: -SoloModelo
param(
    [Parameter(Mandatory)] [string]$Dir,
    [Parameter(Mandatory)] [string]$Plan,
    [string]$Modelo = "",
    [string]$Extra = "",
    [string]$Log = (Join-Path $env:TEMP ("opencode_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".log")),
    [string]$Titulo = "",
    [switch]$SoloModelo,
    [switch]$Vision,
    [switch]$Ligero,
    [string]$Excluir = ""   # regex de modelos a saltar; tras un LIMITE de Go usar '^opencode-go/(?!.*free)' para pasar a los gratis
)
$ErrorActionPreference = "Stop"
if (-not (Test-Path $Plan)) { throw "No existe el plan: $Plan" }
Remove-Item "$Log.fin" -ErrorAction SilentlyContinue
if (-not $Titulo) { $Titulo = [IO.Path]::GetFileNameWithoutExtension($Plan) }

$requiereVision = [bool]$Vision -or ($Plan -match 'qa-visual|vision')

# Orden de preferencia (regex sobre `opencode models`). Editar aqui cuando cambie el roster.
# Modelos con vision nativa reales (evita delegar capturas desde modelos solo-texto como glm-5.3).
$PreferenciaVision = @(
    '^opencode-go/kimi-k3\.1-pro$', '^opencode-go/glm-5\.3-flash$', '^opencode-go/deepseek-v4\.1-flash$',
    '^opencode-go/kimi-k3$', '^opencode-go/gemini-4-argon$',
    '^opencode/deepseek-v4\.1-flash-free$', '^opencode/nemotron-3\.5-super-vl-free$'
)
# Modelos flash rapidos para tareas mecanicas simples sin quemar tope mensual.
$PreferenciaLigero = @(
    '^opencode-go/glm-5\.3-flash$', '^opencode-go/deepseek-v4\.1-flash$', '^opencode-go/gpt-6-luna$', '^opencode-go/qwen3\.8-flash$'
)
$PreferenciaCodigo = @(
    '^opencode-go/glm-5\.3$', '^opencode-go/kimi-k3\.1-pro$', '^opencode-go/glm-', '^opencode-go/kimi-',
    '^opencode-go/deepseek-', '^opencode-go/qwen4-', '^opencode-go/qwen', '^opencode-go/minimax-',
    '^opencode-go/(hy4-flash|longcat-2\.5)-free$',
    '^opencode/glm-.*-free$', '^opencode/deepseek-.*-free$', '^opencode/minimax-.*-free$', '^opencode/longcat-.*-free$'
)
$Preferencia = if ($requiereVision) {
    $PreferenciaVision + $PreferenciaCodigo
} elseif ($Ligero) {
    $PreferenciaLigero + $PreferenciaCodigo
} else {
    $PreferenciaCodigo
}

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

$notaVision = if ($requiereVision) { "Este modelo tiene vision nativa: analiza las capturas directamente sin delegarlas." } else { "" }
$prompt = "Usa la skill executing-plans para ejecutar el plan $Plan. Sigue la skill ponytail: solo el codigo necesario. No hagas commits. $notaVision $Extra Al terminar ejecuta las pruebas del plan y responde con: archivos cambiados, resultado de las pruebas y cualquier punto que no pudiste completar."
$utf8 = New-Object Text.UTF8Encoding $false
[IO.File]::WriteAllText("$Log.prompt.txt", $prompt, $utf8)
$cfg = @{ Dir = $Dir; Plan = $Plan; Modelo = $Modelo; Log = $Log; Titulo = $Titulo } | ConvertTo-Json -Compress
[IO.File]::WriteAllText("$Log.cfg.json", $cfg, $utf8)

$monitor = Join-Path $PSScriptRoot "monitor.ps1"
Start-Process powershell.exe -ArgumentList "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$monitor`"", "-Cfg", "`"$Log.cfg.json`""
Write-Output "Tablero abierto. Log: $Log  | Fin: $Log.fin"
