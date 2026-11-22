# Prende o apaga una skill moviendola entre su carpeta activa y la apagada (no borra nada).
# Uso: .\skills_toggle.ps1 -Nombre differential-review -Accion on [-Agente claude|opencode|agy|agents]
# Luego abrir una sesion nueva del agente (las skills se leen al arrancar).
param(
    [Parameter(Mandatory)] [string]$Nombre,
    [Parameter(Mandatory)] [ValidateSet('on', 'off')] [string]$Accion,
    [ValidateSet('claude', 'opencode', 'agy', 'agents')] [string]$Agente = 'claude'
)
$ErrorActionPreference = 'Stop'
$base = switch ($Agente) {
    'claude'   { "$HOME\.claude" }
    'opencode' { "$HOME\.config\opencode" }
    'agy'      { "$HOME\.gemini\antigravity-cli" }
    'agents'   { "$HOME\.agents" }
}
$activa = Join-Path $base 'skills'
$apagadas = @((Join-Path $base 'skills-apagadas'), (Join-Path $base 'skills-bajo-demanda')) | Where-Object { Test-Path $_ }

if ($Accion -eq 'on') {
    $origen = $apagadas | ForEach-Object { Join-Path $_ $Nombre } | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $origen) { throw "No encuentro '$Nombre' en $($apagadas -join ', ')" }
    if (Test-Path (Join-Path $activa $Nombre)) { throw "'$Nombre' ya esta activa en $activa" }
    Move-Item $origen (Join-Path $activa $Nombre)
    Write-Output "ON: $Nombre ($Agente). Abre una sesion nueva para que la cargue."
} else {
    $origen = Join-Path $activa $Nombre
    if (-not (Test-Path $origen)) { throw "'$Nombre' no esta activa en $activa" }
    $destino = if (Test-Path (Join-Path $base 'skills-bajo-demanda')) { Join-Path $base 'skills-bajo-demanda' } else { Join-Path $base 'skills-apagadas' }
    New-Item -ItemType Directory -Force $destino | Out-Null
    Move-Item $origen (Join-Path $destino $Nombre)
    Write-Output "OFF: $Nombre ($Agente) -> $destino"
}
