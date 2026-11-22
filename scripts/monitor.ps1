# Tablero de OpenCode: corre "opencode run" en segundo plano y muestra el avance en vivo.
# Teclas: L = ver log completo · C = abrir la carpeta en VS Code · D = detener OpenCode · Q = cerrar el tablero (solo al final)
param([Parameter(Mandatory)] [string]$Cfg)

$ErrorActionPreference = "Continue"
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$OutputEncoding = [Text.Encoding]::UTF8
$c = Get-Content $Cfg -Raw -Encoding UTF8 | ConvertFrom-Json
$Host.UI.RawUI.WindowTitle = "OpenCode - $($c.Titulo)"
try { $Host.UI.RawUI.CursorSize = 0 } catch {}

# --- Arranque de OpenCode (sin TTY: salida limpia a archivo UTF-8) ---
$exe = Join-Path $env:APPDATA "npm\node_modules\@opencode\cli\bin\opencode.exe"
if (-not (Test-Path $exe)) { $exe = (Get-Command opencode.exe -ErrorAction SilentlyContinue).Source }
if (-not $exe) { Write-Host "No encuentro opencode.exe" -ForegroundColor Red; Read-Host "Enter para cerrar"; exit 1 }
$prompt = [IO.File]::ReadAllText("$($c.Log).prompt.txt") -replace '"', '\"'
$vacio = "$($c.Log).stdin"; [IO.File]::WriteAllText($vacio, "")
Remove-Item $c.Log, "$($c.Log).err" -ErrorAction SilentlyContinue
$proc = Start-Process -FilePath $exe -ArgumentList "run", "-m", $c.Modelo, "`"$prompt`"" -WorkingDirectory $c.Dir `
    -RedirectStandardOutput $c.Log -RedirectStandardError "$($c.Log).err" -RedirectStandardInput $vacio `
    -WindowStyle Hidden -PassThru
$null = $proc.Handle  # sin esto PowerShell 5.1 pierde el ExitCode del proceso
$baseHead = (git -C $c.Dir rev-parse HEAD 2>$null)  # para contar también lo que OpenCode ya commiteó

# --- Qué archivos nombra el plan (para medir avance) ---
$planTxt = Get-Content $c.Plan -Raw -Encoding UTF8
$archivosPlan = @([regex]::Matches($planTxt, '(?<![\w/])((?:src|supabase|docs|api|scripts|tests?)/[\w\-./]+\.(?:tsx?|jsx?|css|md|sql|json))') |
    ForEach-Object { $_.Groups[1].Value } | Where-Object { $_ -notmatch '^docs/plans/' -and $_ -notmatch '^supabase/' } | Sort-Object -Unique)

$inicio = Get-Date
$ansi = [regex]'\x1b\[[0-9;?]*[A-Za-z]'
$acciones = 'Read|Edit|Write|Bash|Grep|Glob|List|Patch|Skill|Todo\w*|WebFetch|Task'
$ultimoTam = -1; $ultimoCambio = Get-Date; $git = @(); $gitCuando = [datetime]::MinValue
$spin = '|/-\'; $i = 0

function Barra([double]$p, [int]$ancho = 40) {
    $n = [math]::Round([math]::Max(0, [math]::Min(1, $p)) * $ancho)
    return ('█' * $n) + ('░' * ($ancho - $n))
}
function Linea([string]$t, [string]$color = 'Gray') {
    $w = [math]::Max(40, $Host.UI.RawUI.WindowSize.Width - 1)
    if ($t.Length -gt $w) { $t = $t.Substring(0, $w - 1) + '…' }
    Write-Host $t.PadRight($w) -ForegroundColor $color
}

while ($true) {
    $vivo = -not $proc.HasExited
    $lineas = @()
    if (Test-Path $c.Log) {
        $tam = (Get-Item $c.Log).Length
        if ($tam -ne $ultimoTam) { $ultimoTam = $tam; $ultimoCambio = Get-Date }
        # OpenCode escribe el texto del modelo en stdout y las acciones (→ Read, → Edit…) en stderr: se leen ambos.
        $lineas = @(Get-Content $c.Log, "$($c.Log).err" -Encoding UTF8 -ErrorAction SilentlyContinue | ForEach-Object { $ansi.Replace($_, '').Trim() } | Where-Object { $_ })
    }
    # Límite de uso (OpenCode Go: tope por 5 h / semana / mes; gratis: tope diario). `opencode run` sale con código 0 aunque
    # el modelo se haya cortado, así que se busca el error en el log y se avisa a Claude con "LIMITE:" en el .fin.
    $limite = ''
    $hit = $lineas | Where-Object { $_ -match '(?i)^\W*error\b' -and $_ -match '(?i)(usage|rate|monthly|weekly|5.?hour)\s*limit|limit (reached|exceeded)|quota|too many requests|\b429\b|insufficient (balance|credit)|subscribe to opencode go|reached your' } | Select-Object -Last 1
    if ($hit) {
        $limite = $hit
        if ($vivo) { taskkill /PID $proc.Id /T /F | Out-Null; $vivo = $false; Start-Sleep -Milliseconds 500 }
    }
    if (((Get-Date) - $gitCuando).TotalSeconds -ge 4) {
        $commiteados = if ($baseHead) { @(git -C $c.Dir diff --name-only $baseHead HEAD 2>$null) } else { @() }
        $pendientes = @(git -C $c.Dir status --porcelain 2>$null | ForEach-Object { $_.Substring(3).Trim('"') })
        $git = @($commiteados + $pendientes | Where-Object { $_ } | Sort-Object -Unique)
        $gitCuando = Get-Date
    }

    # Eventos: líneas de herramienta ("→ Read …", "✱ Grep …") y turnos ("> build · modelo")
    $eventos = @($lineas | Where-Object { $_ -match "^\W{0,3}\s*($acciones)\b" })
    $cuenta = @{}; foreach ($e in $eventos) { $k = [regex]::Match($e, "($acciones)").Value; $cuenta[$k] = 1 + [int]$cuenta[$k] }
    $editados = @($git | Where-Object { $_ -notmatch '^docs/plans/' })
    $hechos = @($archivosPlan | Where-Object { $p = $_; $editados | Where-Object { $_ -like "$p*" } })
    $avance = if ($archivosPlan.Count) { $hechos.Count / $archivosPlan.Count } else { 0 }
    $reciente = ($lineas | Select-Object -Last 6) -join ' '
    $fase = if (-not $vivo) { 'Terminado' }
            elseif ($reciente -match 'tsc|lint|npm run build|vitest|pytest') { 'Probando (tsc / lint / build)' }
            elseif ($editados.Count -gt 0) { 'Programando' }
            else { 'Leyendo el plan y el código' }
    $quieto = [int]((Get-Date) - $ultimoCambio).TotalMinutes
    $t = (Get-Date) - $inicio

    [Console]::SetCursorPosition(0, 0)
    Linea ''
    Linea "  OPENCODE  ·  $($c.Titulo)" 'Cyan'
    Linea "  Modelo: $($c.Modelo)    Carpeta: $($c.Dir)" 'DarkGray'
    Linea ('  ' + ('─' * 70)) 'DarkGray'
    $s = if ($vivo) { $spin[$i % 4] } else { '✔' }
    Linea ("  [{0}] {1}    Tiempo: {2:hh\:mm\:ss}" -f $s, $fase, $t) $(if ($vivo) { 'Yellow' } else { 'Green' })
    Linea ''
    # Barra en dos colores: lo hecho en verde, lo pendiente en gris (antes todo verde parecía lleno en 0 %)
    $n = [math]::Round([math]::Max(0, [math]::Min(1, $avance)) * 40)
    Write-Host '  Avance del plan  [' -NoNewline
    Write-Host ('█' * $n) -NoNewline -ForegroundColor Green
    Write-Host ('░' * (40 - $n)) -NoNewline -ForegroundColor DarkGray
    $resto = "] {0,3:N0} %   ({1} de {2} archivos del plan)" -f ($avance * 100), $hechos.Count, $archivosPlan.Count
    Write-Host $resto.PadRight([math]::Max(0, $Host.UI.RawUI.WindowSize.Width - 61)) -ForegroundColor $(if ($avance -ge 1) { 'Green' } else { 'Gray' })
    Linea ("  Acciones: leídos {0} · ediciones {1} · búsquedas {2} · comandos {3}" -f `
        ([int]$cuenta['Read']), ([int]$cuenta['Edit'] + [int]$cuenta['Write'] + [int]$cuenta['Patch']), ([int]$cuenta['Grep'] + [int]$cuenta['Glob'] + [int]$cuenta['List']), ([int]$cuenta['Bash']))
    if ($vivo -and $quieto -ge 3) { Linea "  Aviso: sin actividad hace $quieto min (el modelo puede estar pensando o colgado; D para detener)" 'Yellow' } else { Linea '' }
    Linea ''
    Linea "  ARCHIVOS CAMBIADOS ($($editados.Count))" 'Cyan'
    $listaArch = @($editados | Select-Object -First 8)
    foreach ($f in $listaArch) { Linea ("   " + $(if ($archivosPlan | Where-Object { $f -like "$_*" }) { '● ' } else { '○ ' }) + $f) }
    if ($editados.Count -gt 8) { Linea "   … y $($editados.Count - 8) más" 'DarkGray' }
    for ($k = $listaArch.Count; $k -lt 8; $k++) { Linea '' }
    Linea ''
    Linea '  ÚLTIMAS ACCIONES' 'Cyan'
    $ult = @($lineas | Where-Object { $_ -notmatch '^>\s*build' } | Select-Object -Last 9)
    foreach ($l in $ult) {
        $l2 = $l -replace "^\W{1,3}\s*(?=($acciones)\b)", '› '
        Linea ("   " + $l2) $(if ($l2 -like '› *') { 'Gray' } else { 'White' })
    }
    for ($k = $ult.Count; $k -lt 9; $k++) { Linea '' }
    Linea ''
    if ($vivo) { Linea '  [L] ver log completo   [C] abrir en VS Code   [D] detener OpenCode' 'DarkCyan' }
    else {
        if (-not (Test-Path "$($c.Log).fin")) {
            Set-Content -Path "$($c.Log).fin" -Value $(if ($limite) { "LIMITE: $limite (modelo $($c.Modelo)). Relanzar con otro modelo o agy segun SKILL.md" } else { $proc.ExitCode })
            [Console]::Beep(880, 200); [Console]::Beep(1175, 300)
        }
        if ($limite) { Linea "  ⚠ LÍMITE DE USO ALCANZADO: $limite" 'Red'; Linea '  Claude cambia de modelo o pasa a agy; revisa lo que ya quedó hecho.' 'Yellow' }
        $err = if (Test-Path "$($c.Log).err") { (Get-Content "$($c.Log).err" -Encoding UTF8 | Where-Object { $_ -match '\S' } | Select-Object -Last 1) } else { '' }
        Linea ("  TERMINADO (código {0}). Claude revisa el resultado ahora.  {1}" -f $proc.ExitCode, $(if ($err) { "Último error: $err" })) 'Green'
        Linea '  [L] ver log completo   [C] abrir en VS Code   [Q] cerrar' 'DarkCyan'
    }

    $hasta = (Get-Date).AddMilliseconds(1000)
    while ((Get-Date) -lt $hasta) {
        if ([Console]::KeyAvailable) {
            switch ([Console]::ReadKey($true).Key) {
                'L' { Start-Process notepad.exe $c.Log }
                'C' { Start-Process code -ArgumentList "`"$($c.Dir)`"" -WindowStyle Hidden }
                'D' {
                    if ($vivo) {
                        Linea '  ¿Detener OpenCode? (S/N)' 'Yellow'
                        if ([Console]::ReadKey($true).Key -eq 'S') { taskkill /PID $proc.Id /T /F | Out-Null }
                    }
                }
                'Q' { if (-not $vivo) { exit 0 } }
            }
        }
        Start-Sleep -Milliseconds 100
    }
    $i++
}
